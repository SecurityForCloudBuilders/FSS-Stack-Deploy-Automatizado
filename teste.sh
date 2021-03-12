#!/bin/bash

# If you don't already have the AWS CLI installed
# curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# unzip awscliv2.zip
# sudo ./aws/install
# You will also need to install jq (https://github.com/stedolan/jq) and curl

external_id=${{ secrets.externalid }} #"external-id-obtained"


echo $external_id