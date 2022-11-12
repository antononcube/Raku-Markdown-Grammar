use v6.d;

class Markdown::Actions::OrgMode {

    has $.defaultLang = 'raku';

    method TOP($/) {
        my @mdBlocks = $<md-block>>>.made;

        my $res;
        if @mdBlocks.all ~~ Str {
            $res = @mdBlocks.join("\n");
        } else {
            # Obtain references
            my %references = @mdBlocks.grep({ $_ ~~ Pair && $_.key ne 'TEXTLINE' }).map({ '[' ~ $_.key ~ ']' => $_.value });

            # Consolidate text lines into text blocks
            my @mdBlocks2;
            my $textBlock = '';
            for @mdBlocks -> $b {
                if $b ~~ Pair && $b.key eq 'TEXTLINE' {
                    $textBlock ~= "\n" ~ $b.value;
                } elsif $textBlock {
                    @mdBlocks2.append($textBlock.trim.map({ '- ' ~ $_ }).join("\n"));
                    $textBlock = '';
                    @mdBlocks2.append($b)
                } else {
                    @mdBlocks2.append($b)
                }
            }
            if $textBlock {
                @mdBlocks2.append("=para\n" ~ $textBlock.trim);
            }
            @mdBlocks = @mdBlocks2;

            # Process references
            @mdBlocks = @mdBlocks.grep({ $_ !~~ Pair });
            $res = @mdBlocks.join("\n");
            for %references.kv -> $k, $v {
                $res = $res.subst($k, $v):g;
            }
        }

        make $res.subst(:g, / \n ** 2..* /, "\n").trim;
    }

    method md-block($/) { make $/.values[0].made; }

    method md-math-block($/) {
        my $code = $<code>.Str;
        make '\[' ~ "\n" ~ $code ~ "\n" ~ '\]';
    }

    method md-code-block($/) {
        my $code = $<code>.Str;
        my $lang = $!defaultLang;
        if $<header><lang>.defined && $<header><lang>.Str {
            $lang = $<header><lang>.Str;
        } elsif $lang.isa(Whatever) || $lang ~~ Str && $lang.lc ∈ <whatever raku perl6> {
            $lang = ''
        }

        make '#+BEGIN_SRC ' ~ $lang ~ ' :results output :exports both :session' ~ "\n" ~ $code.trim-trailing ~ "\n" ~ '#+END_SRC';
    }

    method md-code-indented-block($/) {
        my $code = $<code>.Str;
        $code = $code.subst(/ ^ \h ** 4 /, ''):g;
        $code = $code.subst(/ \n \h ** 4 /, "\n"):g;
        make '#+BEGIN_SRC :results output :exports both :session' ~ "\n" ~ $code.trim-trailing ~ "\n" ~ '#+END_SRC';
    }

    method md-list-of-params($/) { make $/.Str; }

    method md-header1($/) { make '#+TITLE: ' ~ $<head>.made; }
    method md-header2($/) { make '* ' ~  ~ $<head>.made; }
    method md-header3($/) { make '** ' ~ $<head>.made; }
    method md-header4($/) { make '*** ' ~ $<head>.made; }
    method md-header5($/) { make '****' ~ $<head>.made; }
    method md-header6($/) { make '***** ' ~ $<head>.made; }

    method md-horizontal-line($/) { make "\n" ~ ('-' x 100) ~ "\n"; }

    method md-image-simple-link($/) { make $<md-link>.made; }

    method md-image-complex-link($/) {
        make $<md-link>.made;
    }

    method md-image-complex-link-to($/) { make $/.values[0].made; }
    method md-image-complex-link-url($/) { make $/.values[0].made; }
    method md-image-complex-link-reference($/) { make $/.values[0].made; }

    method md-link($/) { make $/.values[0].made; }
    method md-simple-link($/) { make '[[' ~ $<md-link-url>.made ~ '][' ~ $<md-link-name>.made ~ ']]'; }

    method md-reference-link($/) { make '[[' ~  $<md-link-label>.made ~ '][' ~ $<md-link-name>.made ~ ']]'; }
    method md-reference($/) { make $<md-link-label>.made => $<md-link-url>.made; }

    method md-link-name($/) { make $/.Str; }
    method md-link-url($/) { make $/.Str; }
    method md-link-label($/) { make $/.Str; }

