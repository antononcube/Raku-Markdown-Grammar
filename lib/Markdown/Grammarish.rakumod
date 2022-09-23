use v6.d;

constant $mdTicks = '```';

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
        || <md-quote-block>
        || <md-emphasize-block>
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
    regex md-reference { '[' <md-link-label> ']:' \h* <md-link-url>}

    regex md-link-name { <-[\[\]\v]>* }
    regex md-link-url { <-[()\v]>* }
    regex md-link-label { <-[\[\]\v]>* }

    regex md-word { (\S+) <!{ (so $0.Str ~~ self.md-simple-link-strict) || (so $0.Str ~~ self.md-reference-link-strict) }> }
    regex md-word-bold-italic { ('***' | '___') <md-word> $0 }
    regex md-word-bold { ('**' | '__') <md-word> $0 }
    regex md-word-italic { ('*' | '_') <md-word> $0 }
    regex md-word-code { ('`' | '```') <md-word> $0 }
    regex md-empty-line { \h* \n }

    regex md-text-element { <md-link> || <md-word-bold-italic> || <md-word-bold> || <md-word-italic> || <md-word-code> || <md-word> }
    regex md-text-line-tail { $<first>=(<md-text-element>) \h*? [$<rest>=([<md-text-element>+ % \h* ])]? \h* <!{ $<first>.Str eq $mdTicks }> }
    regex md-text-line { \h ** ^4 <md-text-line-tail> \n }
    regex md-text-block { <md-text-line>+ }

    regex md-quote-line { '>' \h+ [ <md-text-line-tail> \n || \n ] }
    regex md-quote-block { <md-quote-line>+ }

    regex md-emphasize-block { $<emph>=( '***' | '**' | '*' | '___' | '__' | '_' ) [<md-text-line-tail> | <md-text-line-tail>+ % \n] $<emph> }

    regex md-item-list-block { <md-item-list-element>+ }
    token md-item-list-marker { '-' | '+' | '*' }
    regex md-item-list-element { $<indent>=(\h*) <md-item-list-marker> \h+ <content=.md-text-line> }

    regex md-numbered-list-block { <md-numbered-list-element>+ }
    regex md-numbered-list-element { $<indent>=(\h*) <num=[\d+]> \. \h+ <content=.md-text-line> }
    regex md-any-line { \V* \n }
}
