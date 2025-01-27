# Importer le module Active Directory
Import-Module ActiveDirectory

# Fonction pour lister les OUs, les groupes et les utilisateurs
function Get-ADStructure {
    # Lister toutes les OUs
    $OUs = Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName

    foreach ($OU in $OUs) {
        Write-Host $OU.Name
        
        # Lister les groupes dans l'OU
        $Groups = Get-ADGroup -Filter * -SearchBase $OU.DistinguishedName | Select-Object Name
        if ($Groups) {
            Write-Host "  - Groupes :"
            $Groups | ForEach-Object { Write-Host "    - " $_.Name }
        } else {
            Write-Host "  - Aucun groupe trouvé."
        }

        # Lister les utilisateurs dans l'OU
        $Users = Get-ADUser -Filter * -SearchBase $OU.DistinguishedName | Select-Object Name
        if ($Users) {
            Write-Host "  - Utilisateurs :"
            $Users | ForEach-Object { Write-Host "    - " $_.Name }
        } else {
            Write-Host "  - Aucun utilisateur trouvé."
        }

        Write-Host "`n"  # Ligne vide pour séparer les OUs
    }
}

# Appeler la fonction
Get-ADStructure
