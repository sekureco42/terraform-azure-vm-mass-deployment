# terraform-azure-vm-mass-deployment
This repo shows how to deploy an existing image in Microsoft Azure multiple times (eg. for lab usage)

## Introduction
For a incident response excercise I wanted to provide Windows based VMs where the "Flare-VM", https://github.com/fireeye/flare-vm, is installed. My first approach was to deploy a windows VM directly from the image gallery of azure and install afterwards flare VM with the install script. Unfortunatly the installation of the tools takes several hours - not really useful due I wanted to deploy VMs adhoc (depending on the count of participants of the LAB).

My second approach was to create on master image (called custom image) and then deploy all LAB VMs based on this custom image. Way faster (except initial image creation). I followed this Microsoft article to create the image: https://docs.microsoft.com/en-us/azure/virtual-machines/windows/capture-image-resource

The image in this example has the name `win10-flare` and is referenced in file `variables.tf`.

## Steps to use it
1. Make sure that terraform is installed
2. Make sure that you have a base image to deploy in Azure cloud (must be in the same location as your destination VMs/Ressource group, see `variables.tf`, image is called `win10-flare`)
3. Just clone this repo
4. Open a shell (`cmd.exe`)
5. Login to Azure (approve console for login) by calling `az login` (of course Azure CLI must be installed)
6. call `terraform plan`, then `terraform apply`
7. Confirm Terraform actions by entering `yes`
After some minutes you should have VMs deployed with specified base image.