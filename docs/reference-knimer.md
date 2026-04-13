# Reference: knimer — KNIME Automation & Scheduling

> Archived from [nick-solly/knimer](https://github.com/nick-solly/knimer) (MIT License, 2022-08-22)

## Overview

knimer provides Docker + Terraform infrastructure for running KNIME workflows on AWS ECS Fargate
as an alternative to KNIME Server. Features:

- Downloads zipped workflows from S3
- Runs in KNIME batch execution mode
- Handles workflow variables and credentials
- Optional EventBridge scheduling
- Optional Slack notifications via Lambda

## Docker Startup Script

```shell
#!/usr/bin/env bash
set -e

S3_LOCATION="s3://${S3_BUCKET_NAME}/${KNIME_WORKFLOW_FILE}.zip"
aws s3 cp ${S3_LOCATION} /tmp/workflow.zip

wfvars=( $WORKFLOW_VARIABLES )
wfsecrets=( $WORKFLOW_SECRETS )

/opt/knime_4.6.4/knime -reset -nosave -consoleLog -nosplash \
  -application org.knime.product.KNIME_BATCH_APPLICATION \
  -workflowFile=/tmp/workflow.zip \
  "${wfvars[@]}" "${wfsecrets[@]}"
```

## Docker Run (Manual)

```shell
docker run \
  -e S3_BUCKET_NAME=my_workflow_bucket \
  -e KNIME_WORKFLOW_FILE=workflow_file \
  -e WORKFLOW_VARIABLES="-workflow.variable=var_a,foo,String -workflow.variable=var_b,6,int" \
  -e WORKFLOW_SECRETS="-credential=db_creds;user;pass" \
  -e AWS_ACCESS_KEY_ID=... \
  -e AWS_SECRET_ACCESS_KEY=... \
  ghcr.io/nick-solly/knimer/knimer:latest
```

## Terraform Module (AWS ECS Fargate)

```hcl
module "knimer" {
  source              = "github.com/nick-solly/knimer.git//terraform/knimer"
  aws_region          = "eu-west-2"
  name_prefix         = "my-workflow"
  cpu                 = 2048
  memory              = 16384
  knime_workflow_file = "my_workflow"
  s3_bucket_name      = "all_the_workflows"

  workflow_variables  = {
    variable1 = "ThisIsAValue,String"
    variable2 = "1234,int"
  }

  workflow_secrets = {
    database_creds = "username;password"
  }

  subnet_ids           = ["subnet-0af169a6f98a3hg34", "subnet-042b69da4001512ca"]
  schedule_expressions = ["cron(0 4 * * ? *)"]
}
```

## Key Patterns

- Workflow stored as ZIP in S3, downloaded at container start
- Variables passed via environment variables, split into array for CLI args
- Credentials use `-credential=name;login;password` syntax
- Uses `org.knime.product.KNIME_BATCH_APPLICATION` Eclipse application ID
- Extension installation via p2 director in Dockerfile

## Relevance

Demonstrates production-grade batch execution patterns that survive the removal of
built-in batch support. The Docker-based approach is self-contained and doesn't depend
on KNIME's extension marketplace for the batch executor plugin.
