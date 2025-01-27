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


# Fonction pour obtenir l'OU à partir d'un DistinguishedName
function Get-OUFromDistinguishedName {
    param (
        [string]$DistinguishedName
    )

    # Vérifier si le DistinguishedName est valide
    if (-not $DistinguishedName) {
        Write-Host "Le DistinguishedName ne peut pas être vide."
        return
    }

    # Extraire l'OU à partir du DistinguishedName
    try {
        $OU = Get-ADOrganizationalUnit -Identity $DistinguishedName
        if ($OU) {
            Write-Host "L'OU correspondante est : $($OU.Name)"
            Write-Host "DistinguishedName : $($OU.DistinguishedName)"
        } else {
            Write-Host "Aucune OU trouvée pour le DistinguishedName spécifié."
        }
    } catch {
        Write-Host "Erreur : $_"
    }
}

# Exemple d'utilisation
# Remplacez le DistinguishedName par celui que vous souhaitez tester
# Get-OUFromDistinguishedName -DistinguishedName "OU=NomDeVotreOU,DC=exemple,DC=com"


# Fonction pour lister les OUs, les groupes et les utilisateurs
function Get-ADStructure {
    # Lister toutes les OUs
    $OUs = Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName
    $Groups = Get-ADGroup -Filter * | Select-Object Name, DistinguishedName
    $Users = Get-ADUser -Filter * | Select-Object Name, DistinguishedName

    foreach ($OUs in $OU) {
        foreach ($Groups in $Group) {
            
            if ({Get-OUFromDistinguishedName $OU.DistinguishedName} -eq {Get-OUFromDistinguishedName $Group.DistinguishedName}) {
                Write-Host Test
            }
        }
        
    }

}

# Appeler la fonction
Get-ADStructure
