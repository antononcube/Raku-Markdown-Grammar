#!/usr/bin/env raku
use v6.d;

use lib <. lib>;

use Markdown::Grammar;
use HTTP::Tiny;

my $mtext1 = q:to/END/;
# Example Doc

## Introduction

Here is the first doc for Jupyter.

## Code

This should produce a `Rat`:

```raku
my @a;
@a[3] = 1_000 / 3;
@a[2][3] = 5;
```

Some links:

![](https://i.sstatic.net/cUxHw.png)

[![](https://i.stack.imgur.com/XWrJB.png)](https://i.stack.imgur.com/XWrJB.png)

![][3]

Each cell is its own document in Jupyter:

![][3]

[3]: https://i.stack.imgur.com/FTPpW.png

END

my $res = from-markdown($mtext1, to => 'Jupyter');

say $res;

spurt $*HOME ~ '/example-doc.ipynb', $res;

