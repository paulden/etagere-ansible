# Dojo Ansible

This repository showcases basic Ansible functionality (using `ansible-playbook`) to configure an instance.
Terraform code is available to deploy and practice on actual instances.

## Setup

### AWS

- Get an access to AWS (using AWS CLI or environment variables to export your credentials).
- In `setup/aws/terraform.tfvars`, fill the map with the number of instances you want to deploy.
- In `setup/aws/`, run `terraform init` and then `terraform apply`.
- In output, you should get the public DNS of each instance.

### Azure

- Get an access to Azure with CLI :
    - Log in to your account : 
        > `az login`
    - Get subscription info :
        > `az account list`
- In the list display by the previous command, you need to keep the tenantId, copy it in topology.tf
- In `ansible/inventories/hosts` add the ip adress of the machine you just set before.

## Exercise

### Goal

All tasks (except 0) should be completed using `ansible-playbook`!
- 0 - Check your SSH access to your instance.
- 1 - Set up your Ansible inventory and install `cowsay` using `apt`.
- 2 - Install `nginx` using `apt` and try to modify the existing HTML file to display something more personal.
- 3 - Extract the `nginx` installation in an Ansible role.
- 4 - Extract potential variables in `group_vars`.

### Solutions

Check the `steps` branch for solutions.