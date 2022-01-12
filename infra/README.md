# Tarmo infra

## Setup

Run these steps the first time.

1. Install [Terraform](https://terraform.io) and `aws cli`
2. Create an AWS access key and store it locally in a credentials file (
   see [AWS Configuration basics](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html#cli-configure-quickstart-config)
   and [Where are the configuration settings stored](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
   for more info)

### Multi-factor authentication (MFA)

If you get a 403 error when deploying or destroying resources with terraform despite having configured a valid AWS
access key, you may need to set up MFA. Install both AWS CLI and jq, and make sure you have `aws` and `jq` in path. Then
download and execute the `[get-mfa-vars.sh](https://gist.github.com/mvaaltola/0abced5790401f2454444fb2ffd4acc0)` script,
and finally run `. /tmp/aws-mfa-token` to temporarily set the correct MFA environment variables in your shell.

## Configuration

1. Copy [tfvars.example](tfvars.example) to a new file called `tarmo.tfvars`
2. Create new IAM use, and take down the username and credentials. This user can be used to configure CD deployment from
   Github. If CD is already configured, use existing user.
3. Change the values in `tarmo.tfvars` as required
4. Create zip packages for the lambda functions by running `make build-lambda-docker` in the root of the project (this
   has to be done only once since github actions can be configured to update functions).
5.

## Deploy and teardown

To launch the instances, run the following commands:

```shell
terraform init
terraform apply -var-file tarmo.tfvars
```

Note: Setting up the instances takes a couple of minutes.

Take down the following outputs:

- **frontend_route53_dns_record**
- **tileserver_url**

Shut down and destroy the instances with `terraform destroy -var-file tarmo.tfvars`

## Manual interactions

You can interact with the lambda functions using the [Makefile](./Makefile).

> For example populate first few pages from Lipas with `make populate-lipas`
