#!perl

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
  #                "I" (inverse, first occurrence of a number)
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
  use strict;

  my $appear = 2;
  my $sDebug  = 0;
  my $first  = 0;
  my $noTerms    = 256;
  my $method = "A";
  my $noeis  = "030707";
  my $offset = 1;
  my $parm   = 0;
  my $row    = 3; # count in both rows, output both; default
  my $start  = 1;
  my $with0  = 0;

  my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst)
    = localtime (time);
  my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d"
    , $year + 1900, $mon + 1, $mday, $hour, $min);
  my $mK = $offset;
  my $mK2 = $mK; # copy of k, running as if it were rule A
  my %inverse = (); # inverse sequence
  my $mCurMax = $start - 1;
  my $mSegNo = 0;
  my @mSegment = ();
  # $mSegment[i+0] = attribute, how often (i = 1, 3, 5 ..)
  # $mSegment[i+1] = noun, which number is counted,
  # always this order, increasing nouns, always complete with zero attributes
  my @mCount;  # temporary copy of the attributes
  my @m1stApp; # 1st appearance of a noun
  my @mSeqLen = (1); # cumulative length of sequence so far, indexed with $mSegNo
  my $attr;   # attribute, count of nouns
  my $noun;   # the numbers to be counted

  &main();

  sub A055187() {
    # first segment
    $noun = 0;
    while ($noun < $start) { # fill before $start
      push(@mSegment, 0, $noun);
      $noun ++;
    } # while filling
    push(@mSegment, 1, $start);
    
    # first b-file entry
    if (0) {
    } elsif ($method =~ m{[ABIJKP]}i) {
      if (($row & 1) != 0) {
        &emit($start, -1);
      }
    } elsif ($method =~ m{[D]}i) {
      &store($start);
    } elsif ($method =~ m{[N]}i) {
      # &store(1);
      $mSeqLen[0] = 0;
    } elsif ($method =~ m{[S]}i) {
    } elsif ($method =~ m{[T]}i) {
      if ($noeis eq "240508") {
        &store(1);
      }
    } else {
      die "invalid method \"$method\" at bf(1)\n";
    }
    push(@m1stApp, $start);
    $mSegNo ++;
  }
  sub advance { # count between 0 and $nmax, and store in @mCounts
    my $amax = -1; # $nmax is the current segment length / 2
    if (1) { # compute length of current segment
      $mSeqLen[$mSegNo] = 0; # number of elements in segment
      for (my $iseg = $first; $iseg < scalar(@mSegment); $iseg += 2) { # increment for valid entries
        $attr = $mSegment[$iseg + 0];
        $noun = $mSegment[$iseg + 1];
        if ($attr != 0 or ($with0 & 1) != 0) {
          $mSeqLen[$mSegNo] ++;
        }
      } # for incrementing
    } # segment length
  
    if ($sDebug >= 1) {
      print "seg#$mSegNo:";
      for (my $iseg = $first; $iseg < scalar(@mSegment); $iseg += 2) { # print the elements of this segment
        $attr = $mSegment[$iseg + 0];
        $noun = $mSegment[$iseg + 1];
        print " $attr.$noun";
      } # for copying
      print "   mSeqLen=$mSeqLen[$mSegNo]\n";
      print "m1stApp: " . join(" ", @m1stApp) . "\n";
    } # debug
  
    # now the b-file entries
    if (0) {
    } elsif ($method =~ m{[ABIJKP]}i) { # first or second row or both
      if (0) {
      } elsif ($appear == 1) { # order of first appearance
        for (my $iapp = 0; $iapp < scalar(@m1stApp)     ; $iapp ++) {
          my $iseg = $m1stApp[$iapp] << 1;
          $attr = $mSegment[$iseg + 0];
          $noun = $mSegment[$iseg + 1];
          if ($attr != 0 or ($with0 & 1) != 0) {
            &emit($attr, $noun); # for method I: store %inverse only
          }
        } # for
      } elsif ($appear == 2) { # decreasing order
        for (my $iseg = scalar(@mSegment) - 2; $iseg >= $first; $iseg -= 2) {
          $attr = $mSegment[$iseg + 0];
          $noun = $mSegment[$iseg + 1];
          if ($attr != 0 or ($with0 & 1) != 0) {
            &emit($attr, $noun); # for method I: store %inverse only
          }
        } # for
      } elsif ($appear == 3) { # increasing order
        for (my $iseg = $first; $iseg < scalar(@mSegment)     ; $iseg += 2) {
          $attr = $mSegment[$iseg + 0];
          $noun = $mSegment[$iseg + 1];
          if ($attr != 0 or ($with0 & 1) != 0) {
            &emit($attr, $noun); # for method I: store %inverse only
          }
        } # for
      } else {
        die "invalid parameter op=\"$appear\"\n";
      }
  
    } elsif ($method =~ m{[D]}i) { # new terms (for $appear eq "fa")
      if ($sDebug >= 1) {
        print "range " . ($mSeqLen[$mSegNo - 1]) . ".." . ($mSeqLen[$mSegNo] - 1) . "\n";
      }
      for (my $iapp = $mSeqLen[$mSegNo - 1]; $iapp < $mSeqLen[$mSegNo]; $iapp ++) {
        my $iseg = $m1stApp[$iapp] << 1;
        $attr = $mSegment[$iseg + 0];
        $noun = $mSegment[$iseg + 1];
        if ($attr != 0 or ($with0 & 1) != 0) {
          &emit($attr, $noun);
        }
      } # for
  
    } elsif ($method =~ m{[N]}i) { # no. of new terms in segment
      &emit($mSeqLen[$mSegNo] - $mSeqLen[$mSegNo - 1], -1);
  
    } elsif ($method =~ m{[T]}i) { # no. of terms in segment
      &emit($mSeqLen[$mSegNo], -1);
    }
    # compute following segment
    for (my $iseg = $first; $iseg < scalar(@mSegment) ; $iseg += 2) { # copy attr and determine maximum attr
      $attr = $mSegment[$iseg + 0];
      $noun = $mSegment[$iseg + 1];
      $mCount[$noun] = $attr; # copy old attr
      if ($attr > $amax) {
        $amax = $attr;
      }
    } # for copying
    my $last_noun = $noun;
  
    $noun = $last_noun + 1;
    while ($noun <= $amax) { # insert nouns with 0 attributes
      $mCount[$noun ++] = 0;
    } # while inserting
    my $ffCount = $noun;
  
    # now add all (or row1, row2) to @mCount
    if (0) {
    } elsif ($appear == 1) {
      for (my $iapp = 0; $iapp < $mSeqLen[$mSegNo]; $iapp ++) {
        &assemble($m1stApp[$iapp] << 1);
      } # for $iapp
    } else { # "io", "do"
      for (my $iseg = $first; $iseg < scalar(@mSegment); $iseg += 2) { # add
        &assemble($iseg);
      } # for $iseg
    } # "io", "do"
  
    # copy it back to the segment
    my $iseg = 0;
    $noun = 0;
    while ($noun < $ffCount) { # add
      $mSegment[$iseg + 0] = $mCount[$noun];
      $mSegment[$iseg + 1] = $noun;
      $iseg += 2;
      $noun ++;
    } # while copying back
  } # sub advance
  #----------------
  sub assemble {
    my ($iseg) = @_;
    $attr = $mSegment[$iseg + 0];
    $noun = $mSegment[$iseg + 1];
    if (($attr != 0 or ($with0 & 1) != 0) and ($row != 6)) {
      if ($mCount[$attr] == 0) { # appears for the first time
        push(@m1stApp, $attr);
      }
      $mCount[$attr] ++;
    }
    if (($attr != 0 or ($with0 & 1) != 0) and ($noun != 0 or ($with0 & 2) != 0) and ($row != 5)) {
      $mCount[$noun] ++;
    }
    if ($attr == 0 and $noeis eq "079668") {
      $first = 0;
    }
  } # assemble
  #----------------
  sub emit {
    if ($mK > $noTerms) {
      return;
    }
    my ($attr, $noun) = @_;
    if (0) {
    } elsif ($method =~ m{P}i) {
      if ($attr == $parm) {
        &store($mK2);
      }
      $mK2 ++;
    } elsif ($method =~ m{I}i) {
      if (! defined($inverse{$attr})) {
        # assume that method "I" is called with row=1 only !
        $inverse{$attr} = $mK;
        if ($sDebug >= 1) {
          print "# stored $mK in inverse{$attr}\n";
        }
      }
      $mK ++;
    } elsif ($method =~ m{J}i) {
      if ($attr > $mCurMax) {
        &store($attr);
        $mCurMax = $attr;
      }
      $mK2 ++;
    } elsif ($method =~ m{K}i) {
      if ($attr > $mCurMax) {
        &store($mK2);
        $mCurMax = $attr;
      }
      $mK2 ++;
    } elsif ($noun < 0) {
        &store($attr);
    } elsif ($method =~ m{N}i) {
        &store($attr);
    } elsif ($method =~ m{T}i) {
        &store($attr);
    } elsif ($method =~ m{[AD]}i) { # attribute before noun
      if (($row & 1) != 0) {
        &store($attr);
      }
      if (($row & 2) != 0 and $mK <= $noTerms) {
        &store($noun);
      }
    } elsif ($method =~ m{[BD]}i) { # noun before attribute
      if (($row & 1) != 0) {
        &store($noun);
      }
      if (($row & 2) != 0 and $mK <= $noTerms) {
        &store($attr);
      }
    } else {
      die "invalid method \"$method\" in sub bfile\n";
    }
  } # emit
  
  sub store {
    my ($val) = @_;
    print "$mK $val\n";
    ++$mK;
  }
  
  sub main {
    while (scalar(@ARGV) > 0) {
      my $opt = shift(@ARGV);
      if (0) {
      } elsif ($opt eq "-a") { $appear  = shift(@ARGV);
      } elsif ($opt eq "-d") { $sDebug  = shift(@ARGV);
      } elsif ($opt eq "-f") { $first   = shift(@ARGV);
      } elsif ($opt eq "-l") { $noTerms = shift(@ARGV);
      } elsif ($opt eq "-m") { $method  = shift(@ARGV);
      } elsif ($opt eq "-n") { $noeis   = shift(@ARGV);
      } elsif ($opt eq "-o") { $offset  = shift(@ARGV);
      } elsif ($opt eq "-p") { $parm    = shift(@ARGV);
      } elsif ($opt eq "-r") { $row     = shift(@ARGV);
      } elsif ($opt eq "-s") { $start   = shift(@ARGV);
      } elsif ($opt eq "-w") { $with0   = shift(@ARGV);
      } else { die "invalid option \"$opt\"\n";
      }
    } # while ARGV
    
    if ($sDebug == 99) {
      print " [http://oeis.org/A$noeis A$noeis] $method $start $appear $row";
      if ($offset != 1) { print " offset=$offset"; }
      if ($first  != 0) { print " first=$first"; }
      if ($parm   != 0) { print " parm=$parm"; }
      if ($with0  != 0) { print " with0=$with0"; }
      print "\n";
      exit(0);
    }
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
    if ($sDebug == 98) { # seq4 format
      print join("\t", "A$noeis", "cumulcnt", $offset, $method, $start, $appear, $row, $first, $with0, $parm) . "\n";
      exit(0);
    }
    print <<"GFis";
    # http://oeis.org/A$noeis/b$noeis.txt: table n,a(n) for n=1..$noTerms
    # Generated  on $timestamp by
    # perl cumulcount.pl -m $method -r $row -n $noeis -l $noTerms -a $appear -f $first -o $offset -s $start -p $parm -w $with0
GFis
    
    &A055187();
    # main loop
    while ($mK <= $noTerms and $mSegNo <= $noTerms) { # compute new segment from current
      &advance();
      $mSegNo ++;
    } # while b-file
    
    if ($method =~ m{I}i) { # special treatment of the inverse
      $mK = 1;
      foreach my $attr (sort {$a <=> $b} (keys(%inverse))) {
        last if $attr > $mK; # must be monotone
        &store($inverse{$attr});
      } # foreach
    } # method I
  } 
  