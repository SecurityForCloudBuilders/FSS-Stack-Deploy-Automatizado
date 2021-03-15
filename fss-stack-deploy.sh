#!/bin/bash

# If you don't already have the AWS CLI installed
# curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# unzip awscliv2.zip
# sudo ./aws/install
# You will also need to install jq (https://github.com/stedolan/jq) and curl

# Mude essas variáveis de acordo com o que faz sentido para o seu ambiente, tanto da AWS como também do Cloud One File Storage Security:
external_id=$externalid
allinone_stack_name=$allinone_stackname
region=$region
s3_bucket_to_scan=$s3bucket_to_scan
kms_master_key_arn=$kmsmaster_key_arn
kms_master_key_arn_for_sqs=$kmsmaster_key_arn_for_sqs
api_secret_key=$c1_api_key

# --! Mude essas variáveis de acordo com o que faz sentido para o seu ambiente, tanto da AWS como também do Cloud One File Storage Security. 
# --! Caso queira executar no seu computador, comente ou exclua o bloco de variáveis acima, 
# --! E descomente o bloco de variáveis abaixo:

# external_id="external-id-obtained"
# allinone_stack_name="deploy-all-in-one-stackfss" 
# region="region-you-want-to-install-the-stack"
# s3_bucket_to_scan="the-name-of-your-bucket-to-scan" 
# kms_master_key_arn="" # "your-KMS-master-key-which-is-used-to-encrypt-objects-in-your-s3-bucket-to-scan" # Leave it blank if you haven't enabled SSE-KMS on your bucket.
# kms_master_key_arn_for_sqs="" # "your-KMS-master-key-which-is-used-to-encrypt-SQS-massages-in your-scanner-stack" # Leave it blank if you haven't enabled SSE-KMS on your bucket.
# api_secret_key="Your Cloud One API"


# Deploy the Cloud One - File Storage Security All-in-One Stack:

    # --! O retorno ao criar a Stack, irá imprimir na tela o ARN dessa Stack !--

aws cloudformation create-stack --stack-name ${allinone_stack_name} --region ${region} --template-url https://file-storage-security.s3.amazonaws.com/latest/templates/FSS-All-In-One.template --parameters ParameterKey=S3BucketToScan,ParameterValue=${s3_bucket_to_scan} ParameterKey=KMSKeyARNForBucketSSE,ParameterValue=${kms_master_key_arn} ParameterKey=KMSKeyARNForQueueSSE,ParameterValue=${kms_master_key_arn_for_sqs} ParameterKey=ExternalID,ParameterValue=${external_id} --capabilities CAPABILITY_NAMED_IAM

echo "==========---------------================-----------==========----------------=========================="

# Verify that the stack creation is complete:

        # When the stack is ready, the status will become CREATE_COMPLETE.

stack_status=$(aws cloudformation describe-stacks --stack-name ${allinone_stack_name} --output json | jq -r '.Stacks[0].StackStatus')

# Before entering the loop, sleep for 10 seconds
sleep 10

echo $stack_status

# echo "==========---------------================-----------==========----------------=========================="

# Loop until the variable $stack_status is equal to "CREATE_COMPLETE"
while [[ "$stack_status" == "CREATE_IN_PROGRESS" ]]

do

    stack_status=$(aws cloudformation describe-stacks --stack-name ${allinone_stack_name} --output json | jq -r '.Stacks[0].StackStatus')

    echo "==========---------------================-----------==========----------------=========================="

    # sleep for 17 seconds
    sleep 17

    echo $stack_status

    if [[ "$stack_status" == "CREATE_COMPLETE" ]]

      then

      echo "==========---------------================-----------==========----------------=========================="   

      echo "Stack Created!"
    
      echo "==========---------------================-----------==========----------------=========================="

      break  

    fi

    # If the FSS Deploy was unsuccessful in the creation of one or more stacks.
    if [[ "$stack_status" == "CREATE_FAILED" ]]

      then

      echo "==========---------------================-----------==========----------------=========================="

      echo "Stack Failed, check the AWS CloudFormation Console."

      echo "==========---------------================-----------==========----------------=========================="

      exit 0

    fi

    # Ongoing removal of one or more stacks after a failed stack creation or after an explicitly canceled stack creation.
    if [[ "$stack_status" == "ROLLBACK_IN_PROGRESS" ]]

      then

      echo "==========---------------================-----------==========----------------=========================="

      echo "Stack with Roolback in Progress, check the AWS CloudFormation Console."

      echo "==========---------------================-----------==========----------------=========================="

      exit 0

    fi

