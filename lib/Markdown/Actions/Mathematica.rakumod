use v6.d;

class Markdown::Actions::Mathematica {

    method TOP($/) { make 'CreateDocument[{' ~ $<markdown-block>>>.made.join(', ') ~ '}]' }
    method markdown-block($/) { make $/.values[0].made; }
    method header1($/) { make 'TextCell["' ~ $<head> ~ '", "Title"]'; }
    method header2($/) { make 'TextCell["' ~ $<head> ~ '", "Section"]'; }
    method header3($/) { make 'TextCell["' ~ $<head> ~ '", "Subsection"]'; }
    method header4($/) { make 'TextCell["' ~ $<head> ~ '", "Subsubsection"]'; }
    method header5($/) { make 'TextCell["' ~ $<head> ~ '", "Subsubsubsection"]'; }
    method horizontal-line($/) { make 'TextCell["\[HorizontalLine]", "Text"]'; }
    method code-block($/) { make 'ExpressionCell[' ~ $<code> ~ ', "Input"]'; }
    method simple-link($/) { make 'Hyperlink[' ~ $<link-name>.made ~ ', ' ~ $<link-url>.made ~ ']'; }
    method link-name($/) { make '"' ~ $/.Str.subst(:g, '"', '\"') ~ '"'; }
    method link-url($/) { make 'URL["' ~ make $/.Str ~ '"]'; }
    method text-line($/) {
        my @res;
        with $<text1>       { @res.append('TextCell["' ~ $<text1>.Str ~ '", "Text"]'); }
        with $<simple-link> { @res.append('TextCell[' ~ $<simple-link>.made ~ ', "Text"]'); }
        with $<text2>       { @res.append('TextCell["' ~ $<text2>.Str ~ '", "Text"]'); }
        make 'CellGroup[' ~ @res.join(', ') ~ ']';
    }
}

