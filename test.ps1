# Importer le module Active Directory
Import-Module ActiveDirectory

# Fonction pour extraire l'OU à partir d'un DistinguishedName
function Get-OUFromDistinguishedName {
    param (
        [string]$DistinguishedName
    )

    # Diviser le DistinguishedName en parties
    $parts = $DistinguishedName -split ','

    # Filtrer pour obtenir uniquement les parties qui commencent par "OU="
    $OUParts = $parts | Where-Object { $_ -like 'OU=*' }

    # Joindre les parties de l'OU pour former le DistinguishedName de l'OU
    if ($OUParts) {
        $OUResult = $OUParts -join ','
        return $OUResult
    }
}

# Fonction pour lister les OUs et les groupes associés
function Get-ADStructure {
    # Lister toutes les OUs
    $OUs = Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName
    # Lister tous les groupes
    $Groups = Get-ADGroup -Filter * | Select-Object Name, DistinguishedName

    foreach ($OU in $OUs) {
        # Extraire le nom de l'OU pour l'affichage
        $OUName = $OU.Name -replace 'OU=', ''
        Write-Host $OUName
        
        # Initialiser un indicateur pour vérifier si des groupes sont trouvés
        $groupFound = $false
        
        foreach ($Group in $Groups) {
            # Comparer l'OU de l'OU avec l'OU du groupe
            if (Get-OUFromDistinguishedName $OU.DistinguishedName -eq Get-OUFromDistinguishedName $Group.DistinguishedName) {
                Write-Host " - $($Group.Name)"
                $groupFound = $true
            }
        }
        
        # Si aucun groupe n'est trouvé, afficher un message
        if (-not $groupFound) {
            Write-Host " - Aucun groupe trouvé."
        }
        
        Write-Host ""  # Ligne vide pour séparer les OUs
    }
}

# Appeler la fonction
Get-ADStructure
