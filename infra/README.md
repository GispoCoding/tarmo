# Tarmo infra

## Setup

Run these steps the first time.

1. Install [Terraform](https://terraform.io) and `aws cli`
2. Create an AWS access key and store it locally in a credentials file (
   see [AWS Configuration basics](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html#cli-configure-quickstart-config)
   and [Where are the configuration settings stored](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
   for more info)
3. Optionally, install [sops](https://github.com/mozilla/sops) to decrypt encrypted variable files in the repository.

### Multi-factor authentication (MFA)

If you get a 403 error when deploying or destroying resources with terraform despite having configured a valid AWS
access key, you may need to set up MFA. Install both AWS CLI and jq, and make sure you have `aws` and `jq` in path. Then
download and execute the `[get-mfa-vars.sh](https://gist.github.com/mvaaltola/0abced5790401f2454444fb2ffd4acc0)` script,
and finally run `. /tmp/aws-mfa-token` to temporarily set the correct MFA environment variables in your shell.

## Configuration

1. Decrypt `tarmo.tfvars.enc.json` by running `sops -d tarmo.tfvars.enc.json > tarmo.tfvars.json`. Alternatively, copy [tfvars.sample.json](tfvars.sample.json) to a new file called `tarmo.tfvars.json`
2. Create two new IAM users for CI/CD and take down the username and credentials. These users can be used to configure CD deployment from
   Github. If CD is already configured, use existing users:
   1. User to upload frontend to S3. Fill this user in `AWS_S3_USER` part in `tarmo.tfvars.json`. Fill credentials in Github secrets `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.
   2. User to update lambda functions. Fill this user in `AWS_LAMBDA_USER` part in `tarmo.tfvars.json`. Fill credentials in Github secrets `AWS_LAMBDA_UPLOAD_ACCESS_KEY_ID` and `AWS_LAMBDA_UPLOAD_SECRET_ACCESS_KEY`.
3. Change the values in `tarmo.tfvars.json` as required
4. Create zip packages for the lambda functions by running `make build-lambda -C ..` (this
   has to be done only once since github actions can be configured to update functions).

## Deploy and teardown

To launch the instances, run the following commands:

```shell
terraform init
terraform apply --var-file tarmo.tfvars.json
```

Note: Setting up the instances takes a couple of minutes.

Take down the following outputs:

- **frontend_route53_dns_record**
- **tileserver_route53_dns_record**

Shut down and destroy the instances with `terraform destroy --var-file tarmo.tfvars.json`

## Manual interactions

You can interact with the lambda functions using the [Makefile](./Makefile).

> For example populate first few pages from Lipas with `make populate-lipas`
