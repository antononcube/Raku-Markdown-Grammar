use v6.d;

sub to-wl-text(Str $s) {
    $s.subst(:g, '\\', '\\\\').subst(:g, '"', '\"')
}

class Markdown::Actions::Mathematica {

    method TOP($/) {
        my @mdBlocks = $<md-block>>>.made;
        @mdBlocks = $<md-block>>>.made.grep({ $_ ne 'Cell[TextData[{""}]]' });

        my $res;
        if @mdBlocks.all ~~ Str {
            $res = @mdBlocks.join(', ');
        } else {
            my %references = @mdBlocks.grep({ $_ ~~ Pair });
            @mdBlocks = @mdBlocks.grep({ $_ !~~ Pair });
            for %references.kv -> $k, $v {
                @mdBlocks = do for @mdBlocks -> $b {
                    # The image links are represented in the Mathematica notebook with an Import statement.
                    # Hence, we have to check the do we have a code cell.
                    if $b ~~ / ^ 'Cell[' .* '"Input"]' $ / {
                        $b.subst($k, $v.subst('"','\"'):g):g
                    } else {
                        $b.subst($k, $v):g
                    }
                }
            }
            $res = @mdBlocks.join(', ');
        }

        # Special treatment of monadic symbols.
        if $res.contains('⟹') {
            $res = $res.subst('⟹', '\[DoubleLongRightArrow]'):g
        }
        make 'NotebookPut @ Notebook[{' ~ $res ~ '}]'
    }

    method md-block($/) { make $/.values[0].made; }

