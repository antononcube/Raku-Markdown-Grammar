use v6.d;

constant $mdTicks = '```';

grammar Markdown::Grammar {

    rule TOP { <markdown-block>+ }
    rule markdown-block {
        || <header5>
        || <header4>
        || <header3>
        || <header2>
        || <header1>
        || <horizontal-line>
        || <code-block>
        || <text-line>
    }
    #regex code-block { '```' \V* \n [ .* ] \n '```' \h* \n }
    regex code-block {
        $<header>=($mdTicks \V*) \n
        $<code>=[<!before $mdTicks> .]*
        $mdTicks
    }
    regex header1 { '#' $<head>=(\V*) \n }
    regex header2 { '##' $<head>=(\V*) \n }
    regex header3 { '###' $<head>=(\V*) \n }
    regex header4 { '####' $<head>=(\V*) \n }
    regex header5 { '#####' $<head>=(\V*) \n }
    regex horizontal-line { '---' ['-']* \n }
    regex simple-link { '[' <link-name> ']' \h* '(' <link-url> ')' }
    regex link-name { <-[\[\]]>* }
    regex link-url { <-[()]>* }
    regex text-line { <simple-link> <text2=.text>? || <text1=.text>? <simple-link>? <text2=.text>? \n }
    regex text { [\V]* }
}