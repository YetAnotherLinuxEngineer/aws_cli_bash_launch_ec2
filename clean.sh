#!/bin/bash
echo "Hello"
#https://docs.aws.amazon.com/cli/latest/userguide/cli-services-ec2.html
keyPairName=$1"_keys"
sgName=$1"_sg"

instanceId=$(aws ec2 describe-instances --filters Name=tag:Name,Values=$1  --output text --query 'Reservations[*].Instances[*].InstanceId')
aws ec2 terminate-instances --instance-ids $instanceId
while [ $state -ne 48 ]; do sleep 1; export state=$(aws ec2 describe-instances --filters Name=tag:Name,Values=$1  --output text --query 'Reservations[*].Instances[*].State' | cut -f1); done
aws ec2 delete-key-pair --key-name $keyPairName
aws ec2 delete-security-group --group-name $sgName
rm -fr $keyPairName.pem
