![psvault_banner](https://github.com/dbaknack/PSVault/assets/39814152/3d82658a-5152-49fa-9be5-cfea186c8b5d)
# PowerShell SecretStore Module Usage Guide
## Description
The ```PSVault``` PowerShell module is a dynamic module that provides utility functions for managing secrets and secret vaults in PowerShell. It simplifies the process of working with secrets by leveraging the ```Microsoft.PowerShell.SecretManagement``` and ```Microsoft.PowerShell.SecretStore modules```
This guide provides detailed instructions on how to use the PowerShell ```PSVault``` module to securely store and access your secrets. The ```PSVault``` module allows you to manage multiple vaults and their associated secrets conveniently.

## Features
- ***Secret Management:*** Easily create, retrieve, update, and delete secrets stored in the default secret vault.
- ***Vault Management:*** Create, list, and remove secret vaults.
- ***Property Management:*** Get and set properties associated with the utility module, including default vault name and secret expiration settings.
- ***Login Secrets:*** Supports setting and retrieving secrets of type "Login" with various subtypes such as SQL Login, Windows Authentication, and GitLab credentials
## Usage
The module provides several functions that can be used for different purposes:

- ***Get-SecretInfo:*** Retrieve information about a specific secret stored in the default vault.
- ***Get-SecretVault:*** Get details about a specific secret vault.
- ***Remove-Secret:*** Remove a specific secret from the default vault.
- ***Get-Secret:*** Retrieve a specific secret from the default vault.
- ***Set-Secret:*** Set a new secret in the default vault.
- ***Register-SecretVault:*** Create a new secret vault.
- ***Unregister-SecretVault:*** Remove a secret vault.
- 


## Importing the Module

To start using PowerShell SecretStore, import the module using the following command:

```powershell
Import-Module .\PSVault.psd1
```
> **Note:** In the example above. its assumed that your current working directory is the same in which you are currently in within your PowerShell terminal. </br> In order for you to import the module successfully, you will either need to change your working directory to the same one you saved this project to, or you can replace the ```.``` with the parent direcory path containing the module. For example
> </br> ```Import-Module c:\path\to\module\PSVault.psd1```

You'll need to initialize an instance of the ```UtilitySecretManagement``` class in your session in order to make use of the methods defined in the class that will allow you to manage your vault and secrets. To do this use the following command

```powershell
$SecretManager = Import-UtilitySecretManagement
```
> **Note:** ```$SecretManager``` is a PowerShell variable. You don't need to use the same characters to define your variable as the example provided, just make sure to declare it properly with the ```$``` symbole. For example
> ```$MyVault = 'something'```
This command loads the module and makes its functionality available for use.

# Managing Vaults
You can create multiple vaults to manage different sets of secrets. To set the current active vault, use the ```SetProperty``` method of the ```Import-UtilitySecretManagement``` module. Specify the VaultName property to update the current vault. For example:

```
$SecretManager.SetProperty(@{VaultName = 'GitLabCreds'})
```

## Creating a Vault

To create a new vault, use the ```CreateSecretsVault``` method of the `Import-UtilitySecretManagement` module. Provide a unique name for the vault as the parameter. If a vault with the same name already exists, you will receive a failure message. When you create a new vault, it becomes the default vault automatically.

```powershell
$SecretManager.CreateSecretsVault('GitLabCreds3')
```

To retrieve information about all available vaults, use the ```GetVault``` method. You can use the ```'*'``` wildcard to retrieve information for all vaults, or specify the name of a specific vault. For example:
```
$SecretManager.GetVault("*")
$SecretManager.GetVault('SQLCreds')
```

# Managing Secrets
To retrieve information about all secrets in the current vault, use the ```GetSecretInfo``` method. You will be prompted to enter the password used to access the vault's information. This password will be the same password you use to access the vault in subsequent operations. For example:

```
$SecretManager.GetSecretInfo("*")
```
To retrieve information about a specific secret, use the ```GetSecretInfo``` method and provide the name of the secret. For example:
```
$SecretManager.GetSecretInfo('QueryProjectCreds')
```
To retrieve the value of a specific secret, use the ```GetSecret```  method and provide the name of the secret. For example:
```
$SecretManager.GetSecret("TEST")
```
If you no longer need a secret saved in your vault, you can remove it using the ```RemoveSecretsVault``` method. Provide the name of the secret vault as the parameter. For example:
```
$SecretManager.RemoveSecretsVault("GitLabCreds3")
```
To save a new secret to your vault, use the ```SetSecret``` method. Specify the secret name, followed by a hashtable containing the secret properties. For example:
```
$SecretManager.SetSecret('Login','<secretname>',@{
    LoginType = 'GitLab'
    UserName = '<username>'
    Password = '<password>'
    InstanceName = '<instancename>'
})
```
# Addition Information
This module makes use of the included SecretStore module. It utilizes the Windows Data Protection API (DPAPI) to encrypt and store secrets on the local machine. Here's how secrets are stored with SecretStore on Windows:

- Master Key Generation: When SecretStore is first used, a master key is generated for the user. This key is unique to the user and is securely stored in the user's profile.

 - Secret Encryption: When a secret is stored using the Set-Secret cmdlet, the secret value is encrypted using the user's master key generated in the previous step. The encryption process is handled by the DPAPI, which ensures that only the user who encrypted the secret can decrypt it.

- Secret Storage: Encrypted secrets are stored in a directory specific to the user, which is located at %APPDATA%\Microsoft\SecretStore. Each secret is saved as a separate file within this directory. The file name is a hash derived from the secret name, ensuring that the actual secret value is not exposed in the file name.

- Key Protection: The user's master key, which is used to encrypt and decrypt secrets, is itself protected by DPAPI. DPAPI uses the user's Windows credentials to encrypt and decrypt the master key, ensuring that it is securely stored and only accessible by the user.

- Access Control: Access to the secret store is limited to the user who encrypted the secrets. Other users on the same machine or administrators cannot access or decrypt the secrets stored in SecretStore.

- Retrieval and Decryption: When a secret is retrieved using the Get-Secret cmdlet, the SecretStore module locates the corresponding encrypted secret file and decrypts it using the user's master key. The decrypted secret is then returned to the user.

- It's important to note that the security of secrets stored in SecretStore relies on the security of the user's Windows credentials and the protection provided by DPAPI. Therefore, it is crucial to follow best practices for securing Windows user accounts, such as using strong passwords and enabling multi-factor authentication.

Additionally, it's worth mentioning that SecretStore is a local secret store and is not designed for centralized management or sharing secrets across multiple machines or users. If you require a more centralized and scalable solution, you may consider using other secret management systems like Azure Key Vault, HashiCorp Vault, or other external secret stores integrated with PowerShell.