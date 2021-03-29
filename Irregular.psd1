@{
    ModuleVersion = '0.5.5'
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
0.5.5
----
* New Programming RegExes:
** ?<PowerShell_Requires>
** ?<C_Include>
** ?<C_Define>
** ?<CSharp_Using>
** ?<CSharp_Namespace>

Renaming ?<Namespace> to ?<Code_Namespace> [breaking]

?<REST_Variable>:
support for {/optionalsegments} (as seen in Git)
$ now requires backtick (URL parameters can be named $, e.g. $top)


0.5.4
----
* Fixes in Irregular import (no longer producing a module per RegEx on import)
* Fixing a subtle bug in Write-RegEx -Until (was failing to match when no characters were between)
* New regex:
** ?<HTML_LinkedData>, ?<HexColor>, ?<IPv4Address>


0.5.3
----
* Get/Export-Regex: Now supporting -As EmbeddedEngine (lambas) or -As Engine (smart aliases)
* Write-RegEx:  Added -UnicodeCharacter
* New regex:
** ?<PowerShell_Region>
** ?<Unix_Conf_Line>, ?<Unix_Conf_Section>, ?<Unix_Conf_File>, ?<Unix_Mount>, ?<Unix_FileSystemType>, ?<Unix_User>
* Updated RegEx Generators:
** ?<MultilineComment> now supports OpenSCAD (.scad)


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