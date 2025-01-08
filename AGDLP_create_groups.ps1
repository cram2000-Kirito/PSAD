# Importer le module Active Directory
Import-Module ActiveDirectory
$baseOU = "OU=techform,DC=ad,DC=lab"

# Récupérer toutes les OUs
$ous = Get-ADOrganizationalUnit -Filter * -SearchBase $baseOU

$ous | ForEach-Object { Write-Host "$($_.DistinguishedName)" }

foreach ($ou in $ous) {

    $ggsGroupName = "GGS_${$ou.Name}"
    $dlgGroupNameR = "DLG_${$ou.Name}_R"
    $dlgGroupNameRW = "DLG_${$ou.Name}_RW"

    try {
        New-ADGroup -Name $ggsGroupName -GroupScope Global -GroupCategory Security -Path $ou.DistinguishedName
        Write-Host "Groupe créé : $ggsGroupName"
    
        New-ADGroup -Name $dlgGroupNameR -GroupScope Global -GroupCategory Security -Path $ou.DistinguishedName
        Write-Host "Groupe créé : $dlgGroupNameR"
    
        New-ADGroup -Name $dlgGroupNameRW -GroupScope Global -GroupCategory Security -Path $ou.DistinguishedName
        Write-Host "Groupe créé : $dlgGroupNameRW"
    } catch {
        Write-Host "Erreur lors de la création des groupes : $_"
    }
}
