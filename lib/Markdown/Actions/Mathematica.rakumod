use v6.d;

class Markdown::Actions::Mathematica {

    method TOP($/) { make 'NotebookPut @ Notebook[{' ~ $<md-block>>>.made.join(', ') ~ '}]' }
    method md-block($/) { make $/.values[0].made; }
    method md-header1($/) { make 'Cell[TextData["' ~ $<head> ~ '"], "Title"]'; }
    method md-header2($/) { make 'Cell[TextData["' ~ $<head> ~ '"], "Section"]'; }
    method md-header3($/) { make 'Cell[TextData["' ~ $<head> ~ '"], "Subsection"]'; }
    method md-header4($/) { make 'Cell[TextData["' ~ $<head> ~ '"], "Subsubsection"]'; }
    method md-header5($/) { make 'Cell[TextData["' ~ $<head> ~ '"], "Subsubsubsection"]'; }
    method md-horizontal-line($/) { make 'TextCell["\[HorizontalLine]", "Text"]'; }
    method md-code-block($/) {
        my $code = $<code>.Str.subst(:g, '"', '\"');
        with $<header><lang> {
            if $<header><lang>.lc ∈ <wl mathematica> {
                make 'Cell[ BoxData["' ~ $code ~ '"], "Input"]';
            } else {
                make 'Cell["'  ~ $code ~ '", "ExternalLanguage", CellEvaluationLanguage->"' ~ $<header><lang>.Str ~ '"]'
            }
        } else {
            make 'Cell[ BoxData["' ~ $code ~ '"], "Input"]';
        }
    }
    method md-simple-link($/) { make 'ButtonBox[' ~ $<md-link-name>.made ~ ', BaseStyle -> "Hyperlink", ButtonData -> { ' ~ $<md-link-url>.made ~ ', None}]'; }
    method md-link-name($/) { make '"' ~ $/.Str.subst(:g, '"', '\"') ~ '"'; }
    method md-link-url($/) { make 'URL["' ~ make $/.Str ~ '"]'; }
    method md-text($/) { make $/.Str.subst(:g, '"', '\"'); }
#    method text-line($/) {
#        my @res;
#        with $<text1>       { @res.append('"' ~ $<text1>.made ~ '"'); }
#        with $<simple-link> { @res.append($<simple-link>.made); }
#        with $<text2>       { @res.append('"' ~ $<text2>.made ~ '"'); }
#        make 'Cell[TextData[{' ~ @res.join(', ') ~ '}], "Text"]';
#    }
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
    #method ws($/) { make $/.Str; }
}

