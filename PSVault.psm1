Function Import-ExternalModules {
	Import-Module ".\ExternalModules\Microsoft.PowerShell.SecretManagement" -DisableNameChecking
	Import-Module ".\ExternalModules\Microsoft.PowerShell.SecretStore"	-DisableNameChecking
}

class UtilitySecretManagement{
	$Properties = @{
		VaultProperties = @{
			VaultName = [string]''
			VaultDescription = [string]''
		}
		SecretProperties = @{
			ExpireInDays = [int]1
			SecretTypes = @{
				Login 	= @('SQLLogin','WindowsAuthentication','GitLab')
			}
		}
	}
	$utilityVars = @{
		hideparentprop = $true
		ExternalModules = @{
			SecreteManagement = ".\ExternalModules\Microsoft.PowerShell.SecretManagement"
			SecretStore = ".\ExternalModules\Microsoft.PowerShell.SecretStore"
		}
	}
	[psobject]SetDefaultVault([string]$VaultName){
		$Message = "{0} {1}'{2}'" -f '+','Updating Current Vault To:',$VaultName
		Write-Verbose -Message $Message -Verbose
		Set-SecretVaultDefault -Name $VaultName
		return $true
	}
	[psobject]GetSecretInfo([string]$SecretName){
		$DefaultVault = $this.GetProperty('VaultName')
		$Info = Get-SecretInfo -Name $SecretName -Vault $DefaultVault
		
		return $Info | Select-Object Name, Type
	}
	[psobject]GetProperty([string]$searchProperty){
		$property_value 	= $null
		$property_key 		= $null
		$foudProperty 		= $false
		$propertiesList  	= $this.Properties.keys
		$totalProperties	= $propertiesList.count
		$parentprop 		= [string]
		$results_object 	= [hashtable]

		$Message = "{0} {1}" -f '+','Starting Property Search'
		Write-Verbose -Message $Message -Verbose

		$property_count = 1
		foreach($property in $propertiesList){
			$property_num = $property_count++
			$Message = "{0}{1} ({2} of {3})" -f '+-','Main property',$property_num,$totalProperties
			Write-Verbose -Message $Message -Verbose
			if($property -match $searchProperty){
				$foudProperty 	= $true
				$property_key 	= $property
				$parentprop 	= $property
				$property_value = $this.Properties[$property]

				$Message = "{0}'{1}' matches '{2}'" -f '+-',$property,$searchProperty
				Write-Verbose -Message $Message -Verbose
			}
			if(-not($foudProperty)){
				$Message = "{0}'{1}' does not matches '{2}'" -f '+-',$property,$searchProperty
				Write-Verbose -Message $Message -Verbose
				
				$subpropertyTable = $this.Properties[$property]
				$subpropertyLists = $subpropertyTable.keys

				foreach($subproperty in $subpropertyLists){
					if($subproperty -match $searchProperty){
						$Message = "{0}'{1}' matches '{2}'" -f '+-',$subproperty,$searchProperty
						Write-Verbose -Message $Message -Verbose
						$foudProperty = $true
						$property_key = $subproperty
						$parentprop 	= $property
						$property_value = $subpropertyTable[$property_key]
					}
					if(-not($foudProperty)){
						$Message = "{0}'{1}' does not matches '{2}'" -f '+-',$subproperty,$searchProperty
						Write-Verbose -Message $Message -Verbose
					}
				}
			}

			if($foudProperty){
				$Message = "{0} {1}" -f '+','Property Search complete'
				Write-Verbose -Message $Message -Verbose
				break
			}
		}

		if(-not($foudProperty)){
			$Message = "{0} {1}" -f '+','Property Search complete'
			Write-Verbose -Message $Message -Verbose
			$ErrorMessage = "{0}{1} '{2}' {3}" -f '--','Property',$searchProperty,'does not exist'
			Write-Error -Message $ErrorMessage
			return $Error[0]
			return $foudProperty
		}
		if(-not($this.utilityVars.hideparentprop)){
			$results_object = @{
				parentprop = $parentprop
				$property_key = $property_value
			}
			return $results_object
		}else{
			$results_object = @{
				parentprop = $parentprop
				$property_key = $property_value
			}
			return $results_object[$property_key]
		}
	}
	[psobject]SetProperty([hashtable]$Property){
		$updateFailed = $false
		$this.utilityVars.hideparentprop = $false
		$property_key = [string]$Property.keys
		$newproperty_value 	= [string]$Property.Values

		$Message = "{0} {1} {2} to '{3}'" -f '+','Starting Update Request:',$property_key,$newproperty_value
		Write-Verbose -Message $message -Verbose
		$parentproperty = $this.GetProperty($property_key)['parentprop']
		try{
			$this.Properties[$parentproperty][$property_key] = $newproperty_value
			$this.SetDefaultVault($newproperty_value)
		}catch{
			$Message = "{0}{1} '{2}' does not exists" -f '--','Property',$property_key
			Write-Verbose -Message $message -Verbose
			$ErrorMessage = "{0}{1} '{2}' {3}" -f '--','Property',$property_key,'does not exist'
			Write-Error -Message $ErrorMessage
			$updateFailed = $true
		}
		if($updateFailed){
			return $Error[0]
		}
		$this.utilityVars.hideparentprop = $true

		$Message = "{0} {1}" -f '+','Update Request complete'
		Write-Verbose -Message $message -Verbose
		return $true
	}
	[psobject]CreateSecretsVault([string]$newVaultName){
		$Message =  "{0} {1}" -f '+','Starting Create Vault Action...'
		Write-Verbose -Message $Message -Verbose

		if($newVaultName.Length -le 1){
			$Message = "{0} {1}" -f '--','Vault name cannot be and empty string'
			Write-Verbose -Message $Message -Verbose
			$ErrorMessage = $Message
			Write-Error -Message $Message
			return $Error[0]
		}
		if($null -match $newVaultName){
			$ErrorMessage = "{0} {1}" -f '--',"Vault name cannot be 'null'..."
			Write-Error -Exception $ErrorMessage
			return $Error[0]
		}
		try{
			Register-SecretVault -Name $newVaultName -ModuleName $this.utilityVars.ExternalModules.SecretStore -DefaultVault
			$isVaultCreated = $true
		}catch{
			$isVaultCreated = $false
		}

		if(-not($isVaultCreated)){
			$Message = "{0} {1}" -f '--','Create Vault Action did not complete'
			Write-Verbose -Message $Message -Verbose
		}

		if(-not($isVaultCreated)){
			$current_vault  = $this.GetVault($newVaultName)
			$Message = "{0} {1} '{2}'" -f '--','There is already a vault with the name:',$current_vault.name
			Write-Verbose -Message $Message -Verbose
		}

		if(-not($isVaultCreated)){
			$Message = "{0} {1}" -f "+","Create Vault Action Completed with failures..."
			Write-Verbose -Message $Message -Verbose
			return $false
		}

		$Message = "{0} {1}" -f '+','Create Vault Action Completed successfully...'
		Write-Verbose -Message $Message -Verbose
		$this.SetProperty(@{VaultName = $newVaultName})
		return $true
	}
	[psobject]GetVault([string]$VaultName){
		$Message = "{0} {1}: '{2}'" -f '+','GetVault',$VaultName
		Write-Verbose -Message $Message -Verbose
		return  Get-SecretVault $VaultName
	}
	[psobject]GetSecret([string]$SecretName){
		$DefaultVault = $this.GetProperty('VaultName')
		$Secret =  Get-Secret -name $SecretName  -AsPlainText -Vault $DefaultVault
		$SecretEncrypted =  Get-Secret -name $SecretName -Vault $DefaultVault

		$secretTable = [ordered]@{
			InstanceName 	= $Secret.InstanceName
			UserName 		= $Secret.UserName
			Password 		= $SecretEncrypted.Password
			}
		return $secretTable
	}
	[boolean]RemoveSecretsVault([string]$VaultName){
		$isVaultRemoved = $false
		$isVault 	= Get-SecretVault -Name $VaultName

		if($isVault){
			try{
				Unregister-SecretVault -name $VaultName
				$isVaultRemoved = $true
			}catch{
				$isVaultRemoved = $false
			}
		}
		if(-not($isVault)){
			$isVaultRemoved = $false
		}

		return $isVaultRemoved
	}
	[psobject]RemoveSecret([string]$SecretName){
		$DefaultVault = $this.GetProperty('VaultName')
		Remove-Secret -Name $SecretName -Vault $DefaultVault
		return $true
	}
	[psobject]SetSecret([string]$SetSecretType,[string]$SecretName,[hashtable]$SetSecretParams){
		$isSecretSet 			= $false
		$Secret 			= [hashtable]
		#$LoginType 			= $SetSecretParams.LoginType
		$SecureCredentials 	= [hashtable]
		$Subpropeties 		= $this.GetProperty('SecretProperties')
		$SetSecretTypeList	= [string]($Subpropeties['SecretTypes'].keys)
		
		if($SetSecretTypeList -notcontains $SetSecretType){
			Write-Verbose -Message 'invalid secret type provided' -Verbose
		}
		
		
		switch($SetSecretTypeList){
			# when the secret is a login type
			'Login' {	# login secret can be only sql, windows, or gitlab
						$typesofLoginList = @($Subpropeties.SecretTypes.login)
						if($typesofLoginList -notcontains $SetSecretParams.LoginType){
							Write-Verbose -Message 'login secret can be only sql, windows, or gitlab' -Verbose
							return $false}

						# the login type is matched and used
						if($typesofLoginList -contains $SetSecretParams.LoginType){
							Write-Verbose -Message "secret login type provided is '$($SetSecretParams.LoginType)'" -Verbose
						# for secrets that are type login, we encrypt the password
						Write-Verbose -Message "encrypting login creds" -Verbose
						$SecureCredentials	= $this.ConvertPasswordToSecureString(
							@{	Username 	= $SetSecretParams.Username
								Password 	= $SetSecretParams.Password})

								
						# set the secret here
						$Secret = @{
							InstanceName 	= $SetSecretParams.InstanceName
							UserName 	= $SecureCredentials.UserName
							Password 	= $SecureCredentials.Password}
					}
			}
			default {Write-Verbose -Message 'only login type secrets can be set with this method' -Verbose
			return $false}
		}


		$SecretTable = @{
			Vault 		= $this.GetProperty('VaultName')
			Name 		= $SecretName
			Metadata 	= @{Expiration = (get-date).AddDays($this.GetProperty('ExpireInDays'))}
		}
		
		# you can only set a secrete if you have a vault
		if($null -like $this.GetProperty('VaultName')){
			Write-Verbose -Message 'no vaultname property set..' -Verbose
			return $false
		}
		try{
			Write-Verbose -Message 'secrete set...' -Verbose
			Set-Secret -Vault $SecretTable.Vault -Name $SecretTable.Name -Secret $Secret -Metadata $SecretTable.Metadata
			$isSecretSet = $true
		}catch{
			$isSecretSet = $false
		}
		return $isSecretSet
		
	}
	[psobject]ConvertPasswordToSecureString([hashtable]$SuppliedCreds){
		# password needs to be converted to secure string
		$PasswordSecureString 		= ConvertTo-SecureString $SuppliedCreds.Password -AsPlainText -Force
		$credentials 			= New-Object System.Management.Automation.PSCredential($SuppliedCreds.Username,$PasswordSecureString)
		return $credentials
	}

}

Function Import-UtilitySecretManagement {
	Import-ExternalModules 
	$PSVault = [UtilitySecretManagement]::new()
	$PSVault
	Export-ModuleMember -Cmdlet @(
		'Get-SecretInfo',
		'Get-SecretVault',
		'Remove-Secret',
		'Get-Secret',
		'Set-Secret',
		'Register-SecretVault',
		'Unregister-SecretVault'
		) 
}
Export-ModuleMember -Function @('Import-UtilitySecretManagement') 