done

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

stackid=$(curl --location --request POST 'https://cloudone.trendmicro.com/api/filestorage/stacks' --header 'api-secret-key: '${api_secret_key}'' --header 'Api-Version: v1' --header 'Content-Type: text/plain' --data-raw '{
  "type": "scanner",
  "provider": "aws",
  "details": {
    "managementRole":  '$scannerstackmanagementrolearn'
  }
}') 

echo "==========---------------================-----------==========----------------=========================="

echo $stackid

echo "==========---------------================-----------==========----------------=========================="

stackid_result=$(echo $stackid | jq -r '.stackID')

c1_url=$(echo 'https://cloudone.trendmicro.com/api/filestorage/stacks/'$stackid_result) 

check_stack_in_fss_console=$(curl --location --request GET $c1_url --header 'api-secret-key: '${api_secret_key}'' --header 'Api-Version: v1' | jq -r '.status')

echo "==========---------------================-----------==========----------------=========================="

echo "Status ao Adicionar a Scanner Stack na Console do FSS: " $check_stack_in_fss_console

echo "==========---------------================-----------==========----------------=========================="

# Continue calling until the status in the response body becomes ok
while [[ "$check_stack_in_fss_console" != "ok" ]]

do

  # sleep for 10 seconds
  sleep 10

  check_stack_in_fss_console=$(curl --location --request GET $c1_url --header 'api-secret-key: '${api_secret_key}'' --header 'Api-Version: v1' | jq -r '.status')

  echo "==========---------------================-----------==========----------------=========================="

  echo "Status ao Adicionar a Scanner Stack na Console do FSS: " $check_stack_in_fss_console

  echo "==========---------------================-----------==========----------------=========================="

done

printf "Scanner Stack Added in the Console!\n"

echo "==========---------------================-----------==========----------------=========================="

    # Take note of stackID in the API response, which is the scanner stack’s ID.

    # Call Describe Stack using the scanner stack's stackID noted in the previous step, and continue calling until the status in the response body becomes ok.

    # You have now added the scanner stack.

# # ----------------------==============================================---------------------------------====================


# Now add the Storage Stack:

    # Call Create Stack, and include the previously-noted scanner stack stackID and storage stack StorageStackManagementRoleARN output value in the request body.
    
    # The creation of the storage stack will begin.

    # Take note of stackID in the API response, which is the storage stack’s ID.

    # Call Describe Stack using the storage stack's stackID noted in the previous step, and continue calling until the status in the response body becomes ok.

stackid_result=$(echo $stackid | jq '.stackID')

stackid=$(curl --location --request POST 'https://cloudone.trendmicro.com/api/filestorage/stacks' --header 'api-secret-key: '${api_secret_key}'' --header 'Api-Version: v1' --header 'Content-Type: text/plain' --data-raw '{
  "type": "storage",
  "scannerStack": '$stackid_result',
  "provider": "aws",
  "details": {
    "managementRole": '$storagestackmanagementrolearn'
  }
}') 

echo "==========---------------================-----------==========----------------=========================="

stackid_result=$(echo $stackid | jq -r '.stackID')

c1_url=$(echo 'https://cloudone.trendmicro.com/api/filestorage/stacks/'$stackid_result) 

check_storage_in_fss_console=$(curl --location --request GET $c1_url --header 'api-secret-key: '${api_secret_key}'' --header 'Api-Version: v1' | jq -r '.status')

echo "==========---------------================-----------==========----------------=========================="

echo "Status ao Adicionar a Storage Stack na Console do FSS: " $check_storage_in_fss_console

echo "==========---------------================-----------==========----------------=========================="

# Continue calling until the status in the response body becomes ok
while [[ "$check_storage_in_fss_console" != "ok" ]]

do

  # sleep for 10 seconds
  sleep 10

  check_storage_in_fss_console=$(curl --location --request GET $c1_url --header 'api-secret-key: '${api_secret_key}'' --header 'Api-Version: v1' | jq -r '.status')

  echo "==========---------------================-----------==========----------------=========================="

  echo "Status ao Adicionar a Storage Stack na Console do FSS: " $check_storage_in_fss_console

  echo "==========---------------================-----------==========----------------=========================="

done

printf "Storage Stack Added in the Console!\n"