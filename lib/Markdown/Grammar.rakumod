use v6.d;

constant $mdTicks = '```';

constant $mdItemListMarker = '-';

grammar Markdown::Grammar {

    rule TOP { <md-block>+ }
    rule md-block {
        || <md-header5>
        || <md-header4>
        || <md-header3>
        || <md-header2>
        || <md-header1>
        || <md-horizontal-line>
        || <md-code-block>
        || <md-empty-line>
        || <md-item-list-block>
        || <md-text-block>
    }

    regex md-code-block {
        $<header>=(
        $mdTicks '{'? \h* $<lang>=(\w*)
        [ \h+ $<name>=(<alpha>+) ]?
        [ \h* ',' \h* $<params>=(<md-list-of-params>) ]? \h* '}'? \h* \v )
        $<code>=[<!before $mdTicks> .]*
        $mdTicks
    }

    regex md-header1 { '#' \h* $<head>=(\V*) \n }
    regex md-header2 { '##' \h* $<head>=(\V*) \n }
    regex md-header3 { '###' \h* $<head>=(\V*) \n }
    regex md-header4 { '####' \h* $<head>=(\V*) \n }
    regex md-header5 { '#####' \h* $<head>=(\V*) \n }

    regex md-horizontal-line { '---' ['-']* \n }

    regex md-simple-link { '[' <md-link-name> ']' \h* '(' <md-link-url> ')' }
    regex md-link-name { <-[\[\]]>* }
    regex md-link-url { <-[()]>* }

    regex md-word { (\S+) <!{ $0 ~~ self.md-simple-link }> }
    regex md-empty-line { \h* \n+ }

    regex md-text-element { <md-simple-link> || <md-word> }
    regex md-text-line { \h* $<first>=(<md-text-element>) \h*? [$<rest>=([<md-text-element>+ % \h+ ])]? \n <!{ $<first>.Str eq $mdTicks }> }
    regex md-text-block { <md-text-line>+ }

    regex md-item-list-block { <md-item-list-element>+ }
    regex md-item-list-element { $<indent>=(\h*) $mdItemListMarker \h+ <content=.md-text-line> }

    regex md-numbered-list-block { <md-numbered-list-element>+ }
}