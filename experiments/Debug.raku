#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use Markdown::Grammar;
use Markdown::Actions::Mathematica;

#-----------------------------------------------------------
my $pCOMMAND = Markdown::Grammar;

sub md-subparse(Str:D $command, Str:D :$rule = 'TOP') {
    $pCOMMAND.subparse($command, :$rule);
}

sub md-parse(Str:D $command, Str:D :$rule = 'TOP') {
    $pCOMMAND.parse($command, :$rule);
}

sub md-interpret(Str:D $command,
                 Str:D:$rule = 'TOP',
                 :$actions = Markdown::Actions::Mathematica.new) {
    $pCOMMAND.parse($command, :$rule, :$actions).made;
}

#-----------------------------------------------------------

my $mtext1 = q:to/END/;
### Execution steps
END

my $mtext2 = q:to/END/;
```perl6
my $obj = @dfTitanic ;
say "Titanic dimensions:", dimensions(@dfTitanic);
say to-pretty-table($obj.pick(7));
```
END


my $mtext3 = q:to/END/;

```mathematica
x + y == Sqrt[Integrate[f[x], {x,0,30}]]
```

-----

## References

### Articles

[AA1] Anton Antonov,
["Introduction to data wrangling with Raku"](https://rakuforprediction.wordpress.com/2021/12/31/introduction-to-data-wrangling-with-raku/),
(2021),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).
END

my $mtext4 = q:to/END/;

Here is a formula:

```mathematica
x + y == Sqrt[Integrate[f[x], {x,0,30}]]
```

Hopefully
you
got it.

No more formulas...

-----

## References

### Articles

[AA1] Anton Antonov,
["Introduction to data wrangling with Raku"](https://rakuforprediction.wordpress.com/2021/12/31/introduction-to-data-wrangling-with-raku/)
,
(2021),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AA2] Anton Antonov,
["Увод в обработката на данни с Raku"](https://rakuforprediction.wordpress.com/2022/05/24/увод-в-обработката-на-данни-с-raku/)
,
(2022),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AA3] Anton Antonov,
["Raku Text::CodeProcessing"](https://rakuforprediction.wordpress.com/2021/07/13/raku-textcodeprocessing/),
(2021),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[HW1] Hadley Wickham,
["The Split-Apply-Combine Strategy for Data Analysis"](https://www.jstatsoft.org/article/view/v040i01),
(2011),
[Journal of Statistical Software](https://www.jstatsoft.org/).

END


my $mtext5 = q:to/END/;
### Execution steps

Copy the Titanic data into a "pipeline object" and show its dimensions and a sample of it:

```perl6
my $obj = @dfTitanic ;
say "Titanic dimensions:", dimensions(@dfTitanic);
say to-pretty-table($obj.pick(7));
```

Filter the data and show the number of rows in the result set:

```perl6
$obj = $obj.grep({ $_{"passengerSex"} eq "male" and $_{"passengerSurvival"} eq "died" or $_{"passengerSurvival"} eq "survived" }).Array ;
say $obj.elems;
```

Cross tabulate and show the result:
END

say "=" x 60;

#say md-subparse($mtext3, rule => 'TOP');

say md-interpret($mtext4);