    method md-word($/) { make $/.Str; }
    method md-word-bold-italic($/) { make '*/' ~ $/.Str.substr(3, *-3) ~ '/*'; }
    method md-word-bold($/) { make '*' ~ $/.Str.substr(2, *-2) ~ '*'; }
    method md-word-italic($/) { make '/' ~ $/.Str.substr(1, *-1) ~ '/'; }
    # Markdown does not allow underlined text
    # method md-word-underlined($/) { make 'U<' ~ $/.Str ~ '>'; }
    method md-word-code($/) {
        my $off = $<delim>.Str.chars;
        make '~' ~ $/.Str.substr($off, *-$off) ~ '~'; }
    method md-math-code($/) {
        my $off = $<delim>.Str.chars;
        make '~' ~ $/.Str.substr($off, *-$off) ~ '~'; }

    method md-text-element($/) { make $/.values[0].made; }
    method md-empty-line($/) { make ''; }
    method md-text-line($/) {
        make (TEXTLINE => $<md-text-line-tail>.made);
    }
    method md-text-element-list($/) {
        make $<md-text-element>>>.made.join(' ');
    }
    method md-text-line-tail($/) {
        my @res;
        with $<rest> {
            @res = [$<first><md-text-element>.made, |$<rest><md-text-element>>>.made];
        } else {
            @res = [$<first><md-text-element>.made, ]
        }
        make @res.join(' ');
    }
    method md-text-block($/) {
        make $/.values>>.made>>.value.map({ '- ' ~ $_ }).join("\n");
    }

    method md-quote-line($/) {
        with $<md-text-element-list> {
            make $<md-text-element-list>.made
        } else {
            make ' ';
        }
    }
    method md-quote-block($/) {
        make "=para Qoute\n" ~ $/.values>>.made.join("\n");
    }

    method md-emphasize-text-element($/) { make $/.values[0].made; }
    method md-emphasize-text-line($/) {
        my @res = $<md-emphasize-text-element>>>.made;
        make @res.join(' ');
    }

    method md-emphasize-block($/) {
        my $emph = $<emph>.Str;
        my @res = $<md-emphasize-text-line>>>.made.join("\n");
        given $emph.chars {
            when 1 { @res = @res.map({ '/' ~ $_ ~ '/' }) }
            when 2 { @res = @res.map({ '*' ~ $_ ~ '*' }) }
            when 3 { @res = @res.map({ '*/' ~ $_ ~ '/*' }) }
        }
         make '- ' ~ @res.join("\n");
    }

    method md-item-list-block($/) {
        make  $<md-item-list-element>>>.made.join("\n");
    }
    method md-item-list-element($/) {
        my $itemType =
                do given $<indent>.Str.chars {
                    when 0 { '-' }
                    when 1 ≤ $_ ≤ 2 { ' ' x 2 ~ '-' }
                    when 3 ≤ $_ ≤ 4 { ' ' x 4 ~ '-'  }
                    when 5 ≤ $_ ≤ 6 { ' ' x 6 ~ '-'  }
                };

        # $<content> is same as $<md-text-line> hence a Pair
        make $itemType ~ ' ' ~ $<content>.made.value;
    }

    method md-numbered-list-block($/) {
        make  $<md-numbered-list-element>>>.made.join("\n");
    }
    method md-numbered-list-element($/) {
        my $itemType =
                do given $<indent>.Str.chars {
                    when 0 { '1) ' }
                    when 1 ≤ $_ ≤ 2 { ' ' x 2 ~ '1)'  }
                    when 3 ≤ $_ ≤ 4 { ' ' x 4 ~ '1)'  }
                    when 5 ≤ $_ ≤ 6 { ' ' x 5 ~ '1)'  }
                };

        # $<content> is same as $<md-text-line> hence a Pair
        make $itemType ~ ' ' ~ $<content>.made.value;
    }

    method md-table-block($/) {
        make '- note table \\\\' ~ "\n" ~ $/.Str.lines.map({ '  ' ~ $_ }).join("\n");
    }

    method md-any-line($/) {
        make $/.Str;
    }

    method md-any-block($/) {
        make '- note \\\\' ~ "\n" ~ $<md-any-line>>>.made.map({ ' ' ~ $_ }).join("\n");
    }
}

