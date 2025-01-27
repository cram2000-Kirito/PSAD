# Importer le module Active Directory
Import-Module ActiveDirectory

# Fonction pour supprimer les doublons en gardant les derniers
function Remove-Duplicates {
    param (
        [array]$InputArray
    )
    $UniqueItems = @{}

    foreach ($item in $InputArray) {
        # Utiliser le nom comme clé pour garder le dernier élément
        $UniqueItems[$item.Name] = $item
    }

    return $UniqueItems.Values
}

# Fonction pour lister les OUs, les groupes et les utilisateurs
function Get-ADStructure {
    # Lister toutes les OUs
    $OUs = Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName

    foreach ($OU in $OUs) {
        Write-Host $OU.Name
        
        # Lister les groupes dans l'OU
        $Groups = Get-ADGroup -Filter * -SearchBase $OU.DistinguishedName | Select-Object Name
        $UniqueGroups = Remove-Duplicates -InputArray $Groups
        if ($UniqueGroups) {
            Write-Host "  - Groupes :"
            $UniqueGroups | ForEach-Object { Write-Host "    - " $_.Name }
        } else {
            Write-Host "  - Aucun groupe trouvé."
        }

        # Lister les utilisateurs dans l'OU
        $Users = Get-ADUser -Filter * -SearchBase $OU.DistinguishedName | Select-Object Name
        $UniqueUsers = Remove-Duplicates -InputArray $Users
        if ($UniqueUsers) {
            Write-Host "  - Utilisateurs :"
            $UniqueUsers | ForEach-Object { Write-Host "    - " $_.Name }
        } else {
            Write-Host "  - Aucun utilisateur trouvé."
        }

        Write-Host "`n"  # Ligne vide pour séparer les OUs
    }
}

# Appeler la fonction
Get-ADStructure
