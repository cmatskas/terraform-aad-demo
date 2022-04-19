## Basic instructions for setting up Terrarform with Azure AD and Key Vault

> This is for new resources that need to be deployed to Azure. For existing resources, see the [existing resources](https://docs.microsoft.com/en-us/azure/terraform/terraform-provider-azurerm#existing-resources) guide.


### Necessary steps

1. Create an Azure AD service principal with the right permissions to use for the deployment scripts
```
az ad sp create-for-rbac --name TerraformDeploymentSP --scopes /subscriptions/<your subscription id> --role Contributor
```
The output should look like this

```
{
    "appId": "dafc5200-9618-4c6c-a48b-98735c31304a",
    "displayName": "TerraformDeploymentSP",
    "password": "<client secret>",
    "tenant": "<azure ad tenant id>"
}
```
2. In the Azure Portal, in the appropriate Key Vault, add the SP so that it can **List** and **Get** secrets
3. In the Azure Portal, in the storage account, add the SP as a **Storage Blob Data Contributor**

4. Sign in to the Azure CLI with the right SP
`az login --service-principal -u <appId> -p <client secret> --tenant <tenant id>`

5. Set up the environment variables for Terraform to run under the Service Principal context. 
Open PowerShell and type the following

```
Set-Item -Path env:ARM_CLIENT_ID -Value "<client id>"
Set-Item -Path env:ARM_CLIENT_SECRET - Value "<client secret>"
Set-Item -Path env:ARM_TENANT_ID -Value "<tenand it>"
Set-Item -Path env:ARM_SUBSCRIPTION_ID -Value "<subscription id>
```

6. Run `terraform init` to configure the backend
7. Run `terraform plan`
8. Run `terraform apply -auto-approve`


### Import an existing resource 

I wanted to use TF to deploy resources to an existing Resource Group. Although the deployment run, it complained that the RG was not managed by Terraform and that it had to be added to the state. To do this, run the following command

`terraform import azurerm_resource_group.<resource group name> <azure resource id>`