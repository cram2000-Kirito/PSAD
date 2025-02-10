param (
    [Parameter(Mandatory=$true)]
    [string]$baseOU,
    [Parameter(Mandatory=$false)]
    [string[]]$DLGs
)

Import-Module ActiveDirectory
Import-Module "$PSScriptRoot\PSmodules\AD.psm1"
Import-Module "$PSScriptRoot\PSmodules\utils.psm1"

try {
    $baseOU = Get-CheckVariable $baseOU
    $OUs = Get-ADOrganizationalUnit -Filter * -SearchBase $baseOU
}
catch {
    <#Do this if a terminating exception happens#>
}

if (-not $DLGs) {
    $DLGs = "R", "RW"
}

foreach ($OU in $OUs) {
    #Cree le group GGS
    $ggsGroup.Name = "GGS_$($ou.Name)"
    New-ADGroup -Name $ggsGroup.Name -GroupScope Global -GroupCategory Security -Path $ou.DistinguishedName
    Write-Host "Groupe créé : $($ggsGroup.Name)"
    
    #Recup le DistinguishedName du GGS
    $ggsGroup.DistinguishedName = Get-ADGroup -Identity $ggsGroup.Name -SearchBase $ou.DistinguishedName -SearchScope OneLevel
    
    #Ajoute les users au GGS
    $Users = Get-ADUser -Filter * -SearchBase $ou.DistinguishedName -SearchScope OneLevel
    foreach ($User in $Users) {
        Add-ADGroupMember -Identity $ggsGroup.DistinguishedName -Members $User.DistinguishedName
    }

    #Ajoute les GGS enfants au GGS
    $Groups = Get-ADGroup -Filter 'Name -like "GGS_*"' -SearchBase $ou.DistinguishedName -SearchScope OneLevel
    foreach ($Group in $Groups) {
        Add-ADGroupMember -Identity $ggsGroup.DistinguishedName -Members $Group.DistinguishedName
    }

    foreach ($DLG in $DLGs) {
        #Cree le group DLG
        $dlgGroupName = "DLG_$($ou.Name)_$DLG"
        New-ADGroup -Name $dlgGroupName -GroupScope DomainLocal -GroupCategory Security -Path $ou.DistinguishedName
        Write-Host "Groupe créé : $dlgGroupName"

        #Ajoute le group GGS au group DLG
        Add-ADGroupMember -Identity $dlgGroupName -Members $ggsGroup.DistinguishedName
        Write-Host "Ajouté $($ggsGroup.Name) dans $dlgGroupName"
    }
}