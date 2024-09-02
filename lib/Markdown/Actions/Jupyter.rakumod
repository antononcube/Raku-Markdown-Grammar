use v6.d;
use JSON::Fast;

#============================================================
# The actions class
#============================================================

use JSON::Fast;

class Markdown::Actions::Jupyter {
    has $.defaultLang = 'raku';

    method markdown-cell(Str:D $content) {
        return {
            "cell_type" => "markdown",
            "metadata" => {},
            "source" => $content
        }
    }
    
    method TOP($/) {
        my @mdBlocks = $<md-block>>>.made;
        
        make to-json {
            "cells" => @mdBlocks,
            "metadata" => {},
            "nbformat" => 4,
            "nbformat_minor" => 2
        };
    }

    method md-block($/) {
        make $/.values[0].made;
    }

    method md-code-block($/) {
        make {
            "cell_type" => "code",
            "execution_count" => 0,
            "metadata" => {},
            "outputs" => [],
            "source" => $<code>.Str
        };
    }

    method md-text-line($/) {
        make self.markdown-cell($/.Str);
    }

    method md-header1($/) {
        make self.markdown-cell("#### " ~ $<head>.Str);
    }

    method md-header2($/) {
        make self.markdown-cell("#### " ~ $<head>.Str);
    }

    method md-header3($/) {
        make self.markdown-cell("#### " ~ $<head>.Str);
    }

    method md-header4($/) {
        make self.markdown-cell("#### " ~ $<head>.Str);
    }

    method md-header5($/) {
        make self.markdown-cell("##### " ~ $<head>.Str);
    }

    method md-header6($/) {
        make self.markdown-cell("###### " ~ $<head>.Str);
    }

    method md-horizontal-line($/) {
        make self.markdown-cell("---");
    }

    method md-empty-line($/) {
        #make self.markdown-cell("\n");
        make Empty;
    }

    method md-quote-block($/) {
        make self.markdown-cell($/.Str);
    }

    method md-emphasize-block($/) {
        make self.markdown-cell($/.Str);
    }

    method md-item-list-block($/) {
        make self.markdown-cell($/.Str);
    }

    method md-numbered-list-block($/) {
        make self.markdown-cell($/.Str);
    }

    method md-table-block($/) {
        make self.markdown-cell($/.Str);
    }

    method md-html-block($/) {
        make self.markdown-cell($/.Str);
    }

    method md-any-block($/) {
        make self.markdown-cell($/.Str);
    }
}