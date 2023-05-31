# SQLUtility Class

<p>
 The `SQLUtility` class is a PowerShell utility class designed for managing SQL-related secrets and interacting with a secrets vault.<br>
 It provides various methods to facilitate secrets management and vault operations.
</p>

> **Note:** When the script is dot sourced, any functions, variables, or aliases defined within the script will be available in the current scope.<br>This can be useful when you want to reuse code or load a script that defines functions or variables needed in the current context.

```
. .\PSSQLQueryStoreTool\SQLUtility.ps1
```


### Property Declaration

The class defines a set of properties within the `$Properties` hashtable. This includes properties for the vault (`VaultProperties`) and secrets (`SecretProperties`). Each property has default values.

### Property Access

The `GetProperty` method allows retrieving the value of a specific property or subproperty from the `$Properties` hashtable. It iterates over the properties and subproperties, searching for a match based on the provided search property.

### Utility Methods

- `TestUtility`: A method that takes a parameter (`$TestThis`) and returns a hashtable (`$testTable`) containing information about the parameter.

- `SetProperty`: A method to update the value of a property. It sets the `hideparentprop` variable to `$false` to display the parent property in the result, updates the specified property value, and then sets `hideparentprop` back to `$true`.

- `CreateSecretsVault`: Creates a secrets vault with the specified name (`$newVaultName`). It uses the `Register-SecretVault` cmdlet to register the vault and sets the `VaultName` property.

- `GetSecret`: Retrieves the specified secret (`$SecretName`) from the secrets vault and returns a hashtable containing information about the secret.

- `RemoveSecretsVault`: Removes the secrets vault. It checks if the vault exists using the `Get-SecretVault` cmdlet and unregisters it with the `Unregister-SecretVault` cmdlet.

- `GetVault`: Retrieves information about the specified vault (`$VaultName`) using the `Get-SecretVault` cmdlet.

- `SetSecret`: Sets a secret in the vault. The method takes parameters like `VaultName`, `SetSecretType`, `SecretName`, and `SetSecretParams`. It checks the secret type and encrypts the password. Then it uses the `Set-Secret` cmdlet to store the secret in the vault.

- `ConvertPasswordToSecureString`: Converts a password supplied as plaintext to a secure string using the `ConvertTo-SecureString` cmdlet and returns a `PSCredential` object.

The class provides methods to interact with secrets, manage the secrets vault, and perform various operations related to secrets management. It utilizes PowerShell cmdlets to interact with the underlying SecretStore module for secrets management.
