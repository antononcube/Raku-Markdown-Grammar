use v6.d;

class Markdown::Actions::Pod6 {

    method TOP($/) { make $<md-block>>>.made.join("\n"); }

    method md-block($/) { make $/.values[0].made; }

    method md-code-block($/) {
        my $code = $<code>.Str;
        my $lang = '';
        with $<header><lang> {
            $lang = ' ' ~ $<header><lang>.Str;
        }
        make '=begin code' ~ $lang ~ "\n" ~ $code ~ "\n" ~ '=end code';
    }

    method md-header1($/) { make '=begin head1' ~ "\n" ~ $<head>.made ~ "\n" ~ '=end head1'; }
    method md-header2($/) { make '=begin head2' ~ "\n" ~ $<head>.made ~ "\n" ~ '=end head2'; }
    method md-header3($/) { make '=begin head3' ~ "\n" ~ $<head>.made ~ "\n" ~ '=end head3'; }
    method md-header4($/) { make '=begin head4' ~ "\n" ~ $<head>.made ~ "\n" ~ '=end head4'; }
    method md-header5($/) { make '=begin head5' ~ "\n" ~ $<head>.made ~ "\n" ~ '=end head5'; }
    method md-header6($/) { make '=begin head6' ~ "\n" ~ $<head>.made ~ "\n" ~ '=end head6'; }

    method md-horizontal-line($/) { make "=para \n" ~ ('-' x 100); }

    method md-image-simple-link($/) {
        make $<md-simple-link>.made;
    }

    method md-image-complex-link($/) {
        make $<md-simple-link>.made;
    }

    method md-simple-link($/) { make 'L<' ~ $<md-link-name>.made ~ '|' ~ $<md-link-url>.made ~ '>'; }
    method md-link-name($/) { make $/.Str; }
    method md-link-url($/) { make make $/.Str; }

    method md-word($/) { make $/.Str; }
    method md-text-element($/) { make $/.values[0].made; }
    method md-empty-line($/) { make ''; }
    method md-text-line($/) {
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

    method md-item-list-block($/) {
        make  $<md-item-list-element>>>.made.join(', ');
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
        make  $<md-numbered-list-element>>>.made.join(', ');
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
}

