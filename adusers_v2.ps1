param (
    [Parameter(Mandatory=$true)]
    [string]$DomainName,
    [string]$FileCsv,
    
    [Parameter()]
    [string]$GenerateUsername = $True,
    [string]$GenerateEmail = $True
)

Import-Module ActiveDirectory
Import-Module "$PSScriptRoot\PSmodules\AD.psm1"
Import-Module "$PSScriptRoot\PSmodules\characters.psm1"
Import-Module "$PSScriptRoot\PSmodules\utils.psm1"

$ADUsers = Import-csv $FileCsv -Delimiter ";" -Encoding UTF8

foreach ($User in $ADUsers) {
    $Username = $User.username
    $Password = $User.password
    $Firstname = $User.firstname
    $Lastname = $User.lastname
    $Email = $User.email
    $OU = Get-ADOrganizationalUnit -Filter "Name -like '$($User.ou)'"

    if ($GenerateUsername) {
        $Username = Set-Username -Firstname $User.firstname -Lastname $User.lastname
    }

    if ($GenerateEmail) {
        $Email = Set-Email -Username $Username -DomainName $DomainName
    } else {
        if (-not $Email) {
            $Email = ""
        }
    }
    

    try {
        Get-CheckVariable $DomainName
        Get-CheckVariable $OU
        Get-CheckVariable $Username
        Get-CheckVariable $Firstname
        Get-CheckVariable $Lastname
        Get-CheckVariable $Password

        New-AdUsers `
            -DomainName $DomainName `
            -OU $OU `
            -Username $Username `
            -Firstname $Firstname `
            -Lastname $Lastname `
            -Password $Password `
            -Email $Email
    }
    catch {
        Write-Host $($_.Exception.Message) -ForegroundColor DarkYellow
    }
}