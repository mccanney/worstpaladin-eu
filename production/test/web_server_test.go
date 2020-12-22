package test

import (
	"strings"
	"testing"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestWebServer(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../",
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApplyAndIdempotent(t, terraformOptions)

	http_helper.HttpGetWithCustomValidation(t, "http://worstpaladin.eu", nil, func(statusCode int, body string) bool {
		if statusCode == 200 && strings.Contains(body, "worldofwarcraft.com/en-gb/character/argent-dawn/tebin") {
			return true
		}

		return false
	})

	http_helper.HttpGetWithCustomValidation(t, "http://worstpaladin.eu/wrong.html", nil, func(statusCode int, body string) bool {
		if statusCode == 404 && strings.Contains(body, "Something went wrong.  Sorry.") {
			return true
		}

		return false
	})
}
