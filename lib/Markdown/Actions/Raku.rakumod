use v6.d;

class Markdown::Actions::Raku {

    has Bool $.as-section-tree = False;
    has UInt $.max-level = 5;
    has $.modifier = WhateverCode;
    has Bool $.combine-adjacent-text-lines = True;

    method TOP($/) {
        my @mdBlocks = $<md-block>>>.made;

        if $!combine-adjacent-text-lines {
            @mdBlocks = self.combine-adjacent-text-lines(@mdBlocks);
        }

        if  $!as-section-tree {
            make self.section-tree(@mdBlocks, :$!max-level, :$!modifier);
        } else {
            make @mdBlocks;
        }
    }

    method md-block($/) { make $/.values[0].made; }

    method FALLBACK ($name, $/) {
        make %(level => 7, type => $name, content => $/.Str, name => Whatever);
    }

    method md-header1($/) { make %(level => 1, type => 'md-header1', content => $/.Str, name => $/.Str.trim.subst(/^ '#' \h* /, ''));}
    method md-header2($/) { make %(level => 2, type => 'md-header2', content => $/.Str, name => $/.Str.trim.subst(/^ '#'+ \h* /, ''));}
    method md-header3($/) { make %(level => 3, type => 'md-header3', content => $/.Str, name => $/.Str.trim.subst(/^ '#'+ \h* /, ''));}
    method md-header4($/) { make %(level => 4, type => 'md-header4', content => $/.Str, name => $/.Str.trim.subst(/^ '#'+ \h* /, ''));}
    method md-header5($/) { make %(level => 5, type => 'md-header5', content => $/.Str, name => $/.Str.trim.subst(/^ '#'+ \h* /, ''));}
    method md-header6($/) { make %(level => 6, type => 'md-header6', content => $/.Str, name => $/.Str.trim.subst(/^ '#'+ \h* /, ''));}

    method md-html-block($/) {
        make %(level => 7, type => 'md-html-block', content => $/.Str, name => Whatever);
    }

    method md-math-block($/) {
        make %(level => 7, type => 'md-math-block', content => $/.Str, name => Whatever);
    }

    method md-code-block($/) {
        make %(level => 7, type => 'md-code-block', content => $/.Str, name => Whatever);
    }


    method md-code-indented-block($/) {
        make %(level => 7, type => 'md-code-indented-block', content => $/.Str, name => Whatever);
    }

    method md-quote-block($/) {
        make %(level => 7, type => 'md-quote-block', content => $/.Str, name => Whatever);
    }

    method md-emphasize-block($/) {
        make %(level => 7, type => 'md-emphasize-block', content => $/.Str, name => Whatever);
    }

    method md-table-block($/) {
        make %(level => 7, type => 'md-table-block', content => $/.Str, name => Whatever);
    }

    method md-text-line($/) {
        make %(level => 7, type => 'md-text-line', content => $/.Str, name => Whatever);
    }

    #=======================================================
    multi method section-tree(@blocks,
                              UInt :$max-level = 6,
                              :$modifier = WhateverCode) {
        return self.section-tree(@blocks, 1, :$max-level, :$modifier);
    }

    multi method section-tree(@blocks,
                              UInt $level,
                              UInt :$max-level = 5,
                              :$modifier is copy = WhateverCode) {
        if $level ≤ $max-level {
            my @inds = @blocks.pairs.grep({ $_.value<level> == $level })>>.key;

            if @inds {
                my @bounds = [0, |@inds, @blocks.elems].rotor(2 => -1).grep({ $_[0] < $_[1] });

                my @content = @bounds.map({ @blocks[$_[0]]<name> => @blocks[$_[0] + 1 .. ($_[1] - 1)] });

                return @content.map({ $_.key => self.section-tree($_.value, $level + 1, :$max-level, :$modifier) }).Array;
            }
        }

        $modifier = do given $modifier {
            when $_ ~~ Str:U && $_.lc ∈ <text texts> {
                { $_.map(*<content>).join() }
            }

            when $_ ~~ Str:U && $_.lc ∈ <code code-blocks codeblocks> {
                { $_.grep({ $_<type> ∈ <md-code-block md-indented-block> }).map(*<content>).Array }
            }

            default { WhateverCode }
        }

        given $modifier {
            when WhateverCode { return @blocks }
            when Callable     { return $modifier(@blocks) }
            default           { return @blocks }
        }
    }

    #=======================================================
    method make-md-text-block(@blocks) {
        return %(level => 7, type => 'md-text-block', content => @blocks.map(*<content>).join, name => Whatever);
    }

    #=======================================================
    # Consolidate text lines into text blocks
    method combine-adjacent-text-lines(@blocks) {
        my @mdBlocks2;
        my @textBlockLines;
        for @blocks -> $b {
            if $b<type> ∈ <md-text-line md-empty-line> {
                @textBlockLines.push($b);
            } elsif @textBlockLines {
                @mdBlocks2.push(self.make-md-text-block(@textBlockLines));
                @textBlockLines = [];
                @mdBlocks2.push($b)
            } else {
                @mdBlocks2.push($b)
            }
        }

        if @textBlockLines {
            @mdBlocks2.push( self.make-md-text-block(@textBlockLines) );
        }

       return @mdBlocks2;
    }
}

