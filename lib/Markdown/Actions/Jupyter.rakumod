use v6.d;
use JSON::Fast;

#============================================================
# The actions class
#============================================================

use JSON::Fast;

class Markdown::Actions::Jupyter {
    has $.defaultLang = 'raku';

    multi method make-markdown-cell(@lines --> Map:D) {
        return self.make-markdown-cell(@lines.grep(*.defined).join("\n"))
    }

    multi method make-markdown-cell(Str:D $content --> Map:D) {
        return {
            "cell_type" => "markdown",
            "metadata" => {},
            "source" => $content
        }
    }
    
    method TOP($/) {
        my @mdBlocks = $<md-block>>>.made;

        if @mdBlocks.all ~~ Map:D {
            @mdBlocks = @mdBlocks.grep({ $_<source>.chars });
        } else {
            # Consolidate text lines into text blocks
            my @mdBlocks2;
            my @textBlockLines;
            for @mdBlocks -> $b {
                if $b ~~ Pair:D && $b.key eq 'TEXTLINE' {
                    @textBlockLines.append($b.value);
                } elsif @textBlockLines {
                    @mdBlocks2.push(self.make-markdown-cell(@textBlockLines));
                    @textBlockLines = [];
                    if $b ~~ Map:D && $b<source>.chars {
                        @mdBlocks2.push($b)
                    }
                } else {
                    if $b ~~ Map:D && $b<source>.chars {
                        @mdBlocks2.push($b)
                    }
                }
            }
            if @textBlockLines {
                @mdBlocks2.push( self.make-markdown-cell(@textBlockLines) );
            }
            @mdBlocks = @mdBlocks2;
        }

        # Result
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

    method md-math-block($/) {
        my $code = $<code>.Str.trim;
        make self.make-markdown-cell('$$' ~ $code ~ '$$');
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
        my $tail = $<md-text-line-tail>.Str;
        if $tail.contains('````') {
            $tail .= subst(/ '````' (<-[`\v]>*) '````' /, -> $x { '$' ~ $x[0].Str ~ '$' }):g;
        }
        make Pair.new('TEXTLINE', $tail);
    }

    method md-header1($/) {
        make self.make-markdown-cell("# " ~ $<head>.Str);
    }

    method md-header2($/) {
        make self.make-markdown-cell("## " ~ $<head>.Str);
    }

    method md-header3($/) {
        make self.make-markdown-cell("### " ~ $<head>.Str);
    }

    method md-header4($/) {
        make self.make-markdown-cell("#### " ~ $<head>.Str);
    }

    method md-header5($/) {
        make self.make-markdown-cell("##### " ~ $<head>.Str);
    }

    method md-header6($/) {
        make self.make-markdown-cell("###### " ~ $<head>.Str);
    }

    method md-horizontal-line($/) {
        make self.make-markdown-cell("---");
    }

    method md-image-simple-link($/) {
        make Pair.new('TEXTLINE', $/.Str);
    }

    method md-image-complex-link($/) {
        make Pair.new('TEXTLINE', $/.Str);
    }

    method md-reference($/) {
        make Pair.new('TEXTLINE', $/.Str);
    }

    method md-empty-line($/) {
        make self.make-markdown-cell("");
    }

    method md-quote-block($/) {
        make self.make-markdown-cell($/.Str);
    }

    method md-emphasize-block($/) {
        make self.make-markdown-cell($/.Str);
    }

    method md-item-list-block($/) {
        make self.make-markdown-cell($/.Str);
    }

    method md-numbered-list-block($/) {
        make self.make-markdown-cell($/.Str);
    }

    method md-table-block($/) {
        make self.make-markdown-cell($/.Str);
    }

    method md-html-block($/) {
        make self.make-markdown-cell($/.Str);
    }

    method md-any-block($/) {
        make self.make-markdown-cell($/.Str);
    }
}