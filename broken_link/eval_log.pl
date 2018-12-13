#!/usr/bin/perl

# Evaluate wget logfile.
# determine whether the connection failed, or which
# return code was received. 
# For 3xx codes, get the redirect location
# 2018-12-112: revived
# 2009-01-07, Georg Fischer 
#-----------------------------------
use strict;

$/ = "\n--"; # split into blocks separated by "\n--"

while (<>) {
    my $block = $_;
    $block =~ m[\-\- ([^\n]+)];
    my $url = $1;
    my $result = "unknown";
    my $redirect = "";
    if (0) {
    } elsif ($block =~m[\.\.\.\s*failed.\s*([^\n]*)]) {
        $result = $1;       
    } elsif ($block =~ m[HTTP request sent\, awaiting response\.\.\.\s*(\S+)]) {
        $result = $1;       
        if ($result =~ m[\A3]) {
            if ($block =~ m[Location:\s*(\S+)]) {
                $redirect = $1;
            }
        }
    }
    print "$result\t$url\t$redirect\n";
} # while <>

__DATA__
--00:17:01--  http://contentdm.lib.byu.edu/cdm4/item_viewer.php?CISOROOT=/ETD&CISOPTR=388&CISOBOX=1&REC=3
           => `item_viewer.php?CISOROOT=%2FETD&CISOPTR=388&CISOBOX=1&REC=3'
Resolving contentdm.lib.byu.edu... 128.187.72.31
Connecting to contentdm.lib.byu.edu|128.187.72.31|:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: unspecified [text/html]
200 OK

--00:17:02--  http://cosmos.ucc.ie/~cjvdb1/html/binops.shtml
           => `binops.shtml'
Resolving cosmos.ucc.ie... 143.239.159.63
Connecting to cosmos.ucc.ie|143.239.159.63|:80... connected.
HTTP request sent, awaiting response... 302 Found
Location: http://cjb.ie/cs/html/binops.shtml [following]
--00:17:03--  http://cjb.ie/cs/html/binops.shtml
           => `binops.shtml'
Resolving cjb.ie... 81.17.252.5
Connecting to cjb.ie|81.17.252.5|:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: unspecified [text/html]
200 OK

--00:17:24--  http://cs.roanoke.edu/~shende/Papers/Snakes/MaxReversible.ps
           => `MaxReversible.ps'
Resolving cs.roanoke.edu... 199.111.151.8
Connecting to cs.roanoke.edu|199.111.151.8|:80... failed: Connection timed out.
Giving up.

--00:17:29--  http://cvm.msu.edu/~dobrzele/dp/Automata/
           => `index.html'
Resolving cvm.msu.edu... 35.8.208.37
Connecting to cvm.msu.edu|35.8.208.37|:80... connected.
HTTP request sent, awaiting response... 301 Moved Permanently
Location: http://user.cvm.msu.edu/~dobrzele/dp/Automata/ [following]
--00:17:30--  http://user.cvm.msu.edu/~dobrzele/dp/Automata/
           => `index.html'
Resolving user.cvm.msu.edu... 35.8.208.14
Connecting to user.cvm.msu.edu|35.8.208.14|:80... connected.
HTTP request sent, awaiting response... 404 Not Found
00:17:31 ERROR 404: Not Found.

--00:17:46--  http://demonstrations.wolfram.com/CanonicalPolygons/
           => `index.html'
Resolving demonstrations.wolfram.com... 140.177.205.90
Connecting to demonstrations.wolfram.com|140.177.205.90|:80... connected.
HTTP request sent, awaiting response... 403 Forbidden
00:17:46 ERROR 403: Forbidden.


--00:17:58--  http://dlmf.nist.gov/Contents/AI/AI.4.html
           => `AI.4.html'
Resolving dlmf.nist.gov... 129.6.13.90
Connecting to dlmf.nist.gov|129.6.13.90|:80... connected.
HTTP request sent, awaiting response... 404 /dlmfpub/Contents/AI/AI.4.html
00:17:59 ERROR 404: /dlmfpub/Contents/AI/AI.4.html.

--00:18:00--  http://dmtcs.loria.fr/proceedings/html/dmAC0122.abs.html
           => `dmAC0122.abs.html'
Resolving dmtcs.loria.fr... failed: Connection timed out.
--00:18:02--  http://dmtcs.loria.fr/proceedings/html/pdfpapers/dmAA0103.pdf
           => `dmAA0103.pdf'
Resolving dmtcs.loria.fr... failed: Name or service not known.
--00:18:04--  http://dmtcs.loria.fr/proceedings/html/pdfpapers/dmAA0112.pdf
           => `dmAA0112.pdf'
Resolving dmtcs.loria.fr... failed: Name or service not known.

--00:18:35--  http://dx.doi.org/10.1006/jsco.1999.1011
           => `jsco.1999.1011'
Connecting to dx.doi.org|38.100.138.149|:80... connected.
HTTP request sent, awaiting response... 302 Moved Temporarily
Location: http://linkinghub.elsevier.com/retrieve/pii/S0747717199910118 [following]
--00:18:36--  http://linkinghub.elsevier.com/retrieve/pii/S0747717199910118
           => `S0747717199910118'
Connecting to linkinghub.elsevier.com|198.185.19.37|:80... connected.
HTTP request sent, awaiting response... 302 Found
Location: http://www.sciencedirect.com/science?_ob=GatewayURL&_origin=inwardhub&_urlversion=4&_method=citationSearch&_piikey=S0747717199910118&_version=1&md5=3564e01843b27c653857c0e9b7a9b349 [following]
--00:18:36--  http://www.sciencedirect.com/science?_ob=GatewayURL&_origin=inwardhub&_urlversion=4&_method=citationSearch&_piikey=S0747717199910118&_version=1&md5=3564e01843b27c653857c0e9b7a9b349
           => `science?_ob=GatewayURL&_origin=inwardhub&_urlversion=4&_method=citationSearch&_piikey=S0747717199910118&_version=1&md5=3564e01843b27c653857c0e9b7a9b349'
Connecting to www.sciencedirect.com|198.81.200.2|:80... connected.
HTTP request sent, awaiting response... 400 Bad Request
00:18:36 ERROR 400: Bad Request.


