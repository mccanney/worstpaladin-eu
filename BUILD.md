# Building the site

## Pre-requisites

The site relies on the AWS infrastructure for Titanium Vanguard being brought up first (specifically the nameservers).

## Start up

`terraform init` and then `terraform apply` to spin up the initial AWS infrastructure.  The following commands are required after this succeeds to set the nameservers to the correct values:

```PowerShell
aws route53 change-resource-record-sets --hosted-zone-id /hostedzone/XYZ123 --change-batch file://static\nameservers.json
```

Followed by:

```PowerShell
aws route53domains --region us-east-1 update-domain-nameservers `
--cli-input-json file://static\registrar.json
```
