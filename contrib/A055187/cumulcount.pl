#!perl

use strict;

  # Generate OEIS A030707, A055187, A217760 and related
  # "cumulative counting" sequences as defined by Clark Kimberling.
  # http://faculty.evansville.edu/ck6/integer/unsolved.html, Problem 4
  # @(#) $Id$
  # 2022-01-13: debug=98 -> seq4 format
  # 2018-04-20, Georg Fischer (previosu version in cumulcount2.pl)
  #------------------------------------------------------
  # Comment from A217760:
  #   Write 0 followed by segments defined inductively as follows: each segment
  #   tells how many times each previously written integer occurs, in the order
  #   of first occurrence.  This is Method A (adjective-before-noun pairs); for
  #   Method B (noun-before-adjective), see A055168.
  # Example:
  #   Start with 0, followed by the adjective-noun pair 1,0; followed by
  #   adjective-noun pairs 2,0 then 1,1; etc. Writing the pairs vertically,
  #   the initial segments are
  #   0.|.1.|.2 1.|.3 3 1.|.4 5 2 2.|.5 6 5 3 1 1.|.6 9 6 5 2 4 1.|.7 11 8 6 4 6 4 1
  #   ..|.0.|.0 1.|.0 1 2.|.0 1 2 3.|.0 1 2 3 4 5.|.0 1 2 3 4 5 6.|.0 1  2 3 4 5 6 9
  #
  # Usage:
  #   perl cumulcount.pl -m method -r row -n noeis -l len -a appear -o offset -s start -p parm -w with0 -d debug
  #       All parameters are optional and have a default value:
  #       method = "A" (attribute over noun; default)
  #                "B" (noun over attribute)
  #                "D" (new, distinct elements)
  #                "I" (inverse, first occurrence of a number) - no longer supported
  #                "J" (next term which is greater than all previous)
  #                "K" (next position where term is greater than all previous)
  #                "N" (number of new elements in segment)
  #                "P" (positions of small numbers (parm))
  #                "S" (sum of terms in segment n)
  #                "T" (number of terms in segment n)
  #       row    =  3 (count in both rows,    output both; default)
  #                 1 (count in both rows,    output 1st)
  #                 2 (count in both rows,    output 2nd)
  #                 5 (count in 1st row only, output 1st)
  #                 6 (count in 1st row only, output 2nd)
  #       noeis  = "030707|055187|217760 ..." (OEIS number without "A", default "030707")
  #       len    = length of sequence to be generated (default: 256)
  #       appear = "io" (increasing order; default)
  #                "do" (decreasing order)
  #                "fa" (order of first appearance)
  #       first  = 0, 2 (first index in @segment)
  #       offset = 0, 1 (index f 1st b-file entry, default: 1)
  #       start  = starting value for a(1): 0, 1 (default), 3, 4, 5
  #       parm   = 2nd parameter (for rule "P"): 1, 2, 3, 4
  #       with0  =  0 (0 is not counted for neither attr nor noun)
  #                 1 (0 is counted for attr only)
  #                 2 (0 is counted for noun only)
  #                 3 (0 is counted for both attr and noun)
  #       debug  = 0 (none; default)
  #                1 (with segments)
  #--------------------------------------------------------
  my $sDebug;
  my $mAppear;
  my $mFirst;
  my $mMethod;
  my $mNoeis;
  my $mOffset;
  my $mParm;
  my $mRow; # count in both rows,    output both; default
  my $mStart;
  my $mWith0;
  my $mSegNo;
  my @mSegment;
  # $mSegment[i+0] = attribute, how often (i = 1, 3, 5 ..)
  # $mSegment[i+1] = noun, which number is counted,
  # always this order, increasing nouns, always complete with zero attributes
  my @mCount;  # temporary copy of the attributes
  my @m1stApp; # 1st appearance of a noun
  my @mSeqLen; # cumulative length of sequence so far, indexed with $mSegNo
  my $mCurMax; # for methods J, K
  my $mK;
  my $mK2;
  my @mResult; # buffer for next
  my $mResIx; # next index in mResult to be consumed by next()

  sub A055187 {
    my ($offset, $noeis, $method, $start, $appear, $row, $first, $with0, $parm) = @_;
    $mOffset = $offset;
    $mNoeis = $noeis;
    $mMethod = $method;
    $mStart = $start;
    $mAppear = $appear;
    $mRow = $row;
    $mFirst = $first;
    $mWith0 = $with0;
    $mParm = $parm;
    @mResult = ();
    $mResIx = 0;
    $mSegNo = 0;
    @mSegment = ();
    $mCurMax = $mStart - 1;
    @mSeqLen = (1);
    # first segment
    my $attr;
    my $noun = 0;
    while ($noun < $mStart) { # fill before $mStart
      push(@mSegment, 0, $noun);
      $noun ++;
    }
    push(@mSegment, 1, $mStart);

    # first b-file entry
    $mK = $mOffset;
    $mK2 = $mK; # copy of k, running as if it were rule A
    if (0) {
    } elsif ($mMethod =~ m{[ABIJKP]}i) {
      if (($mRow & 1) != 0) {
        &emit($mStart, -1);
      }
    } elsif ($mMethod =~ m{[D]}i) {
      &store($mStart);
    } elsif ($mMethod =~ m{[N]}i) {
      $mSeqLen[0] = 0;
    } elsif ($mMethod =~ m{[S]}i) {
    } elsif ($mMethod =~ m{[T]}i) {
      if ($mNoeis eq "240508") {
        &store(1);
      }
    } else {
      die "invalid method \"$mMethod\" at bf(1)\n";
    }
    push(@m1stApp, $mStart);
    $mSegNo ++;
  }

  sub advance { # count between 0 and $nmax, and store in @mCounts
    my $attr;
    my $noun;
    my $amax = -1; # $nmax is the current segment length / 2
    # compute length of current segment
    $mSeqLen[$mSegNo] = 0; # number of elements in segment
    for (my $iseg = $mFirst; $iseg < scalar(@mSegment); $iseg += 2) { # increment for valid entries
      $attr = $mSegment[$iseg + 0];
      $noun = $mSegment[$iseg + 1];
      if ($attr != 0 or ($mWith0 & 1) != 0) {
        $mSeqLen[$mSegNo] ++;
      }
    }
    if ($sDebug >= 1) {
      print "seg#$mSegNo:";
      for (my $iseg = $mFirst; $iseg < scalar(@mSegment); $iseg += 2) { # print the elements of this segment
        $attr = $mSegment[$iseg + 0];
        $noun = $mSegment[$iseg + 1];
        print " $attr.$noun";
      }
      print "   mSeqLen=$mSeqLen[$mSegNo]\n";
      print "m1stApp: " . join(" ", @m1stApp) . "\n";
    }
    # now the b-file entries
    if ($mMethod =~ m{[ABIJKP]}i) { # first or second row or both
      if ($mAppear == 1) { # order of first appearance
        for (my $iapp = 0; $iapp < scalar(@m1stApp); $iapp ++) {
          my $iseg = $m1stApp[$iapp] << 1;
          $attr = $mSegment[$iseg + 0];
          $noun = $mSegment[$iseg + 1];
          if ($attr != 0 or ($mWith0 & 1) != 0) {
            &emit($attr, $noun);
          }
        }
      } elsif ($mAppear == 2) { # decreasing order
        for (my $iseg = scalar(@mSegment) - 2; $iseg >= $mFirst; $iseg -= 2) {
          $attr = $mSegment[$iseg + 0];
          $noun = $mSegment[$iseg + 1];
          if ($attr != 0 or ($mWith0 & 1) != 0) {
            &emit($attr, $noun);
          }
        }
      } elsif ($mAppear == 3) { # increasing order
        for (my $iseg = $mFirst; $iseg < scalar(@mSegment); $iseg += 2) {
          $attr = $mSegment[$iseg + 0];
          $noun = $mSegment[$iseg + 1];
          if ($attr != 0 or ($mWith0 & 1) != 0) {
            &emit($attr, $noun);
          }
        }
      } else {
        die "invalid parameter op=\"$mAppear\"\n";
      }
    } elsif ($mMethod =~ m{[D]}i) { # new terms (for $mAppear eq "fa")
      for (my $iapp = $mSeqLen[$mSegNo - 1]; $iapp < $mSeqLen[$mSegNo]; $iapp ++) {
        my $iseg = $m1stApp[$iapp] << 1;
        $attr = $mSegment[$iseg + 0];
        $noun = $mSegment[$iseg + 1];
        if ($attr != 0 or ($mWith0 & 1) != 0) {
          &emit($attr, $noun);
        }
      }
    } elsif ($mMethod =~ m{[N]}i) { # no. of new terms in segment
      &emit($mSeqLen[$mSegNo] - $mSeqLen[$mSegNo - 1], -1);
    } elsif ($mMethod =~ m{[T]}i) { # no. of terms in segment
      &emit($mSeqLen[$mSegNo], -1);
    }
    # compute following segment
    for (my $iseg = $mFirst; $iseg < scalar(@mSegment); $iseg += 2) { # copy attr and determine maximum attr
      $attr = $mSegment[$iseg + 0];
      $noun = $mSegment[$iseg + 1];
      $mCount[$noun] = $attr; # copy old attr
      if ($attr > $amax) {
        $amax = $attr;
      }
    }
    my $last_noun = $noun;
    $noun = $last_noun + 1;
    while ($noun <= $amax) { # insert nouns with 0 attributes
      $mCount[$noun ++] = 0;
    }
    my $ffCount = $noun;
    # now add all (or row1, row2) to @mCount
    if ($mAppear == 1) {
      for (my $iapp = 0; $iapp < $mSeqLen[$mSegNo]; $iapp ++) {
        &assemble($m1stApp[$iapp] << 1);
      }
    } else { # "io", "do"
      for (my $iseg = $mFirst; $iseg < scalar(@mSegment); $iseg += 2) { # add
        &assemble($iseg);
      } # for $iseg
    }
    # copy it back to the segment
    my $iseg = 0;
    for ($noun = 0; $noun < $ffCount; $noun ++) { # add
      $mSegment[$iseg + 0] = $mCount[$noun];
      $mSegment[$iseg + 1] = $noun;
      $iseg += 2;
    }
  }

  sub assemble {
    my ($pseg) = @_;
    my $attr = $mSegment[$pseg + 0];
    my $noun = $mSegment[$pseg + 1];
    if (($attr != 0 or ($mWith0 & 1) != 0) and ($mRow != 6)) {
      if (!defined($mCount[$attr]) or $mCount[$attr] == 0) { # appears for the first time
        push(@m1stApp, $attr);
      }
      $mCount[$attr] ++;
    }
    if (($attr != 0 or ($mWith0 & 1) != 0) and ($noun != 0 or ($mWith0 & 2) != 0) and ($mRow != 5)) {
      $mCount[$noun] ++;
    }
    if ($attr == 0 and $mNoeis eq "079668") {
      $mFirst = 0;
    }
  }

  sub emit {
    my ($attr, $noun) = @_;
    if (0) {
    } elsif ($mMethod =~ m{P}i) {
      if ($attr == $mParm) {
        &store($mK2);
      }
      $mK2 ++;
    } elsif ($mMethod =~ m{I}i) {
      print STDERR "cannot process method I for A$mNoeis\n";
      exit(1);
    } elsif ($mMethod =~ m{J}i) {
      if ($attr > $mCurMax) {
        &store($attr);
        $mCurMax = $attr;
      }
      $mK2 ++;
    } elsif ($mMethod =~ m{K}i) {
      if ($attr > $mCurMax) {
        &store($mK2);
        $mCurMax = $attr;
      }
      $mK2 ++;
    } elsif ($noun < 0) {
        &store($attr);
    } elsif ($mMethod =~ m{N}i) {
        &store($attr);
    } elsif ($mMethod =~ m{T}i) {
        &store($attr);
    } elsif ($mMethod =~ m{[AD]}i) { # attribute before noun
      if (($mRow & 1) != 0) {
        &store($attr);
      }
      if (($mRow & 2) != 0) {
        &store($noun);
      }
    } elsif ($mMethod =~ m{[BD]}i) { # noun before attribute
      if (($mRow & 1) != 0) {
        &store($noun);
      }
      if (($mRow & 2) != 0) {
        &store($attr);
      }
    } else {
      die "invalid method \"$mMethod\" in sub bfile\n";
    }
  }

  sub store {
    my ($val) = @_;
    push(@mResult, $val);
    ++$mK;
  }

  sub next {
    while ($mResIx >= scalar(@mResult)) {
      &advance();
      $mSegNo ++;
    }
    return $mResult[$mResIx ++];
  }

  sub main {
    my $appear = 2;
    $sDebug  = 0;
    my $first  = 0;
    my $noTerms    = 256;
    my $method = "A";
    my $noeis  = "030707";
    my $offset = 1;
    my $parm   = 0;
    my $row    = 3; # count in both rows,    output both; default
    my $start  = 1;
    my $with0  = 0;

    while (scalar(@ARGV) > 0) {
      my $opt = shift(@ARGV);
      if (0) {
      } elsif ($opt eq "-a") {
        $appear  = shift(@ARGV);
        if (0) {
        } elsif ($appear eq "fa") {
          $appear = 1;
        } elsif ($appear eq "do") {
          $appear = 2;
        } elsif ($appear eq "io") {
          $appear = 3;
        } else  {
          # keep numeric $appear
        }
      } elsif ($opt eq "-d") {
        $sDebug  = shift(@ARGV);
      } elsif ($opt eq "-f") {
        $first   = shift(@ARGV);
      } elsif ($opt eq "-l") {
        $noTerms = shift(@ARGV);
      } elsif ($opt eq "-m") {
        $method  = shift(@ARGV);
      } elsif ($opt eq "-n") {
        $noeis   = shift(@ARGV);
      } elsif ($opt eq "-o") {
        $offset  = shift(@ARGV);
      } elsif ($opt eq "-p") {
        $parm    = shift(@ARGV);
      } elsif ($opt eq "-r") {
        $row     = shift(@ARGV);
      } elsif ($opt eq "-s") {
        $start   = shift(@ARGV);
      } elsif ($opt eq "-w") {
        $with0   = shift(@ARGV);
      } else {
        die "invalid option \"$opt\"\n";
      }
    }

    if (0) {
    } elsif ($sDebug == 99) {
      print " [http://oeis.org/A$noeis A$noeis] $method $start $appear $row";
      if ($offset != 1) { print " offset=$offset"; }
      if ($first  != 0) { print " first=$first"; }
      if ($parm   != 0) { print " parm=$parm"; }
      if ($with0  != 0) { print " with0=$with0"; }
      print "\n";
      exit(0);
    } elsif ($sDebug == 98) { # seq4 format
      print join("\t", "A$noeis", "cumulcnt", $offset, $method, $start, $appear, $row, $first, $with0, $parm) . "\n";
      exit(0);
    }

    &A055187($offset, $noeis, $method, $start, $appear, $row, $first, $with0, $parm);
    for (my $n = $offset; $n <= $noTerms; $n ++) {
      print "$n " . &next() . "\n";
    } # while b-file
  }
  &main();

