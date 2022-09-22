use v6.d;

constant $mdTicks = '```';

constant $mdItemListMarker = '-';

role Markdown::Grammarish {

    rule TOP { <md-block>+ }

    regex md-block {
        || <md-header5>
        || <md-header4>
        || <md-header3>
        || <md-header2>
        || <md-header1>
        || <md-horizontal-line>
        || <md-code-block>
        || <md-code-indented-block>
        || <md-reference>
        || <md-image-complex-link>
        || <md-image-simple-link>
        || <md-empty-line>
        || <md-item-list-block>
        || <md-numbered-list-block>
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

    regex md-code-indented-block {
        [\h* \n]
        $<code>=([[\h ** 4] \V+ \n]+)
        [\h* \n]
    }

    regex md-header1 { '#' \h* <head=.md-text-line> }
    regex md-header2 { '##' \h* <head=.md-text-line> }
    regex md-header3 { '###' \h* <head=.md-text-line> }
    regex md-header4 { '####' \h* <head=.md-text-line> }
    regex md-header5 { '#####' \h* <head=.md-text-line> }
    regex md-header6 { '######' \h* <head=.md-text-line> }

    regex md-horizontal-line { '---' ['-']* \n }

    regex md-image-simple-link { '!' <md-link> }
    regex md-image-complex-link { '[' \h* '!' <md-link> \h* ']' \h* <md-image-complex-link-to> };
    regex md-image-complex-link-to {  <md-image-complex-link-url> | <md-image-complex-link-reference> }
    regex md-image-complex-link-url { '(' <md-link-url> ')' }
    regex md-image-complex-link-reference { '[' <md-link-label> ']' }

    regex md-link { <md-reference-link> | <md-simple-link> }
    regex md-simple-link { '[' <md-link-name> ']' \h* '(' <md-link-url> ')' }
    regex md-simple-link-strict { ^ <md-simple-link> $ }

    regex md-reference-link { '[' <md-link-name> ']' \h* '[' <md-link-label> ']' }
    regex md-reference-link-strict { ^ <md-reference-link> $ }
    regex md-reference { '[' <md-link-label> ']:' \h* <md-link-url> \h* \n}

    regex md-link-name { <-[\[\]\v]>* }
    regex md-link-url { <-[()\v]>* }
    regex md-link-label { <-[\[\]\v]>* }

    regex md-word { (\S+) <!{ (so $0.Str ~~ self.md-simple-link-strict) || (so $0.Str ~~ self.md-reference-link-strict) }> }
    regex md-empty-line { \h* \n }

    regex md-text-element { <md-link> || <md-word> }
    regex md-text-line { \h ** ^4 $<first>=(<md-text-element>) \h*? [$<rest>=([<md-text-element>+ % \h* ])]? \h* \n <!{ $<first>.Str eq $mdTicks }> }
    regex md-text-block { <md-text-line>+ }

    regex md-item-list-block { <md-item-list-element>+ }
    regex md-item-list-element { $<indent>=(\h*) $mdItemListMarker \h+ <content=.md-text-line> }

    regex md-numbered-list-block { <md-numbered-list-element>+ }
    regex md-numbered-list-element { $<indent>=(\h*) <num=[\d+]> \. \h+ <content=.md-text-line> }
    regex md-any-line { \V* \n }
}
