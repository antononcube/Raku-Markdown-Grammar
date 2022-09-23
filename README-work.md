# Markdown::Grammar (Raku package)

## In brief

Markdown parser suitable for making converters of Markdown files into files of different kind of formats:
- [X] Mathematica notebook
- [ ] RMarkdown notebook 
- [ ] Jupyter notebook
- [X] Pod6 file
- [ ] Org-mode file

### Motivation

#### Mathematica notebooks

I am most interested in generating Mathematica notebooks from Markdown. 

I have written fair amount of Raku-related Markdown documents. Many of those Markdown documents
were generated from Mathematica notebooks using 
[M2MD](https://github.com/kubaPod/M2MD), [JPp1]. 
But of course, most of the time, further changes and embellishments were made over those Markdown documents. 
Hence it would be very nice to be able to go back to Mathematica.

**Remark:** Raku can be used in Mathematica via the so called `RakuMode` -- see [AA1].

**Remark:** Markdown documents with Raku cells can be evaluated with Command Line Interface (CLI)
scripts of the package 
["Text::CodeProcessing"](https://raku.land/cpan:ANTONOV/Text::CodeProcessing), [AAp1]. 
For more details see the article 
["Connecting Mathematica and Raku"](https://rakuforprediction.wordpress.com/2021/12/30/connecting-mathematica-and-raku/), [AA1].

Here is a flowchart that gives better idea of the workflow outlined above:

```mermaid
graph TD
    Rnb[Make Raku notebook in Mathematica]-->LT
    LT[Literate programming]-->GE
    GE{Good enough?}-->|yes|CN
    CN[Convert notebook to Markdown]-->P
    P["Publish (GitHUb/WordPress)"]-->SP
    SP-->|yes|R
    R[Review and modify]-->P
    GE-->|no|LT
    SP{Needs refinement?}-->|no|CM
    CM[Convert Markdown document to notebook]-->PC
    PC["Publish to Community.wolfram.com"]   
```

#### Pod6

The notebook formats have syntax that is hard to evaluate the conversions visually. 
That is why I use Pod6 -- during development it is much easier to evaluate the Pod6 interpretations 
produced by the package. 
(I.e. no need to use another tool to open and evaluate the obtained conversion artifact.)

------

## Installation

From Zef ecosystem:

```shell
zef install Markdown::Grammar
```

From GitHub:

```shell
zef install https://github.com/antononcube/Raku-Markdown-Grammar.git
```

------

# Round trip translation

Consider the following round trip translation experiment:

1. Make a Mathematica notebook

2. Convert WL notebook into Markdown file with the Mathematica package [M2MD](https://github.com/kubaPod/M2MD)

3. Convert the obtained Markdown file into Mathematica notebook using the Raku package "Markdown::Grammar"

4. Compare the notebooks


Here is the corresponding flowchart:

```mermaid
graph TD
    wl[Make a Mathematica notebook] --> e
    e["Examine notebooks(s)"] --> m2md
    m2md["Convert to Markdown with M2MD"] --> md2wl
    md2wl["Convert to Mathematica with Markdown::Grammar"] --> |Compare|e
```

------

## Related work

### Pod6 to Markdown

- ["Raku::Pod::Render"](https://raku.land/zef:finanalyst/Raku::Pod::Render)

- ["Pod::To::Markdown"](https://raku.land/cpan:SOFTMOTH/Pod::To::Markdown)

### Markdown to HTML

- ["Markit"](https://raku.land/cpan:UZLUISF/Markit)

- ["Text::Markdown"](https://raku.land/zef:JJMERELO/Text::Markdown)

### Markdown to Pod6

*Except this 
["this package"](https://github.com/antononcube/Raku-Markdown-Grammar)
there are no other converters.*

### Jupyter to Markdown

- ["Jupyter"](https://jupyter.org) notebook interfaces have the option to be saved as Markdown files.

### Jupyter <-> Markdown

- ["jupytext"](https://jupytext.readthedocs.io/en/latest/install.html) allows the conversion 
  of Jupyter notebooks from and to Markdown.

- ["pandoc"](https://pandoc.org)allows the conversion
  of Jupyter notebooks from and to Markdown.

------

## Command line interface

The package provides a Command Line Interface (CLI) script, `from-markdown`. Here is its usage message:

```shell
>from-markdown --help
# Usage:
#  from-markdown [-t|--to=<Str>] [-o|--output=<Str>] <file> -- Converts Markdown files into Mathematica notebooks.
#  
#    <file>               Input file.
#    -t|--to=<Str>        Format to convert to. (One of 'mathematica' or 'pod6'.) [default: 'mathematica']
#    -o|--output=<Str>    Output file; if an empty string then the result is printed to stdout. [default: '']
```

------

## Usage example

Consider the following Markdown text:

```perl6
my $mtext = q:to/END/;
Here is data wrangling code:

    obj = dfTitanic;
    obj = GroupBy[ obj, #["passengerSex"]& ];
    Echo[Map[ Length, obj], "counts:"]

## References

### Articles

[AA1] Anton Antonov,
["Introduction to data wrangling with Raku"](https://rakuforprediction.wordpress.com/2021/12/31/introduction-to-data-wrangling-with-raku/),
(2021),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).
END

say $mtext.chars;
```

Here is the corresponding Mathematica notebook:

```perl6
use Markdown::Grammar;

from-markdown($mtext, to => 'mathematica')
```

Here is the corresponding Pod6 text:

```perl6
from-markdown($mtext, to => 'pod6')
```

------

## TODOs

The most important items are placed first.

- [X] DONE Parsing bold, italic, code "words."

- [ ] TODO Parsing bold, italic, code "phrases."

- [ ] TODO Parsing blocks with bold, italic formatting specs
  
- [X] DONE Parsing code blocks given with indentation.

- [X] DONE Parsing and interpretation of "deferred" links. E.g. `[![enter image description here][1]][1]`.

   - This is somewhat complicated, needing a "second pass" interpreter.
   - The "second pass" is handled in the TOP action methods.
   
- [ ] TODO Parsing quote lines and quote blocks

- [ ] TODO Parsing tables

------

## References

### Articles

[AA1] Anton Antonov,
["Connecting Mathematica and Raku"](https://rakuforprediction.wordpress.com/2021/12/30/connecting-mathematica-and-raku/),
(2021),
[RakuForPrediction at WordPress]([https://rakuforprediction.wordpress.com/).

### Guides

[MG1] [Markdown Guide](https://www.markdownguide.org).

[RD1] [Raku Pod6](https://docs.raku.org/language/pod).

### Packages

[AAp1] Anton Antonov
[Text::CodeProcessing Raku package](https://github.com/antononcube/Raku-Text-CodeProcessing),
(2021-2022),
[GitHub/antononcube](https://github.com/antononcube).

[JPp1] Jakub Podkalicki,
[M2MD](https://github.com/kubaPod/M2MD),
(2018-2022),
[GitHub/kubaPod](https://github.com/kubaPod).

