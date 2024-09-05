use v6.d;
use JSON::Fast;

#============================================================
# The actions class
#============================================================

use JSON::Fast;
use Markdown::Actions::Jupyter;
class Markdown::Actions::JupyterObsidian
        is Markdown::Actions::Jupyter {

    my regex q-block {
        ^ '>' \h+ '[!' $<type>=(\w+) ']' [\h+ $<name>=(<-[\v]>*)]? \v
        ['>' \h+ $<content>=(<-[\v]>+) [\v | $]]*
    }

    my sub to-html($code) {
        my $res = $code;
        with $code.match(&q-block) {
            $res = [
                "<div class=\"alert alert-block alert-{ $<type> }\">",
                "<b>{$<name> ?? $<name> !! $<type>.tc }</b><br/>",
                $<content>.join("<br/>"),
                '</div>'
            ].join
        }
        return $res;
    }
    method md-quote-block($/) {
        # > [!info] Callouts can have custom titles
        # > Like this one.
        # > info to show
        # <div class="alert alert-block alert-info"><b>Info</b><br />Like this one.<br />info to show</div>

        make self.make-markdown-cell(to-html($/.Str));
    }

    my sub extract-image-size(Str:D $linkName) {
        my %res = :$linkName, widthSpec => '';
        with $linkName.match(/ (<-[|]>*) '|' (\d+)/) -> $m {
            %res<linkName> = $m[0].Str;
            %res<widthSpec> = 'width="' ~ $m[1] ~ '"';
        }
        return %res<linkName widthSpec>;
    }

    # Very similar to the same-name method in Markdown::Actions::HTML::md-image-simple-link
    method md-image-simple-link($/) {
        # ![Engelbart|100](https://history-computer.com/ModernComputer/Basis/images/Engelbart.jpg)
        # <img src="https://history-computer.com/ModernComputer/Basis/images/Engelbart.jpg" alt="Engelbart" width="100"/>

        my $link;
        my $linkName;
        my $widthSpec = '';
        if $<md-link><md-simple-link> {
            $link = $<md-link><md-simple-link><md-link-url>.Str;
            $linkName = $<md-link><md-simple-link><md-link-name>.Str;
            ($linkName, $widthSpec) = extract-image-size($linkName);
        } else {
            $link = '[' ~ $<md-link><md-reference-link><md-link-label>.made ~ ']';
            $linkName = $<md-link><md-reference-link><md-link-name>.Str;
        }
        make Pair.new('TEXTLINE', '<img src="' ~ $link ~ '" alt="' ~ $linkName ~ '" ' ~ $widthSpec ~'/>');
    };
}