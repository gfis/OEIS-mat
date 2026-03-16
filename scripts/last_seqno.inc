#!perl
# Program to be included; get the currenct aseqno from Chrome's window title (last opened tab)
# 2026-03-14, Georg Fischer; used in poly_seq4.pl, ratos_seq4.pl, convol_seq4.pl
sub last_seqno { # get aseqno from history.txt 
    my $line = `tasklist /FI "STATUS eq RUNNING" /FI "IMAGENAME eq chrome.exe" /nh /v | grep OEIS`;
    my @fields = split(/\s+/, $line); 
    return substr($fields[9], 1);
}
1;
