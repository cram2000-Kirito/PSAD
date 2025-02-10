#Entrez un chemin d’acces vers votre fichier d’importation CSV
Import-Module ActiveDirectory
$ADUsers = Import-csv users.csv -Delimiter ";" -Encoding UTF8

$DomainName = "ad.lab"

#fonction pour retirer les caractere speciaux
function Remove-StringSpecialCharacters{
     param ([string]$String)
          $String = $String -replace 'é', 'e' `
              -replace 'è', 'e' `
              -replace 'ç', 'c' `
              -replace 'ë', 'e' `
              -replace 'à', 'a' `
              -replace 'ö', 'o' `
              -replace 'ô', 'o' `
              -replace 'ü', 'u' `
              -replace 'ù', 'u' `
              -replace 'ï', 'i' `
              -replace 'î', 'i' `
              -replace 'â', 'a' `
              -replace 'ê', 'e' `
              -replace 'û', 'u' `
              -replace '-', '' `
              -replace ' ', '.' `
              -replace '/', '' `
              -replace '\*', '' `
              -replace "'", ""
          [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($String))
}

foreach ($User in $ADUsers){
     $Username = $User.username
     $Password = $User.password
     $Firstname = $User.firstname
     $Lastname = $User.lastname
     $OU = Get-ADOrganizationalUnit -Filter 'Name -like $User.ou'

     #Creation de l'username de connection 
     $Username = "$Firstname.$Lastname"
     $Username = Remove-StringSpecialCharacters -string $Username
     $Username = $Username.Substring(0, [System.Math]::Min(20, $Username.Length)) #Max 20 caractere pour SamAccountName

     write-output $OU

     #Verifiez si le compte utilisateur existe dejà dans AD
     if (Get-ADUser -F {SamAccountName -eq $Username}){
          #Si l’utilisateur existe, editez un message d’avertissement
          Write-Warning "A user account $Username has already exist in Active Directory."
     }
     else{
          #Si un utilisateur n’existe pas, creez un nouveau compte utilisateur
          #Le compte sera cree dans l’unite d’organisation indiquee dans la variable $OU du fichier CSV ; n’oubliez pas de changer le nom de domaine dans la variable « -UserPrincipalName ».
          New-ADUser `
               -SamAccountName $Username `
               -UserPrincipalName "$Username@$DomainName" `
               -Name "$Firstname $Lastname" `
               -GivenName $Firstname `
               -Surname $Lastname `
               -Enabled $True `
               -ChangePasswordAtLogon $True `
               -DisplayName "$Lastname, $Firstname" `
               -Path $OU `
               -AccountPassword (convertto-securestring $Password -AsPlainText -Force)
     }
}
