class SQLUtility{
	$Properties = @{
		VaultProperties = @{
			VaultName 			= [string]''
			VaultDescription 	= [string]''
		}
		SecretProperties = @{
			ExpireInDays 	= [int]1
			test = [int]
			SecretTypes 	= @{
				Login 		= @('SQLLogin','WindowsAuthentication')
			}
		}
	}
	$utilityVars = @{
		hideparentprop = $true
	}
	[psobject]GetProperty([string]$searchProperty) {
		$property_value 	= $null
		$property_key 		= $null
		$foudProperty 		= $false
		$propertiesList  	= $this.Properties.keys
		$parentprop 		= [string]
		$results_object 	= [hashtable]

		foreach($property in $propertiesList){
			if($property -match $searchProperty){
				$foudProperty 	= $true
				$property_key 	= $property
				$parentprop 	= $property
				$property_value = $this.Properties[$property]
				Write-Verbose -Message "property search: $property matches $searchProperty" -Verbose
			}
			if(-not($foudProperty)){
				Write-Verbose -Message "property search: $property did not match  $searchProperty" -Verbose
				
				$subpropertyTable = $this.Properties[$property]
				$subpropertyLists = $subpropertyTable.keys

				foreach($subproperty in $subpropertyLists){
					if($subproperty -match $searchProperty){
						Write-Verbose -Message "subproperty search: $subproperty matches $searchProperty" -Verbose
						$foudProperty = $true
						$property_key = $subproperty
						$parentprop 	= $property
						$property_value = $subpropertyTable[$property_key]
					}
					if(-not($foudProperty)){
						Write-Verbose -Message "subproperty search: $subproperty did not match  $searchProperty" -Verbose
					}
				}
			}

			if($foudProperty){
				Write-Verbose -Message "building object to return..." -Verbose
				break
			}
		}
		if(-not($this.utilityVars.hideparentprop)){
			$results_object = @{
				parentprop = $parentprop
				$property_key = $property_value}
			return $results_object
		}else{
			$results_object = @{
				parentprop = $parentprop
				$property_key = $property_value}
				return $results_object[$property_key]
		}
	}
	[psobject]TestUtility($TestThis){
		$testTable = @{
			msg1 = $TestThis.GetType();  	
			msg2 = $TestThis;  				
		}
		return $testTable
	}
	[void]SetProperty([hashtable]$Property){
		$this.utilityVars.hideparentprop = $false
		$property_key 		= [string]$Property.keys
		$newproperty_value 	= [string]$Property.Values
		$message 			= "updating $property_key to $newproperty_value" -f $property_key,$newproperty_value
		Write-Verbose -Message $message -Verbose
		$parentproperty = $this.GetProperty($property_key)['parentprop']
		$this.Properties[$parentproperty][$property_key] = $newproperty_value
		$this.utilityVars.hideparentprop = $true
	}
	[psobject]CreateSecretsVault([string]$newVaultName){
		if($null -match $newVaultName){
			Write-Verbose -Message "vault name can't be empty"
		}

		# you want to see what vaults exists
		try{
			Register-SecretVault -Name $newVaultName -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault
			$isVaultCreated = $true
		}catch{
			$isVaultCreated = $false
		}

		if($isVaultCreated){$msg_var = 'not'}else{$msg_var = ''}
		$message = "Vault '{0}' was {1} created" -f $newVaultName,$msg_var
		Write-Verbose -Message $message -Verbose

		$this.SetProperty(@{VaultName = $newVaultName})
		return $isVaultCreated
	}
	[psobject]GetSecret([string]$SecretName){
	$Secret 			=  Get-Secret -name $SecretName  -AsPlainText
	$SecretEncrypted 	=  Get-Secret -name $SecretName

	$secretTable = [ordered]@{
		InstanceName 	= $Secret.InstanceName
		UserName 		= $Secret.UserName
		Password 		= $SecretEncrypted.Password
		}
		return $secretTable
	}
	[boolean]RemoveSecretsVault(){
		$isVaultRemoved = $false
		$VaultName = $this.GetProperty('VaultName')
		$isVault = Get-SecretVault -Name $VaultName

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
	[psobject]GetVault([string]$VaultName){
		return  Get-SecretVault $VaultName 
	}
	[psobject]SetSecret([string]$VaultName,[string]$SetSecretType,[string]$SecretName,[hashtable]$SetSecretParams){
		$isSecretSet 		= $false
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
			'Login' {	# the logintype can be sql or windows
						$typesofLoginList = @($Subpropeties.SecretTypes.login)
						if($typesofLoginList -notcontains $SetSecretParams.LoginType){
							Write-Verbose -Message 'login secret can be only sql or windows' -Verbose
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
							InstanceName = $SetSecretParams.InstanceName
							UserName 	= $SecureCredentials.UserName
							Password = $SecureCredentials.Password}
					}
			}
			default {Write-Verbose -Message 'only login type secrets can be set with this method' -Verbose
			return $false}
		}


		$SecretTable = @{
			Vault 		= $VaultName
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
		$PasswordSecureString 	= ConvertTo-SecureString $SuppliedCreds.Password -AsPlainText -Force
		$credentials 			= New-Object System.Management.Automation.PSCredential($SuppliedCreds.Username,$PasswordSecureString)
		return $credentials
	}
	[psobject]GetSecretInfo([string]$VaultName){
		$Info = Get-SecretInfo -Vault $VaultName
		return $Info
	}
}