    method md-code-block($/) {
        my $code = $<code>.Str.subst(:g, '"', '\"').subst(:g, '\\\\"', <\\\\\">);
        with $<header><lang> {
            if $<header><lang>.lc ∈ <wl mathematica> {
                make 'Cell[ BoxData["' ~ $code ~ '"], "Input"]';
            } else {
                make 'Cell["'  ~ $code ~ '", "ExternalLanguage", CellEvaluationLanguage->"' ~ $<header><lang>.Str.tc ~ '"]'
            }
        } else {
            make 'Cell[ BoxData["' ~ $code ~ '"], "Input"]';
        }
    }

    method md-code-indented-block($/) {
        my $code = $<code>.Str.subst(:g, '"', '\"').subst(:g, '\\\\"', <\\\\\">);
        $code = $code.subst(/ ^ \h ** 4 /, ''):g;
        $code = $code.subst(/ \n \h ** 4 /, "\n"):g;
        make 'Cell[ BoxData["' ~ $code ~ '"], "Input"]';
    }

    method md-header1($/) { make 'Cell[TextData[{' ~ $<head>.made ~ '}], "Title"]'; }
    method md-header2($/) { make 'Cell[TextData[{' ~ $<head>.made ~ '}], "Section"]'; }
    method md-header3($/) { make 'Cell[TextData[{' ~ $<head>.made ~ '}], "Subsection"]'; }
    method md-header4($/) { make 'Cell[TextData[{' ~ $<head>.made ~ '}], "Subsubsection"]'; }
    method md-header5($/) { make 'Cell[TextData[{' ~ $<head>.made ~ '}], "Subsubsubsection"]'; }
    method md-header6($/) { make 'Cell[TextData[{' ~ $<head>.made ~ '}], "Subsubsubsection"]'; }

    method md-horizontal-line($/) { make 'Cell[TextData["\[HorizontalLine]"], "Text"]'; }

    method md-image-simple-link($/) {
        my $link = $<md-link><md-simple-link> ?? $<md-link><md-simple-link><md-link-url>.made !! $<md-link><md-reference-link><md-link-label>.made;
        my $code = 'Import[' ~ $link ~ ']';
        $code = $code.Str.&to-wl-text;
        make 'Cell[ BoxData["' ~ $code ~ '"], "Input"]';
    }

    method md-image-complex-link($/) {
        my $link = $<md-link><md-simple-link> ?? $<md-link><md-simple-link><md-link-url>.made !! $<md-link><md-reference-link><md-link-label>.made;
        my $code = 'Import[' ~  $link ~ ']';
        $code = $code.Str.&to-wl-text;
        make 'Cell[ BoxData["' ~ $code ~ '"], "Input"]';
    }

    method md-image-complex-link-to($/) { make $/.values[0].made; }
    method md-image-complex-link-url($/) { make $/.values[0].made; }
    method md-image-complex-link-reference($/) { make $/.values[0].made; }

    method md-link($/) { make $/.values[0].made; }
    method md-simple-link($/) {
        make 'ButtonBox[' ~ $<md-link-name>.made ~ ', BaseStyle -> "Hyperlink", ButtonData -> { ' ~ $<md-link-url>.made ~ ', None}]';
    }

    method md-reference-link($/) {
        make 'ButtonBox[' ~ $<md-link-name>.made ~ ', BaseStyle -> "Hyperlink", ButtonData -> { ' ~ $<md-link-label>.made ~ ', None}]';
    }
    method md-reference($/) { make $<md-link-label>.made => $<md-link-url>.made; }

    method md-link-name($/) { make '"' ~ $/.Str.&to-wl-text ~ '"'; }
    method md-link-url($/) { make 'URL["' ~ $/.Str ~ '"]'; }
    method md-link-label($/) { make 'Label[' ~ $/.Str ~ ']'; }

    method md-word($/) { make '"' ~ $/.Str.&to-wl-text ~ '"'; }
    method md-word-bold-italic($/) { make 'StyleBox["' ~ $/.Str.substr(3,*-3).&to-wl-text ~ '", FontWeight->"Bold", FontSlant->"Italic"]'; }
    method md-word-bold($/) { make 'StyleBox["' ~ $/.Str.substr(2,*-2).&to-wl-text ~ '", FontWeight->"Bold"]'; }
    method md-word-italic($/) { make 'StyleBox["' ~ $/.Str.substr(1,*-1).&to-wl-text ~ '", FontSlant->"Italic"]'; }
    method md-word-code($/) { make 'StyleBox["' ~ $/.Str.substr(1,*-1).&to-wl-text ~ '", "Program"]'; }

    method md-text-element($/) { make $/.values[0].made; }
    method md-empty-line($/) { make 'Cell[TextData[{""}]]'; }
    method md-text-line-tail($/) {
        my @res;
        with $<rest> {
            @res = [$<first><md-text-element>.made, |$<rest><md-text-element>>>.made];
        } else {
            @res = [$<first><md-text-element>.made, ]
        }
        make @res.join(', " ", ');
    }
    method md-text-line($/) { make $<md-text-line-tail>.made; }
    method md-text-block($/) {
        make 'Cell[TextData[{' ~ $/.values>>.made.join(', " ", ') ~ '}], "Text"]';
    }

    method md-quote-line($/) {
        with $<md-text-line-tail> {
            make $<md-text-line-tail>.made
        } else {
            make '"\\n\\n"';
        }
    }
    method md-quote-block($/) {
        make 'Cell[TextData[{' ~ $/.values>>.made.join(', " ", ') ~ '}], "ItemParagraph", Background->GrayLevel[0.97]]';
    }

    method md-emphasize-text-element($/) { make $/.values[0].made; }
    method md-emphasize-text-line($/) {
        my @res = $<md-emphasize-text-element>>>.made;
        make @res.join(', " ", ');
    }
    method md-emphasize-block($/) {
        my $emph = $<emph>.Str;
        my @res = $<md-emphasize-text-line>>>.made.map({ $_.subst(/ ^ $emph /, '') });
        my $opts = do given $emph.chars {
            when 1 { 'FontSlant->"Italic"' }
            when 2 { 'FontWeight->"Bold"' }
            when 3 { 'FontWeight->"Bold", FontSlant->"Italic"' }
        }
        make 'Cell[TextData[{' ~ @res.join(', " ", ') ~ '}], "Text", ' ~ $opts ~ ']';
    }

    method md-item-list-block($/) {
        make  $<md-item-list-element>>>.made.join(', ');
    }
    method md-item-list-element($/) {
        my $itemType =
                do given $<indent>.Str.chars {
                    when 0 { 'Item' }
                    when 1 ≤ $_ ≤ 2 { 'Subitem' }
                    when 3 ≤ $_ ≤ 4 { 'Subsubitem' }
                };

        make 'Cell[TextData[{' ~ $<content>.made ~ '}], "' ~ $itemType ~ '"]';
    }

    method md-numbered-list-block($/) {
        make  $<md-numbered-list-element>>>.made.join(', ');
    }
    method md-numbered-list-element($/) {
        my $itemType =
                do given $<indent>.Str.chars {
                    when 0 { 'ItemNumbered' }
                    when 1 ≤ $_ ≤ 2 { 'SubitemNumbered' }
                    when 3 ≤ $_ ≤ 4 { 'SubsubitemNumbered' }
                };

        make 'Cell[TextData[{' ~ $<content>.made ~ '}], "' ~ $itemType ~ '"]';
    }

    method md-any-line($/) {
        make '"' ~ $/.Str.&to-wl-text ~ '"';
    }

    method md-any-block($/) {
        make 'Cell[TextData[{' ~ $<md-any-line>>>.made.join(', "\\n", ') ~ '}], "Text"]';
    }
}

