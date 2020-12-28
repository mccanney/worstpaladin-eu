$accessKey = Read-Host -Prompt 'Enter the production access key'
$secretKey = Read-Host -Prompt 'Enter the production secret key' -AsSecureString

$Env:AWS_ACCESS_KEY_ID = $accessKey
$Env:AWS_SECRET_ACCESS_KEY = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secretKey)
)
$Env:PATH += ";C:\AWS"

# https://github.com/gruntwork-io/terragrunt/issues/581
$Env:TERRAGRUNT_DOWNLOAD = "C:\AWS"

Set-Alias -Name terragrunt -Value C:\AWS\terragrunt_windows_amd64.exe

Write-Host "You now have access to the PRODUCTION AWS environment.  Don't fuck things up.`n" -ForegroundColor Red
