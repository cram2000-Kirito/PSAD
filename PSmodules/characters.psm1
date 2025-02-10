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

Export-ModuleMember -Function Remove-StringSpecialCharacters
