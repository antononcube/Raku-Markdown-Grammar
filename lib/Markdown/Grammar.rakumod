use v6.d;

use Markdown::Grammarish;
use Markdown::Actions::Mathematica;
use Markdown::Actions::Pod6;

grammar Markdown::Grammar
        does Markdown::Grammarish {
}

#-----------------------------------------------------------
our sub md-subparse(Str:D $command, Str:D :$rule = 'TOP') is export {
    Markdown::Grammar.subparse($command, :$rule);
}

our sub md-parse(Str:D $command, Str:D :$rule = 'TOP') is export {
    Markdown::Grammar.parse($command, :$rule);
}

our sub md-interpret(Str:D $command,
                       Str:D:$rule = 'TOP',
                       :$actions = Markdown::Actions::Mathematica.new) is export {
    return Markdown::Grammar.parse($command, :$rule, :$actions).made;
}

#-----------------------------------------------------------
#| Converts Markdown files into Mathematica notebooks.
#| $md -- A markdown string or file name.
#| t(:$to) = 'mathematica' -- Format to convert to. (One of 'mathematica' or 'pod6'.)
our proto from-markdown(Str $md,
                        Str :t(:$to) = 'mathematica') is export {*}


multi from-markdown(Str $file where *.IO.f, Str :t(:$to) = 'mathematica') {

    my $text = slurp($file);
    return from-markdown($text, :to);
}


multi from-markdown(Str $text, Str :t(:$to) = 'mathematica' --> Str) {

    my $res;
    given $to.lc {
        when  $_ ∈ <mathematica wl> { $res = md-interpret($text, actions => Markdown::Actions::Mathematica.new); }
        when  $_ ∈ <pod pod6> { $res = md-interpret($text, actions => Markdown::Actions::Pod6.new); }
        default {
            die 'Unknown output format.'
        }
    }
    return $res;
}