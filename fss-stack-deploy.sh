#!/bin/bash

# If you don't already have the AWS CLI installed
# curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# unzip awscliv2.zip
# sudo ./aws/install
# You will also need to install jq (https://github.com/stedolan/jq) and curl


# Mude essas variáveis de acordo com o que faz sentido para o seu ambiente, tanto da AWS como também do Cloud One File Storage Security
external_id="external-id-obtained"
allinone_stack_name="deploy-all-in-one-stackfss" 
region="region-you-want-to-install-the-stack"
s3_bucket_to_scan="the-name-of-your-bucket-to-scan" 
kms_master_key_arn="" # "your-KMS-master-key-which-is-used-to-encrypt-objects-in-your-s3-bucket-to-scan" # Leave it blank if you haven't enabled SSE-KMS on your bucket.
kms_master_key_arn_for_sqs="" # "your-KMS-master-key-which-is-used-to-encrypt-SQS-massages-in your-scanner-stack" # Leave it blank if you haven't enabled SSE-KMS on your bucket.
api_secret_key="Your Cloud One API"


# Deploy the Cloud One - File Storage Security All-in-One Stack:

    # Para criar os recursos na AWS via esse Template, demorou 5 minutos e 32 segundos.

aws cloudformation create-stack --stack-name ${allinone_stack_name} --region ${region} --template-url https://file-storage-security.s3.amazonaws.com/latest/templates/FSS-All-In-One.template --parameters ParameterKey=S3BucketToScan,ParameterValue=${s3_bucket_to_scan} ParameterKey=KMSKeyARNForBucketSSE,ParameterValue=${kms_master_key_arn} ParameterKey=KMSKeyARNForQueueSSE,ParameterValue=${kms_master_key_arn_for_sqs} ParameterKey=ExternalID,ParameterValue=${external_id} --capabilities CAPABILITY_NAMED_IAM

# Verify that the stack creation is complete:

        # When the stack is ready, the status will become CREATE_COMPLETE.

aws cloudformation describe-stacks --stack-name ${allinone_stack_name} --output json --query 'Stacks[0].StackStatus'

# Obtain the ARNs of the scanner and storage stacks:

        # In the command Output, take note of the ScannerStackManagementRoleARN && StorageStackManagementRoleARN output values!

storagestackmanagementrolearn=$(aws cloudformation describe-stacks --stack-name ${allinone_stack_name} --output json --query 'Stacks[0].Outputs[2].OutputValue')

scannerstackmanagementrolearn=$(aws cloudformation describe-stacks --stack-name ${allinone_stack_name} --output json --query 'Stacks[0].Outputs[5].OutputValue')

# echo $scannerstackmanagementrolearn

# echo $storagestackmanagementrolearn

# ----------------------==============================================---------------------------------====================



# Add the scanner and storage stacks to File Storage Security:

# First, add the Scanner Stack:

    # Call Create Stack and include the ScannerStackManagementRoleARN output value in the request body.

    # The creation of the scanner stack will begin.

    # Take note of stackID in the API response, which is the scanner stack’s ID.

    # Call Describe Stack using the scanner stack's stackID noted in the previous step, and continue calling until the status in the response body becomes ok.

    # You have now added the scanner stack.

stackid=$(curl --location --request POST 'https://cloudone.trendmicro.com/api/filestorage/stacks' --header 'api-secret-key: '${api_secret_key}'' --header 'Api-Version: v1' --header 'Content-Type: text/plain' --data-raw '{
  "type": "scanner",
  "provider": "aws",
  "details": {
    "managementRole":  '$scannerstackmanagementrolearn'
  }
}') 

echo $stackid

stackid_result=$(echo $stackid | jq -r '.stackID')

c1_url=$(echo 'https://cloudone.trendmicro.com/api/filestorage/stacks/'$stackid_result) 

# Continue calling until the status in the response body becomes ok

curl --location --request GET $c1_url --header 'api-secret-key: '${api_secret_key}'' --header 'Api-Version: v1'


# ----------------------==============================================---------------------------------====================



# Now add the Storage Stack:

    # Call Create Stack, and include the previously-noted scanner stack stackID and storage stack StorageStackManagementRoleARN output value in the request body.
    
    # The creation of the storage stack will begin.

    # Take note of stackID in the API response, which is the storage stack’s ID.

    # Call Describe Stack using the storage stack's stackID noted in the previous step, and continue calling until the status in the response body becomes ok.

stackid=$(curl --location --request POST 'https://cloudone.trendmicro.com/api/filestorage/stacks' --header 'api-secret-key: '${api_secret_key}'' --header 'Api-Version: v1' --header 'Content-Type: text/plain' --data-raw '{
  "type": "storage",
  "scannerStack": "your-scanner-stack-id-here",
  "provider": "aws",
  "details": {
    "managementRole": '$storagestackmanagementrolearn'
  }
}') 

echo $stackid

stackid_result=$(echo $stackid | jq -r '.stackID')

c1_url=$(echo 'https://cloudone.trendmicro.com/api/filestorage/stacks/'$stackid_result) 

# Continue calling until the status in the response body becomes ok

curl --location --request GET $c1_url --header 'api-secret-key: '${api_secret_key}'' --header 'Api-Version: v1'