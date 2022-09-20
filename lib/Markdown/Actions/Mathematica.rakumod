use v6.d;

class Markdown::Actions::Mathematica {

    method TOP($/) { make 'NotebookPut @ Notebook[{' ~ $<markdown-block>>>.made.join(', ') ~ '}]' }
    method markdown-block($/) { make $/.values[0].made; }
    method header1($/) { make 'Cell[TextData["' ~ $<head> ~ '"], "Title"]'; }
    method header2($/) { make 'Cell[TextData["' ~ $<head> ~ '"], "Section"]'; }
    method header3($/) { make 'Cell[TextData["' ~ $<head> ~ '"], "Subsection"]'; }
    method header4($/) { make 'Cell[TextData["' ~ $<head> ~ '"], "Subsubsection"]'; }
    method header5($/) { make 'Cell[TextData["' ~ $<head> ~ '"], "Subsubsubsection"]'; }
    method horizontal-line($/) { make 'TextCell["\[HorizontalLine]", "Text"]'; }
    method code-block($/) {
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
    method simple-link($/) { make 'ButtonBox[' ~ $<link-name>.made ~ ', BaseStyle -> "Hyperlink", ButtonData -> { ' ~ $<link-url>.made ~ ', None}]'; }
    method link-name($/) { make '"' ~ $/.Str.subst(:g, '"', '\"') ~ '"'; }
    method link-url($/) { make 'URL["' ~ make $/.Str ~ '"]'; }
    method text($/) { make $/.Str.subst(:g, '"', '\"'); }
    method text-line($/) {
        my @res;
        with $<text1>       { @res.append('"' ~ $<text1>.made ~ '"'); }
        with $<simple-link> { @res.append($<simple-link>.made); }
        with $<text2>       { @res.append('"' ~ $<text2>.made ~ '"'); }
        make 'Cell[TextData[{' ~ @res.join(', ') ~ '}], "Text"]';
    }
#    method md-word($/) { make '"' ~ $/.Str ~ '"'; }
#    method md-text-element($/) { make $/.values[0].made; }
#    method text-line($/) {
#        my @res = $/.values>>.made;
#        make 'Cell[TextData[{' ~ @res.join(', ') ~ '}], "Text"]';
#    }
}

