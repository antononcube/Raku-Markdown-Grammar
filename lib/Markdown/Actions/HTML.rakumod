use v6.d;

class Markdown::Actions::HTML {

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
                    @mdBlocks2.append("<p>\n" ~ $textBlock.trim ~ "\n</p>");
                    $textBlock = '';
                    @mdBlocks2.append($b)
                } else {
                    @mdBlocks2.append($b)
                }
            }
            if $textBlock {
                @mdBlocks2.append("<p>\n" ~ $textBlock.trim ~ "\n</p>");
            }
            @mdBlocks = @mdBlocks2;

            # Process references
            @mdBlocks = @mdBlocks.grep({ $_ !~~ Pair });
            $res = @mdBlocks.join("\n");
            for %references.kv -> $k, $v {
                $res = $res.subst($k, $v):g;
            }
        }

        make $res;
    }

    method md-block($/) { make $/.values[0].made; }

    method md-math-block($/) {
        my $code = $<code>.Str;
        make '<pre><code{math}>' ~ "\n" ~ $code ~ "\n" ~ '</code></pre>';
    }

    method md-code-block($/) {
        my $code = $<code>.Str;
        my $lang = $!defaultLang;
        if $<header><lang>.defined && $<header><lang>.Str {
            $lang = ' class="' ~  $<header><lang>.Str ~ '"';
        } elsif $lang.isa(Whatever) || $lang ~~ Str && $lang.lc ∈ <whatever raku perl6> {
            $lang = ''
        }

        make "<pre><code{$lang}>\n" ~ $code.trim-trailing ~ "\n</code></pre>";
    }

    method md-code-indented-block($/) {
        my $code = $<code>.Str;
        $code = $code.subst(/ ^ \h ** 4 /, ''):g;
        $code = $code.subst(/ \n \h ** 4 /, "\n"):g;
        make '<pre><code>' ~ "\n" ~ $code.trim-trailing ~ "\n" ~ '</code></pre>';
    }

    method md-header1($/) { make '<h1>' ~ "\n" ~ $<head>.made ~ "\n" ~ '</h1>'; }
    method md-header2($/) { make '<h2>' ~ "\n" ~ $<head>.made ~ "\n" ~ '</h2>'; }
    method md-header3($/) { make '<h3>' ~ "\n" ~ $<head>.made ~ "\n" ~ '</h3>'; }
    method md-header4($/) { make '<h4>' ~ "\n" ~ $<head>.made ~ "\n" ~ '</h4>'; }
    method md-header5($/) { make '<h5>' ~ "\n" ~ $<head>.made ~ "\n" ~ '</h5>'; }
    method md-header6($/) { make '<h6>' ~ "\n" ~ $<head>.made ~ "\n" ~ '</h6>'; }

    method md-horizontal-line($/) { make '<p><hr></p>'; }

    method md-image-simple-link($/) {
        my $link;
        my $linkName;
        if $<md-link><md-simple-link> {
            $link = $<md-link><md-simple-link><md-link-url>.Str;
            $linkName = $<md-link><md-simple-link><md-link-name>.Str;
        } else {
            $link = '[' ~ $<md-link><md-reference-link><md-link-label>.made ~ ']';
            $linkName = $<md-link><md-reference-link><md-link-name>.Str;
        }
        make '<img src="' ~ $link ~ '" alt="' ~ $linkName ~ '" />' ;
    };

    method md-image-complex-link($/) {
        my $link;
        my $linkName;
        if $<md-link><md-simple-link> {
            $link = $<md-link><md-simple-link><md-link-url>.Str;
            $linkName = $<md-link><md-simple-link><md-link-name>.Str;
        } else {
            $link = '[' ~ $<md-link><md-reference-link><md-link-label>.made ~ ']';
            $linkName = $<md-link><md-reference-link><md-link-name>.Str;
        }
        make '<img src="' ~ $link ~ '" alt="' ~ $linkName ~ '" />' ;
    }

    method md-image-complex-link-to($/) { make $/.values[0].made; }
    method md-image-complex-link-url($/) { make $/.values[0].made; }
    method md-image-complex-link-reference($/) { make $/.values[0].made; }

    method md-link($/) { make $/.values[0].made; }
    method md-simple-link($/) { make '<a href="' ~  $<md-link-url>.made ~ '">' ~ $<md-link-name>.made ~ '</a>'; }

    method md-reference-link($/) { make '<a href="[' ~  $<md-link-label>.made ~ ']">' ~ $<md-link-name>.made ~ '</a>'; }
    method md-reference($/) { make $<md-link-label>.made => $<md-link-url>.made; }

    method md-link-name($/) { make $/.Str; }
    method md-link-url($/) { make $/.Str; }
    method md-link-label($/) { make $/.Str; }

    method md-word($/) { make $/.Str; }
    method md-word-bold-italic($/) { make '<strong><em>' ~ $/.Str.substr(3, *-3) ~ '</em></strong>'; }
    method md-word-bold($/) { make '<strong>' ~ $/.Str.substr(2, *-2) ~ '</strong>'; }
    method md-word-italic($/) { make '<em>' ~ $/.Str.substr(1, *-1) ~ '</em>'; }
    # Markdown does not allow underlined text
    # method md-word-underlined($/) { make 'U<' ~ $/.Str ~ '>'; }
    method md-word-code($/) {
        my $off = $<delim>.Str.chars;
        make '<code>' ~ $/.Str.substr($off, *-$off) ~ '</code>'; }
    method md-math-code($/) {
        my $off = $<delim>.Str.chars;
        make '<code>' ~ $/.Str.substr($off, *-$off) ~ '</code>'; }

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
        make "<p>\n" ~ $/.values>>.made>>.value.join("\n") ~ "\n</p>";
    }

    method md-quote-line($/) {
        with $<md-text-element-list> {
            make $<md-text-element-list>.made
        } else {
            make ' ';
        }
    }
    method md-quote-block($/) {
        make '<blockquote>' ~ $/.values>>.made.join("\n") ~ '</blockquote>';
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
            when 1 { @res = @res.map({ '<em>' ~ $_ ~ '</em>' }) }
            when 2 { @res = @res.map({ '<strong>' ~ $_ ~ '</strong>' }) }
            when 3 { @res = @res.map({ '<strong><em>' ~ $_ ~ '</strong></em>' }) }
        }
         make "<b>\n" ~ @res.join("\n") ~ "\n</p>";
    }

    method md-item-list-block($/) {
        make "<ul>\n" ~ $<md-item-list-element>>>.made.join("\n") ~ "\n</ul>";
    }
    method md-item-list-element($/) {
        my $start;
        my $end;
        given $<indent>.Str.chars {
            when 0 { $start = '<li>'; $end = '</li>'; }
            when 1 ≤ $_ ≤ 2 { $start = '<ul><li>'; $end = '</li></ul>'; }
            when 3 ≤ $_ ≤ 4 { $start = '<ul><ul><li>'; $end = '</li></ul></ul>'; }
            when 5 ≤ $_ ≤ 6 { $start = '<ul><ul><ul><li>'; $end = '</li></ul></ul></ul>'; }
        };

        # $<content> is same as $<md-text-line> hence a Pair
        make $start ~ ' ' ~ $<content>.made.value ~ $end;
    }

    method md-numbered-list-block($/) {
        make '<ol type="1">' ~ $<md-numbered-list-element>>>.made.join("\n") ~ '</ol>';
    }
    method md-numbered-list-element($/) {
        my $start;
        my $end;
        given $<indent>.Str.chars {
            when 0 { $start = '<li>'; $end = '</li>'; }
            when 1 ≤ $_ ≤ 2 { $start = '<ul><li>'; $end = '</li></ul>'; }
            when 3 ≤ $_ ≤ 4 { $start = '<ul><ul><li>'; $end = '</li></ul></ul>'; }
            when 5 ≤ $_ ≤ 6 { $start = '<ul><ul><ul><li>'; $end = '</li></ul></ul></ul>'; }
        };

        $start = $start.subst('<ul>', '<ol type="1">'):g;
        $end = $end.subst('</ul>', '</ol>'):g;

        # $<content> is same as $<md-text-line> hence a Pair
        make $start ~ ' ' ~ $<content>.made.value ~ $end;
    }

    method md-table-block($/) {
        make "<table>\n" ~ $/.Str ~ "\n</table>";
    }

    method md-any-line($/) {
        make $/.Str;
    }

    method md-any-block($/) {
        make "<p>\n" ~ $<md-any-line>>>.made.join("\n") ~ "\n</p>";
    }
}

