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
        $<header>=(
        $mdTicks '{'? \h* $<lang>=(\w*)
        [ \h+ $<name>=(<alpha>+) ]?
        [ \h* ',' \h* $<params>=(<md-list-of-params>) ]? \h* '}'? \h* \v )
        $<code>=[<!before $mdTicks> .]*
        $mdTicks
    }
    regex header1 { '#' \h* $<head>=(\V*) \n }
    regex header2 { '##' \h* $<head>=(\V*) \n }
    regex header3 { '###' \h* $<head>=(\V*) \n }
    regex header4 { '####' \h* $<head>=(\V*) \n }
    regex header5 { '#####' \h* $<head>=(\V*) \n }
    regex horizontal-line { '---' ['-']* \n }
    regex simple-link { '[' <link-name> ']' \h* '(' <link-url> ')' }
    regex link-name { <-[\[\]]>* }
    regex link-url { <-[()]>* }
    regex md-word { \S+ }
    regex text-line { <simple-link> <text2=.text>? || <text1=.text>? <simple-link>? <text2=.text>? \n }
#    regex md-text-element { <simple-link> || <md-word> }
#    regex text-line { (<md-text-element>) <.ws>? [<md-text-element>+ % <.ws> ]? \n <!{ $0 eq $mdTicks }>}
    regex text { [\V]* }
}