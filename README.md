# [PSVault]🔒:


 The `PSVault` class is a PowerShell utility class designed for managing ***SQL-related*** secrets and interacting with a secrets vault.
 It provides various methods to facilitate secrets management and vault operations. Follow the instruction below to get familiar with how to use this.
<p>
</br>
</p>

> **Note:** When the script is dot sourced, any functions, variables, or aliases defined within the script will be available in the current scope.
> This can be useful when you want to reuse code or load a script that defines functions or variables needed in the current context.

### Dot Source Instructions:

To 'dot source' the ```PSVault.ps1``` script located in the ```LocalRepo``` directory, you can follow these step-by-step instructions.

1. Open a PowerShell session or launch the PowerShell Integrated Scripting Environment (ISE). Run the following command(s).

```
# change directory 📁
set-location 'c:\'

# create a folder in this directory 🏗️
mkdir 'LocalRepo'
```
> Note: The first command changes the working directory to ```c:\``` the second command creates a folder called 'LocalRepo'.
> With the directory set up, Make sure that the ```PSVault.ps1``` file is located in ```C:\LocalRepo```
<p></br></p>

2. With that bit of validation done. Back in your PowerShell session run the following command. Again Make sure youre in the correct working directory. Should be ```PS C:\LocalRepo\```
```
. .\PSVault.psd1
```
 3. With the class 'dot sourced' you can now assign an instance of the PSVault class to a variable. You'll want to do this so you have the ability to access the methods of the class.
```
# here we assign an instance to a variable
$LocalVault = [PSVault]::new()
```
4. After dot sourcing the script, you can access and use any functions, variables, or aliases defined within `SQLUtility.psd1` in your PowerShell session or script.
```
# This is one way to define a new object.
$LocalVault = [SQLUtility]::new()
```
5. Before you create a vault, you need to create a reference to the vault with the ```SetProperty```  method. In this example, We are setting up the vault with ```SQLCreds``` as the name. 
```
$LocalVault.SetProperty(@{VaultName = 'SQLCreds'})
```
6. Now you can create a secret vault
```
$LocalVault.CreateSecretsVault('SQLCreds')
```
7. To vaildate that your vault was successfully created run the following command
```
$LocalVault.GetVault('SQLCreds')
```
> Note: Your output should be something like this

|Name|ModuleName|IsDefaultVault|
|----|----------|--------------|
|SQLCreds|Microsoft.PowerShell.SecretStore|True

8. Now you can go ahead and create your first secret to store in your vault
```
# replace vault_name with the name of your vault
# replace secrete_name with a name you want to use for the secret
# replace user_name with the user name used to login to a sql instance
# replace the user_password with the password used to login to a sql instance
# replace instance_name with the name of the instance you`ll be wanting to relate your creds too
$LocalVault.SetSecret('<vault_name>','Login','<secret_name>',@{
	  LoginType = 'SQLLogin'
	  username = '<user_name>'
	  password = '<user_password>'
	  instancename = 'instance_name'
})
```
> Note: you will be promted at this this point to provide a password to secure your vault. this password will allow you to access your vault in the future. 

9. In order to get back a secret stored in your vault, execute the following command
```
# make sure to replace secret_name with the name of the secret you want to get back from your vault
# passwords are saved as secure string
$LocalVault.GetSecret('secrete_name').InstanceName
$LocalVault.GetSecret('secrete_name').UserName
$LocalVault.GetSecret('secrete_name').Password
```
### Property Declaration
The class defines a set of properties within the `$Properties` hashtable. This includes properties for the vault (`VaultProperties`) and secrets (`SecretProperties`). Each property has default values.

### Property Access

The `GetProperty` method allows retrieving the value of a specific property or subproperty from the `$Properties` hashtable. It iterates over the properties and subproperties, searching for a match based on the provided search property.

### Utility Methods
 A breakdown of the methods and other utilities included in this class:

- `TestUtility`: A method that takes a parameter (`$TestThis`) and returns a hashtable (`$testTable`) containing information about the parameter.

- `SetProperty`: A method to update the value of a property. It sets the `hideparentprop` variable to `$false` to display the parent property in the result, updates the specified property value, and then sets `hideparentprop` back to `$true`.

- `CreateSecretsVault`: Creates a secrets vault with the specified name (`$newVaultName`). It uses the `Register-SecretVault` cmdlet to register the vault and sets the `VaultName` property.

- `GetSecret`: Retrieves the specified secret (`$SecretName`) from the secrets vault and returns a hashtable containing information about the secret.

- `RemoveSecretsVault`: Removes the secrets vault. It checks if the vault exists using the `Get-SecretVault` cmdlet and unregisters it with the `Unregister-SecretVault` cmdlet.

- `GetVault`: Retrieves information about the specified vault (`$VaultName`) using the `Get-SecretVault` cmdlet.

- `SetSecret`: Sets a secret in the vault. The method takes parameters like `VaultName`, `SetSecretType`, `SecretName`, and `SetSecretParams`. It checks the secret type and encrypts the password. Then it uses the `Set-Secret` cmdlet to store the secret in the vault.

- `ConvertPasswordToSecureString`: Converts a password supplied as plaintext to a secure string using the `ConvertTo-SecureString` cmdlet and returns a `PSCredential` object.

The class provides methods to interact with secrets, manage the secrets vault, and perform various operations related to secrets management. It utilizes PowerShell cmdlets to interact with the underlying SecretStore module for secrets management.
