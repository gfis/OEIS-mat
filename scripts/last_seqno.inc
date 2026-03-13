#----
sub last_seqno { # get aseqno from history.txt
    my ($makefile) = @_;
    map {   #        1   1
            if (m{\/A(\d+)}) { # take the 1st
                return $1;
            }
        }
        split(/\n/, `make -f $makefile histoeis`);
    return "";
} # last_seqno
1;
