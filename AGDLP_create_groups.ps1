param (
    [Parameter(Mandatory=$true)]
    [string]$baseOU
)

# Importer le module Active Directory
Import-Module ActiveDirectory

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
    
        New-ADGroup -Name $dlgGroupNameR -GroupScope DomainLocal -GroupCategory Security -Path $ou.DistinguishedName
        Write-Host "Groupe créé : $dlgGroupNameR"
    
        New-ADGroup -Name $dlgGroupNameRW -GroupScope DomainLocal -GroupCategory Security -Path $ou.DistinguishedName
        Write-Host "Groupe créé : $dlgGroupNameRW"

        # Ajouter le groupe GGS dans les groupes DLG
        Add-ADGroupMember -Identity $dlgGroupNameR -Members $ggsGroupName
        Write-Host "Ajouté $ggsGroupName dans $dlgGroupNameR"

        Add-ADGroupMember -Identity $dlgGroupNameRW -Members $ggsGroupName
        Write-Host "Ajouté $ggsGroupName dans $dlgGroupNameRW"

        $Users = Get-ADUser -Filter * -SearchBase $ou.DistinguishedName
        foreach ($User in $Users){
            Add-ADGroupMember -Identity $ggsGroupName -Members $Users.DistinguishedName
        }
    } catch {
        Write-Host "Erreur lors de la création des groupes : $_"
    }
}
