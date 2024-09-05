use v6.d;

use Markdown::Grammarish;
use Markdown::Actions::HTML;
use Markdown::Actions::Jupyter;
use Markdown::Actions::JupyterObsidian;
use Markdown::Actions::Mathematica;
use Markdown::Actions::OrgMode;
use Markdown::Actions::Pod6;
use Markdown::Actions::Raku;

grammar Markdown::Grammar
        does Markdown::Grammarish {
}

#-----------------------------------------------------------
our sub md-subparse(Str:D $command, Str:D :$rule = 'TOP') is export {
    my $ending = $command.substr(*- 1, *) eq "\n" ?? '' !! "\n";
    Markdown::Grammar.subparse($command ~ $ending, :$rule);
}

our sub md-parse(Str:D $command, Str:D :$rule = 'TOP') is export {
    my $ending = $command.substr(*- 1, *) eq "\n" ?? '' !! "\n";
    Markdown::Grammar.parse($command ~ $ending, :$rule);
}

our sub md-interpret(Str:D $command,
                     Str:D :$rule = 'TOP',
                     :$actions = Markdown::Actions::Mathematica.new) is export {
    my $ending = $command.substr(*- 1, *) eq "\n" ?? '' !! "\n";
    return Markdown::Grammar.parse($command ~ $ending, :$rule, :$actions).made;
}

#-----------------------------------------------------------
#| Converts Markdown files into Mathematica notebooks.
#| C<$md> -- A Markdown string or file name.
#| C<:t(:$to)> = 'mathematica' -- Format to convert to. (One of 'mathematica' or 'pod6'.)
our proto from-markdown($md,
                        Str :t(:$to) = 'mathematica', | --> Str) is export {*}

multi from-markdown(IO::Path $file,
                    Str :t(:$to) = 'mathematica',
                    :l(:$default-language) = Whatever,
                    :$raku-code-cell-name = Whatever,
                    Bool :$docked-cells = False --> Str) {
    my $text = slurp($file);
    return from-markdown($text, :$to, :$default-language, :$raku-code-cell-name, :$docked-cells);
}

multi from-markdown(Str:D $file where *.IO.f,
                    Str :t(:$to) = 'mathematica',
                    :l(:$default-language) = Whatever,
                    :$raku-code-cell-name = Whatever,
                    Bool :$docked-cells = False --> Str) {

    my $text = slurp($file);
    return from-markdown($text, :$to, :$default-language, :$raku-code-cell-name, :$docked-cells);
}

multi from-markdown(Str:D $text,
                    Str :t(:$to) = 'mathematica',
                    :l(:$default-language) is copy = Whatever,
                    :$raku-code-cell-name = Whatever,
                    Bool :$docked-cells = False --> Str) {

    my $res;
    my $ending = $text.substr(*- 1, *) eq "\n" ?? '' !! "\n";

    die 'The argument default-language is expected to be a string or Whatever.'
    unless $default-language.isa(Whatever) || $default-language ~~ Str;

    if $default-language.isa(Whatever) {
        $default-language = 'Whatever'
    }

    given $to.lc {
        when  $_ ∈ <html html5> {
            $res = md-interpret($text ~ $ending,
                    actions => Markdown::Actions::HTML.new(
                            defaultLang =>$default-language.lc eq 'whatever' ?? 'raku' !! $default-language
                            ));
        }
        when  $_ ∈ <jupyter ipynb> {
            $res = md-interpret($text ~ $ending,
                    actions => Markdown::Actions::Jupyter.new(
                            defaultLang =>$default-language.lc eq 'whatever' ?? 'raku' !! $default-language
                            ));
        }
        when  $_ ~~ / jupyter [<:Pd> | '::']? obsidian / {
            $res = md-interpret($text ~ $ending,
                    actions => Markdown::Actions::JupyterObsidian.new(
                            defaultLang =>$default-language.lc eq 'whatever' ?? 'raku' !! $default-language
                            ));
        }
        when  $_ ∈ <mathematica wl> {
            $res = md-interpret($text ~ $ending,
                    actions => Markdown::Actions::Mathematica.new(
                            defaultLang => $default-language.lc eq 'whatever' ?? 'mathematica' !! $default-language,
                            addDockedCells => $docked-cells,
                            fromLaTeXButtonName => 'Convert found formulas',
                            rakuLaTeXCellName => 'RakuFoundLaTeX',
                            rakuCodeCellName => $raku-code-cell-name));
        }
        when  $_ ∈ <org org-mode> {
            $res = md-interpret($text ~ $ending,
                    actions => Markdown::Actions::OrgMode.new(
                            defaultLang =>$default-language.lc eq 'whatever' ?? 'raku' !! $default-language
                            ));
        }
        when  $_ ∈ <pod pod6> {
            $res = md-interpret($text ~ $ending,
                    actions => Markdown::Actions::Pod6.new(
                            defaultLang =>$default-language.lc eq 'whatever' ?? 'raku' !! $default-language
                    ));
        }
        default {
            die 'Unknown output format.'
        }
    }
    return $res;
}

#-----------------------------------------------------------
#| Converts Markdown text or blocks into a section tree.
#| C<$md> -- A Markdown string or an array of Markdown blocks.
#| C<:$max-level)> -- Maximum level (or depth) of the tree.
#| C<::$modifier> -- Modifier function spec.
our proto md-section-tree($md, UInt :$max-level = 6, :$modifier = WhateverCode) is export {*}

multi md-section-tree(IO::Path $file, *%args) {
    my $text = slurp($file);
    return md-section-tree($text, |%args);
}

multi md-section-tree(Str:D $file where *.IO.f, *%args) {
    my $text = slurp($file);
    return md-section-tree($text, |%args);
}

multi md-section-tree(Str $md,
                      :$max-level = 6,
                      :$modifier is copy = WhateverCode) {

    my $actObj = Markdown::Actions::Raku.new(:as-section-tree, :$max-level, :$modifier, :combine-adjacent-text-lines);

    return md-interpret($md, actions => $actObj);
}

multi md-section-tree(@mdBlocks where @mdBlocks.all ~~ Hash,
                      :$max-level = 6,
                      :$modifier = WhateverCode) {


    my $actObj = Markdown::Actions::Raku.new(:as-section-tree, :$max-level, :$modifier, :combine-adjacent-text-lines);

    return $actObj.section-tree(@mdBlocks, :$max-level, :$modifier);
}