package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestS3Bucket(t *testing.T) {
	t.Parallel()

	envTag := "Automated Testing"

	// Don't neccessarily want to use _every_ region - those in the EU will be fine.
	possibleRegions := []string{
		"eu-central-1",
		"eu-north-1",
		"eu-south-1",
		"eu-west-1",
		"eu-west-2",
		"eu-west-3",
	}
	domainName := fmt.Sprintf("worstpaladin-%s.eu", strings.ToLower(random.UniqueId()))
	awsRegion := aws.GetRandomStableRegion(t, possibleRegions, nil)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/s3",
		Vars: map[string]interface{}{
			"environment": envTag,
			"domain":      domainName,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
			"TF_IN_AUTOMATION":   "Y",
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApplyAndIdempotent(t, terraformOptions)

	/*
		Web bucket tests
		Check the bucket exists and that a 200 and 404 HTTP status code is returned
	*/

	/*
		Lamdba bucket tests
		Check the bucket exists and that versioning is enabled
	*/
	LambdaBucketName := terraform.Output(t, terraformOptions, "lambda_bucket_id")
	aws.AssertS3BucketExists(t, awsRegion, LambdaBucketName)
	aws.AssertS3BucketVersioningExists(t, awsRegion, LambdaBucketName)
}
