﻿function New-RegEx
{
    <#
    .Synopsis
        Creates a regular expression
    .Description
        Helps to simplifify creating regular expressions
    .Link
        Use-RegEx
    .Example
        New-RegEx -CharacterClass Any -Repeat
    .Example
        New-RegEx -CharacterClass Digit -Repeat -Name Digits
    .Example
        # A regular expression for a quoted string (with \" and `" as valid escape sequences)
        New-RegEx -Pattern '"' |
                New-RegEx -CharacterClass Any -Repeat -Lazy -Before (
                    New-RegEx -Pattern '"' -NotAfter '\\|`'
                ) |
                New-RegEx -Pattern '"'
    .Example
        # A regular expression for an email address.

        New-RegEx -Description "Matches an Email Address" |
            New-RegEx -Name UserName -Pattern (
                New-RegEx -CharacterClass Word -Comment "Match the username, which starts with a word character" |
                    New-RegEx -CharacterClass Word -LiteralCharacter '-.' -Min 0 -Comment "and can contain any number of word characters, dashes, or dots"
            ) |
            New-RegEx -LiteralCharacter '@' -Comment "Followed by an @"|
            New-RegEx -Name Domain -Pattern (
                New-RegEx -CharacterClass Word  -Comment "The domain starts with a word character" |
                    New-RegEx -CharacterClass Word -LiteralCharacter '-' -Min 0 -Comment "and can contain any words with dashes," |
                    New-RegEx -NoCapture -Pattern (
                        New-RegEx -LiteralCharacter '.' -Comment "followed by at least one suffix (which starts with a dot),"|
                            New-RegEx -CharacterClass Word -Comment "followed by a word character," |
                            New-RegEx -CharacterClass Word -LiteralCharacter '-' -Min 0 -Comment "followed by any word characters or dashes"
                    ) -Min 1
            )
    .Example
        # Writes a pattern for multiline comments
        New-RegEx -Pattern \<\# |
            New-RegEx -Name Block -Until \#\> |
            New-RegEx -Pattern \#\>
    #>
    [OutputType([Regex], [PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSPossibleIncorrectComparisonWithNull", "", Justification="This is explicitly checking for null (lazy -If would miss 0)")]
    param(
    # One or more regular expressions.
    [Parameter(Position=0)]
    [Alias('Expression')]
    [string[]]
    $Pattern,

    # If provided, will name the capture
    [Alias('CaptureName')]
    [string]
    $Name,

    # One or more character classes.
    [Alias('CC','CharacterClasses')]
    [ValidateSet(
        'Any', '.',
        'Word', '\w',
        'NonWord', '\W',
        'Whitespace', '\s',
        'NonWhitespace', '\S',
        'Digit', '\d',
        'NonDigit', '\D',
        'Escape', '\e',
        'Tab', '\t',
        'CarriageReturn', '\r',
        'NewLine', '\n',
        'VerticalTab', '\v',
        'FormFeed', '\f',
        'UpperCaseLetter', '\p{Lu}',
        'LowerCaseLetter', '\p{Ll}',
        'TitleCaseLetter', '\p{Lt}',
        'ModifierLetter' , '\p{Lm}',
        'OtherLetter' , '\p{Lo}',
        'Letter' , '\p{L}',
        'NonSpacingMark' ,'\p{Mn}',
        'CombiningMark' ,'\p{Mc}',
        'EnclosingMark' , '\p{Me}',
        'Mark' , '\p{M}',
        'Number' , '\p{N}',
        'NumberDecimalDigit' , '\p{Nd}',
        'NumberLetter' , '\p{Nl}',
        'NumberOther' , '\p{No}',
        'PunctuationConnector' , '\p{Pc}',
        'PunctuationDash' , '\p{Pd}',
        'PunctuationOpen' , '\p{Ps}',
        'PunctuationClose' , '\p{Pe}',
        'PunctuationInitialQuote' , '\p{Pi}',
        'PunctuationFinalQuote' , '\p{Pf}',
        'PunctuationOther' , '\p{Po}',
        'Punctuation' , '\p{P}',
        'SymbolMath' ,'\p{Sm}',
        'SymbolCurrency' ,'\p{Sc}',
        'SymbolModifier' ,'\p{Sk}',
        'SymbolOther' ,'\p{So}',
        'Symbol' , '\p{S}',
        'SeparatorSpace' ,'\p{Zs}',
        'SeparatorLine' , '\p{Zl}',
        'SeparatorParagraph' , '\p{Zp}',
        'Separator' , '\p{Z}',
        'Control' , '\p{C}',
        'NonUpperCaseLetter', '\P{Lu}',
        'NonLowerCaseLetter', '\P{Ll}',
        'NonTitleCaseLetter', '\P{Lt}',
        'NonModifierLetter' , '\P{Lm}',
        'NonOtherLetter' , '\P{Lo}',
        'NonLetter' , '\P{L}',
        'NonNonSpacingMark' ,'\P{Mn}',
        'NonCombiningMark' ,'\P{Mc}',
        'NonEnclosingMark' , '\P{Me}',
        'NonMark' , '\P{M}',
        'NonNumber' , '\P{N}',
        'NonNumberDecimalDigit' , '\P{Nd}',
        'NonNumberLetter' , '\P{Nl}',
        'NonNumberOther' , '\P{No}',
        'NonPunctuationConnector' , '\P{Pc}',
        'NonPunctationDash' , '\P{Pd}',
        'NonPunctationOpen' , '\P{Ps}',
        'NonPunctationClose' , '\P{Pe}',
        'NonPunctationInitialQuote' , '\P{Pi}',
        'NonPunctationFinalQuote' , '\P{Pf}',
        'NonPunctuationOther' , '\P{Po}',
        'NonPunctuation' , '\P{P}',
        'NonSymbolMath' ,'\P{Sm}',
        'NonSymbolCurrency' ,'\P{Sc}',
        'NonSymbolModifier' ,'\P{Sk}',
        'NonSymbolOther' ,'\P{So}',
        'NonSymbol' , '\P{S}',
        'NonSeparatorSpace' ,'\P{Zs}',
        'NonSeparatorLine' , '\P{Zl}',
        'NonSeparatorParagraph' , '\P{Zp}',
        'NonSeparator' , '\P{Z}',
        'NonControl' , '\P{C}'
    )]
    [string[]]
    $CharacterClass,    

    # If provided, will match any number of specific literal characters.
    [Alias('LC','LiteralCharacters')]
    [string[]]
    $LiteralCharacter,

    # If provided, will match any number of unicode characters.
    # Note:  Unless the RegEx is case-sensitive, this will match both uppercase and lowercase.
    # To make a RegEx explicitly case-sensitive, use New-RegEx -Modifier IgnoreCase -Not
    [Alias('UC', 'UnicodeCharacters')]
    [int[]]
    $UnicodeCharacter,
    
    # When provided with -CharacterClass, -LiteralCharacter, or -UnicodeCharacter, will subtract one set of characters from the other.
    # Otherwise, will match any character classes that are not excluded.
    [Alias('XCC','ExcludeCC','ExcludeCharacterClasses','NotCharacterClass')]
    [ValidateSet(
        'Any', '.',
        'Word', '\w',
        'NonWord', '\W',
        'Whitespace', '\s',
        'NonWhitespace', '\S',
        'Digit', '\d',
        'NonDigit', '\D',
        'Escape', '\e',
        'Tab', '\t',
        'CarriageReturn', '\r',
        'NewLine', '\n',
        'VerticalTab', '\v',
        'FormFeed', '\f',
        'UpperCaseLetter', '\p{Lu}',
        'LowerCaseLetter', '\p{Ll}',
        'TitleCaseLetter', '\p{Lt}',
        'ModifierLetter' , '\p{Lm}',
        'OtherLetter' , '\p{Lo}',
        'Letter' , '\p{L}',
        'NonSpacingMark' ,'\p{Mn}',
        'CombiningMark' ,'\p{Mc}',
        'EnclosingMark' , '\p{Me}',
        'Mark' , '\p{M}',
        'Number' , '\p{N}',
        'NumberDecimalDigit' , '\p{Nd}',
        'NumberLetter' , '\p{Nl}',
        'NumberOther' , '\p{No}',
        'PunctuationConnector' , '\p{Pc}',
        'PunctuationDash' , '\p{Pd}',
        'PunctuationOpen' , '\p{Ps}',
        'PunctuationClose' , '\p{Pe}',
        'PunctuationInitialQuote' , '\p{Pi}',
        'PunctuationFinalQuote' , '\p{Pf}',
        'PunctuationOther' , '\p{Po}',
        'Punctuation' , '\p{P}',
        'SymbolMath' ,'\p{Sm}',
        'SymbolCurrency' ,'\p{Sc}',
        'SymbolModifier' ,'\p{Sk}',
        'SymbolOther' ,'\p{So}',
        'Symbol' , '\p{S}',
        'SeparatorSpace' ,'\p{Zs}',
        'SeparatorLine' , '\p{Zl}',
        'SeparatorParagraph' , '\p{Zp}',
        'Separator' , '\p{Z}',
        'Control' , '\p{C}',
        'NonUpperCaseLetter', '\P{Lu}',
        'NonLowerCaseLetter', '\P{Ll}',
        'NonTitleCaseLetter', '\P{Lt}',
        'NonModifierLetter' , '\P{Lm}',
        'NonOtherLetter' , '\P{Lo}',
        'NonLetter' , '\P{L}',
        'NonNonSpacingMark' ,'\P{Mn}',
        'NonCombiningMark' ,'\P{Mc}',
        'NonEnclosingMark' , '\P{Me}',
        'NonMark' , '\P{M}',
        'NonNumber' , '\P{N}',
        'NonNumberDecimalDigit' , '\P{Nd}',
        'NonNumberLetter' , '\P{Nl}',
        'NonNumberOther' , '\P{No}',
        'NonPunctuationConnector' , '\P{Pc}',
        'NonPunctationDash' , '\P{Pd}',
        'NonPunctationOpen' , '\P{Ps}',
        'NonPunctationClose' , '\P{Pe}',
        'NonPunctationInitialQuote' , '\P{Pi}',
        'NonPunctationFinalQuote' , '\P{Pf}',
        'NonPunctuationOther' , '\P{Po}',
        'NonPunctuation' , '\P{P}',
        'NonSymbolMath' ,'\P{Sm}',
        'NonSymbolCurrency' ,'\P{Sc}',
        'NonSymbolModifier' ,'\P{Sk}',
        'NonSymbolOther' ,'\P{So}',
        'NonSymbol' , '\P{S}',
        'NonSeparatorSpace' ,'\P{Zs}',
        'NonSeparatorLine' , '\P{Zl}',
        'NonSeparatorParagraph' , '\P{Zp}',
        'NonSeparator' , '\P{Z}',
        'NonControl' , '\P{C}'
    )]
    [string[]]
    $ExcludeCharacterClass,

    # When provided with -CharacterClass, -LiteralCharacter, or -UnicodeCharacter, will subtract one set of characters from the other.
    # Otherwise, will match any characters that are not one of the provided literal characters.
    [Alias('XLC','ExcludeLC','ExcludeLiteralCharacters','NotLiteralCharacter')]
    [string[]]
    $ExcludeLiteralCharacter,

    # When provided with -CharacterClass, -LiteralCharacter, or -UnicodeCharacter, will subtract one set of characters from the other.
    # Otherwise, will match any characters that are not one of the provided unicode characters.
    # Note:  Unless the RegEx is case-sensitive, this will match both uppercase and lowercase.
    # To make a RegEx explicitly case-sensitive, use New-RegEx -Modifier IgnoreCase -Not
    [Alias('XUC', 'ExcludeUC', 'ExcludeUnicodeCharacters','NotUnicodeCharacter')]
    [int[]]
    $ExcludeUnicodeCharacter,

    # If provided, will match digits up to a value.
    [uint32]
    $DigitMax,

    # The name or number of a backreference (a reference to a previous capture)
    [string]$Backreference,

    # A negative lookbehind (?<!). This pattern that must not match after the current position..
    [Alias('NegativeLookBehind')]
    [string]
    $NotAfter,

    # A negative lookahead (?!). This pattern must not match before the current position.
    [Alias('NegativeLookAhead')]
    [string]
    $NotBefore,

    # A positive lookbehind (?<=). This pattern that must match after the current position.
    [Alias('LookBehind')]
    [string]
    $After,

    # A positive lookahead (?=). This pattern that must match before the current position.
    [Alias('LookAhead')]
    [string]
    $Before,

    # If set, will match repeated occurances of a character class or pattern
    [Alias('Repeating')]
    [switch]
    $Repeat,

    # If set, repeated occurances will be matched greedily.
    # A greedy match is the last possible match that completes a condition.
    # For example when you run "abcabc" -match 'a.*c' (a greedy match)
    # $matches will be abcabc
    [switch]
    $Greedy,

    # If set, repeated occurances will be matched lazily.
    # A lazy match is the first possible match that completes a conidition.
    # For example, when you run "abcabc" -match 'a.*?c' (a lazy match)
    # $matches will be abc
    [switch]
    $Lazy,

    # The minimum number of repetitions.
    [Alias('AtLeast')]
    [int]$Min,

    # The maximum number of repetitions.
    [Alias('AtMost')]
    [int]$Max,

    # If provided, inserts a Regular Expression conditional.
    [Alias('IfExpression')]
    [string]$If,

    # If the pattern provided in -If is true, it will attempt to continue to match with the pattern provided in -Then
    [Alias('ThenExpression')]
    [string[]]$Then,

    # If the pattern provided in -If if false, it will attempt to continue to match the with the pattern provided in -Else.
    [Alias('ElseExpression')]
    [string[]]$Else,

    # If provided, will match all content until any of these conditions or the end of the string are found.
    [string[]]$Until,

    # A comment (yes, they exist in Regular Expressions)
    [string]$Comment,

    # A description.  This will be added to the top of the expression as a comment.
    [string]$Description,

    # If set and -CharacterClass is provided, will match anything but the provided set of character classes.
    # If set and -Expression is provided, will match anything that does not contain the expression
    # If set and neither -Expression or -CharacterClass is provided, will do an empty lookbehind (this will always fail)
    # If set and -Modifier is provided, will negate the modifier.
    [switch]
    $Not,

    # If set, will match any of a number of character classes, or any number of patterns.
    [switch]
    $Or,

    # The start anchor.
    [ValidateSet(
        'Boundary', '\b',
        'NotBoundary', '\B',
        'LineStart', '^',
        'LineEnd', '$',
        'StringStart', '\A',
        'StringEnd', '\z',
        'LastLineEnd', '\Z'
    )]
    [string]
    $StartAnchor,

    # The end anchor.
    [ValidateSet(
        'Boundary', '\b',
        'NotBoundary', '\B',
        'LineStart', '^',
        'LineEnd', '$',
        'StringStart', '\A',
        'StringEnd', '\z',
        'LastLineEnd', '\Z'
    )]
    [string]
    $EndAnchor,

    # Regular expression modifiers.  These affect the way the expression is interpreted.
    # Modifiers can be turned off by passing -Modifier and -Not.
    # If -NoCapture is provided, modifiers will only apply to the current group.
    [ValidateSet(
        'Multiline','m',
        'Singleline', 's',
        'IgnoreCase', 'i',
        'IgnorePatternWhitespace', 'x',
        'ExplicitCapture', 'n'
    )]
    [Alias('Mode')]
    [string[]]
    $Modifier,

    # If set, will make the pattern optional
    [switch]
    $Optional,

    # If set, will make the pattern atomic.  This will allow one and only one match.
    [switch]
    $Atomic,

    # # If set, will make the pattern non-capturing.  This will omit the group from the resulting match.
    [Alias('NonCapturing','NoCap')]
    [switch]
    $NoCapture,

    # A regular expression that occurs before the generated regular expression.
    [Parameter(ValueFromPipeline)]
    [Alias('PreExpression')]
    [string[]]
    $PrePattern,

    # The timeout of the regular expression.  By default, 5 seconds.
    [TimeSpan]
    $TimeOut = '00:00:05',

    # If provided, will match between a given string or pair of strings.
    [string[]]
    $Between,

    # The escape sequence used with -Between.  By default, a slash.
    [string]
    $EscapeSequence = '\\',

    # If set, comments in the regular expression will not be normalized.
    # By default, all comments that do not start on the beginning are normalized to start at the same column.
    [switch]
    $Denormalized,

    # Named parameters.  These are only valid if the regex is using a Generator script.
    [Alias('Parameters')]
    [Collections.IDictionary]
    $Parameter = @{},

    # A list of arguments.  These are only valid if the regex is using a Generator script.
    [Alias('Arguments','Args')]
    [PSObject[]]$ArgumentList = @()
    )

    begin {
        $ccLookup = @{}

        foreach ($paramName in 'CharacterClass', 'StartAnchor', 'EndAnchor', 'Modifier') {
            $vvl =
                foreach ($attr in $MyInvocation.MyCommand.Parameters[$paramName].Attributes) {
                   if (-not $attr.ValidValues) { continue }
                   $attr.ValidValues
                   break
                }

            for ($i = 0; $i -lt $vvl.Count; $i+= 2) {
                $ccLookup[$vvl[$i]] = $vvl[$i + 1]
                $ccLookup[$vvl[$i + 1]] = $vvl[$i + 1]
            }
        }

        $SavedCaptureReferences = [Regex]::new(@'
(\(\?\<(?<NewCaptureName>\w+)\>)?
(?<!\()                   # Not preceeded by a (
\?\<(?<CaptureName>\w+)\> # ?<CaptureName>
(?<HasArguments>
    (?:
        \((?<Arguments>     # An open parenthesis
        (?>                 # Followed by...
            [^\(\)]+|       # any number of non-parenthesis character OR
            \((?<Depth>)|   # an open parenthesis (in which case increment depth) OR
            \)(?<-Depth>)   # a closed parenthesis (in which case decrement depth)
        )*(?(Depth)(?!))    # until depth is 0.
        )\)                  # followed by a closing parenthesis
    )|
    (?:
        \{(?<Arguments>     # An open bracket
        (?>                 # Followed by...
            [^\{\}]+|       # any number of non-bracket character OR
            \{(?<Depth>)|   # an open bracket (in which case increment depth) OR
            \}(?<-Depth>)   # a closed bracket (in which case decrement depth)
        )*(?(Depth)(?!))    # until depth is 0.
        )\}             # followed by a closing bracket
    )
)?
'@, 'IgnoreCase, IgnorePatternWhitespace', '00:00:01')


        $replaceSavedCapture = {
            $m = $args[0]
            $startsWithCapture = '(?<StartsWithCapture>\A\(\?\<(?<FirstCaptureName>\w+))>'
            $regex = $script:_RegexLibrary.($m.Groups["CaptureName"].ToString())
            if (-not $regex) { return $m }
            $regex =
                if ($regex -isnot [Regex]) {
                    if ($m.Groups["Arguments"].Success) {
                        $args = @($m.Groups["Arguments"].ToString() -split '(?<!\\),')
                        & $regex @args
                    } else {
                        & $regex
                    }
                } else {
                    $regex
                }
            if ($m.Groups["NewCaptureName"].Success) {
                if ($regex -match $startsWithCapture -and
                    $matches.FirstCaptureName -ne $m.Groups['NewCaptureName']) {
                    $repl= $regex -replace $startsWithCapture, "(?<$($m.Groups['NewCaptureName'])>"
                    $repl.Substring(0, $repl.Length - 1) + [Environment]::NewLine
                }
            } else {
                "$regex" + [Environment]::NewLine
            }
        }


        $startsWithCapture = [Regex]::new(
            '(?<StartsWithCapture>\A\(\?\<(?<FirstCaptureName>\w+))>',
            'IgnoreCase,IgnorePatternWhitespace', '00:00:01')
    }
    process {
        $myParams = @{} + $PSBoundParameters
        #region Generate RegEx
        $regex = . {

            $theOC = 0

            if ($PrePattern) { # If we've been provided a pre-expression, this goes first.
                $prePattern -join ''
            }
            if ($Description) {
                if ($prePattern -and -not $prePattern[-1].EndsWith([Environment]::NewLine)) {
                    [Environment]::NewLine
                }
                @(foreach ($l in $Description -split ([Environment]::NewLine)) {
                    "# $($l.TrimStart('#'))"
                }) -join ([Environment]::NewLine)
                [Environment]::NewLine
            }

            if ($Between) {
                if ($between.Length -gt 2) {
                    Write-Error 'Can pass only one or two -Between'
                    return
                }
                $firstBetween, $secondBetween = $between
                $escapePattern =
                    if ($EscapeSequence) {
                        if ($EscapeSequence -ne ($firstBetween * 2)) {
                            "(?<!$escapeSequence)"
                        } else {
                            ''
                        }

                    } else { '' }

                "(?:" + $escapePattern + $firstBetween

                if (-not $pattern) {
                    if (-not $secondBetween) {
                        $secondBetween = $firstBetween
                    }
                    if ($escapeSequence -ne ($firstBetween * 2)) {
                        $pattern = "(?:.|\s)*?(?=\z|${escapePattern}${secondBetween})"
                    } else {
                        $pattern = "(?:$escapeSequence|[^$firstBetween])*(?=\z|$secondBetween)"
                    }
                }
                $theOC++
            }

            if ($Modifier) {
                $modifiers =
                    @(
                        if ($not) { '-' }
                        foreach ($m in $Modifier) {
                            $ccLookup[$m]
                        }
                    ) -join ''
            }

            if ($Atomic) {
                $theOC++
                "(?>" + [Environment]::NewLine + (' ' * $theOc * 2)
            }

            if ($NoCapture) {
                if ($modifiers) {
                    "(?${modifiers}:"
                } else {
                    '(?:'
                }
                $theOC++
            } elseif ($modifiers) {
                "(?$modifiers)"
            }

            if ($Name) { # If the capture has a name, add it.
                "(?<$Name>"; $theOC++
            }

            if ($StartAnchor) { # Then add start anchors
                $ccLookup[$startAnchor]
            }

            if ($NotAfter) { # Then put negative lookbehind
                "(?<!$NotAfter)"
            }

            if ($After) { # and positive lookbehind.
                "(?<=$after)"
            }

            if ($Backreference) { # Then add backrefencees
                if ($backreference -as [int] -ne $null) {
                    "\$($backreference -as [int])"
                } else {
                    "\k<$backreference>"
                }
            }

            if ($DigitMax) {
                # Matching number ranges is annoying.
                # In order to do so, we need to match specific strings up to a given point.

                $digitMaxStr = "$DigitMax"
                $digitCount = $DigitMaxStr.Length
                $numberRangePattern = @(
                    $firstDigitStr = $digitMaxStr.Substring(0,1)
                    $firstDigitInt = $firstDigitStr -as [int]
                    # It can be the maximum value at that digit, e.g 2[0-5][0-5]

                    @(
                        "[0-$($firstDigitInt)]"
                        for ($di2 = 1; $di2 -lt $digitCount; $di2++) {
                            $intD = $digitMaxStr.Substring($di2,1) -as [int]
                            if ($intD) {
                                "[0-$intD]"
                            } else {
                                '\d'
                            }
                        }
                    ) -join ''

                    # or the range of values beneath that digit, e.g [0-1]\d\d
                    if ($firstDigitInit - 1) {
                        @(
                            "[0-$($firstDigitInt - 1)]"
                            for ($di2 = 1; $di2 -lt $digitCount; $di2++) {'\d' }
                        ) -join ''
                    }


                    $remainingDigits = $digitCount - 1
                    if ($remainingDigits -ge 1) {
                        "\d{1,$remainingDigits}"
                    }

                ) -join '|'

                $pattern += "(?>$numberRangePattern)"
            }

            if ($Pattern) {
                $Pattern =
                    foreach ($expr in $Pattern) { # Now handle any expressions they passed in.
                        $SavedCaptureReferences.Replace($expr, $replaceSavedCapture)
                    }

                if ($Or -and $Pattern.Length -gt 1) { # (join multiples with | if -Of is passed)
                    $joinWith = (' ' * $theOc * 2) + '|' + [Environment]::NewLine + (' ' * $theOc * 2)
                    if ($atomic) {
                        $pattern -join $joinWith
                    } else {
                        "(?:$($Pattern -join $joinWith))"
                    }
                }
                elseif ($Not) { "\A((?!($($Pattern -join ''))).)*\Z" } # (create an antipattern if -Not is passed)
                elseif ($pattern.Length -gt 1 -and # If more than one pattern was passed
                    ($repeat -or $greedy -or $lazy -or $optional -or ($min -ge 0))) { # and we're interested in repetitions
                    "(?:$($pattern))" # put the pattern in a non-capturing group[
                }
                else { $Pattern }
            }

            if ($until) {
                if ($until -notlike '\z*') {
                    $until = @("\z") + $until
                }
                "(?:.|\s){0,}?(?=$($until -join '|'))"
            }

            # If we're passed in a character class, literal character, or UnicodeCharacter (or any to exclude)
            if ($CharacterClass -or $LiteralCharacter -or $UnicodeCharacter -or 
                $ExcludeCharacterClass -or $ExcludeLiteralCharacter -or $ExcludeUnicodeCharacter) {
                $cout =
                    @(foreach ($cc in $CharacterClass) { # find them in the lookup table.
                        $ccLookup[$cc]
                    })

                $notCout =
                    @(foreach ($notcc in $ExcludeCharacterClass) {
                        $ccLookup[$notcc]
                    })

                $lc = @($literalCharacter -replace '[\p{P}\p{S}-[_]]', '\$0')
                $notLC = @($ExcludeliteralCharacter -replace '[\p{P}\p{S}]', '\$0')
                
                $charSet = @(
                    $cout +
                    $lc +
                    @(
                    foreach ($uc in $unicodeCharacter) {
                        "\u{0:x4}" -f $uc
                    })
                ) -ne ''

                $notCharSet = @(
                    $Notcout +
                    $Notlc +
                    @(
                    foreach ($notuc in $ExcludeUnicodeCharacter) {
                        "\u{0:x4}" -f $notuc
                    })
                )

                
                $charSubtract = 
                    if ($notCharSet -and $charSet) {
                        "-[$($notCharSet -join '')]"
                    } elseif ($notCharSet) {
                        ''
                        $charSet = @('^') + $notCharSet
                    } else {
                        ''
                    }

                if ($not) # If -Not was passed
                {
                    "[^$($charSet -join '')$charSubtract]" # it can be any character that is not in any of the character classes.
                }
                # If we have more than one character class
                elseif ($charSubtract -or $charSet.Length -gt 1 -or ($literalCharacter -and $literalCharacter[0].Length -gt 1))
                {
                    "[$($charSet -join '')$charSubtract]" # It can be any of the character classes
                }
                else # Unless there was only one character class (in this case, put it inline)
                {
                    $charSet
                }
            }

            if ($If -and $Then) { # If they passed us a coniditional, embed it
                if ($Else) {
                    "(?($if)($($then -join ''))|($($else -join '')))"
                } else {
                    "(?($if)($($then -join '')))"
                }
            }

            if ($Greedy) { # If the regex was "Greedy", pass the greedy quantifier (*)
                '*'
            }

            if ($Repeat) { # If the regex was Repeated, pass the one or more quantifier (+)
                '+'
            }

            if ($myParams.ContainsKey('Min') -and -not $theOc) { # If the regex has a minimum,
                "{$min,$(if($max) { $max})}"    # pass the repeitions range quantifier ({min,[max]})
            }

            if ($Optional -and -not $theOc) {
                '?'
            }

            if ($Lazy) {
                '?'
            }

            if ($NotBefore) { # If we've got a negative lookahead
                "(?!$notbefore)" # add it.
            }

            if ($Before) {   # If we've got a positive lookahead
                "(?=$before)"    # add it
            }

            if ($not -and # If we're passed -Not,
                -not ($CharacterClass -or
                    $Pattern -or
                    $modifier -or
                    $LiteralCharacter
                )) { # but not passed -CharacterClass or -Pattern or -Modifier or -LiteralCharacter
                '(?!)' # emit an empty lookahead (this will always fail)
            }

            if ($EndAnchor) {
                $cclookup[$endanchor]
            }

            if ($between) {
                $firstBetween, $secondBetween = $between
                if (-not $secondBetween) { $secondBetween = $firstBetween }
                ")${escapePattern}${secondBetween}"
                $theOc--
            }

            $hadToBeClosed = $false
            for($n=0; $n -lt $theOc; $n++) {
                ')'; $hadToBeClosed =$true
            }

            if ($HadToBeCLosed -and $myParams.ContainsKey('Min') ) { # If the regex has a minimum,
                "{$min,$(if($max) { $max})}"    # pass the repeitions range quantifier ({min,[max]})
            }

            if ($hadToBeClosed -and $optional) {
                '?'
            }
        }

        $regex = $regex -join ''

        if ($comment) {
            $regex += " # $($comment -replace '\#', '')
"
        }

        if (-not $Denormalized) {
            $regexLines = $regex -split '(?>\r\n|\n)'
            $findComment = [Regex]::new('(?<!\\)\#')
            $commentIndeces =
                foreach ($l in $regexLines) {
                    $matched = @($findComment.Matches($l))
                    if ($matched) {                        
                        if ($matched[0].Index -gt 0) {
                            $matched[0].Index
                        }
                    }
                }

            foreach ($ci in $commentIndeces) {
                if ($ci -gt $max) {$max  = $ci }
            }

            $regex =
                @(foreach ($l in $regexLines) {
                    $matched = @($findComment.Matches($l))
                    if ($matched) {
                        $commentIndex = $matched[0].Index                        
                        if ($commentIndex -eq 0) {
                            # Not important for normalization
                            $l
                        } else {
                            # As long as the comment is not escaped
                            $l.Substring(0, $commentIndex) + $(
                                ' ' * ($max - $commentIndex)
                            ) + $l.Substring($commentIndex)
                        }
                    } else {
                        $l
                    }
                }) -join [Environment]::NewLine



        }

        #endregion Generate RegEx

        $regOut =
            try {
                [psobject]::new([Regex]::new($regex, 'IgnoreCase,IgnorePatternWhitespace', '00:00:05'))
            } catch {
                $_
            }
        if (-not $regOut) { return }
        if ($regOut -is [Management.Automation.ErrorRecord]) {
            $o = [PSCustomObject]@{Pattern=$regex;PSTypeName='Irregular.Regular.Expression'}
            $o | Add-Member ScriptMethod ToString { return $this.Pattern } -PassThru -Force
        } else {
            $regOut.pstypenames.add('Irregular.Regular.Expression')
            $regOut
        }
    }
}