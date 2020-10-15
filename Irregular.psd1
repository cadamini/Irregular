@{
    ModuleVersion = '0.5.2'
    RootModule = 'Irregular.psm1'
    Description = 'Regular Expressions made Strangely Simple'
    FormatsToProcess = 'Irregular.format.ps1xml'
    TypesToProcess = 'Irregular.types.ps1xml'
    Guid = '39eb966d-7437-4e2c-abae-a496e933fb23'
    Author = 'James Brundage'
    Copyright = '2019 Start-Automating'
    PrivateData = @{
        PSData = @{
            Tags = 'RegularExpressions', 'RegEx', 'Irregular', 'PatternMatching'
            ProjectURI = 'https://github.com/StartAutomating/Irregular'
            LicenseURI = 'https://github.com/StartAutomating/Irregular/blob/master/LICENSE'
            IconURI    = 'https://github.com/StartAutomating/Irregular/blob/master/Assets/Irregular_85x85.png'        
        }
        ReleaseNotes = @'
0.5.2
---
* Use-RegEx now matches within returns by default.
* Use-RegEx can -Scan to match after a given item
* Use-Regex breaking change:  -Parameter/-ArgumentList are now -ExpressionParameter/-ExpressionArgumentList
* Improving formatting (no longer showing match status, which was always 'true')
0.5.1
---
* Making Import-Regex support Regexes defined in other modules
* Allowing Import-Regex to import as lambdas
* Get/Export-Regex now include -As "Engine", which will export an embeddedable engine including an inline Import
* Write-Regex now supports -Modifier
* New Expressions:
** ?<HexDigits>
** ?<Git_Diff>
** ?<Git_DiffHeader>
** ?<Git_DiffRange>
** ?<Git_Log>
** ?<HTML_IDAttribute>
** ?<HTML_DataAttribute>
** ?<HTML_DataSet>
** ?<HTML_ItemScope>
'@
    }
}