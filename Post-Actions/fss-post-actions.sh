#!/bin/bash

# To use Github Actions
allinone_stack_name=$allinone_stackname
function_name=$function_name
bucket_to_promote_name=$bucket_to_promote_name
bucket_to_quarantine_name=$bucket_to_quarantine_name
bucket_to_scan_arn=$bucket_to_scan_arn
bucket_to_promote_arn=$bucket_to_promote_arn
bucket_to_quarantine_arn=$bucket_to_quarantine_arn

# To use locally. Change with the name of your all-in-one-stack previously deployed
# allinone_stack_name="the-name-of-your-all-in-one-stack"
# my_promote_bucket_arn="the-arn-of-your-bucket-to-scan" # It must follow this format:  arn:aws:s3:::<YOUR_BUCKET_TO_SCAN>/*
# my_quarantine_bucket_arn="the-arn-of-your-quarantine-bucket" # It must follow this format: arn:aws:s3:::<YOUR_QUARANTINE_BUCKET>/*
# bucket_to_scan_arn="the-arn-of-your-promote-bucket" # It must follow this format:  arn:aws:s3:::<YOUR_PROMOTE_BUCKET>/*
# function_name="the-name-of-your-lambda-function"
# bucket_to_promote_name="the-name-of-your-promote-bucket"
# bucket_to_quarantine_name="the-name-of-your-quarantine-bucket"

# Creating the Promote Bucket
aws s3api create-bucket --bucket $bucket_to_promote_name --region us-east-1

# Creating the Quarantine Bucket
aws s3api create-bucket --bucket $bucket_to_quarantine_name --region us-east-1

# Calling parsing.py to change the values of the fss-trust-policy.json to our values
python3.6 parsing.py

# Sleeps for 16 seconds
# sleep 16

fss_lambda_policy_arn=$(aws iam create-policy --policy-name FSS_Lambda_Policy --policy-document file://fss-trust-policy.json | jq -r .'Policy.Arn')

# echo $fss_lambda_policy_arn

fss_lambda_role_arn=$(aws iam create-role --role-name FSS_Lambda_Role --assume-role-policy-document file://trust.json | jq -r .'Role.Arn')

# echo $fss_lambda_role_arn

aws iam attach-role-policy --role-name FSS_Lambda_Role --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

aws iam attach-role-policy --role-name FSS_Lambda_Role --policy-arn $fss_lambda_policy_arn

curl -OL https://raw.githubusercontent.com/trendmicro/cloudone-filestorage-plugins/master/post-scan-actions/aws-python-promote-or-quarantine/handler.py -o handler.py

zip ./promote-or-quarantine.zip handler.py

# For some reason that i don't know why, you have to sleep for at least 5 to 6 seconds before creating the function. 
# Otherwise will give an error: "An error occurred (InvalidParameterValueException) when calling the CreateFunction operation: The role defined for the function cannot be assumed by Lambda."
sleep 15

aws lambda create-function --function-name $function_name --role $fss_lambda_role_arn --runtime python3.8 --timeout 30 --memory-size 512 --handler handler.lambda_handler --zip-file fileb://./promote-or-quarantine.zip --environment Variables=\{PROMOTEBUCKET=$bucket_to_promote_name,QUARANTINEBUCKET=$bucket_to_quarantine_name\}

scan_result_topic_arn=$(aws cloudformation describe-stacks --stack-name $allinone_stack_name | jq -r .'Stacks[0].Outputs[4].OutputValue')

lambda_arn=$(aws lambda get-function --function-name $function_name | jq -r .'Configuration.FunctionArn')

aws lambda add-permission --function-name $function_name \
--source-arn $scan_result_topic_arn \
--statement-id $function_name --action "lambda:InvokeFunction" \
--principal sns.amazonaws.com

aws sns subscribe --topic-arn $scan_result_topic_arn --notification-endpoint $lambda_arn --protocol lambda