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
#| C<$md> -- A markdown string or file name.
#| C<:t(:$to)> = 'mathematica' -- Format to convert to. (One of 'mathematica' or 'pod6'.)
our proto from-markdown($md,
                        Str :t(:$to) = 'mathematica', | --> Str) is export {*}

multi from-markdown(IO::Path $file,
                    Str :t(:$to) = 'mathematica',
                    :l(:$default-language) = 'mathematica',
                    :$raku-code-cell-name = Whatever,
                    Bool :$docked-cells = False --> Str) {
    my $text = slurp($file);
    return from-markdown($text, :$to, :$default-language, :$raku-code-cell-name, :$docked-cells);
}

multi from-markdown(Str:D $file where *.IO.f,
                    Str :t(:$to) = 'mathematica',
                    :l(:$default-language) = 'mathematica',
                    :$raku-code-cell-name = Whatever,
                    Bool :$docked-cells = False --> Str) {

    my $text = slurp($file);
    return from-markdown($text, :$to, :$default-language, :$raku-code-cell-name, :$docked-cells);
}

multi from-markdown(Str:D $text,
                    Str :t(:$to) = 'mathematica',
                    :l(:$default-language) = 'mathematica',
                    :$raku-code-cell-name = Whatever,
                    Bool :$docked-cells = False --> Str) {

    my $res;
    my $ending = $text.substr(*- 1, *) eq "\n" ?? '' !! "\n";
    given $to.lc {
        when  $_ ∈ <mathematica wl> {
            $res = md-interpret($text ~ $ending,
                    actions => Markdown::Actions::Mathematica.new(
                            defaultLang => $default-language,
                            addDockedCells => $docked-cells,
                            fromLaTeXButtonName => 'Convert found formulas',
                            rakuLaTeXCellName => 'RakuFoundLaTeX',
                            rakuCodeCellName => $raku-code-cell-name));
        }
        when  $_ ∈ <pod pod6> {
            $res = md-interpret($text ~ $ending, actions => Markdown::Actions::Pod6.new);
        }
        default {
            die 'Unknown output format.'
        }
    }
    return $res;
}