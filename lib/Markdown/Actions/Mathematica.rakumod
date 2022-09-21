use v6.d;

class Markdown::Actions::Mathematica {

    method TOP($/) { make 'Notebook[{' ~ $<md-block>>>.made.join(', ') ~ '}]' }

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


    method md-header1($/) { make 'Cell[TextData[{' ~ $<head>.made ~ '}], "Title"]'; }
    method md-header2($/) { make 'Cell[TextData[{' ~ $<head>.made ~ '}], "Section"]'; }
    method md-header3($/) { make 'Cell[TextData[{' ~ $<head>.made ~ '}], "Subsection"]'; }
    method md-header4($/) { make 'Cell[TextData[{' ~ $<head>.made ~ '}], "Subsubsection"]'; }
    method md-header5($/) { make 'Cell[TextData[{' ~ $<head>.made ~ '}], "Subsubsubsection"]'; }

    method md-horizontal-line($/) { make 'Cell[TextData["\[HorizontalLine]"], "Text"]'; }

    method md-image-simple-link($/) {
        my $code = 'Import[' ~ $<md-simple-link><md-link-url>.made ~ ']';
        $code = $code.Str.subst(:g, '"', '\"');
        make 'Cell[ BoxData["' ~ $code ~ '"], "Input"]';
    }

    method md-image-complex-link($/) {
        my $code = 'Import[' ~ $<md-simple-link><md-link-url>.made ~ ']';
        $code = $code.Str.subst(:g, '"', '\"');
        make 'Cell[ BoxData["' ~ $code ~ '"], "Input"]';
    }

    method md-simple-link($/) { make 'ButtonBox[' ~ $<md-link-name>.made ~ ', BaseStyle -> "Hyperlink", ButtonData -> { ' ~ $<md-link-url>.made ~ ', None}]'; }
    method md-link-name($/) { make '"' ~ $/.Str.subst(:g, '"', '\"') ~ '"'; }
    method md-link-url($/) { make 'URL["' ~ make $/.Str ~ '"]'; }

    method md-word($/) { make '"' ~ $/.Str.subst(:g, '"', '\"') ~ '"'; }
    method md-text-element($/) { make $/.values[0].made; }
    method md-empty-line($/) { make 'Cell[TextData[{""}]]'; }
    method md-text-line($/) {
        my @res;
        with $<rest> {
            @res = [$<first><md-text-element>.made, |$<rest><md-text-element>>>.made];
        } else {
            @res = [$<first><md-text-element>.made, ]
        }
        make @res.join(', " ", ');
    }
    method md-text-block($/) {
        make 'Cell[TextData[{' ~ $/.values>>.made.join(', " ", ') ~ '}], "Text"]';
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
}

