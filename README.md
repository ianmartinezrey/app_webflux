# TALLER DESPLIEGUE AUTOMATICO DE APLICACIONES WEB EN AWS

En el archivo aws_cli.sh se encuentra el script descrito a continuacion para desplegar 3 instancias EC2 en Amazon Web Services


## Se establece la VPC que deseamos utilizar de nuestra cuenta
`vPCId=vpc-c807f3a3`
## De igual manera se seleeciona la subnet a utilizar
`subnetId=subnet-5d879b35`
## Nombre del grupo de seguridad a crear
`groupName=my-sg-cli`
## Cantidad de instancia a desplegar
`qtyInst=3`

## Creación de grupo de seguridad
`aws ec2 create-security-group --group-name $groupName --description "My security group" --vpc-id $vPCId`
## Habilitacíon de puertos a utilizar
`aws ec2 authorize-security-group-ingress --group-name $groupName --protocol tcp --port 22 --cidr 0.0.0.0/0`
`aws ec2 authorize-security-group-ingress --group-name $groupName --protocol tcp --port 8080 --cidr 0.0.0.0/0`
## Creación de instancias EC2
`aws ec2 run-instances --image-id ami-027cab9a7bf0155df --count $qtyInst --instance-type t2.micro --key-name MyKeyPair --security-groups $groupName`
## Se consultan las instancias creadas para el grupo de seguridad y se guardan en el archivo instances.json para ser consultadas en adelante
`aws ec2 describe-instances --filters "Name=instance.group-name,Values=$groupName" --query "Reservations[].Instances[]" > instances.json`

## Por medio de un ciclo For se prepara cada instancia
`for (( c=0; c<$qtyInst; c++ ))`
`do  `
  ### Se consultan datos de la instancia creada de acuerdo al archivo JSON creado
  `idinstance=$(jq -r '.['$c'].InstanceId' instances.json)`
	`dns=$(jq -r '.['$c'].PublicDnsName' instances.json)`
  
  ### Se prepara cada instacion para ejecutar Git y clonar el repositorio de la aplicacion
	`ssh -i "MyKeyPair.pem" ec2-user@$dns "sudo yum install -y git"`
	`ssh -i "MyKeyPair.pem" ec2-user@$dns "git clone https://github.com/ianmartinezrey/app_webflux app_webflux"`
  
  ### Se ejecuta la aplicacion
	`ssh -i "MyKeyPair.pem" ec2-user@$dns "cd app_webflux && java -jar target/turnos-0.0.1-SNAPSHOT.jar"`
`done`
