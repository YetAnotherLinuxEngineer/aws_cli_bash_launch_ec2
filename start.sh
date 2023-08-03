#!/bin/bash
echo "Hello"
#https://docs.aws.amazon.com/cli/latest/userguide/cli-services-ec2.html
keyPairName=$1"_keys"
sgName=$1"_sg"


aws ec2 create-key-pair --key-name $keyPairName --query 'KeyMaterial' --output text > $keyPairName.pem

aws ec2 describe-key-pairs --key-name $keyPairName

chmod 400 $keyPairName.pem

#aws ec2 delete-key-pair --key-name $keyPairName
# ============================================================#
# Creating Security Group

vpcIdName=$(aws ec2 describe-vpcs | jq -r ".Vpcs[].VpcId")
echo $vpcIdName
aws ec2 create-security-group --group-name $sgName --description "My security group" --vpc-id $vpcIdName
aws ec2 describe-security-groups --filter Name=group-name,Values=$sgName
groupId=$(aws ec2 describe-security-groups --filter Name=group-name,Values=$sgName --query 'SecurityGroups[*].[GroupId]' --output text)
#aws ec2 delete-security-group --group-id $groupId

subnetId=$(aws ec2 describe-subnets | jq -r ".Subnets[].SubnetId" | head -n 1)
#echo $subnetId
#
aws ec2 authorize-security-group-ingress --group-id $groupId --protocol tcp --port 22 --cidr "0.0.0.0/0"
aws ec2 authorize-security-group-ingress --group-id $groupId --protocol tcp --port 80 --cidr "0.0.0.0/0"
amiId=$(aws ec2 describe-images --owner amazon --filters 'Name=architecture,Values=x86_64'  Name=description,Values="*Debian 12*" --query 'Images[*].[ImageId,CreationDate,Description,ImageOwnerAlias]' --output text | sort -k 2 -r | head -n 1 | cut -f1)
echo $amiId
aws ec2 run-instances --image-id $amiId  --count 1 --instance-type t2.micro --key-name $keyPairName --security-group-ids $groupId --subnet-id $subnetId --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$1}]"
#while [ $state -ne 16 ]; do sleep 1; export state=$(aws ec2 describe-instances --filters Name=tag:Name,Values=$1  --output text --query 'Reservations[*].Instances[*].State' | cut -f1); done
aws ec2 wait instance-status-ok --instance-ids $instanceId
ipAddr=$(aws ec2 describe-instances --filters Name=tag:Name,Values=$1  --output text --query 'Reservations[*].Instances[*].NetworkInterfaces[*].Association' | cut -f3)
instanceId=$(aws ec2 describe-instances --filters Name=tag:Name,Values=$1  --output text --query 'Reservations[*].Instances[*].InstanceId')

echo "Logging in to $ipAddr"
ssh -o StrictHostKeyChecking=no  -i ./*.pem admin@$ipAddr
