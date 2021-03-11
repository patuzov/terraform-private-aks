# Private AKS Terraform
Manage a "Fully" private AKS infrastructure with Terraform.

Explanation in details in this [medium article](https://medium.com/@paveltuzov/create-a-fully-private-aks-infrastructure-with-terraform-e92358f0bf65?source=friends_link&sk=124faab1bb557c25c0ed536ae09af0a3).

# Running the script
After you configure authentication with Azure, just init and apply (no inputs are required):

`terraform init`

`terraform apply`

# Connecting to the jumpbox VM
During deployment, your IP where you deployed from is whitelisted in the `SSH` rule so that you (and only you) can SSH into the jumpbox VM.  In the future, if you're not able to ssh into the jumpbox VM, then check the `SSH` rule in your network security group to make sure your current IP address is whitelisted.
