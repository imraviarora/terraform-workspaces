# get terraform version
terraform version
# Terraform v0.14.4

# get terraform commands
terraform

# init terraform's Azure provider (main.tf)
terraform init

# list existing workspaces
terraform workspace list

# create dev workspace
terraform workspace new dev
terraform workspace list

terraform plan -out dev.tfplan

terraform apply --auto-approve dev.tfplan

# create test workspace
terraform workspace new test
terraform workspace list

terraform plan -out test.tfplan

terraform apply --auto-approve test.tfplan

# create prod workspace
terraform workspace new prod
terraform workspace list

terraform plan -out prod.tfplan

terraform apply --auto-approve prod.tfplan



#Terraform Graph

terraform graph > base.dot
code base.dot
terraform graph | dot -Tsvg > graph.svg
