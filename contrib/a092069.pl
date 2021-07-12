#!perl

my $quot = 4;
while(<DATA>) {
  my $line = $_;
  my @coeffs = map { $_ = substr($_, 1); 
      if (($_ % $quot) != 0) { 
          print STDERR "######## $_ % $quot != 0\n"; 
      } $_  
      } ($line =~ m{(\^\d+)}g);
  $line =~ s{\^(\d+)}{"^" . ($1/$quot)}eg;
  $line =~ s{t\^}{x\^}g;
  print $line;
} # while

my $maple = <<'GFis';

CoefficientList[Series[(1 + t^4 + 6*t^12 + 30*t^16 + 57*t^20 + 207*t^24 + 565*t^28 + 1000*t^32 + 2031*t^36 + 3880*t^40 + 5804*t^44 + 8696*t^48 + 12991*t^52 + 16595*t^56 + 20527*t^60 + 25965*t^64 + 29418*t^68 + 31536*t^72 + 34772*t^76 + 35273*t^80 + 33093*t^84 + 31969*t^88 + 29068*t^92 + 23862*t^96 + 20052*t^100 + 16217*t^104 + 11369*t^108 + 7996*t^112 + 5554*t^116 + 3097*t^120 + 1642*t^124 + 930*t^128 + 350*t^132 + 104*t^136 + 51*t^140 + 9*t^144 + t^148 + t^152) / ((1-t^36)^2 * (1-t^20)^2 * (1-t^12)^4 * (1-t^8)), {t,0,45}],t]

seq(coeff(series((x + 6*x^3 + 30*x^4 + 57*x^5 + 207*x^6 + 565*x^7 + 1000*x^8 + 2031*x^9 + 3880*x^10 + 5804*x^11 + 8696*x^12 + 12991*x^13 + 16595*x^14 + 20527*x^15 + 25965*x^16 + 29418*x^17 + 31536*x^18 + 34772*x^19 + 35273*x^20 + 33093*x^21 + 31969*x^22 + 29068*x^23 + 23862*x^24 + 20052*x^25 + 16217*x^26 + 11369*x^27 + 7996*x^28 + 5554*x^29 + 3097*x^30 + 1642*x^31 + 930*x^32 + 350*x^33 + 104*x^34 + 51*x^35 + 9*x^36 + x^37 + x^38 + 1) / (1 - x^2 - 4*x^3 + 2*x^5 + 6*x^6 + 2*x^7 + 2*x^8 - 6*x^9 - 7*x^10 - 6*x^11 + 8*x^12 + 8*x^13 + 3*x^14 - 8*x^15 - 6*x^16 - 6*x^17 + 3*x^18 + 12*x^19 + 15*x^20 - 15*x^22 - 12*x^23 - 3*x^24 + 6*x^25 + 6*x^26 + 8*x^27 - 3*x^28 - 8*x^29 - 8*x^30 + 6*x^31 + 7*x^32 + 6*x^33 - 2*x^34 - 2*x^35 - 6*x^36 - 2*x^37 + 4*x^39 + x^40 - x^42), x, n+1), x, n), n = 0..30);


(1,1,0,0,-1,0,-2,0,2,0,0,1,0,-1,0,1,0,-1,0,0,-2,0,2,0,1,0,0,-1,-1,1)

GFis


__DATA__
make runpf NT=46 NUM="1 + t^4 + 6*t^12 + 30*t^16 + 57*t^20 + 207*t^24 + 565*t^28 + 1000*t^32 + 2031*t^36 + 3880*t^40 + 5804*t^44 + 8696*t^48 + 12991*t^52 + 16595*t^56 + 20527*t^60 + 25965*t^64 + 29418*t^68 + 31536*t^72 + 34772*t^76 + 35273*t^80 + 33093*t^84 + 31969*t^88 + 29068*t^92 + 23862*t^96 + 20052*t^100 + 16217*t^104 + 11369*t^108 + 7996*t^112 + 5554*t^116 + 3097*t^120 + 1642*t^124 + 930*t^128 + 350*t^132 + 104*t^136 + 51*t^140 + 9*t^144 + t^148 + t^152" 
   DEN="- t^8 - 4*t^12 + 2*t^20 + 6*t^24 + 2*t^28 + 2*t^32 - 6*t^36 - 7*t^40 - 6*t^44 + 8*t^48 + 8*t^52 + 3*t^56 - 8*t^60 - 6*t^64 - 6*t^68 + 3*t^72 + 12*t^76 + 15*t^80 - 15*t^88 - 12*t^92 - 3*t^96 + 6*t^100 + 6*t^104 + 8*t^108 - 3*t^112 - 8*t^116 - 8*t^120 + 6*t^124 + 7*t^128 + 6*t^132 - 2*t^136 - 2*t^140 - 6*t^144 - 2*t^148 + 4*t^156 + t^160 - t^168 + 1"
   | tee x.tmp