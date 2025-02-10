function Get-CheckVariable {
    param (
        [string]$VariableName
    )

    # Vérifier si la variable est définie
    if (Get-Variable -Name $VariableName -ErrorAction SilentlyContinue) {
        # Vérifier si la variable a une valeur
        if ($null -ne $VariableName.Value) {
            return $VariableName
        } else {throw [System.Exception]::new($VariableName, " is null.")}
    } else {throw [System.Exception]::new($VariableName, " does not exist.")}
}

Export-ModuleMember -Function Get-CheckVariable
