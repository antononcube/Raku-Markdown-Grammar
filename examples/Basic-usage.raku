#!/usr/bin/env raku
use v6.d;

use Markdown::Grammar;
use HTTP::Tiny;

#`[
my $mtext1 = q:to/END/;
[enter image description here][1]

[![enter image description here][2]][2]

[1]: https://i.stack.imgur.com/cUxHw.png
[2]: https://i.stack.imgur.com/XWrJB.png
END

say from-markdown($mtext1, to => 'Mathematica');
]


my $url = 'https://raw.githubusercontent.com/antononcube/Raku-LLM-Functions/main/docs/Workflows-with-LLM-functions.md';
my $response = HTTP::Tiny.new.get($url);
say $response<status>;

my $mtext2 = $response<content>.decode;
say $mtext2.chars;

say md-parse($mtext2);

