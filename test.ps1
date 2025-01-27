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


# Fonction pour extraire l'OU à partir d'un DistinguishedName
function Get-OUFromDistinguishedName {
    param (
        [string]$DistinguishedName
    )

    # Vérifier si le DistinguishedName est valide
    if (-not $DistinguishedName) {
        Write-Host "Le DistinguishedName ne peut pas être vide."
        return
    }

    # Diviser le DistinguishedName en parties
    $parts = $DistinguishedName -split ','

    # Filtrer pour obtenir uniquement les parties qui commencent par "OU="
    $OUParts = $parts | Where-Object { $_ -like 'OU=*' }

    # Joindre les parties de l'OU pour former le DistinguishedName de l'OU
    if ($OUParts) {
        $OUResult = $OUParts -join ','
        Write-Host "L'OU correspondante est : $OUResult"
    } else {
        Write-Host "Aucune OU trouvée dans le DistinguishedName spécifié."
    }
}

# Exemple d'utilisation
# Remplacez le DistinguishedName par celui que vous souhaitez tester
# Get-OUFromDistinguishedName -DistinguishedName "CN=luc Pierre,OU=test,DC=ad,DC=lab"



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
