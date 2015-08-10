function Get-TeamcityBuildTypeParameter {
	param(
		[Parameter(Mandatory=$True)][string]$BaseUrl,
		[Parameter(Mandatory=$True)][string]$Credentials,
		[Parameter(Mandatory=$True)][string]$BuildTypeId,
		[Parameter(Mandatory=$True)][string]$ParameterName
	)

	$url = "$($BaseUrl)/app/rest/buildTypes/$($BuildTypeId)/parameters/$($ParameterName)"
	$response = Invoke-RestCall "$url" -Credentials $Credentials
	return $response.property.value
}

function Announce-TeamcityBuildVersions {
	param(
		[Parameter(Mandatory=$True)][string]$InformationalVersion
	)

	if (-Not ($InformationalVersion -match '([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)(-+)?')) {
		Throw "Invalid informational version"
	}

	$version = [version] ("$($Matches[1]).$($Matches[2]).$($Matches[3]).$($Matches[4])")
	$assemblyVersion = "$($version.Major).$($version.Minor).$($version.Build)"
	$fileVersion = "$($version.Major).$($version.Minor).$($version.Build).$($version.Revision)"

	Set-TeamcityParameter -Parameter "build.assemblyVersion" -Value $assemblyVersion
	Set-TeamcityParameter -Parameter "env.fileVersion" -Value $fileVersion
	Set-TeamcityParameter -Parameter "env.informationalVersion" -Value $InformationalVersion
}

function Set-TeamcityParameter {
	param (
		[Parameter(Mandatory=$True)][string]$Parameter,
		[Parameter(Mandatory=$True)][string]$Value
	)

	Write-Host "##teamcity[setParameter name='$Parameter' value='$Value']"
}

function Set-TeamcityBuildTypeParameter {
	param(
		[Parameter(Mandatory=$True)][string]$BaseUrl,
		[Parameter(Mandatory=$True)][string]$Credentials,
		[Parameter(Mandatory=$True)][string]$BuildTypeId,
		[Parameter(Mandatory=$True)][string]$ParameterName,
		[Parameter(Mandatory=$True)][string]$Value
	)
	 
	$url = "$($BaseUrl)/app/rest/buildTypes/$($BuildTypeId)/parameters/$($ParameterName)"
	Invoke-RestCall "$url" -Credentials $Credentials -Body $Value
}

function Reset-BuildCounterForBuildType {
	param(
		[Parameter(Mandatory=$True)][string]$BaseUrl,
		[Parameter(Mandatory=$True)][string]$Credentials,
		[Parameter(Mandatory=$True)][string]$BuildTypeId
	)

	$url = "$($BaseUrl)/app/rest/buildTypes/$($BuildTypeId)/settings/buildNumberCounter"
	Invoke-RestCall "$url" -Credentials $Credentials -Body "2" | Out-Null
}

function Invoke-RestCall {
	param(
		[Parameter(Mandatory=$True)][string]$Url, 
		[Parameter(Mandatory=$True)][string]$Credentials,
		[Parameter(Mandatory=$False)][string]$Body
	)

	if ($Body) {
		return Invoke-RestMethod "$Url" -Headers @{"Authorization" = "$Credentials"} -Method Put -ContentType "text/plain" -Body $Body
	} else {
		return Invoke-RestMethod "$Url" -Headers @{"Authorization" = "$Credentials"} -Method Get
	}
	
}

function Get-CredentialHeader {
	param(
		[Parameter(Mandatory=$True)][string]$User,
		[Parameter(Mandatory=$True)][string]$Pass
	)

	$credentials = "$($User):$($Pass)"
	$base64String = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$credentials"))

	return "Basic $base64String"
}
