# import the module to make use of powershell vaults
Import-Module .\PSVault.psd1
# you dont need to remove the module since it's only defined in memory for the duration of the calling session (generally the session the user is running in)
# the module will not exists once you close the session, your saved secret will still be accessible next time you import the module. 
$SecretManager = Import-UtilitySecretManagement

# +- create a vault, pass it a name and you are good to go,
# +- you will get a failure message if the name of the vault is the same of one that already exists
# +- when creating a new vault, it becomes the default vault automatically
$SecretManager.CreateSecretsVault('GitLabCreds')

# +- actions will look at what is the current set vaultname property to perform actions
# +- you can create as many vaults as you need, just make sure to update the VaultName to the one you want to use.
# +- this way you can manage each vault and its related secrets without issue
# +- updating the vault nane vaule here will change what vault is default currently
$SecretManager.SetProperty(@{VaultName = 'GitLabCreds'})

# +- the vault name set doesn't matter here, you can see all your vault with '*'
$SecretManager.GetVault("*")

# get info on a specific vault
$SecretManager.GetVault('SQL')

# +- get info on all secrets for all your vault with '*'
# +- you will be prompted to use as password to used access vaults info, this will be the same password
# +- you'll use next time to access the vault
$SecretManager.GetSecretInfo("*")

# +- get info on a specific secret
$SecretManager.GetSecretInfo('QueryProjectCreds')

# +- pass in the name of a secret you previously created in order to use that secret
$SecretManager.GetSecret("TEST") 

# +- Incase you don't need a secret saved anymore, you can use this command to remove it for your vault
$SecretManager.RemoveSecretsVault("GitLabCreds3")

# +- use this command in order to save a secret to your vault, remember that it will be save to the default vault
$SecretManager.SetSecret('Login','<secretname>',@{
	LoginType = 'GitLab'
	UserName = '<username>'
	Password = '<password>'
	InstanceName = '<instancename>'
})






