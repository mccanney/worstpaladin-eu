package test

import (
	"fmt"
	"io"
	"strings"
	"testing"

	"github.com/aws/aws-sdk-go/service/s3/s3manager"
	"github.com/gruntwork-io/terratest/modules/aws"
	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestUT_S3WebBucket(t *testing.T) {
	t.Parallel()

	// Don't neccessarily want to use _every_ region - those in the EU will be fine.
	possibleRegions := []string{
		"eu-central-1",
		"eu-north-1",
		"eu-south-1",
		"eu-west-1",
		"eu-west-2",
		"eu-west-3",
	}
	awsRegion := aws.GetRandomStableRegion(t, possibleRegions, nil)
	bucketName := fmt.Sprintf("s3-web-bucket-test-%s", strings.ToLower(random.UniqueId()))
	envTag := "Automated Testing"
	workingDir := ".."

	defer test_structure.RunTestStage(t, "cleanup", func() {
		destroyTerraform(t, workingDir)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		deployWithTerraform(t, awsRegion, bucketName, envTag, workingDir)
	})

	test_structure.RunTestStage(t, "basic_check", func() {
		checkS3Bucket(t, awsRegion, bucketName)

	})

	test_structure.RunTestStage(t, "create_test_files", func() {
		indexFile := strings.NewReader("<!DOCTYPE html><html><head><title>Test site</title></head><body>This is a test site.</body></html>")
		errorFile := strings.NewReader("<!DOCTYPE html><html><head><title>Test site</title></head><body>Something went wrong.  Sorry.</body></html>")

		var files = map[string]io.Reader{
			"index.html": indexFile,
			"error.html": errorFile,
		}
		for name, contents := range files {
			uploadS3File(t, awsRegion, bucketName, contents, name)
		}
	})

	test_structure.RunTestStage(t, "web_site_check", func() {
		checkWebBucket(t, awsRegion, bucketName, workingDir)
	})
}

func deployWithTerraform(t *testing.T, awsRegion string, bucketName string, envTag string, workingDir string) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: workingDir,
		Vars: map[string]interface{}{
			"environment": envTag,
			"bucket_name": bucketName,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
			"TF_IN_AUTOMATION":   "Y",
		},
	})

	test_structure.SaveTerraformOptions(t, workingDir, terraformOptions)
	terraform.InitAndApplyAndIdempotent(t, terraformOptions)
}

func uploadS3File(t *testing.T, awsRegion string, bucketName string, fileContents io.Reader, fileKey string) {
	upParams := &s3manager.UploadInput{
		Bucket: &bucketName,
		Key:    &fileKey,
		Body:   fileContents,
	}

	file := aws.NewS3Uploader(t, awsRegion)
	_, err := file.Upload(upParams)
	if err != nil {
		logger.Log(t, err)
	}
}

func checkS3Bucket(t *testing.T, awsRegion string, bucketName string) {
	aws.AssertS3BucketExists(t, awsRegion, bucketName)
}

func checkWebBucket(t *testing.T, awsRegion string, bucketName string, workingDir string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)

	s3DomainName := terraform.Output(t, terraformOptions, "website_domain")
	indexPage := fmt.Sprintf("http://%s.%s", bucketName, s3DomainName)
	errorPage := fmt.Sprintf("%s/wrong.html", indexPage)

	/*
		Does the bucket serve the index page correctly with the correct HTTP status code?
	*/
	http_helper.HttpGetWithCustomValidation(t, indexPage, nil, func(statusCode int, htmlBody string) bool {
		if statusCode == 200 && strings.Contains(htmlBody, "This is a test site.") {
			return true
		}

		return false
	})

	/*
		Does the bucket serve the 404 page correctly with the correct HTTP status code?
	*/
	http_helper.HttpGetWithCustomValidation(t, errorPage, nil, func(statusCode int, htmlBody string) bool {
		if statusCode == 404 && strings.Contains(htmlBody, "Something went wrong.  Sorry.") {
			return true
		}

		return false
	})

	/*
		We need to empty the bucket after testing or the destroy will fail
	*/
	aws.EmptyS3Bucket(t, awsRegion, bucketName)
}

func destroyTerraform(t *testing.T, workingDir string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
	terraform.Destroy(t, terraformOptions)
}
