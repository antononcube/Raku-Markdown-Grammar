use v6.d;

class Markdown::Actions::Pod6 {

    method TOP($/) {
        my @mdBlocks = $<md-block>>>.made;

        my $res;
        if @mdBlocks.all ~~ Str {
            $res = @mdBlocks.join("\n");
        } else {
            my %references = @mdBlocks.grep({ $_ ~~ Pair }).map({ '[' ~ $_.key ~ ']' => $_.value });
            @mdBlocks = @mdBlocks.grep({ $_ !~~ Pair });
            $res = @mdBlocks.join("\n");
            for %references.kv -> $k, $v {
                $res = $res.subst($k, $v):g;
            }
        }

        make "=begin pod\n" ~ $res ~ "\n=end pod";
    }

    method md-block($/) { make $/.values[0].made; }

    method md-math-block($/) {
        my $code = $<code>.Str;
        make '=begin code :lang<math>' ~ "\n" ~ $code ~ "\n" ~ '=end code';
    }

    method md-code-block($/) {
        my $code = $<code>.Str;
        my $lang = '';
        with $<header><lang> {
            $lang = ' :lang<' ~ $<header><lang>.Str ~ '>';
        }
        make '=begin code' ~ $lang ~ "\n" ~ $code.trim-trailing ~ "\n" ~ '=end code';
    }

    method md-code-indented-block($/) {
        my $code = $<code>.Str;
        $code = $code.subst(/ ^ \h ** 4 /, ''):g;
        $code = $code.subst(/ \n \h ** 4 /, "\n"):g;
        make '=begin code' ~ "\n" ~ $code.trim-trailing ~ "\n" ~ '=end code';
    }

    method md-header1($/) { make '=begin head1' ~ "\n" ~ $<head>.made ~ "\n" ~ '=end head1'; }
    method md-header2($/) { make '=begin head2' ~ "\n" ~ $<head>.made ~ "\n" ~ '=end head2'; }
    method md-header3($/) { make '=begin head3' ~ "\n" ~ $<head>.made ~ "\n" ~ '=end head3'; }
    method md-header4($/) { make '=begin head4' ~ "\n" ~ $<head>.made ~ "\n" ~ '=end head4'; }
    method md-header5($/) { make '=begin head5' ~ "\n" ~ $<head>.made ~ "\n" ~ '=end head5'; }
    method md-header6($/) { make '=begin head6' ~ "\n" ~ $<head>.made ~ "\n" ~ '=end head6'; }

    method md-horizontal-line($/) { make "=para \n" ~ ('-' x 100); }

    method md-image-simple-link($/) { make $<md-link>.made; }

    method md-image-complex-link($/) {
        make $<md-link>.made;
    }

    method md-image-complex-link-to($/) { make $/.values[0].made; }
    method md-image-complex-link-url($/) { make $/.values[0].made; }
    method md-image-complex-link-reference($/) { make $/.values[0].made; }

    method md-link($/) { make $/.values[0].made; }
    method md-simple-link($/) { make 'L<' ~ $<md-link-name>.made ~ '|' ~ $<md-link-url>.made ~ '>'; }

    method md-reference-link($/) { make 'L<' ~ $<md-link-name>.made ~ '|[' ~ $<md-link-label>.made ~ ']>'; }
    method md-reference($/) { make $<md-link-label>.made => $<md-link-url>.made; }

    method md-link-name($/) { make $/.Str; }
    method md-link-url($/) { make $/.Str; }
    method md-link-label($/) { make $/.Str; }

    method md-word($/) { make $/.Str; }
    method md-word-bold-italic($/) { make 'B<I<' ~ $/.Str.substr(3, *-3) ~ '>>'; }
    method md-word-bold($/) { make 'B<' ~ $/.Str.substr(2, *-2) ~ '>'; }
    method md-word-italic($/) { make 'I<' ~ $/.Str.substr(1, *-1) ~ '>'; }
    # Markdown does not allow underlined text
    # method md-word-underlined($/) { make 'U<' ~ $/.Str ~ '>'; }
    method md-word-code($/) {
        my $off = $<delim>.Str.chars;
        make 'C<' ~ $/.Str.substr($off, *-$off) ~ '>'; }
    method md-math-code($/) {
        my $off = $<delim>.Str.chars;
        make 'C<' ~ $/.Str.substr($off, *-$off) ~ '>'; }

    method md-text-element($/) { make $/.values[0].made; }
    method md-empty-line($/) { make ''; }
    method md-text-line($/) {
        make $<md-text-line-tail>.made;
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
        make "=para\n" ~ $/.values>>.made.join("\n");
    }

    method md-quote-line($/) {
        make $<md-text-line-tail>.made;
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
            when 1 { @res = @res.map({ 'I<' ~ $_ ~ '>' }) }
            when 2 { @res = @res.map({ 'B<' ~ $_ ~ '>' }) }
            when 3 { @res = @res.map({ 'B>I<' ~ $_ ~ '>>' }) }
        }
         make "=para\n" ~ @res.join("\n");
    }

    method md-item-list-block($/) {
        make  $<md-item-list-element>>>.made.join("\n");
    }
    method md-item-list-element($/) {
        my $itemType =
                do given $<indent>.Str.chars {
                    when 0 { '=item1' }
                    when 1 ≤ $_ ≤ 2 { '=item2' }
                    when 3 ≤ $_ ≤ 4 { '=item3' }
                    when 5 ≤ $_ ≤ 6 { '=item4' }
                };

        make $itemType ~ ' ' ~ $<content>.made;
    }

    method md-numbered-list-block($/) {
        make  $<md-numbered-list-element>>>.made.join("\n");
    }
    method md-numbered-list-element($/) {
        my $itemType =
                do given $<indent>.Str.chars {
                    when 0 { '=item1' }
                    when 1 ≤ $_ ≤ 2 { '=item2' }
                    when 3 ≤ $_ ≤ 4 { '=item3' }
                    when 5 ≤ $_ ≤ 6 { '=item4' }
                };

        make $itemType ~ ' # ' ~ $<content>.made;
    }

    method md-table-block($/) {
        make "=para\n" ~ $/.Str;
    }

    method md-any-line($/) {
        make $/.Str;
    }

    method md-any-block($/) {
        make "=para\n" ~ $<md-any-line>>>.made.join("\n");
    }
}

