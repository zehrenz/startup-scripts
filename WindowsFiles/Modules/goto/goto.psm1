$STORE = "~/.config/goto_locations.json"

Function goto{
    param(
        [Alias('s')][switch]$Save,
        [Alias('r')][switch]$Remove,
        [Alias('l')][switch]$List,
        [Parameter(ValueFromRemainingArguments=$true)][string[]]$Names
    )
	if(Test-Path $STORE -PathType Leaf) {
		$locations = Get-Content -Raw -Path $STORE | ConvertFrom-Json -AsHashtable
	}else{
		$locations = @{}
	}
	if($List){
		if($locations.Count -eq 0){
			Write-Host "No saved locations"
			return
		}
		$locations.Keys | Sort-Object | ForEach-Object {
			Write-Host "$_ -> $($locations[$_])"
		}
		return
	}
	if($Save -and $Remove){
		Write-Host "Cannot save and remove at the same time"
		return
	}
	if(-not $Names){
		Write-Host "Names parameter is required when not using -List flag"
		return
	}
	if($Save){
		foreach($name in $Names){
			$locations[$name] = $pwd.Path
		}
		Save-Locations $locations
		return
	}
	if($Remove){
		$removed = 0
		foreach($name in $Names){
			if($locations.ContainsKey($name)){
				$locations.Remove($name)
				$removed++
			}else{
				Write-Warning "Location '$name' not found"
			}
		}
		if($removed -gt 0){
			Save-Locations $locations
		}
		return
	}
	if($Names.Count -gt 1){
		Write-Host "Error: Multiple names provided without Save or Remove flag. Only one name allowed for navigation."
		return
	}
	$name = $Names[0]
	if(!($locations.ContainsKey($name))){
		Write-Host "No such location: $name"
		return
	}
	$locations[$name] | Set-Location
	return
}

Function Save-Locations {
	param($locations)
	$sortedLocations = [ordered]@{}
	$locations.Keys | Sort-Object | ForEach-Object {
		$sortedLocations[$_] = $locations[$_]
	}
	$sortedLocations | ConvertTo-Json | Set-Content -Path $STORE
}

Export-ModuleMember -Function goto