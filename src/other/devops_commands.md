# 🧰 Essential DevOps Commands

## 🐧 Linux Basics
```bash
ls -l                         # List files
cd /path/to/dir               # Change directory
pwd                           # Show current directory
cp source.txt destination/    # Copy file
mv file.txt /new/location/    # Move file
rm file.txt                   # Delete file
rm -r foldername/             # Delete folder
cat file.txt                  # View file content
tail -f logfile.log           # View live log output
```

## 🐙 Docker & crictl 
```bash

docker --version                    # Check Docker version
docker ps                           # List running containers
docker ps -a                        # List all containers
docker build -t myimage .           # Build image
docker run -d -p 8080:80 myimage    # Run container
docker stop <container_id>          # Stop container
docker rmi <container_id>           # Remove container
docker exec -it <container_id> bash # Execute command inside container
crictl images                       # Afficher les images locales
crictl pull nginx:latest            # Pull une image depuis un registre
crictl inspect <container_id>       # Inspecter un conteneur
crictl logs <container_id>          # Voir les logs d’un conteneur
crictl info                         # Informations sur le runtime

```

## ☸️ Kubernetes


## 🌍 Terraform
```bash

terraform init      # Initialize Terraform
terraform validate  # Validate configuration
terraform fmt       # Format Terraform files
terraform plan      # Create execution plan
terraform apply     # Apply infrastructure changes
terraform destroy   # Destroy infrastructure
```

## ⚙️ Ansible
```bash

ansible-playbook playbook.yml            # Run a playbook
ansible all -m ping -i inventory.ini     # Ping hosts from inventory
ansible all -a "uptime" -i inventory.ini # Check uptime on remote hosts
```

## ☁️ AWS CLI
```bash

aws configure                           # Configure AWS credentials
aws s3 ls                               # List S3 buckets
aws s3 cp file.txt s3://bucket-name/    # Copy file to S3

# Launch EC2 instance
aws ec2 run-instances   --image-id ami-xxxx   --count 1   --instance-type t2.micro   --key-name MyKey   --security-groups MySecurityGroup
```
