
#cisco IPCOMM registry change tftp server Script
#By Eddgar Rojas
#This scripts  is usefull for a massive change of tftp servers address on cisco IPCOMM
#Tested with Cisco IP Communicator 8.6 and above
#env PowerShell


# Fill IP'S and fill registry path as necesary
$ip_tftp1 = "172.17.101.11"
$ip_tftp2 = "172.17.101.12"
$hkcu_path = "HKCU:\Software\Cisco Systems, Inc.\Communicator"
$hklm_path = "HKLM:\SOFTWARE\WOW6432Node\Cisco Systems, Inc.\Communicator"
$property_tftp1 = "TftpServer1"
$property_tftp2 = "TftpServer2"

###############################
$val_tftp1 = 0
$val_tftp2 = 0




# Function to convert IP address to Hexadecimal(Type Int)

Function IP-To-Hex{
    param([string]$ip, [bool]$reverse = 0)
    $ip_splitted = $ip.split(".")
    $ip_hex = ""
	IF ($reverse){
	#  Windows reverse the Hex value on registry, so add the option to reverse the hex Array
        [array]::Reverse($ip_splitted)
    }
	foreach ($octec in $ip_splitted){
	    $oct_hex = [int]$octec
		$ip_hex = $ip_hex + ("{0:x}" -f $oct_hex)
	} 
    [int]"0x$ip_hex" 
}

Function Hex-To-IP{
    param([int]$value, [bool]$reverse = 0)
	$hex_splitted = ("{0:x8}" -f $value)
	
    IF ($hex_splitted.lenght -gt 8){
	    throw "This value does not correspond to an IP address on Hex Format"
	}
	
	$hex_splitted = $hex_splitted -split  "(..)" -ne ""
	
	IF ($reverse){
	    [array]::Reverse($hex_splitted)
	}
	
	$ip_address =""
	
	foreach ($hex in $hex_splitted) {
	    $ip_address = $ip_address +[string]([int]"0x$hex") + "."
	}
	echo $ip_address
}

#converting IP to Values that Windows understand
$val_tftp1 = IP-To-Hex $ip_tftp1  1
$val_tftp2 = IP-To-Hex $ip_tftp2  1




IF(Test-path $hkcu_path){
    $output_var1 = ""
	$output_var2 = ""
    Write-Output "Working on Current users path:"
	Write-Output $hkcu_path
    Write-Output "Current tftp servers"
	$output_var1 =  (Get-ItemProperty -Path $hkcu_path -Name $property_tftp1).$property_tftp1
	$output_var2 = (Get-ItemProperty -Path $hkcu_path -Name $property_tftp2).$property_tftp2
    Write-Output "$property_tftp1 : $(Hex-To-IP $output_var1)" 
	Write-Output "$property_tftp2 : $(Hex-To-IP $output_var2)"

    New-ItemProperty -path $hkcu_path -Name $property_tftp1 -Value $val_tftp1 -PropertyType DWORD -FORCE | Out-Null
    New-ItemProperty -path $hkcu_path -Name $property_tftp2 -Value $val_tftp2 -PropertyType DWORD -FORCE | Out-Null
	
    Write-Output "Updated tftp servers"
	$output_var1 = (Get-ItemProperty -Path $hkcu_path -Name $property_tftp1).$property_tftp1
	$output_var2 = (Get-ItemProperty -Path $hkcu_path -Name $property_tftp2).$property_tftp2
    Write-Output "$property_tftp1 : $(Hex-To-IP $output_var1)" 
	Write-Output "$property_tftp1 : $(Hex-To-IP $output_var2)"
}
ELSE{
Write-Output "An error has occurred please check path: $hkcu_path"
}

IF(Test-path $hklm_path){
    $output_var1 = ""
	$output_var2 = ""
    Write-Output "Working in Local Machine"
	Write-Output "Current tftp servers"
	$output_var1 = (Get-ItemProperty -Path $hklm_path -Name $property_tftp1).$property_tftp1
	$output_var2 = (Get-ItemProperty -Path $hklm_path -Name $property_tftp2).$property_tftp2
    Write-Output "$property_tftp1 : $(Hex-To-IP $output_var1)" 
	Write-Output "$property_tftp2 : $(Hex-To-IP $output_var2)"

    
    IF(!(($output_var1 -eq $val_tftp1) -and ($output_var2 -eq $val_tftp2)))
	{
	    Write-Output "HKLM tftps differ form HKLU"
		Write-Output "Fixing!!!"
		New-ItemProperty -path $hklm_path -Name $property_tftp1 -Value $val_tftp1 -PropertyType DWORD -FORCE | Out-Null
		New-ItemProperty -path $hklm_path -Name $property_tftp2 -Value $val_tftp2 -PropertyType DWORD -FORCE | Out-Null
	    $output_var1 =  (Get-ItemProperty -Path $hkcu_path -Name $property_tftp1).$property_tftp1
	    $output_var2 = (Get-ItemProperty -Path $hkcu_path -Name $property_tftp2).$property_tftp2
        Write-Output "$property_tftp1 : $(Hex-To-IP $output_var1)" 
	    Write-Output "$property_tftp2 : $(Hex-To-IP $output_var2)"
	}
    ELSE {echo "tftp same avoiding!!!"}
}
ELSE{
Write-Output "An error has occurred please check path: $hklm_path"
}

