s/\s+\Z//; my ($aseqno, $superclass, $offset, $termno, $list) = split(/\t/); 
	 if ($termno >= 40) { my @terms = split(/\,/, $list); 
	 print join("\t", $aseqno, $superclass, $offset, $termno, join(",", splice(@terms, 8, 32))) . "\n"; } 
	