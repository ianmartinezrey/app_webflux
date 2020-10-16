#!/bin/sh

vPCId=vpc-c807f3a3
subnetId=subnet-5d879b35
groupName=my-sg-cli
qtyInst=3

aws ec2 create-security-group --group-name $groupName --description "My security group" --vpc-id $vPCId
aws ec2 authorize-security-group-ingress --group-name $groupName --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name $groupName --protocol tcp --port 8080 --cidr 0.0.0.0/0
aws ec2 run-instances --image-id ami-027cab9a7bf0155df --count $qtyInst --instance-type t2.micro --key-name MyKeyPair --security-groups $groupName
aws ec2 describe-instances --filters "Name=instance.group-name,Values=$groupName" --query "Reservations[].Instances[]" > instances.json

for (( c=0; c<$qtyInst; c++ ))
do  
	idinstance=$(jq -r '.['$c'].InstanceId' instances.json)
	dns=$(jq -r '.['$c'].PublicDnsName' instances.json)
	ssh -i "MyKeyPair.pem" ec2-user@$dns "sudo yum install -y git"
	ssh -i "MyKeyPair.pem" ec2-user@$dns "git clone https://github.com/ianmartinezrey/app_webflux app_webflux"
	ssh -i "MyKeyPair.pem" ec2-user@$dns "cd app_webflux && java -jar target/turnos-0.0.1-SNAPSHOT.jar"
done



