#!perl
# Shallit's constant
# 2022-08-23, Georg Fischer
use strict;
use warnings;
use integer;

my @aseqnos = ("A086276", "A356686");
while (<DATA>) {
    next if ! m{\A\d};
    s/\s+\Z//; # chompr
    my $expan = $_;
    my $seqno = substr(shift(@aseqnos), 1);
    my $bfname = "b$seqno.txt";
    open(BF, ">", $bfname) || die "cannot write $bfname";
    for (my $ibf = 0; $ibf < length($expan); $ibf ++) {
        my $digit = substr($expan, $ibf, 1);
        print ", $digit" if $ibf < 130;
        print BF "" . ($ibf + 1) . " $digit\n";
    } # for $ibf
    print BF "\n\n";
    print "\n";
    print "$bfname written\n";
    close(BF);
} # while <DATA>
#--------
__DATA__
136945140399377005843552792420621433660771875900631876657838900801471491756464698944345709273426843763414400578948143136588000258668969373319030899889087661338724042220421629124855821828996392195797332371207864807721940600187110072129181141618595948780474771320341602509471984170127755114694417686933122641568691652661120042454933291650324779877238620756313168644067581730655070193831898528418301296696
14470543500162794065643653202232215013451147766099633541911604260928884594955381538985337173235890178445261434133244032743825746860288053221130735048740033459533293814234655041913746856744460334899455135796272850688980015659307375350206718027627632733422680037199616193759421269454319307248002055846487221657971199205495888006905386036491212261165571663216645295020299203349516473157637104275782708157

 1.36945140399377005843552792420621433660771875900631
   87665783890080147149175646469894434570927342684376
   34144005789481431365880002586689693733190308998890
   87661338724042220421629124855821828996392195797332
   37120786480772194060018711007212918114161859594878
   04747713203416025094719841701277551146944176869331
   22641568691652661120042454933291650324779877238620
   756313168644067581730655070193831898528418301296696
   
p
∗
 1.44705435001627940656436532022322150134511477660996
   33541911604260928884594955381538985337173235890178
   44526143413324403274382574686028805322113073504874
   00334595332938142346550419137468567444603348994551
   35796272850688980015659307375350206718027627632733
   42268003719961619375942126945431930724800205584648
   72216579711992054958880069053860364912122611655716
   63216645295020299203349516473157637104275782708157