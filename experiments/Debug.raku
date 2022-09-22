#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use Markdown::Grammar;

my $mtext1 = q:to/END/;
[enter image description here][1]

[![enter image description here][2]][2]

[1]: https://i.stack.imgur.com/cUxHw.png
[2]: https://i.stack.imgur.com/XWrJB.png
END

say from-markdown($mtext1, to => 'Mathematica');