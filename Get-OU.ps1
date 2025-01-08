# Importer le module Active Directory
Import-Module ActiveDirectory

# Définir l'OU de base à partir de laquelle vous souhaitez récupérer les OUs
$baseOU = "OU=techform,DC=ad,DC=lab"

# Fonction pour récupérer les OUs récursivement
function Get-OUsRecursively {
    param (
        [string]$ou
    )

    # Récupérer toutes les OUs dans l'OU spécifié
    $ous = Get-ADOrganizationalUnit -Filter * -SearchBase $ou

    # Afficher les OUs trouvées
    foreach ($ou in $ous) {
        Write-Output $ou.DistinguishedName

        # Appeler la fonction récursivement pour chaque sous-OU
        Get-OUsRecursively -ou $ou.DistinguishedName
    }
}

# Appeler la fonction avec l'OU de base
Get-OUsRecursively -ou $baseOU
