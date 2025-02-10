function New-AdUsers {
    param (
        [Parameter(Mandatory=$true)]
        [string]$DomainName,
        [string]$OU,
        [string]$Username,
        [string]$Firstname,
        [string]$Lastname,
        [SecureString]$Password,

        [Parameter()]
        [string]$EnableAccount = $True,
        [string]$ChangePsswdLogon = $True,
        [string]$Email = ""
    )

    #Verifiez si le compte utilisateur existe dejà dans AD
    if (Get-ADUser -Filter {SamAccountName -eq $Username} -ErrorAction SilentlyContinue) {
        Write-Host "A user account $Username has already exist in Active Directory." -ForegroundColor DarkYellow
    }
    else{
        #Si un utilisateur n’existe pas, creez un nouveau compte utilisateur
        #Le compte sera cree dans l’unite d’organisation indiquee dans la variable $OU du fichier CSV ; n’oubliez pas de changer le nom de domaine dans la variable « -UserPrincipalName ».
        try {
            New-ADUser `
                -SamAccountName $Username `
                -UserPrincipalName "$Username@$DomainName" `
                -Name "$Firstname $Lastname" `
                -GivenName $Firstname `
                -Surname $Lastname `
                -Enabled $EnableAccount `
                -ChangePasswordAtLogon $ChangePsswdLogon `
                -DisplayName "$Lastname, $Firstname" `
                -Path $OU `
                -EmailAddress $Email `
                -AccountPassword $Password
            Write-Host "Add user: $Username in OU: $OU"
        }
        catch [System.DirectoryServices.DirectoryServicesCOMException] {
            # Gérer les erreurs liées à Active Directory
            Write-Host "Erreur de connexion à Active Directory ou problème avec les paramètres : $($_.Exception.Message)" -ForegroundColor DarkRed
        }
        catch [System.Security.SecurityException] {
            # Gérer les erreurs de sécurité
            Write-Host "Erreur de sécurité : vous n'avez pas les autorisations nécessaires pour créer cet utilisateur." -ForegroundColor DarkRed
        }
        catch [System.ArgumentException] {
            # Gérer les erreurs d'argument
            Write-Host "Erreur d'argument : $($_.Exception.Message)" -ForegroundColor DarkYellow
        }
        catch {
            # Gérer toutes les autres erreurs
            Write-Host "Une erreur s'est produite : $($_.Exception.Message)" -ForegroundColor DarkRed
        }
    }
}


function Set-Username {
    param (
        [Parameter(Mandatory=$true)]
        [String]$Firstname,
        [String]$Lastname
    )
    try {
        $Username = "$Firstname.$Lastname"
        $Username = Remove-StringSpecialCharacters -string $Username
        $Username = $Username.Substring(0, [System.Math]::Min(20, $Username.Length)) #Max 20 caractere pour SamAccountName
    }
    catch {
        Write-Host "Une erreur s'est produite : $($_.Exception.Message)" -ForegroundColor DarkRed
        $Username = $False
    }
    return $Username
}

function Set-Email {
    param (
        [Parameter(Mandatory=$true)]
        [String]$Username,
        [String]$DomainName
    )

    try {
        $Email = "$Username@$DomainName"
        $Email = $Email.ToLower().Trim().Replace(" ", "")    
    }
    catch {
        Write-Host "Une erreur s'est produite : $($_.Exception.Message)" -ForegroundColor DarkRed
        $Email = $False
    }
    return $Email
}

function Get-OUFromDistinguishedName {
    param (
        [parameter(Mandatory=$true)]
        [string]$DistinguishedName
    )

    # Diviser le DistinguishedName en parties
    $parts = $DistinguishedName -split ','

    # Filtrer pour obtenir uniquement les parties qui commencent par "OU=" et "DC="
    $OUParts = $parts | Where-Object {$_ -like 'OU=*'}
    $DCParts = $parts | Where-Object {$_ -like 'DC=*'}

    # Joindre les parties de l'OU pour former le DistinguishedName de l'OU
    if ($OUParts) {
        $OUResult = $OUParts -join ','
        $OUResult = $DCParts -join ','
        return $OUResult
    }
}

function Get-ADObjectSameOU {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ADObjetone,
        [Parameter(Mandatory=$false)]
        [string]$ADObjets
    )
    
    if ($ADObjets) {
        throw [System.Exception]::new($ADObjets, " does not exist or null.")
    }

    $ADObjetone = Get-OUFromDistinguishedName $ADObjetone
    foreach ($ADObjet in $ADObjets) {
        if (Get-OUFromDistinguishedName $ADObjet -eq $ADObjetone) {
            $ADObjectsResult = $ADObjet -join ','
        }
    }
    return $ADObjectsResult
}

Export-ModuleMember -Function New-AdUsers, Set-Username, Set-Email, Get-OUFromDistinguishedName, Get-ADObjectSameOU