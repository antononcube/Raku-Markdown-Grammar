#!/usr/bin/env raku
use v6.d;

use Markdown::Grammar;
use HTTP::Tiny;

# Generic
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

# Obsidian specific
my $mtext2 = q:to/END/;

> [!info]
> Like this one.
> info

> [!warning] This is a warning!
> Like this
> warning block

> [!danger] This is a danger warning!
> See this
> danger block

Formula test:

$$
\begin{vmatrix}a & b\\\\
c & d
\end{vmatrix}=ad-bc
$$

![Engelbart|100](https://history-computer.com/ModernComputer/Basis/images/Engelbart.jpg)

END

#my $res = from-markdown($mtext2, to => 'Jupyter-Obsidian');
my $res = from-markdown($mtext2, flavor => 'obsidian', to => 'jupyter');

say $res;

spurt $*CWD ~ '/example-doc.ipynb', $res;

