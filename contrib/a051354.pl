#!perl

while(<DATA>) {
  my $line = $_;
  my @coeffs = map { $_ = substr($_, 1); 
      if (($_ % 4) != 0) { 
          print STDERR "######## $_ % 4 != 0\n"; 
      } $_  
      } ($line =~ m{(\^\d+)}g);
  $line =~ s{\^(\d+)}{"^" . ($1/4)}eg;
  $line =~ s{t\^}{x\^}g;
  print $line;
} # while
__DATA__
make runpf NT=1001 NUM="1 + t^8 - t^12 + 2 t^16 + 3 t^24 + t^28 + 12 t^32 + 
   13 t^36 + 34 t^40 + 43 t^44 + 107 t^48 + 157 t^52 + 335 t^56 + 
   549 t^60 + 1094 t^64 + 1861 t^68 + 3501 t^72 + 5965 t^76 + 
   10728 t^80 + 18041 t^84 + 31051 t^88 + 51025 t^92 + 84427 t^96 + 
   134865 t^100 + 215008 t^104 + 333369 t^108 + 513542 t^112 + 
   773052 t^116 + 1153627 t^120 + 1688292 t^124 + 2447124 t^128 + 
   3487706 t^132 + 4922301 t^136 + 6845055 t^140 + 9427941 t^144 + 
   12816307 t^148 + 17262549 t^152 + 22980000 t^156 + 
   30324507 t^160 + 39594318 t^164 + 51272203 t^168 + 
   65756890 t^172 + 83679250 t^176 + 105549085 t^180 + 
   132161437 t^184 + 164140047 t^188 + 202451163 t^192 + 
   247823660 t^196 + 301389903 t^200 + 363960630 t^204 + 
   436814071 t^208 + 520802553 t^212 + 617312656 t^216 + 
   727180701 t^220 + 851846951 t^224 + 992056493 t^228 + 
   1149232929 t^232 + 1323941514 t^236 + 1517506330 t^240 + 
   1730214602 t^244 + 1963201767 t^248 + 2216376776 t^252 + 
   2490597453 t^256 + 2785299743 t^260 + 3100983710 t^264 + 
   3436532034 t^268 + 3792023955 t^272 + 4165731123 t^276 + 
   4557273329 t^280 + 4964284431 t^284 + 5385917115 t^288 + 
   5819175192 t^292 + 6262771875 t^296 + 6713128315 t^300 + 
   7168581264 t^304 + 7625054128 t^308 + 8080605429 t^312 + 
   8530781308 t^316 + 8973489231 t^320 + 9404047193 t^324 + 
   9820361028 t^328 + 10217690359 t^332 + 10594101406 t^336 + 
   10944974102 t^340 + 11268698558 t^344 + 11560953224 t^348 + 
   11820605627 t^352 + 12043796179 t^356 + 12230003475 t^360 + 
   12375970644 t^364 + 12481889419 t^368 + 12545212616 t^372 + 
   12566910422 t^376 + 12545212616 t^380 + 12481889419 t^384 + 
   12375970644 t^388 + 12230003475 t^392 + 12043796179 t^396 + 
   11820605627 t^400 + 11560953224 t^404 + 11268698558 t^408 + 
   10944974102 t^412 + 10594101406 t^416 + 10217690359 t^420 + 
   9820361028 t^424 + 9404047193 t^428 + 8973489231 t^432 + 
   8530781308 t^436 + 8080605429 t^440 + 7625054128 t^444 + 
   7168581264 t^448 + 6713128315 t^452 + 6262771875 t^456 + 
   5819175192 t^460 + 5385917115 t^464 + 4964284431 t^468 + 
   4557273329 t^472 + 4165731123 t^476 + 3792023955 t^480 + 
   3436532034 t^484 + 3100983710 t^488 + 2785299743 t^492 + 
   2490597453 t^496 + 2216376776 t^500 + 1963201767 t^504 + 
   1730214602 t^508 + 1517506330 t^512 + 1323941514 t^516 + 
   1149232929 t^520 + 992056493 t^524 + 851846951 t^528 + 
   727180701 t^532 + 617312656 t^536 + 520802553 t^540 + 
   436814071 t^544 + 363960630 t^548 + 301389903 t^552 + 
   247823660 t^556 + 202451163 t^560 + 164140047 t^564 + 
   132161437 t^568 + 105549085 t^572 + 83679250 t^576 + 
   65756890 t^580 + 51272203 t^584 + 39594318 t^588 + 
   30324507 t^592 + 22980000 t^596 + 17262549 t^600 + 
   12816307 t^604 + 9427941 t^608 + 6845055 t^612 + 4922301 t^616 + 
   3487706 t^620 + 2447124 t^624 + 1688292 t^628 + 1153627 t^632 + 
   773052 t^636 + 513542 t^640 + 333369 t^644 + 215008 t^648 + 
   134865 t^652 + 84427 t^656 + 51025 t^660 + 31051 t^664 + 
   18041 t^668 + 10728 t^672 + 5965 t^676 + 3501 t^680 + 1861 t^684 + 
   1094 t^688 + 549 t^692 + 335 t^696 + 157 t^700 + 107 t^704 + 
   43 t^708 + 34 t^712 + 13 t^716 + 12 t^720 + t^724 + 3 t^728 + 
   2 t^736 - t^740 + t^744 + t^752" 
   DEN="- t^12 - 17*t^256 - 16*t^260 - 5*t^264 - 5*t^268 + 6*t^272 + 3*t^276 + 18*t^280 + 12*t^284 - 4*t^288 - 3*t^292 - 2*t^296 - 14*t^300 - 17*t^304 - 11*t^308 - t^312 + 4*t^316 - t^20 - 10*t^320 + 9*t^324 + 15*t^328 + 6*t^332 + 4*t^340 + 11*t^344 - 2*t^348 - 13*t^352 + 11*t^360 - 10*t^364 - t^368 + 5*t^372 + 10*t^376 - 5*t^380 - 4*t^24 - 12*t^384 + 3*t^388 + 3*t^392 - 12*t^396 - 5*t^400 + 10*t^404 + 5*t^408 - t^412 - 10*t^416 + 11*t^420 - 13*t^428 - 2*t^432 + 11*t^436 + 4*t^440 - t^28 + 6*t^448 + 15*t^452 + 9*t^456 - 10*t^460 + 4*t^464 - t^468 - 11*t^472 - 17*t^476 - 14*t^480 - 2*t^484 - 3*t^488 - 4*t^492 + 12*t^496 + 18*t^500 + 3*t^504 + 6*t^508 + t^32 - 5*t^512 - 5*t^516 - 16*t^520 - 17*t^524 - t^528 + t^532 + 4*t^536 + 16*t^540 + 20*t^544 + 15*t^548 + 12*t^552 - 2*t^556 + 6*t^560 - 11*t^564 - 18*t^568 - 11*t^572 + 3*t^36 - 9*t^576 - 6*t^580 - 3*t^584 + 5*t^588 + 16*t^592 + 9*t^596 + 8*t^604 - 5*t^608 - 12*t^612 - 16*t^616 - 11*t^620 - t^624 - 5*t^628 + t^632 + 16*t^636 + t^40 + 14*t^640 + 7*t^644 + 6*t^648 + 4*t^652 + 4*t^656 - 11*t^660 - 9*t^664 - t^668 - 6*t^672 - 5*t^676 + 8*t^684 + 6*t^688 + 2*t^692 + 3*t^696 + 6*t^700 + 4*t^44 - 5*t^704 - 8*t^708 - 6*t^712 - 3*t^716 - 3*t^720 - 4*t^724 + 4*t^728 + 7*t^732 + 4*t^736 + t^740 + 3*t^744 + t^748 - t^752 - 4*t^756 - t^760 + 7*t^48 - t^768 + t^780 + 4*t^52 - 4*t^56 - 3*t^60 - 3*t^64 - 6*t^68 - 8*t^72 - 5*t^76 + 6*t^80 + 3*t^84 + 2*t^88 + 6*t^92 + 8*t^96 - 5*t^104 - 6*t^108 - t^112 - 9*t^116 - 11*t^120 + 4*t^124 + 4*t^128 + 6*t^132 + 7*t^136 + 14*t^140 + 16*t^144 + t^148 - 5*t^152 - t^156 - 11*t^160 - 16*t^164 - 12*t^168 - 5*t^172 + 8*t^176 + 9*t^184 + 16*t^188 + 5*t^192 - 3*t^196 - 6*t^200 - 9*t^204 - 11*t^208 - 18*t^212 - 11*t^216 + 6*t^220 - 2*t^224 + 12*t^228 + 15*t^232 + 20*t^236 + 16*t^240 + 4*t^244 + t^248 - t^252 + 1"
   | tee x.tmp