package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestUT_S3Bucket(t *testing.T) {
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
	bucketName := fmt.Sprintf("s3-bucket-test-%s", strings.ToLower(random.UniqueId()))
	envTag := "Automated Testing"
	workingDir := ".."

	defer test_structure.RunTestStage(t, "cleanup", func() {
		destroyTerraform(t, workingDir)
	})

	test_structure.RunTestStage(t, "deploy", func() {
		deployWithTerraform(t, awsRegion, bucketName, envTag, workingDir)
	})

	test_structure.RunTestStage(t, "check_bucket", func() {
		checkS3Bucket(t, awsRegion, bucketName)

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

func checkS3Bucket(t *testing.T, awsRegion string, bucketName string) {
	aws.AssertS3BucketExists(t, awsRegion, bucketName)
	aws.AssertS3BucketVersioningExists(t, awsRegion, bucketName)
}

func destroyTerraform(t *testing.T, workingDir string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
	terraform.Destroy(t, terraformOptions)
}
