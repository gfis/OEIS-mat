#!perl

# Clean HTML from Yahoo groups list and store it as plain text
# @(#) $Id$
# 2019-11-12, Georg Fischer
#
#:# Usage:
#:#   perl clean_yahoo.pl [-d] infile.html outfile.txt
#---------------------------------
use strict;
use integer;
use warnings;
my $version = "V1.1";
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

my $debug  = 0;
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
my $srcfile  = shift(@ARGV);
my $tarfile  = shift(@ARGV);
my $state   = "init";
my $author  = "";
my $title   = "";
my $msg_nof = "";
my $date    = "";
my $buffer  = "";
open (SRC, "<", $srcfile) || die "cannot read  \"$srcfile\"\n";
open (TAR, ">", $tarfile) || die "cannot write \"$tarfile\"\n";
print "-------- $srcfile -> $tarfile --------\n";
while (<SRC>) {
    s{\s+\Z}{}; # chompr
    my $line    = $_;
    if ($debug > 0) {
        print TAR "# $state $line\n";
    }
    if (0) {

# class="author fleft fw-600">Sebastian Martin Ruiz</div><div
    } elsif (($state eq "init")  and ($line =~ m{\Aclass\=\"author })) {
        $line =~ m{\>([^\<]+)\<};
        $author = $1;
        $state = "msid1";

# <h2 id="yg-msg-subject" class="fs-14 fw-600 sprite" data-subject="Eisenstein Mersenne and Fermat primes"  data-tooltip="Eisenstein Mersenne and Fermat primes">Eisenstein Mersenne and Fermat primes </h2>
    } elsif (($state eq "init")  and ($line =~ m{\A\s*\<h2})) {
        if ($line =~ m{ data\-subject\=\"([^\"]*)\"}) {
            $buffer = $1;
            &revert_entities();
            print TAR "$buffer\n\n";
        }

# class="cur-msg hide">
# Message 1 of 7
    } elsif (($state eq "msid1") and ($line =~ m{\Aclass\=\"cur\-msg hide})) {
        $state = "msid2";
    } elsif (($state eq "msid2") and ($line =~ m{\AMessage})) {
        $msg_nof = $line;
        $state = "date";

# class="cur-msg-dt tip" pos="bottom" data-tooltip="Message sent time">Mar 14, 2009</span>
    } elsif (($state eq "date")  and ($line =~ m{\Aclass\=\"cur\-msg\-dt tip})) {
        $line =~ m{\>([^\<]+)\<};
        $date  = $1;
        print TAR <<"GFis";
===============================================
$author     $msg_nof  $date
-----------------------------------------------
GFis
        print <<"GFis";
$msg_nof\t$date\t$author
GFis
        $state = "cont1";

# class="msg-content undoreset"><div
# id="ygrps-yiv-1936759143">Hello all:<br/>
# <br/>
    } elsif (($state eq "cont1")  and ($line =~ m{\Aclass=\"msg\-content undoreset})) {
        $state = "cont2";
    } elsif (($state eq "cont2")  and ($line =~ m{\Aid\=})) {
        $line =~ m{\> *(.*)};
        $buffer = "$1";
        $state = "cont3";
    } elsif (($state eq "cont3") ) {
# <br/>
# [Non-text portions of this message have been removed]</div></div><div
# class="msg-inline-video"></div><div
        if ($line =~ m{\<\/div\>}) {
            $line =~ s{\<\/div\>.*}{}; # remove rest
            $buffer .= $line;
            $buffer =~ s{ *\<br\/?\> *\<br\/?\> *\<br\/?\> *}{\<br\/\><br\/\>}g;
            $buffer =~ s{\<br\/?\>}{\n}g;
            $buffer =~ s{title\=\"ireply\"\> *}{\>}g;
            $buffer =~ s{\<(a|span|blockquote|div|p)[^\>]*\>}{}g;
            &revert_entities();
            print TAR "$buffer\n";
            $state = "init";
        } else {
            $buffer .= "$line";
        }
    } else { # nothing
    }
} # while <>
close(SRC);
close(TAR);
#----
sub revert_entities {
            $buffer =~ s{\<\/\w+\>}{}g;
            $buffer =~ s{\&gt\;}{\>}g;
            $buffer =~ s{\&lt\;}{\<}g;
            $buffer =~ s{\&amp\;}{\&}g;
            $buffer =~ s{\&quot\;}{\"}g;
            $buffer =~ s{\&nbsp\;}{ }g;
            $buffer =~ s{\&\#39\;}{\'}g;
            $buffer =~ s{\&\#92\;}{\\}g;
            $buffer =~ s{\&\#178\;}{²}g;
} # revert_entities
#--------------------
__DATA__
<!doctype html>
<html lang="en-US" id="Stencil">
<head >
    <script>
    YUI_config = {
        lang: "en-US",
        combine: true,
        comboBase: 'https://s.yimg.com/zz/combo?',
        root: 'yui:3.15.0/'
    };
    </script>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1"/>
    <title>Yahoo! Groups</title>
    <meta name="description" content=""/>
    <meta name="keywords" content=""/>
    <meta property="og:title" content="Yahoo! Groups" />
    <meta property="og:type" content="website" />
    <meta property="og:url" content="https://groups.yahoo.com" />
    <meta property="og:image" content="https://s1.yimg.com/dh/ap/default/130909/y_200_a.png" />
    <link rel="icon" sizes="any" mask href="https://s.yimg.com/cv/apiv2/default/icons/favicon_y19_32x32_custom.svg">
    <link rel="shortcut icon" href="https://s.yimg.com/cv/apiv2/default/fp/20180826/icons/favicon_y19_32x32.ico" />

            <link rel="dns-prefetch" href="//s.yimg.com">
        <link rel="dns-prefetch" href="//s1.yimg.com">
        <link rel="dns-prefetch" href="//xa.yimg.com">
        <link rel="dns-prefetch" href="//geo.query.yahoo.com">
        <link rel="dns-prefetch" href="//y.analytics.yahoo.com">
        <link rel="dns-prefetch" href="//sb.scorecardresearch.com">
            <script type="text/javascript" src="https://s.yimg.com/zz/combo?yui:3.15.0/yui/yui-min.js"></script>
        <script type="text/javascript" src="https://s.yimg.com/zz/combo?/ss/rapid-3.21.js&/ru/0.9.17/min/js/yg-config.js"></script><link rel="stylesheet" type="text/css" href="https://s.yimg.com/zz/combo?yui:3.15.0/build/cssreset/cssreset-min.css&/ru/0.9.17/min/css/yg-combo-smin.css"/><link rel="stylesheet" type="text/css" href="https://s.yimg.com/zz/combo?/ru/0.9.17/min/css/yg-combo-smin2.css&/ru/0.9.17/min/css/yg-media-queries-desktop.css&/ru/0.9.17/min/css/yg-skin.css"/><style> .yg-dmros-ad-warpper iframe {width:100%;}</style></head><body class=" en-us yg-ltr desktop no-js" data-device="desktop" data-ios="">
  <div class="page-loader yg-button-yellow rnd-crn-2">
    Loading ...  </div>
  <div id="screenreader-infobox" aria-live="polite"></div>
  <div id="yg-error-container" class="hide">
    <div id="yg-error-flag"><i class="yg-sprite"></i></div>
    <div id="yg-error-message">Sorry, an error occurred while loading the content.</div>
    <div id="yg-error-cross"><i class="yg-sprite"></i></div>
  </div>
  <div id="outer-wrapper" class="outer-wrapper">
    <link rel="stylesheet" href="https://s1.yimg.com/zz/combo?kx/yucs/uh3s/atomic/88/css/atomic-min.css&kx/yucs/uh_common/meta/3/css/meta-min.css&kx/yucs/uh3s/uh/410/css/uh-gs-grid-min.css" />
        <div class="ct-box yui-sv">
      <div class="ct-box-hd yui-sv-hd">
        <style type="text/css">@font-face{font-family:uh;src:url(https://s.yimg.com/os/uh-icons/0.1.16/uh/fonts/uh.eot?);src:url(https://s.yimg.com/os/uh-icons/0.1.16/uh/fonts/uh.eot?#iefix) format('embedded-opentype'),url(https://s.yimg.com/os/uh-icons/0.1.16/uh/fonts/uh.woff2?) format('woff2'),url(https://s.yimg.com/os/uh-icons/0.1.16/uh/fonts/uh.woff?) format('woff'),url(https://s.yimg.com/os/uh-icons/0.1.16/uh/fonts/uh.ttf?) format('truetype'),url(https://s.yimg.com/os/uh-icons/0.1.16/uh/fonts/uh.svg?#uh) format('svg');font-weight:400;font-style:normal}[class^=Ycon],[class*=" Ycon"]{font-family:uh;speak:none;font-style:normal;font-weight:400;font-variant:normal;text-transform:none;line-height:1;-webkit-font-smoothing:antialiased;-moz-osx-font-smoothing:grayscale}</style><link type="text/css" rel="stylesheet" href="https://s.yimg.com/zz/combo?os/stencil/3.0.1/desktop/styles-ltr.css" /><!-- meta --><div id="yucs-meta" data-authstate="signedout" data-cobrand="standard" data-crumb="" data-mc-crumb="" data-msrc="mdbm" data-gta="" data-device="desktop" data-experience="stencil-gs-grid" data-firstname="" data-style="" data-flight="1573550913" data-forcecobrand="standard" data-guid="" data-host="groups.yahoo.com" data-https="1" data-languagetag="en-us" data-property="groups" data-protocol="https" data-shortfirstname="" data-shortuserid="" data-status="active" data-spaceid="1158100131" data-test_id="" data-userid="" data-stickyheader="true" data-headercollapse="" data-uh-test="acctswitch" data-beacon="0" ></div><!-- /meta --> <div id="UH" class="Row Pos(r) Start(0) T(0) End(0) Z(10) yucs " role="banner" data-protocol='https' data-property="groups" data-spaceid="1158100131" data-stencil="true"> <style>#yucs-profile {padding-left: 0!important;}
.yucs-trigger .Icon,
.yucs-trigger b {
    line-height: 22px !important;
    height: 22px !important;
}
.yucs-trigger .Icon {
   font-size: 22px !important;
}
.yucs-trigger .AlertBadge,
.yucs-trigger .MailBadge {
    line-height: 13px !important;
    height: 13px !important;
}
.yucs-mail_link_att.yucs-property-frontpage #yucs-mail_link_id i.Icon {
    text-indent: -9999em;
}
/* mail badge */
.AlertBadge,
.MailBadge {
    padding: 3px 6px 2px 6px;
    min-width: 6px;
    max-width: 16px;
    margin-left: -13px;

}

/* search box */

#UHSearchBox {
  border: 1px solid #ceced6 !important;
  border-radius: 2px;
  height: 34px;
  *height: 18px;
}
#UHSearchBox:focus {
border: 1px solid #7590f5 !important;
  box-shadow: none !important;
}
/* buttons */
#UHSearchWeb, #UHSearchProperty {
  height: 32px !important;
  line-height: 34px !important;
-webkit-appearance: none;
}

#Stencil #UHSearchWeb,
#Stencil #UHSearchProperty {
    height: 30px;
    box-sizing: content-box;
    min-width: 92px;
    padding-left: 14px;
    padding-right: 14px;
    *width: 100%;

}

#Stencil .UHCol1{
z-index: 150;
}

body {
margin-top: 0px !important;
}
.DarkTheme .yucs-trigger .Ycon {
color: #fff;
}
#UH[data-property=groups] #uhWrapper {
max-width: 1210px;
margin: 0;
min-width: 995px;
}
/*
#UH[data-property=answers] #uhWrapper {
max-width: 1260px;
margin: 0;
min-width: 1024px;
}
*/
#UH[data-property=groups] .UHCol2{
border-left: 190px solid transparent;
padding-right: 335px;
}
/*
#UH[data-property=answers] .UHCol2{
border-left: 190px solid transparent;
padding-right: 310px;
}
*/
/*#UH[data-property=answers] .UHCol1,*/
#UH[data-property=groups] .UHCol1 {
  width: 190px;
}
#UH #Eyebrow a:link,
#UH #Eyebrow a:visited {
    -moz-osx-font-smoothing: grayscale;
}</style>  <div id="yucs-disclaimer" class="yucs-disclaimer yucs-activate yucs-hide yucs-property-groups yucs-fcb- " data-cobrand="standard" data-cu = "0" data-dsstext="Want a better search experience? {dssLink}Set your Search to Yahoo{linkEnd}" data-dsstext-mobile="Search Less, Find More" data-dsstext-mobile-ok="OK" data-dsstext-mobile-set-search="Set Search to Yahoo" data-dssstbtext="Yahoo is the preferred search engine for Firefox. Switch now." data-dssstb-ok="Yes" data-dssstb-no="Not Now" data-ylt-link="https://search.yahoo.com/searchset?pn=" data-ylt-dssbarclose="/" data-ylt-dssbaropen="/" data-ylt-dssstb-link="https://downloads.yahoo.com/sp-firefox" data-ylt-dssstbbarclose="/" data-ylt-dssstbbaropen="/" data-ylt-dssCookieCleanedSuccess="/" data-ylt-dssCookieCleanedFailed="/" data-linktarget="_top" data-lang="en-us" data-property="groups" data-device="Desktop" data-close-txt="Close this window" data-maybelater-txt = "Maybe Later" data-killswitch = "0" data-host="groups.yahoo.com" data-spaceid="1158100131" data-pn="" data-dss-cookie-cleanup="" data-pn-en-ca-mobile-frontpage="" data-pn-de-de-mobile-frontpage="" data-pn-es-es-mobile-frontpage="" data-pn-fr-fr-mobile-frontpage="" data-pn-en-in-mobile-frontpage="" data-pn-it-it-mobile-frontpage="" data-pn-en-us-mobile-frontpage="" data-pn-en-sg-mobile-frontpage="" data-pn-en-gb-mobile-frontpage="" data-pn-en-us-mobile-mail="" data-pn-en-ca-mobile-mail="" data-pn-de-de-mobile-mail="" data-pn-es-es-mobile-mail="" data-pn-fr-fr-mobile-mail="" data-pn-en-in-mobile-mail="" data-pn-it-it-mobile-mail="" data-pn-en-sg-mobile-mail="" data-pn-en-gb-mobile-mail="" data-pn-pt-br-mobile-mail="" data-pn-en-us-tablet-frontpage="" data-pn-en-us-tablet-mail="" data-pn-en-ca-tablet-mail="" data-pn-de-de-tablet-mail="" data-pn-es-es-tablet-mail="" data-pn-fr-fr-tablet-mail="" data-pn-en-in-tablet-mail="" data-pn-it-it-tablet-mail="" data-pn-en-sg-tablet-mail="" data-pn-en-gb-tablet-mail="" data-pn-pt-br-tablet-mail="" data-news-search-yahoo-com="" data-answers-search-yahoo-com="" data-finance-search-yahoo-com="" data-images-search-yahoo-com="" data-video-search-yahoo-com="" data-sports-search-yahoo-com="" data-shopping-search-yahoo-com="" data-shopping-yahoo-com="" data-us-qa-trunk-news-search-yahoo-com ="" data-dss="0"></div>   <script charset="utf-8" type="text/javascript" src="https://s.yimg.com/zz/kx/yucs/uhc/yset-search/142/js/generic_yset_search-min.js" async></script> <div id="masterNav" class='yucs-ps Bg(#2d1152)' data-ylk="rspns:nav;act:click;t1:a1;t2:uh-d;t3:tb;t5:pty;slk:pty;elm:itm;elmt:pty;itc:0;"><ul id="Eyebrow" class="Mb(12px)! Mx(0)! Mt(0)! Lh(1.7) NavLinks Z(3) H(22px) Pos(r) P(0) Whs(nw)" role="navigation"><li id="yucs-top-home" class="D(ib) Zoom Va(t) Lh(1.7) Mend(18px) Pstart(10px)"><a href="https://www.yahoo.com/" data-ylk="t5:home;slk:home;"class="Td(n)! Td(u)!:h Fz(13px) C(#fff)!"><i id="my-home" class="Fl(start) NavLinks_Lh(1.7) Mend(6px) Ycon YconHome Fz(13px) Mt(-1px) Td(n)! Td(n)!:h C(#fff)!">&#x2302;</i><b class="Mstart(-1px) Fw(400) C(#fff)!">Home</b></a></li><li id="yucs-top-mail" class="D(ib) Zoom Va(t) Lh(1.7) Mend(18px) Pstart(14px)"><a href="https://mail.yahoo.com/?.src=ym" data-ylk="t5:mail;slk:mail;"class="Td(n)! Td(u)!:h Fz(13px) C(#fff)!">Mail</a></li><li id="yucs-top-tumblr" class="D(ib) Zoom Va(t) Lh(1.7) Mend(18px) Pstart(14px)"><a href="https://www.tumblr.com" data-ylk="t5:tumblr;slk:tumblr;"class="Td(n)! Td(u)!:h Fz(13px) C(#fff)!">Tumblr</a></li><li id="yucs-top-news" class="D(ib) Zoom Va(t) Lh(1.7) Mend(18px) Pstart(14px)"><a href="https://www.yahoo.com/news" data-ylk="t5:news;slk:news;"class="Td(n)! Td(u)!:h Fz(13px) C(#fff)!">News</a></li><li id="yucs-top-sports" class="D(ib) Zoom Va(t) Lh(1.7) Mend(18px) Pstart(14px)"><a href="http://sports.yahoo.com/" data-ylk="t5:sports;slk:sports;"class="Td(n)! Td(u)!:h Fz(13px) C(#fff)!">Sports</a></li><li id="yucs-top-finance" class="D(ib) Zoom Va(t) Lh(1.7) Mend(18px) Pstart(14px)"><a href="http://finance.yahoo.com/" data-ylk="t5:finance;slk:finance;"class="Td(n)! Td(u)!:h Fz(13px) C(#fff)!">Finance</a></li><li id="yucs-top-entertainment" class="D(ib) Zoom Va(t) Lh(1.7) Mend(18px) Pstart(14px)"><a href="https://www.yahoo.com/entertainment/" data-ylk="t5:entertainment;slk:entertainment;"class="Td(n)! Td(u)!:h Fz(13px) C(#fff)!">Entertainment</a></li><li id="yucs-top-style" class="D(ib) Zoom Va(t) Lh(1.7) Mend(18px) Pstart(14px)"><a href="https://www.yahoo.com/lifestyle" data-ylk="t5:style;slk:style;"class="Td(n)! Td(u)!:h Fz(13px) C(#fff)!">Lifestyle</a></li><li id="yucs-top-answers" class="D(ib) Zoom Va(t) Lh(1.7) Mend(18px) Pstart(14px)"><a href="https://answers.yahoo.com/" data-ylk="t5:answers;slk:answers;"class="Td(n)! Td(u)!:h Fz(13px) C(#fff)!">Answers</a></li><li id="yucs-top-groups" class="D(ib) Zoom Va(t) Lh(1.7) Mend(18px) Pstart(14px)"><a href="https://groups.yahoo.com/" data-ylk="t5:groups;slk:groups;"class="Td(n)! Td(u)!:h Fz(13px) C(#fff)!">Groups</a></li><li id="yucs-top-mobile" class="D(ib) Zoom Va(t) Lh(1.7) Mend(18px) Pstart(14px)"><a href="https://mobile.yahoo.com/" data-ylk="t5:mobile;slk:mobile;"class="Td(n)! Td(u)!:h Fz(13px) C(#fff)!">Mobile</a></li><li id='yucs-more' class='D(ib) Zoom Va(t) Pos(r) Z(1) Pstart(10px) Pend(6px) MoreDropDown yucs-menu yucs-more-activate' data-ylt=""><a href="http://everything.yahoo.com/" role="button" id='yucs-more-link' class='Pos(r) Z(1) rapidnofollow D(b) Cf P(0)!' data-ylk="rspns:op;t5:more;slk:more;elmt:mu;itc:1;"><b class="Fl(start) Lh(1.7) Td(u):h MoreDropDown_C(#fff) MoreDropDown-on_C(#1d1da3)!">More</b><i class="Fz(15px) Va(m) Lh(1) C(#fff) Mstart(2px) Ycon YconArrowDown Ta(c) Td(n) Td(n):h Fl(end) Mt(4px) MoreDropDown-on_C(#1d1da3)!">&#x22c1;</i></a><div id='yucs-top-menu'><div class="Pos(a) Start(0) T(100%) MoreDropDown-Box Bdbc(#d9d9d9) Bdbs(s) Bdbw(1px) Miw(6em) Mstart(-1px) Bg(#fff) Bdstartc(#d9d9d9) Bdstarts(s) Bdstartw(1px) Bdendc(#d9d9d9) Bdends(s) Bdendw(1px) Bxsh(moresh) D(n) yui3-menu-content"><iframe frameborder="0" class="Pos(a) Start(0) W(100%) H(100%) Bd(0)" src="https://s.yimg.com/os/mit/media/m/base/images/transparent-95031.png"></iframe><ul class="yucs-leavable Pos(r) Px(10px)! My(.55em)"><li id="yucs-top-weather" ><a href="https://www.yahoo.com/news/weather" data-ylk="t5:weather;slk:weather;"class="Td(n)! Td(u)!:h Fz(13px) D(b) Zoom Py(6px) Lh(1.25) C(#1d1da3)!">Weather</a></li><li id="yucs-top-politics" ><a href="https://www.yahoo.com/politics" data-ylk="t5:politics;slk:politics;"class="Td(n)! Td(u)!:h Fz(13px) D(b) Zoom Py(6px) Lh(1.25) C(#1d1da3)!">Politics</a></li><li id="yucs-top-tech" ><a href="https://www.yahoo.com/tech" data-ylk="t5:tech;slk:tech;"class="Td(n)! Td(u)!:h Fz(13px) D(b) Zoom Py(6px) Lh(1.25) C(#1d1da3)!">Tech</a></li><li id="yucs-top-shopping" ><a href="http://shopping.yahoo.com/" data-ylk="t5:shopping;slk:shopping;"class="Td(n)! Td(u)!:h Fz(13px) D(b) Zoom Py(6px) Lh(1.25) C(#1d1da3)!">Shopping</a></li></ul></div></div></li> </ul></div> <div id="uhWrapper" class="Mx(a) Z(1) Pos(r) Zoom" data-ylk="rspns:nav;act:click;t1:a1;t2:uh-d;itc:0;"> <div class="UHCol1 Pos(a) Start(0)" role="presentation"> <style>/** * IE7+ and non-retina display */.YLogoMY { background-repeat: no-repeat; background-image: url(https://s.yimg.com/rz/d/yahoo_groups_en-US_s_f_pw_351x40_groups.png); _background-image: url(https://s.yimg.com/rz/d/yahoo_groups_en-US_s_f_pw_351x40_groups.gif); /* IE6 */ width: 92px !important; }.DarkTheme .YLogoMY { background-position: -351px 0px !important;}/** * For 'retina' display */@media only screen and (-webkit-min-device-pixel-ratio: 2), only screen and ( min--moz-device-pixel-ratio: 2), only screen and ( -o-min-device-pixel-ratio: 2/1), only screen and ( min-device-pixel-ratio: 2), only screen and ( min-resolution: 192dpi), only screen and ( min-resolution: 2dppx) { .YLogoMY { background-image: url(https://s.yimg.com/rz/d/yahoo_groups_en-US_s_f_pw_351x40_groups_2x.png) !important; background-size: 702px 40px !important; }}</style><a class="YLogoMY D(b) Ov(h) Ti(-20em) Zoom Darktheme_Bgp(b_t) W(137px) H(34px) Mx(a)! " data-ylk="slk:logo;t3:logo;t5:logo;elm:img;elmt:logo;" href="https://groups.yahoo.com/" target="_top" >Yahoo Groups</a> </div> <div class="UHCol2 Pos(a) Bxz(bb)" role="presentation"> <form id="UHSearch" target="_top" autocomplete="off" data-vfr="uh3_groups_vert_gs"data-webaction="https://search.yahoo.com/search" action="https://groups.yahoo.com/neo/search" data-webaction-tar="search.yahoo.com" data-verticalaction-tar="groups.yahoo.com"  method="get"class="M(0) P(0) UHSearch-Init"><table class="W(100%) M(0)! P(0) H(100%)"> <tbody> <tr> <td class='W(100%) W-100 Va(t) Px(0)'><input id="UHSearchBox" type="text" class="yucs_W(100%) Ff(ss)! Fz(18px)! O(n):f Fw(200)! Bxz(bb) M(0)! Py(4px)! Bdrs(0)! Bxsh(n) yucs-clear-padding_Pend(35px)" style="border-color:#7590f5;" name="p" aria-describedby="UHSearchBox" data-ylk="slk:srchinpt-hddn;itc:1;" data-yltvsearch="https://groups.yahoo.com/neo/search" data-yltvsearchsugg="/" data-satype="" data-gosurl="" data-pubid="" data-appid="" data-maxresults="10" data-resize=" "> <div id="yucs-satray" class="sa-tray D(n) Fz(13px) uhFancyBox Bg(#fff) Bd(ttbd) Bxsh(ttsh) Bdrs(3px) Bdrstend(0) Bdrststart(0) Lh(1.5) C(#000) Td(n) Td(n):h" data-wstext="Search Web for: " data-wsearch="https://search.yahoo.com/search" data-vfr="uh3_groups_vert_gs" data-vsearch="https://groups.yahoo.com/neo/search" data-vstext= "Search News for: " > </div></td> <!-- ".Grid' is used here to kill white-space -->   <td class="Va(t) Tren(os) W(10%) Whs(nw) Pstart(4px) Pend(0) Bdcl(s)"><style type="text/css">#UH #UHSearchWeb { font-size:13px !important; border-radius:3px!important;}#UHSearchWeb, #UHSearchProperty{ height: 30px; min-width: 120px;} .ua-ie8 #UHSearchWeb, .ua-ie8 #UHSearchProperty, .ua-ie9 #UHSearchWeb, .ua-ie9 #UHSearchProperty{ height: 32px; min-width: 120px;}#UHSearchProperty, .Themable .ThemeReset #UHSearchProperty { background: #400090 !important; border: 0 !important; box-shadow: 0 2px #000000 !important;}</style><input id="UHSearchProperty" class="D(ib) Fz(13px) Zoom Va(t) uhBtn Ff(ss) Fw(40) Bxz(bb) Td(n) D(ib) Zoom Va(m) Ta(c) Bgr(rx) Bdrs(3px) Bdw(1px) M(0)! C(#fff) Cur(p)" type="submit" data-vfr="uh3_groups_vert_gs"data-vsearch="https://groups.yahoo.com/neo/search"value="Search Groups" data-ylk="t3:srch;t5:srchvert;slk:srchvert;elm:btn;elmt:srch;tar:groups.yahoo.com;"></td> <td class="Va(t) Tren(os) W(10%) Whs(nw) fp-default_Pstart(5px) Pstart(4px) Pend(0) Bdcl(s)"><input id="UHSearchWeb" class="D(ib) Py(0) Zoom Va(t) uhBtn Ff(ss)! Fw(40) Bxz(bb) Td(n) D(ib) Zoom Va(m) Ta(c) Bgr(rx) Bdrs(3px) Bdw(1px) M(0)! C(#fff) uh-ignore-rapid Cur(p)" type="submit" value="Search Web" data-ylk="t3:srch;t5:srchweb;slk:srchweb;elm:btn;elmt:srch;itc=0;tar:search.yahoo.com;"></td> <style type="text/css"> #UHSearchWeb { font-size:15px !important; border-radius:4px!important; } #UHSearchWeb, #UHSearchProperty{ height: 30px; } .ua-ie8 #UHSearchWeb, .ua-ie8 #UHSearchProperty, .ua-ie9 #UHSearchWeb, .ua-ie9 #UHSearchProperty{ height: 32px; } #UHSearchWeb, .Themable .ThemeReset #UHSearchWeb { background: #3775dd; border: 0; box-shadow: 0 2px #21487f; } </style>  </tr> </tbody> </table>  <input type="hidden" data-sa="0" id="fr" name="fr" data-ylk="slk:frcode-hddn;itc:1;" value="uh3_groups_web_gs" />    </form> <!-- /#uhSearchForm --> </div> <div class="UHCol3 Pos(a) End(0)" role="presentation" id="uhNavWrapper">  <ul class="Fl(end) Mend(10px)! My(6px)! Lts(-0.31em) Tren(os) Whs(nw)"> <li class="D(ib) Zoom Va(t) Pos(r) Pstart(4px) Mend(20px) Lts(n)" id="yucs-profile" data-yltmenushown="/"> <a class="D(b) MouseOver Td(n) Td(n)!:h signin yucs-trigger Lh(1) Lts($ws)" href="https://login.yahoo.com/config/login?.src=ygrp&.intl=us&.lang=en-US&.done=https://groups.yahoo.com/neo/groups/primenumbers/conversations/topics/19899" target="_top" rel="nofollow" aria-label="Profile" aria-haspopup="true" role="button" data-ylk="t3:tl-lst;t5:usersigni;slk:usersigni;elm:tl;elmt:lgi;"> <i class="Va(m) W(a) yucs-avatar Ycon YconProfile Fz(22px) Lh(1) C(#32007f) Mend(7px) Lts(n)">&#x1f464;</i> <b class="Va(m) yucs-trigger:h_Td(u) Lts(n) Fz(13px)" title="Sign in">Sign in</b></a> </li> <li class="D(ib) Zoom Va(t) Mend(20px) Pos(r) yucs-mail_link yucs-mailpreview-ancestor" id="yucs-mail"> <a id="yucs-mail_link_id" class="D(ib) sp yltasis yucs-fc Pos(r) MouseOver Td(n) Td(n)!:h yucs-menu-link yucs-trigger Lh(1) Lts($ws) Mx(-10px) My(-10px) Px(10px) Py(10px)" href="https://mail.yahoo.com/?.src=ym" data-ylk="t3:tl-lst;t5:mailsignost;slk:mailsignost;elm:tl;elmt:mail;">  <i class="Va(m) W(a) Mend(7px) Ycon YconMail Lh(1) Fz(22px) Lts(n)">&#x2709;</i> <b class="Va(m) yucs-trigger:h_Td(u) Lts(n) Fz(13px)" title="Mail">Mail</b> </a> </li> <li id="yucs-help" class=" yucs-activate yucs-help yucs-menu_nav D(ib) Zoom Va(t) Pos(r)"> <a id="yucs-help_button" class="D(ib) yltasis yucs-trigger Lh(1) Td(n) Td(n):h" href="#" title="Help" aria-haspopup="true" role="button" data-ylk="rspns:op;t3:tl-lst;t4:cog-mu;t5:cogop;slk:cogop;elm:tl;elmt:cog;itc:1;"> <i class="Va(m) W(a)! Fz(22px) Ycon YconSettings C(#32007f) Lts(n) M(-10px) P(10px)">&#x2699;</i> <b class="Hidden">Help</b> </a> <div id="yucs-help_inner" class="uhFancyBox Bg(#fff) Bd(ttbd) Bxsh(ttsh) Bdrs(3px) uhArrow Mt(10px) Px(10px) Pos(a) Lh(1.4) End(0) Mend(-8px) Whs(nw) D(n) yucs-menu yucs-hm-activate" data-yltmenushown="/" aria-hidden="true"> <ul id="yuhead-help-panel" class="Mx(-10px)! Pos(r) My(0)! P(0) C(#000)"> <li class="Py(8px) Px(10px)"><a class="yucs-acct-link Td(n)! Td(u)!:h D(b) C(#000)!" href="https://login.yahoo.com/account/personalinfo?.intl=us&.lang=en-US&.done=https://groups.yahoo.com/neo/groups/primenumbers/conversations/topics/19899&amp;.src=ygrp" target="_top" data-ylk="t3:tl-lst;t4:cog-mu;t5:acctinfo;slk:acctinfo;elm:itm;elmt:acctinfo;">Account Info</a></li> <li class="Pb(8px) Px(10px)"><a id="yhelp-link" data-inproducthelp="groups" class="D(b) C(#000)! Td(n)! Td(u)!:h Fz(13px)" href="javascript:void(0);" rel="nofollow" data-ylk="t3:tl-lst;t4:cog-mu;t5:hlp;slk:hlp;elm:itm;elmt:hlp;">Help</a></li>  <li class="Px(10px) Py(8px) Bdw(0) Bdtw(1px) Bds(s) Bdc(#e2e2e6)"><a class="D(b) C(#000)! Td(n)! Td(u)!:h Fz(13px)" href="http://feedback.yahoo.com/forums/209451" rel="nofollow" data-ylk="t3:tl-lst;t4:cog-mu;t5:sggstn;slk:sggstn;elm:itm;elmt:sggstn;">Suggestions</a></li>   </ul> </div></li>  </ul> </div> </div> <div id="yhelp_container" class="yui3-skin-sam"> </div><!-- /#UH --></div><style>#Stencil body{padding-top: 84px;}#UH {position: fixed; width:100%;top:0;}</style><script charset="utf-8" type="text/javascript" src="https://s.yimg.com/zz/combo?kx/yucs/uh3s/uh/376/js/contentloaded-min.js&kx/yucs/uh3s/uh/445/js/scroll-handler-min.js" async></script><div style="display:none;" data-uh-test=""></div><!-- alert --><!-- /alert --> <!-- polyfills --><!-- /polyfills -->        </div>
      <style>
           /**
             For desktop
            */
            .YLogoMY {
                background-repeat: no-repeat;
                background-image: url(https://s.yimg.com/ru/0.9.12/min/css/yahoo_en-US_s_f_pw_351X40.png) !important;
                _background-image: url(https://s.yimg.com/ru/0.9.12/min/css/yahoo_en-US_s_f_pw_351X40.gif) !important;
                width: 137px !important;
                background-position: 0px -3px !important;
            }
            .DarkTheme .YLogoMY {
                background-position: -351px -3px !important;
            }
            /** * For 'retina' display */
            @media only screen and (-webkit-min-device-pixel-ratio: 2),
            only screen and ( min--moz-device-pixel-ratio: 2),
            only screen and ( -o-min-device-pixel-ratio: 2/1),
            only screen and ( min-device-pixel-ratio: 2),
            only screen and ( min-resolution: 192dpi),
            only screen and ( min-resolution: 2dppx) {
                .YLogoMY {
                    background-image: url(https://s.yimg.com/ru/0.9.12/min/css/yahoo_en-US_s_f_pw_351X40_2x.png) !important;
                    background-size: 702px 37px !important;
                }
            }
            /**
             For mobile devices
             */
            h2.yucs-logo-heading {
                background-image:url(https://s.yimg.com/ru/0.9.12/min/css/yahoo_en-US_f_pw_101x21_2x.png) !important;
                -webkit-background-size: 101px 34px !important;
                -moz-background-size: 101px 34px !important;
                -o-background-size: 101px 34px !important;
                background-size: 101px 34px !important;
                margin-top: 5px !important;
            }
      </style>
      <div class="ct-box-bd yui-sv-bd">
        <div style="overflow-x:hidden;"></div>
        <div class="yui-sv-content">
          <div class='yg-page'>
              <div class="navbar so-homepage-header hide">
    <div class="so-homepage-header-bd">
        <div class="so-homepage-header-mask"></div>
        <div class="so-homepage-header-txt groups_image fw-200">
            <h1 class="so-homepage-welcome-txt fw-200">Welcome to Yahoo Groups.</h1>
            <div class="so-homepage-welcome-txt2 fs-14">
                <div class="fc-gray">An extension to your real life group of friends, interests and communities.</div>
                <div>What's new :
                    <a class="fc-lightblue" href="http://help.yahoo.com/kb/index?locale=en_US&amp;y=PROD_GRPS&amp;page=content&amp;id=VI57" target="_blank">see video</a>
                </div>
            </div>
        </div>
        <!--Navbar -->
        <div class="yom-mod yom-nav group-detail-navbar">
            <div id="so-homepage-header-band">
                <ul class="nav-lt fc-gray">

                    <li id="sign-in"  class="yg-button bg-purple fs-16"><a role="button" href="https://login.yahoo.com/config/login;_ylt=AtI46q.M_jXQ2vBSmsjhpB.gwsEF?.src=ygrp&amp;.intl=us&amp;.lang=en-US&amp;.done=https%3A%2F%2Fgroups.yahoo.com%2Fneo%2Fgroups%2Fprimenumbers%2Fconversations%2Ftopics%2F19899" class="fc-white">Sign In</a></li>

                    <li class="so-header-or"><i>OR</i></li>



                    <li id="create-group"  class="yg-button bg-purple fs-16"><a role="button" class="fc-white" href="https://login.yahoo.com/config/login;_ylt=AtI46q.M_jXQ2vBSmsjhpB.gwsEF?.src=ygrp&amp;.intl=us&amp;.lang=en-US&amp;.done=https%3A%2F%2Fgroups.yahoo.com%2Fneo%2Fgroups%2Fprimenumbers%2Fconversations%2Ftopics%2F19899?creategroup=true"><i class="create-group yg-sprite"></i>Start a New Group</a></li>


                    <li class="sign-up-txt"><span>You must be a registered Yahoo user to start a group.</span><a class="fc-lightblue" href="https://login.yahoo.com/account/create?specId=yidreg&amp;.src=ygrp&amp;.intl=us&amp;.lang=en-US&amp;.done=https%3A%2F%2Fgroups.yahoo.com%2Fneo%2Fgroups%2Fprimenumbers%2Fconversations%2Ftopics%2F19899">&nbsp;&nbsp;Sign Up</a></li>

                </ul>
            </div>
        </div>
    </div>
    <!--End of navbar -->
</div>
            <div class="body-bounding-box">
              <div class="yg-grid " id="body-container">
                <div class="inf-scroll-top-wrapper">
    <div class="inf-scroll-top hide">
        <div class="back-to-top"><i class="yg-sprite"></i></div>
        <div class="scroll-to-search">
            <div class="search-icon"><i class="yg-sprite"></i></div>
            <form action="/neo/search/">
                <input class="hide" id="scroll-to-search-input" type="text" name="query" placeholder="Search">
            </form>
        </div>
    </div>
</div>                  <div class="y-col1" id="yg-left-col">
                    <div class="left-container-child">
                      <div class="yom-mod yom-allgroups yg-rapid" data-ylk="zone:leftnav;ct:conversations;v:allgroups;itc:0;intl:us;grp:primenumbers;pstcat:Number Theory;cat1:Science;cat2:Mathematics;grpst:RESTRICTED;" id="yg-allgroups" role="contentinfo" >

    <div class="browse-groups-link yom-hd fc-gray">

         <a class="fleft" href="/neo/dir">

       Browse Groups

         </a>

    </div>

<div class="yom-bd">
    <ul class="">

    </ul>

</div>


</div>
<div class="yom-mod yom-copyright yg-rapid" data-ylk="zone:leftnav;ct:conversations;v:copyright;itc:0;intl:us;grp:primenumbers;pstcat:Number Theory;cat1:Science;cat2:Mathematics;grpst:RESTRICTED;" id="yg-copyright" role="contentinfo" >

<div class="yom-bd">
    <ul class="ft-mcol">

      <li  value=""><a class='terms' href="http://info.yahoo.com/legal/us/yahoo/utos/en-us/" target="_blank">Terms</a>

    </li>

      <li  value=""><a  href="http://info.yahoo.com/privacy/us/yahoo/groups/details.html" target="_blank">Privacy</a>

    </li>

      <li  value=""><a  href="http://info.yahoo.com/guidelines/us/yahoo/groups/" target="_blank">Guidelines</a>

    </li>

      <li  value=""><a  href="http://yahoo.uservoice.com/forums/209451" target="_blank">Feedback</a>

    </li>

      <li  value=""><a  href="http://help.yahoo.com/kb/index?page=product&amp;y=PROD_GRPS&amp;locale=en_US" target="_blank">Help</a>

    </li>

      <li  value=""><a  href="http://yahoogroups.tumblr.com/" target="_blank">Blog</a>

    </li>

    </ul>

</div>


</div>
                    </div>
                  </div>
                  <div class="y-col2" id="yg-main-content">
                   <div class="main-container-child ">

        <div id="yg-blast-msg">
            <div>
                <b>Attention:</b> Starting December 14, 2019 Yahoo Groups will no longer host user created content on its sites. New content can no longer be uploaded after October 28, 2019.  Sending/Receiving email functionality is not going away, you can continue to communicate via any email client with your group members. <a data-ylk="slk:blast-info" href=https://help.yahoo.com/kb/index?page=content&y=PROD_GRPS&locale=en_US&id=SLN31010&actp=email target="_blank">Learn More</a>
            </div>
        </div>
<div class="subnav-refresh group-img-container yg-rapid" id="yg-grp-main-img" data-category="Number Theory" data-ctree="Science,Mathematics,Number Theory" data-group="primenumbers" data-role="" data-home-photo-url="https://xa.yimg.com/kq/groups/M.1KQn_ufNFoenVU/homepage/name/296729.jpg?type=hr" data-gstatus="restricted" data-ylk="zone:center;ct:conversations;v:topics;itc:0;intl:us;grp:primenumbers;pstcat:Number Theory;cat1:Science;cat2:Mathematics;grpst:RESTRICTED;"  data-gb="GB0" hasCoverImage="false"  data-hideads="0">
    <div class="cover-photo-holder clrfix groups-img-wrapper"  data-cover="https://s.yimg.com/ru/defcovers/1600082641/cat.jpg">
        <div id="cover-photo" class="cover-photo wviewvert"></div>
        <div class="cp-progressbar"><div class="cp-bar"></div></div>
    </div>
    <div class="subnav-middle tbr">
        <h1 class="yg-offscreen">Prime numbers and primality testing is a Restricted Group with 1137 members.</h1>
        <ul class="group-stats stats">
        <li class="group-icon-row fw-300"><a id="yg-group-summary" class="fc-white" href="/neo/groups/primenumbers/info">Prime numbers and primality testing</a></li>

        <li>
            <ul class="gstats">
                <li><i class="yg-sprite restricted"></i></li>
                <li>Restricted Group,</li>


                  <li>1137 members</li>

            </ul>
        </li>

        </ul>

    </div>
</div>

<div id="yg-group-detail-navbar" class="yg-rapid yom-mod yom-nav group-detail-navbar bg-gray shadow" data-ylk="zone:navbar;ct:conversations;v:topics;itc:0;intl:us;grp:primenumbers;pstcat:Number Theory;cat1:Science;cat2:Mathematics;grpst:RESTRICTED;" data-user-level="" data-menu-style="icon-label">
    <div id="navbar-container" class="yom-bd-container yg-navbar-bg dockme" data-docktarget="#UH">
        <div class="yom-bd">
                <h2 class="yg-offscreen">Primary Navigation</h2>
        <nav style="display:inline-block" role="navigation" aria-label="Primary">
        <ul class="nav-lt icon-label" role="tablist">

                    <li role="tab" aria-label="Conversations" id="messagenav"><a href="/neo/groups/primenumbers/conversations/messages" ><i class="yg-sprite" data-tooltip="Conversations"></i><span>Conversations</span></a></li>

                    <li role="tab" aria-label="Photos" id="photosnav"><a  class="disabled" ><i class="yg-sprite" data-tooltip="Photos"></i><span>Photos</span></a></li>

                    <li role="tab" aria-label="Files" id="filesnav"><a  class="disabled" ><i class="yg-sprite" data-tooltip="Files"></i><span>Files</span></a></li>

                    <li role="tab" aria-label="Attachments" id="attachmentnav" class="newitem hide"><a href="/neo/groups/primenumbers/attachments" ><i class="yg-sprite" data-tooltip="Attachments"></i><span>Attachments</span></a></li>

                    <li role="tab" aria-label="Events" id="eventsnav" class="newitem hide"><a  class="disabled" ><i class="yg-sprite" data-tooltip="Events"></i><span>Events</span></a></li>

                    <li role="tab" aria-label="Polls" id="pollsnav" class="newitem hide"><a  class="disabled" ><i class="yg-sprite" data-tooltip="Polls"></i><span>Polls</span></a></li>

                    <li role="tab" aria-label="Links" id="linksnav" class="newitem hide"><a href="/neo/groups/primenumbers/links/all" ><i class="yg-sprite" data-tooltip="Links"></i><span>Links</span></a></li>

                    <li role="tab" aria-label="Database" id="databasenav" class="newitem hide"><a  class="disabled" ><i class="yg-sprite" data-tooltip="Database"></i><span>Database</span></a></li>

                    <li role="tab" aria-label="About" id="infonav" class="newitem hide"><a href="/neo/groups/primenumbers/info" ><i class="yg-sprite" data-tooltip="About"></i><span>About</span></a></li>

            <li id="morenav" role="button" aria-haspopup="true" aria-owns="morenav-items" aria-expanded="false" tabindex="0" aria-label="More">
            <a role="presentation" href="javascript:;" tabindex="-1"><span>More</span><i class="yg-sprite" data-tooltip=""></i></a></li>

        </ul>
        </nav>

                    <h2 class="yg-offscreen">Secondary Navigation</h2>
                    <ul class="nav-rt" role="navigation" aria-label="Secondary">


                    <li id="helpnav"><a href="http://groupshelp.yahoo.com/neo/groups/help" target="_blank"><i class="yg-sprite tip" data-tooltip="Help" pos="bottom">Help</i></a></li>
        </ul>

        </div>
    </div>
    <div id="yg-groupdetail-navbar-empty" class="bg-gray">&nbsp;</div>
</div>


<div id="groupdetail-navbar-moreitems">
    <ul id="morenav-items" class="hide icon-label" role="menu" tabindex="-1" aria-hidden="true" aria-labelledby="morenav" hidefocus="true">

        <li id="attachmentnav-more" role="presentation"><a href="/neo/groups/primenumbers/attachments" class="attachmentnav" role="menuitem"><i class="yg-sprite" alt="Attachments"></i><span>Attachments</span></a></li>

        <li id="eventsnav-more" role="presentation"><a class="eventsnav disabled" aria-disabled="true" role="menuitem"><i class="yg-sprite" alt="Events"></i><span>Events</span></a></li>

        <li id="pollsnav-more" role="presentation"><a class="pollsnav disabled" aria-disabled="true" role="menuitem"><i class="yg-sprite" alt="Polls"></i><span>Polls</span></a></li>

        <li id="linksnav-more" role="presentation"><a href="/neo/groups/primenumbers/links/all" class="linksnav" role="menuitem"><i class="yg-sprite" alt="Links"></i><span>Links</span></a></li>

        <li id="databasenav-more" role="presentation"><a class="databasenav disabled" aria-disabled="true" role="menuitem"><i class="yg-sprite" alt="Database"></i><span>Database</span></a></li>

        <li id="infonav-more" role="presentation"><a href="/neo/groups/primenumbers/info" class="infonav" role="menuitem"><i class="yg-sprite" alt="About"></i><span>About</span></a></li>


    </ul>
</div>


<div id="yg-mem-menu-overlay" class="hide">
    <div id="yg-mem-menu-overlay-bd" role="menu" tabindex="0" aria-hidden="true" aria-labelledby="memnav" hidefocus="true">

        <ul id="yg-member-menu" role=""menu>
            <li><a role="menuitem" class="mem-menu-item" href="/neo/groups/primenumbers/management/membership">Edit Membership</a></li>
        </ul>
    </div>
</div>



<div id="yg-profile-list" class="hide">
    <ul id="yg-profile-list-bd" role="menu">

    </ul>
</div>

<div id="yg-msg-view">
    <div class="group-detail-view">
        <div class="yg-grid yg-clear-space topic-read" id="yg-msg-read">


            <div class="y-col y-col2-1">
                <div id="yg-action-bar" class="yg-rapid" data-ylk="zone:center;ct:conversations;v:topic-read;itc:0;intl:us;grp:primenumbers;pstcat:Number Theory;cat1:Science;cat2:Mathematics;grpst:RESTRICTED;">
                    <div class="yom-mod yom-actions yg-action-bg yom-actions-small dockme" data-docktarget=".yom-bd-container">
                        <div class="yom-bd">
                            <ul class="actions-lt y-msg-lt">
                                <li class="lt-arrow">
                                    <div class="btn-grey  clrfix" role="button" tabindex="0">
                                        <a href="/neo/groups/primenumbers/conversations/topics"><i class="yg-sprite tip" data-tooltip="Back" pos="bottom">Back</i></a>
                                    </div>
                                </li>


                                <li class="fright yg-view-mnu yg-button btn-grey yg-left-margin" role="button" aria-haspopup="true" aria-expanded="false" tabindex="0">
                                <a data-action="view" href="javascript:;">View</a><i class="yg-mygrplist-dd-close yg-sprite fright"></i></li>
                                <li class="fright">
                                    <a href="/neo/groups/primenumbers/conversations/topics/19920" class="fright btn-grey  no-border-radius-left msg-read-prev-next" tabindex="0" role="button"><i class="yg-sprite tip rt-actv" data-tooltip="Next" pos="bottom">Next</i></a><a href="/neo/groups/primenumbers/conversations/topics/19915" class="btn-grey  no-border-radius-right yg-left-margin fright msg-read-prev-next" tabindex="0" role="button"><i class="tip yg-sprite lt-actv" data-tooltip="Previous" pos="bottom">Previous</i></a>
                                </li>
                            </ul>
                        </div>
                    </div>

<div class="hide">
    <div id="yg-view-menu-options" class="optionMenu main-menu-content" tabindex="-1" role="menu" aria-hidden="true">


        <ul class="first" role="menu">

          <li class="yg-topic-fold" data-action="view-mode" role="menuitem" data-href="" data-newtab="">Expand Messages</li>

          <li class="yg-topic-fwf" data-action="view-fwf" role="menuitem" data-href="" data-newtab="">Fixed Width Font</li>

        </ul>


    <div class="menu-group">
        <div class="group-title">Sort by:</div>
        <ul class="sortby-group asc" role="menu">

        <li data-action="sort-date" role="menuitem" class="date" order="">Date</li>

        </ul>
    </div>


    </div>
</div>


                </div>

                <div id="yg-iframe-container" class="yg-grid yg-rapid" data-ylk="zone:center;ct:conversations;v:topic-read;itc:0;intl:us;grp:primenumbers;pstcat:Number Theory;cat1:Science;cat2:Mathematics;grpst:RESTRICTED;">
                    <div id="yg-thread-container" data-topic-prev="/neo/groups/primenumbers/conversations/topics/19915" data-topic-next="/neo/groups/primenumbers/conversations/topics/19920" data-topic-current="/neo/groups/primenumbers/conversations/topics/19899">
                        <div class="msg-container">
                            <div class="yg-splitter"><i class="yg-sprite split-arrow" title="Hide Advertisement"></i></div>

                            <div class="msg-title-bar clrfix">
                                <div class="msg-title">
                                    <h2 id="yg-msg-subject" class="fs-14 fw-600 sprite" data-subject="Integers then Equals"  data-tooltip="Integers then Equals">Integers then Equals </h2>
                                </div>
                                <div class="msg-readview-id"><span class="msg-expand" aria-label="Expand Messages" role="button"  tabindex="0" data-action="msg-expand"><i class="yg-sprite tip expand-right" data-tooltip="Expand Messages" pos="bottom" role="presentation">Expand Messages</i></span></div>

                            </div>
                            <div class="clrfix"></div>
                            <ul class="msg-list-container" data-alternateId="" data-fromMailAddr="" data-msgCount="7" data-reply-to="SENDER" data-sender-status="" data-default-email="primenumbers@{{emailDomain}}" data-member-status="" data-owner="primenumbers-owner@{{emailDomain}}" data-attachment-status="" data-poll-enabled="1">
                                <li
class="yg-msg-read-container  clrfix" data-index="7" data-attachments="0" data-msgId="19899" data-email="s_m_ruiz@..." data-next-msgId="19900" data-prev-msgId="0" data-uid="225268637" data-reply-to-header="{&quot;messageIdInHeader&quot;:&quot;PDM3NDc5OS40NjQ4OS5xbUB3ZWIyNTEwMS5tYWlsLnVrbC55YWhvby5jb20+&quot;}" data-sender-status="" data-poll="" data-content-transformed=""><div
class="wrapper"><div
class="msg-header"><div><div
class="author fleft fw-600">Sebastian Martin Ruiz</div><div
class="body"><div
class="summary">Hello all:     Let P(n) the n-th prime number. Let Sqrt(P)=p^(1/2)   If Sqrt(P(n-1)+7) and Sqrt(P(n+1)-1) are both integers then:   1)</div></div><div
class="tm">
<span
class="cur-msg hide">
Message 1 of 7
, </span>
<span
class="cur-msg-dt tip" pos="bottom" data-tooltip="Message sent time">Mar 14, 2009</span>
<a
href="/neo/groups/primenumbers/conversations/messages/19899" class="new-tab" target="_blank" aria-label="Open message in new tab"><i
class="yg-sprite tip open-msg" data-tooltip="Open message in new tab" pos="bottom"></i></a></div></div></div><div
class="raw-msg-lnk"><button
class="fw-700 yg-font">View Source</button></div><div
class="raw-msg-container hide"></div><div
class="msg-attachment-wrapper"><div
class="msg-attachments-container hide" data-length=""><div
class="header"><ul><li
class="num-attachments fw-600">
<i
class="attachment-icon yg-sprite"></i></li><li
class="total-size"></li></ul></div><div
class="attachment-tray clrfix"><div
class="next"><div
class="next-icon yg-sprite"></div></div><div
class="prev hidden"><div
class="prev-icon yg-sprite"></div></div><ul
class="attachment-ul"></ul></div></div></div><div
class="msg-content undoreset"><div
id="ygrps-yiv-1936759143">Hello all:<br/>
<br/>
 <br/>
<br/>
 <br/>
<br/>
Let P(n)<br/>
the n-th prime number. Let Sqrt(P)=p^(1/2)<br/>
<br/>
 <br/>
<br/>
If<br/>
Sqrt(P(n-1)+7) and Sqrt(P(n+1)-1) are both integers then:<br/>
<br/>
 <br/>
<br/>
1)<br/>
Sqrt(P(n-1)+7)=Sqrt(P(n+1)-1) <br/>
<br/>
 <br/>
<br/>
2)<br/>
P(n)=P(n-1)+2  (Twin Primes) <br/>
<br/>
 <br/>
<br/>
3) P(n+1)=P(n-1)+8<br/>
Sincerely<br/>
Sebastián Martín Ruiz<br/>
<br/>
 <br/>
<br/>
<br/>
<br/>
<br/>
[Non-text portions of this message have been removed]</div></div><div
class="msg-inline-video"></div><div
class="message-read card-action-bar">
<span
class="hover-btn">
</span></div></div></li><li
class="yg-msg-read-container  hide clrfix" data-index="6" data-attachments="0" data-msgId="19900" data-email="kermit@..." data-next-msgId="19901" data-prev-msgId="19899" data-uid="655161" data-reply-to-header="{&quot;messageIdInHeader&quot;:&quot;PDQ5QkRBNEVELjgwMTA3MDRAcG9sYXJpcy5uZXQ+&quot;}" data-sender-status="" data-poll="" data-content-transformed=""><div
class="wrapper"><div
class="msg-header"><div><div
class="author fleft fw-600">Kermit Rose</div><div
class="body"><div
class="summary">1. Integers then Equals Posted by: Sebastian Martin Ruiz s_m_ruiz@yahoo.es s_m_ruiz Date: Sat Mar 14, 2009 12:11 pm ((PDT)) Hello all: Hello Sebastián Let</div></div><div
class="tm">
<span
class="cur-msg hide">
Message 2 of 7
, </span>
<span
class="cur-msg-dt tip" pos="bottom" data-tooltip="Message sent time">Mar 15, 2009</span>
<a
href="/neo/groups/primenumbers/conversations/messages/19900" class="new-tab" target="_blank" aria-label="Open message in new tab"><i
class="yg-sprite tip open-msg" data-tooltip="Open message in new tab" pos="bottom"></i></a></div></div></div><div
class="raw-msg-lnk"><button
class="fw-700 yg-font">View Source</button></div><div
class="raw-msg-container hide"></div><div
class="msg-attachment-wrapper"><div
class="msg-attachments-container hide" data-length=""><div
class="header"><ul><li
class="num-attachments fw-600">
<i
class="attachment-icon yg-sprite"></i></li><li
class="total-size"></li></ul></div><div
class="attachment-tray clrfix"><div
class="next"><div
class="next-icon yg-sprite"></div></div><div
class="prev hidden"><div
class="prev-icon yg-sprite"></div></div><ul
class="attachment-ul"></ul></div></div></div><div
class="msg-content undoreset"><div
id="ygrps-yiv-1242898348">1. Integers then Equals<br/>
Posted by: &quot;Sebastian Martin Ruiz&quot; <a
rel="nofollow" target="_blank" href="mailto:s_m_ruiz@...">s_m_ruiz@...</a> s_m_ruiz<br/>
Date: Sat Mar 14, 2009 12:11 pm ((PDT))<br/>
<br/>
Hello all:<br/>
<br/>
Hello Sebastián<br/>
<br/>
Let P(n)<br/>
the n-th prime number. Let Sqrt(P)=p^(1/2)<br/>
<br/>
Kermit:<br/>
****<br/>
p1 = 2<br/>
p2 = 3<br/>
p3 = 5<br/>
2 + 7 = 9<br/>
5 - 1 = 4<br/>
sqrt(p1+7) = 3<br/>
sqrt(p3-1) = 2<br/>
****<br/>
<br/>
If<br/>
Sqrt(P(n-1)+7) and Sqrt(P(n+1)-1) are both integers then:<br/>
<br/>
Kermit: <br/>
*****<br/>
If sqrt(p(n-1) + 7) is an integer, then p(n-1) = 0 or 2 mod 3.<br/>
If sqrt(p(n+1) -1) is an integer, then p(n+1) = 1 or 2 mod 3.<br/>
p(n-1) = 0 mod 3 implies p = 3.<br/>
<br/>
sqrt(3 + 7) is not an integer,<br/>
<br/>
Thus<br/>
<br/>
If sqrt(p(n-1) + 7) is an integer, then p(n-1) = 2 mod 3<br/>
if sqrt(p(n+1) -1) is an integer, then p(n+1) = 1 or 2 mod 3.<br/>
<br/>
If sqrt(p(n-1) + 7) is an integer  &gt; 3,<br/>
and<br/>
sqrt(p(n+1) - 1) is an integer, then<br/>
<br/>
p(n+1) = p(n-1) + 8<br/>
<br/>
and p(n) might be p(n-1) + 2 or p(n-1) + 6.<br/>
<br/>
<br/>
<br/>
sqrt(p1+7) = 3<br/>
sqrt(p3-1) = 2<br/>
*****<br/>
<br/>
1)<br/>
Sqrt(P(n-1)+7)=Sqrt(P(n+1)-1) <br/>
<br/>
Kermit:<br/>
****<br/>
Provided n is sufficiently large.<br/>
3**2 - 7 = 2<br/>
4**2 - 7 = 9<br/>
5**2 - 7 = 19<br/>
2,3,5,7,11,13,17,19<br/>
p8 = 19<br/>
p9 = 23<br/>
p10 = 29<br/>
sqrt(28) &gt; sqrt(25)<br/>
<br/>
<br/>
******<br/>
<br/>
2)<br/>
P(n)=P(n-1)+2  (Twin Primes) <br/>
<br/>
Kermit:<br/>
***<br/>
I expect there to be exceptions to this also.<br/>
<br/>
Because<br/>
<br/>
If p(n+1) = p(n-1) + 8,<br/>
<br/>
p(n) might be p(n-1) + 2,<br/>
or<br/>
p(n) might be p(n-1) + 6<br/>
<br/>
****** <br/>
<br/>
<br/>
<br/>
<br/>
3) P(n+1)=P(n-1)+8<br/>
Sincerely<br/>
Sebastián Martín Ruiz</div></div><div
class="msg-inline-video"></div><div
class="message-read card-action-bar">
<span
class="hover-btn">
</span></div></div></li><li
class="yg-msg-read-container  hide clrfix" data-index="5" data-attachments="0" data-msgId="19901" data-email="maximilian.hasler@..." data-next-msgId="19907" data-prev-msgId="19900" data-uid="342419398" data-reply-to-header="{&quot;messageIdInHeader&quot;:&quot;PGdwa2k0MytqYWMyQGVHcm91cHMuY29tPg==&quot;,&quot;inReplyToHeader&quot;:&quot;PDQ5QkRBNEVELjgwMTA3MDRAcG9sYXJpcy5uZXQ+&quot;}" data-sender-status="" data-poll="" data-content-transformed=""><div
class="wrapper"><div
class="msg-header"><div><div
class="author fleft fw-600">Maximilian Hasler</div><div
class="body"><div
class="summary">... no: p(n+1)=m²+1 = p(n-1)+6 = m²-1 = (m+1)(m-1) can t be prime. M.</div></div><div
class="tm">
<span
class="cur-msg hide">
Message 3 of 7
, </span>
<span
class="cur-msg-dt tip" pos="bottom" data-tooltip="Message sent time">Mar 15, 2009</span>
<a
href="/neo/groups/primenumbers/conversations/messages/19901" class="new-tab" target="_blank" aria-label="Open message in new tab"><i
class="yg-sprite tip open-msg" data-tooltip="Open message in new tab" pos="bottom"></i></a></div></div></div><div
class="raw-msg-lnk"><button
class="fw-700 yg-font">View Source</button></div><div
class="raw-msg-container hide"></div><div
class="msg-attachment-wrapper"><div
class="msg-attachments-container hide" data-length=""><div
class="header"><ul><li
class="num-attachments fw-600">
<i
class="attachment-icon yg-sprite"></i></li><li
class="total-size"></li></ul></div><div
class="attachment-tray clrfix"><div
class="next"><div
class="next-icon yg-sprite"></div></div><div
class="prev hidden"><div
class="prev-icon yg-sprite"></div></div><ul
class="attachment-ul"></ul></div></div></div><div
class="msg-content undoreset"><div
id="ygrps-yiv-289124527">--- In <a
rel="nofollow" target="_blank" href="mailto:primenumbers@yahoogroups.com">primenumbers@yahoogroups.com</a>, Kermit Rose &lt;kermit@...&gt; wrote:<br/><blockquote><span
title="ireply"> &gt; If<br/>
&gt; Sqrt(P(n-1)+7) and Sqrt(P(n+1)-1) are both integers then:<br/>
&gt; 2)<br/>
&gt; P(n)=P(n-1)+2  (Twin Primes) <br/>
&gt; I expect there to be exceptions to this also.<br/>
&gt; Because<br/>
&gt; If p(n+1) = p(n-1) + 8,<br/>
&gt; p(n) might be p(n-1) + 2,<br/>
&gt; or<br/>
&gt; p(n) might be p(n-1) + 6<br/>
<br/>
</span></blockquote>no:<br/>
p(n+1)=m²+1 =&gt; p(n-1)+6 = m²-1 = (m+1)(m-1) can&#39;t be prime.<br/>
<br/>
M.</div></div><div
class="msg-inline-video"></div><div
class="message-read card-action-bar">
<span
class="hover-btn">
</span></div></div></li><li
class="yg-msg-read-container  hide clrfix" data-index="4" data-attachments="0" data-msgId="19907" data-email="Theo.3.1415@..." data-next-msgId="19908" data-prev-msgId="19901" data-uid="180161047" data-reply-to-header="{&quot;messageIdInHeader&quot;:&quot;PGdwcWs1YiszYTY2QGVHcm91cHMuY29tPg==&quot;,&quot;inReplyToHeader&quot;:&quot;PDM3NDc5OS40NjQ4OS5xbUB3ZWIyNTEwMS5tYWlsLnVrbC55YWhvby5jb20+&quot;}" data-sender-status="" data-poll="" data-content-transformed=""><div
class="wrapper"><div
class="msg-header"><div><div
class="author fleft fw-600">Werner D. Sand</div><div
class="body"><div
class="summary">In words: If N is a square (N=m²) and N+1 and N-7 are primes, then N-5 is a prime, too. 3) is superfluous, because it follows from 1) by simple</div></div><div
class="tm">
<span
class="cur-msg hide">
Message 4 of 7
, </span>
<span
class="cur-msg-dt tip" pos="bottom" data-tooltip="Message sent time">Mar 18, 2009</span>
<a
href="/neo/groups/primenumbers/conversations/messages/19907" class="new-tab" target="_blank" aria-label="Open message in new tab"><i
class="yg-sprite tip open-msg" data-tooltip="Open message in new tab" pos="bottom"></i></a></div></div></div><div
class="raw-msg-lnk"><button
class="fw-700 yg-font">View Source</button></div><div
class="raw-msg-container hide"></div><div
class="msg-attachment-wrapper"><div
class="msg-attachments-container hide" data-length=""><div
class="header"><ul><li
class="num-attachments fw-600">
<i
class="attachment-icon yg-sprite"></i></li><li
class="total-size"></li></ul></div><div
class="attachment-tray clrfix"><div
class="next"><div
class="next-icon yg-sprite"></div></div><div
class="prev hidden"><div
class="prev-icon yg-sprite"></div></div><ul
class="attachment-ul"></ul></div></div></div><div
class="msg-content undoreset"><div
id="ygrps-yiv-1705078770">In words: If N is a square (N=m²) and N+1 and N-7 are primes, then N-5 is a prime, too.<br/>
<br/>
3) is superfluous, because it follows from 1) by simple transformation.<br/>
<br/>
Proof: Let N be a square and p1=N-7 and p3=N+1 primes. Let p2 be the single prime between p1 and p3: p1 &lt; p2 &lt; p3. Then the gap p3-p1=8. Then there are 3 possibilities for p2:<br/>
1.) p2=p1+2 (gaps 2,6)<br/>
2.) p2=p1+4 (gaps 4,4)<br/>
3.) p2=p1+6 (gaps 6,2)<br/>
<br/>
2.) cannot occur, for there are no equal neighbouring gaps besides 6n,6n.<br/>
3.) From p1=N-7 and p2=p1+6 follows p2=N-1=m²-1=(m+1)*(m-1), not prime.<br/>
<br/>
Thus 1.) is the only possibility.<br/>
<br/>
Btw: The final digits of p1,p2,p3 are 9,1,7. Who proves?<br/>
<br/>
Werner D. Sand</div></div><div
class="msg-inline-video"></div><div
class="message-read card-action-bar">
<span
class="hover-btn">
</span></div></div></li><li
class="yg-msg-read-container  hide clrfix" data-index="3" data-attachments="0" data-msgId="19908" data-email="maximilian.hasler@..." data-next-msgId="19909" data-prev-msgId="19907" data-uid="342419398" data-reply-to-header="{&quot;messageIdInHeader&quot;:&quot;PGdwcXIxOSs3dG45QGVHcm91cHMuY29tPg==&quot;,&quot;inReplyToHeader&quot;:&quot;PGdwcWs1YiszYTY2QGVHcm91cHMuY29tPg==&quot;}" data-sender-status="" data-poll="" data-content-transformed=""><div
class="wrapper"><div
class="msg-header"><div><div
class="author fleft fw-600">Maximilian Hasler</div><div
class="body"><div
class="summary">... Stated like this, it is indeed more or less trivial. As I see it, the nontrivial part of the assertion is: There is NO m such that * m²-7 is prime *</div></div><div
class="tm">
<span
class="cur-msg hide">
Message 5 of 7
, </span>
<span
class="cur-msg-dt tip" pos="bottom" data-tooltip="Message sent time">Mar 18, 2009</span>
<a
href="/neo/groups/primenumbers/conversations/messages/19908" class="new-tab" target="_blank" aria-label="Open message in new tab"><i
class="yg-sprite tip open-msg" data-tooltip="Open message in new tab" pos="bottom"></i></a></div></div></div><div
class="raw-msg-lnk"><button
class="fw-700 yg-font">View Source</button></div><div
class="raw-msg-container hide"></div><div
class="msg-attachment-wrapper"><div
class="msg-attachments-container hide" data-length=""><div
class="header"><ul><li
class="num-attachments fw-600">
<i
class="attachment-icon yg-sprite"></i></li><li
class="total-size"></li></ul></div><div
class="attachment-tray clrfix"><div
class="next"><div
class="next-icon yg-sprite"></div></div><div
class="prev hidden"><div
class="prev-icon yg-sprite"></div></div><ul
class="attachment-ul"></ul></div></div></div><div
class="msg-content undoreset"><div
id="ygrps-yiv-362169830">--- In <a
rel="nofollow" target="_blank" href="mailto:primenumbers@yahoogroups.com">primenumbers@yahoogroups.com</a>, &quot;Werner D. Sand&quot; wrote:<br/><blockquote><span
title="ireply"> &gt;<br/>
&gt; In words: If N is a square (N=m²) and N+1 and N-7 are primes,<br/>
&gt; then N-5 is a prime, too.<br/>
<br/>
</span></blockquote>Stated like this, it is indeed more or less trivial.<br/>
<br/>
As I see it, the nontrivial part of the assertion is:<br/>
<br/>
There is NO m such that<br/>
* m²-7 is prime<br/>
* (m+k)²+1 is prime for some k&gt;0 (i.e. k&gt;=2)<br/>
* there is only one prime between m²-7 and (m+k)²+1<br/>
<br/>
I think that one would need to prove something like Cramer&#39;s conjecture to disprove this statement.<br/>
<br/>
<br/><blockquote><span
title="ireply"> &gt; 3) is superfluous, because it follows<br/>
&gt; from 1) by simple transformation.<br/>
<br/>
</span></blockquote>Of course.<br/>
<br/>
<br/><blockquote><span
title="ireply"> &gt; 3.) From p1=N-7 and p2=p1+6 follows p2=N-1=m²-1=(m+1)*(m-1),<br/>
&gt; not prime.<br/>
<br/>
</span></blockquote>As I wrote some days ago, cf. <a
rel="nofollow" target="_blank" href="http://tech.groups.yahoo.com/group/primenumbers/message/19901/.">http://tech.groups.yahoo.com/group/primenumbers/message/19901/.</a><br/>
<br/>
<br/><blockquote><span
title="ireply"> &gt; Thus 1.) is the only possibility.<br/>
&gt; <br/>
&gt; Btw: The final digits of p1,p2,p3 are 9,1,7. Who proves?<br/>
<br/>
</span></blockquote>m²-7 can&#39;t be 1 mod 10.<br/>
<br/>
Maximilian</div></div><div
class="msg-inline-video"></div><div
class="message-read card-action-bar">
<span
class="hover-btn">
</span></div></div></li><li
class="yg-msg-read-container  hide clrfix" data-index="2" data-attachments="0" data-msgId="19909" data-email="maximilian.hasler@..." data-next-msgId="19917" data-prev-msgId="19908" data-uid="342419398" data-reply-to-header="{&quot;messageIdInHeader&quot;:&quot;PGdwcXMwMitsNWJhQGVHcm91cHMuY29tPg==&quot;,&quot;inReplyToHeader&quot;:&quot;PGdwcXIxOSs3dG45QGVHcm91cHMuY29tPg==&quot;}" data-sender-status="" data-poll="" data-content-transformed=""><div
class="wrapper"><div
class="msg-header"><div><div
class="author fleft fw-600">Maximilian Hasler</div><div
class="body"><div
class="summary">... er... I read but you didn t write: ...and there is a prime between N-7 and N+1, ... else we have counter-examples for m =</div></div><div
class="tm">
<span
class="cur-msg hide">
Message 6 of 7
, </span>
<span
class="cur-msg-dt tip" pos="bottom" data-tooltip="Message sent time">Mar 18, 2009</span>
<a
href="/neo/groups/primenumbers/conversations/messages/19909" class="new-tab" target="_blank" aria-label="Open message in new tab"><i
class="yg-sprite tip open-msg" data-tooltip="Open message in new tab" pos="bottom"></i></a></div></div></div><div
class="raw-msg-lnk"><button
class="fw-700 yg-font">View Source</button></div><div
class="raw-msg-container hide"></div><div
class="msg-attachment-wrapper"><div
class="msg-attachments-container hide" data-length=""><div
class="header"><ul><li
class="num-attachments fw-600">
<i
class="attachment-icon yg-sprite"></i></li><li
class="total-size"></li></ul></div><div
class="attachment-tray clrfix"><div
class="next"><div
class="next-icon yg-sprite"></div></div><div
class="prev hidden"><div
class="prev-icon yg-sprite"></div></div><ul
class="attachment-ul"></ul></div></div></div><div
class="msg-content undoreset"><div
id="ygrps-yiv-1284510908"><blockquote><span
title="ireply">&gt; --- In <a
rel="nofollow" target="_blank" href="mailto:primenumbers@yahoogroups.com">primenumbers@yahoogroups.com</a>, &quot;Werner D. Sand&quot; wrote:<br/>
&gt; &gt;<br/>
&gt; &gt; In words: If N is a square (N=m²) and N+1 and N-7 are primes,<br/>
&gt; &gt; then N-5 is a prime, too.<br/>
&gt; <br/>
&gt; Stated like this, it is indeed more or less trivial.<br/>
<br/>
</span></blockquote>er... I read but you didn&#39;t write:<br/>
&quot;...and there is a prime between N-7 and N+1, ...&quot;<br/>
<br/>
else we have counter-examples for m =<br/>
54,66,90,156,240,270,306,474,570,576,636,750,780,1080,1320,1350,2034,<br/>
2154,2406,2700,2760,3204,3240,3306,3480,3516,3756,3774,3984,4056,4086,<br/>
4140,4146,4176,4716,4734,4794,5154,5370,5424,5550,5664,5700,5850,5856,<br/>
5970,6030,6060,6120,6366,6576,6714,6786,7050,7164,8196,8424,8454,8940,<br/>
9180,9246,9486,9696,9804...</div></div><div
class="msg-inline-video"></div><div
class="message-read card-action-bar">
<span
class="hover-btn">
</span></div></div></li><li
class="yg-msg-read-container  clrfix" data-index="1" data-attachments="0" data-msgId="19917" data-email="Theo.3.1415@..." data-next-msgId="0" data-prev-msgId="19909" data-uid="180161047" data-reply-to-header="{&quot;messageIdInHeader&quot;:&quot;PGdxMGY2MSsxaDNjQGVHcm91cHMuY29tPg==&quot;,&quot;inReplyToHeader&quot;:&quot;PGdwcXMwMitsNWJhQGVHcm91cHMuY29tPg==&quot;}" data-sender-status="" data-poll="" data-content-transformed=""><div
class="wrapper"><div
class="msg-header"><div><div
class="author fleft fw-600">Werner D. Sand</div><div
class="body"><div
class="summary">... O.k., put it in.</div></div><div
class="tm">
<span
class="cur-msg hide">
Message 7 of 7
, </span>
<span
class="cur-msg-dt tip" pos="bottom" data-tooltip="Message sent time">Mar 20, 2009</span>
<a
href="/neo/groups/primenumbers/conversations/messages/19917" class="new-tab" target="_blank" aria-label="Open message in new tab"><i
class="yg-sprite tip open-msg" data-tooltip="Open message in new tab" pos="bottom"></i></a></div></div></div><div
class="raw-msg-lnk"><button
class="fw-700 yg-font">View Source</button></div><div
class="raw-msg-container hide"></div><div
class="msg-attachment-wrapper"><div
class="msg-attachments-container hide" data-length=""><div
class="header"><ul><li
class="num-attachments fw-600">
<i
class="attachment-icon yg-sprite"></i></li><li
class="total-size"></li></ul></div><div
class="attachment-tray clrfix"><div
class="next"><div
class="next-icon yg-sprite"></div></div><div
class="prev hidden"><div
class="prev-icon yg-sprite"></div></div><ul
class="attachment-ul"></ul></div></div></div><div
class="msg-content undoreset"><div
id="ygrps-yiv-421294795">--- In <a
rel="nofollow" target="_blank" href="mailto:primenumbers@yahoogroups.com">primenumbers@yahoogroups.com</a>, &quot;Maximilian Hasler&quot; &lt;maximilian.hasler@...&gt; wrote:<br/><blockquote><span
title="ireply"> &gt;<br/>
&gt; &gt; --- In <a
rel="nofollow" target="_blank" href="mailto:primenumbers@yahoogroups.com">primenumbers@yahoogroups.com</a>, &quot;Werner D. Sand&quot; wrote:<br/>
&gt; &gt; &gt;<br/>
&gt; &gt; &gt; In words: If N is a square (N=m&#178;) and N+1 and N-7 are primes,<br/>
&gt; &gt; &gt; then N-5 is a prime, too.<br/>
&gt; &gt; <br/>
&gt; &gt; Stated like this, it is indeed more or less trivial.<br/>
&gt; <br/>
&gt; er... I read but you didn&#39;t write:<br/>
&gt; &quot;...and there is a prime between N-7 and N+1, ...&quot;<br/>
&gt; <br/>
&gt; else we have counter-examples for m =<br/>
&gt; 54,66,90,156,240,270,306,474,570,576,636,750,780,1080,1320,1350,2034,<br/>
&gt; 2154,2406,2700,2760,3204,3240,3306,3480,3516,3756,3774,3984,4056,4086,<br/>
&gt; 4140,4146,4176,4716,4734,4794,5154,5370,5424,5550,5664,5700,5850,5856,<br/>
&gt; 5970,6030,6060,6120,6366,6576,6714,6786,7050,7164,8196,8424,8454,8940,<br/>
&gt; 9180,9246,9486,9696,9804...<br/>
&gt;<br/>
<br/>
<br/>
<br/>
</span></blockquote>O.k., put it in.</div></div><div
class="msg-inline-video"></div><div
class="message-read card-action-bar">
<span
class="hover-btn">
</span></div></div></li>
                            </ul>
                            <div class="msg-response card-margin-bottom hide">Your message has been successfully submitted and would be delivered to recipients shortly.</div>

                        </div>
                    </div>
                </div>
            </div>
            <div class="y-col y-col2-2">
                <div id="right-rail-container" data-scrollpos=300 data-dockpos=134><div class="yom-mod yom-ad yg-rapid" id="yom-rightrail-ad" data-ylk="zone:rightrail;ct:conversations;v:LRECad;itc:0;intl:us;pstcat:Number Theory;cat1:Science;cat2:Mathematics;grpst:RESTRICTED;"  role="complementary" aria-label="Advertisement">
    <div id="yom-ad-LREC">
        <div id="tgtLREC"></div>
    </div>
    <div id="yom-ad-LREC2">
        <div id="tgtLREC2"></div>
    </div>
</div><div class="yg-rapid yom-domros hide" id="yg-dmros-ad-warpper-east" data-ylk="zone:rightrail;ct:conversations;v:eastad;itc:0;intl:us;pstcat:Number Theory;cat1:Science;cat2:Mathematics;grpst:RESTRICTED;">
    <!--<noscript>
        <iframe id="yg-dmros-ad-east" width="300" height="265" frameborder="0" marginheight="0" marginwidth="0" scrolling="no"  src="https://dmros.ysm.yahoo.com/ros/?c=156e7e36&w=300&h=265&ty=noscript&tt=Yahoo Groups&r=/neo/groups/primenumbers/conversations/topics/19899&d=Yahoo Groups|primenumbers|Science,Mathematics,Number Theory">
        </iframe>
    </noscript>-->
</div>
</div>
            </div>

        </div>
    </div>
</div>
                   </div>
                </div>
              </div>
            </div>
            <div id="tooltip" class="hide right"><div class="yg-sprite pointer"></div></div>
<div id="yg-create-group-container">
</div>

    <input type="hidden" id="redirect-url" value="/neo/groups/%groupName%/info?firstRunExp=1">




<script type="text/javascript">

    //Following exact same config as guided here : http://twiki.corp.yahoo.com/view/AdvProdGroup/UsingSecureDARLA#Using_the_SecureDARLA_client_Jav
    var DARLA_CONFIG = {"useYAC":0,"usePE":0,"servicePath":"https:\/\/groups.yahoo.com\/sdarla\/php\/fc.php","xservicePath":"","beaconPath":"https:\/\/groups.yahoo.com\/sdarla\/php\/b.php","renderPath":"","allowFiF":false,"srenderPath":"https:\/\/s.yimg.com\/rq\/darla\/3-19-2\/html\/r-sf.html","renderFile":"https:\/\/s.yimg.com\/rq\/darla\/3-19-2\/html\/r-sf.html","sfbrenderPath":"https:\/\/s.yimg.com\/rq\/darla\/3-19-2\/html\/r-sf.html","msgPath":"https:\/\/fc.yahoo.com\/unsupported-1946.html","cscPath":"https:\/\/s.yimg.com\/rq\/darla\/3-19-2\/html\/r-csc.html","root":"sdarla","edgeRoot":"https:\/\/s.yimg.com\/rq\/darla\/3-19-2","sedgeRoot":"https:\/\/s.yimg.com\/rq\/darla\/3-19-2","version":"3-19-2","tpbURI":"","hostFile":"https:\/\/s.yimg.com\/rq\/darla\/3-19-2\/js\/g-r-min.js","beaconsDisabled":true,"rotationTimingDisabled":true,"fdb_locale":"What don't you like about this ad?|It's offensive|Something else|Thank you for helping us improve your Yahoo experience|It's not relevant|It's distracting|I don't like this ad|Send|Done|Why do I see ads?|Learn more about your feedback.|Want an ad-free inbox? Upgrade to Yahoo Mail Pro!|Upgrade Now","lang":"en-US"};
    DARLA_CONFIG.debug = false;
    DARLA_CONFIG.positions   = {

        "LREC":
        {
           pos:   "LREC",
           w:      300,
           h:      250,
           clean:   "yom-ad-LREC",

           dest:   "tgtLREC"
        },

        "MON":
        {
           pos:   "MON",
           w:      300,
           h:      600,
           clean:   "yom-ad-MON",

           dest:   "tgtMON"
        },

        "LREC2":
        {
           pos:   "LREC2",
           w:      300,
           h:      250,
           clean:   "yom-ad-LREC2",
           dest:   "tgtLREC2"
        },

        "LDRB":
        {
           pos:   "LDRB",
           w:      728,
           h:      90,
           clean:   "yom-ad-LDRB",
           dest:   "tgtLDRB"
        },

        "LDRB2":
        {
           pos:   "LDRB2",
           w:      728,
           h:      90,
           clean:   "yom-ad-LDRB2",
           dest:   "tgtLDRB2"
        }
        // Add more positions here.
    };

    DARLA_CONFIG.events = {
        "AdRotateEvent":{
            name:"AdRotateEvent",
            secure: 1,
            npv: 1
        }
    };

    var initialize_darla_config = function(){
        DARLA.config(DARLA_CONFIG);

    };

    var darla_event = function(position) {
        setTimeout(function () {
            DARLA.event("AdRotateEvent",{
                sp: GROUPS.INSTR_CONFIG['spaceId'] || "1705083388",
                ps: position
            });
        },1);
    };


    DARLA_CONFIG.onFailure = function(e, pos){
        if (typeof(pos) == 'object' && pos[0] == 'LREC') {
            darla_event('LREC2');
        }
    };



    var dmrosAd_event = function(){
        try{
            var dss, adConfig=[];
            if (document.getElementById("yg-grp-main-img")) {
                var grpEl = document.getElementById("yg-grp-main-img");
                dss = grpEl.getAttribute('data-group') + '|' + grpEl.getAttribute('data-ctree');
            } else if (document.getElementById("yg-latestupdates")) {
                    dss = "Latest Updates|Other";
            } else if (document.getElementById("yg-local-srp-container")) {
                var node = document.getElementById("yg-local-srp-container");
                dss = node.getAttribute("query-str") + "|" + node.getAttribute("group-name") + "|Search Results|Other";
            } else if (document.getElementById("yg-srp-container")) {
                var keyword = document.getElementById("yg-srp-container").getAttribute("query-str");
                dss = keyword + "|Search Results|Other";
            } else if (document.getElementById("yg-browse-groups-list")) {
                var keyword = document.getElementById("yg-browse-groups-list").getAttribute("data-categorytree");
                dss = keyword + "|";
            }
            if(dss) {
                //console.log("Inserting text ad with " + dss);
                if(document.getElementById('yg-dmros-ad-warpper-south')){
                    adConfig.push(
                        {
                            dmRosAdSlotId : "south",
                            dmRosAdDivId  : "yg-dmros-ad-warpper-south",
                            dmRosAdWidth  : "675",
                            dmRosAdHeight : "300"
                        });
                }

                if(document.getElementById('yg-dmros-ad-warpper-north')){
                    adConfig.push(
                        {
                            dmRosAdSlotId : "north",
                            dmRosAdDivId  : "yg-dmros-ad-warpper-north",
                            dmRosAdWidth  : "675",
                            dmRosAdHeight : "300"
                        });
                }

                if(document.getElementById('yg-dmros-ad-warpper-east')){
                    adConfig.push(
                        {
                            dmRosAdSlotId : "east",
                            dmRosAdDivId  : "yg-dmros-ad-warpper-east",
                            dmRosAdWidth  : "298",
                            dmRosAdHeight : "265"
                        });
                }
                //console.log(adConfig);
                if(adConfig.length){
                    window.dmRosAds.insertMultiAd({
                        dmRosAdConfig   : "156e7e36",
                        dmRosAdDss      : dss,
                        dmRosAdSlotInfo : adConfig
                    });
                }
            }
        }catch(e){
            // alert(e);
        }
    };

var trackYGJSError = function(err, url, line){
    var suppressErrors=false, pixel, qs, src = "/neo/ygbeacon/?";
    qs = new Array();
    qs.push("jserror=1");
    qs.push("emsg="+ err);
    if(url){
        qs.push("jsfile="+ url.replace(/&/g,';'));
    }
    qs.push("eline="+ line);
    qs.push("qs="+ document.location.search);
    qs.push("url="+ document.location.pathname);
    qs.push("refr="+ document.referrer);
    qs.push("ua="+ navigator.userAgent);
    src = src + qs.join('&');
    pixel = new Image();
    pixel.src = src;
    return suppressErrors;
};

    try {
        window.onerror = function(err, url, line) {
            return trackYGJSError(err, url, line);
        };
    } catch(e) { }



    var _comscore = _comscore || [];
    var ygComscoreBeacon = function(spaceId){
        var pageUrl = encodeURIComponent(window.location.toString()),
        scriptUrl = (document.location.protocol == "https:" ? "https://s.yimg.com/lq" : "http://l.yimg.com/d") + "/lib/3pm/cs_0.2.js";
        _comscore.push({
        c1: "2",
        c2: "7241469",
        c5: spaceId || "1705083388",
        c7: pageUrl
        });//console.log("comscore::"+spaceId+':::'+"1705083388");
        (function(){
            var s = document.createElement("script"),
                el = document.getElementsByTagName("script")[0],
                headNode = el.parentNode;
            s.defer = true;
            s.src = scriptUrl;
            headNode.insertBefore(s, el);
            if(el.src === s.src){
                headNode.removeChild(el);
            }
        })();
    };

</script>

<noscript>
  <img src="https://b.scorecardresearch.com/p?c1=2&c2=7241469&c7=https://groups.yahoo.com/neo/groups/primenumbers/conversations/topics/19899&c5=1705083388&cv=2.0&cj=1" />
</noscript>


<script>

function showFormWarning() {
    return confirm(GROUPS.YRB_STRINGS.STR_SECURITY_CONF);
}

function showPasswordWarning() {
    alert(GROUPS.YRB_STRINGS.STR_SECURITY_WARN);
}

</script>

<div id="yg-debug-container" class="hide tip" data-tooltip="Click on the text to select and then press Ctrl+C (Windows) / Cmd+C (Mac) to copy it." pos="top" ></div>

          </div>
        </div>
      </div>
    </div>
  </div>
 <script>
    document.body.className = document.body.className.replace("no-js",""); // remove no-js class if enabled
    var cfg = {
        logLevel: 'error',
        useBrowserConsole: false,
        skin: { //Required for maps view on photos page
            overrides: {
                "slider-base": ["round"]
            }
        },
        groups: {
            yg: {
                combine: true,
                root: '/ru/0.9.17/min/js/',
                comboBase: 'https://s.yimg.com/zz/combo?',
                base: 'https://groups.yahoo.com/js/',
                modules: YG_DEPENDENCIES,
                lang: 'en-US'
            },
            pw: {
                combine: true,
                root: '/ru/1.9/min/',
                comboBase: 'https://s.yimg.com/zz/combo?',
                base: 'https://groups.yahoo.com/js/',
                modules: YG_PW_DEPENDENCIES,
                lang: 'en-US'
            },
            ymaps: {
                combine: true,
                base: 'https://s.yimg.com/st/4.0.0.825/modules/',
                comboBase: 'https://s.yimg.com/zz/combo?',
                root: 'st/4.0.0.825/modules/',
                lang: 'en-US',
                modules: YG_MAP_DEPENDENCIES
            }
        },
        debug: true,
        filter: "min",
        combine: true    };
    YUI(cfg).use('yahoo-groups', function(Y) {
      GROUPS.Y = Y;
            GROUPS.CONFIG = {"enhancrEnabled":0,"unifiedSearchEnabled":1,"photoMaticEnabled":1,"attExplorerEnabled":1,"exifViewEnabled":1,"showPinboardPromo":0,"zaxEnabled":"photo","messagePollEnabled":"1","adFeedback":"0","yaftEnabled":"1","uhExperience":"stencil-gs-grid","adPrefetch":"0","autoSpellEnabled":"0","pinboardEnabled":0,"inlineResultEnabled":false,"mobilePreviewEnabled":0};
      GROUPS.API_ERROR_MSGS = [];
      GROUPS.USER_ID = "";
      GROUPS.EMAIL= "";
      GROUPS.REPORT_SMP_ENABLED = "1";
      GROUPS.RECAPTCHA_ENABLED = "1";
      GROUPS.RECAPTCHA_LOADED = false;
      GROUPS.YG_YID = "";
      GROUPS.YALIAS = "";
      GROUPS.YG_SIGNED_IN = "";
      GROUPS.YG_NO_SUBSCRIPTION = "";
      GROUPS.YG_GUID = "";
      GROUPS.LANG = "en-US";
      GROUPS.DIRECTION = "ltr";
      GROUPS.INTL = "us";
      GROUPS.MOBILE_PV = "";
      GROUPS.DISABLE_INTL_REDIRECT = "";
      GROUPS.CAPTCHA_APPID = "grps_prd";
      GROUPS.API_VER = "1";
      GROUPS.YG_SESSION_ID = "SID:YHOO:groups.yahoo.com:2019-11-12-09-28-33-J9u5QPxLsCvLzUNgwi2pPQ==";
      GROUPS.YG_CRUMB = "";
      GROUPS.YG_API_CNT = 4;
      GROUPS.INFO_URL_TEMPLATE = "/neo/groups/%groupName%/info";
      GROUPS.TOPICS_URL_TEMPLATE = "/neo/groups/%groupName%/conversations/topics";
      GROUPS.MESSAGES_URL_TEMPLATE = "/neo/groups/%groupName%/conversations/messages";
      GROUPS.POSTS_URL_TEMPLATE = "/neo/groups/%groupName%/pinboard/all";
      GROUPS.YALIAS_LINK_URL = "https://login.yahoo.com/config/login?.scrumb=0&.intl=us&.done=https://login.yahoo.com/account/personalinfo?.scrumb=0&.done=https://groups.yahoo.com&partner=reg&src=&.intl=us&show=";
      GROUPS.GRP_RECOVERY_URL = "https://io.help.yahoo.com/contact/index?y=PROD_GRPS&token=w5FCchB1dWHnXgiuiDb%252FixCxcvOChFTMI5%252B2hMj%252FjA6KR4u44r3TAH58x0diGC9HdjFDgVukZPYCsyvEL0ZZGcn1LWvOt7gZcoHsoneZen1O6HsGr7U0rYKph%252FSyRnwUESuBYDRgtkbWMGp%252BVgDizQ%253D%253D&locale=en_US&page=contactform&selectedChannel=email-icon";
      GROUPS.TIMEZONE = "America/Los_Angeles";
      GROUPS.TIMEZONE_OFFSET = "-28800";
      GROUPS.LOGIN_URL = "https://login.yahoo.com/config/login;_ylt=AtI46q.M_jXQ2vBSmsjhpB.gwsEF?.src=ygrp&.intl=us&.lang=en-US&.done=%doneUrl%";
      GROUPS.USE_FALLBACK_LOGO = false;
      GROUPS.TOS_URL = "http://info.yahoo.com/legal/us/yahoo/utos/en-us/";
      GROUPS.MAX_FILE_UPLOAD_SIZE = 10485760;
      GROUPS.MAX_ATTACHMENT_UPLOAD_SIZE = 10485760;
      GROUPS.MAX_PHOTO_UPLOAD_SIZE = 10485760;
      GROUPS.STR_MONTHS = "Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec";
      GROUPS.EMAIL_DOMAIN = "yahoogroups.com"; // this will not be avail in all pages - check stat call in membership model
      GROUPS.BROWSER_UNSUPPORTED = "0";
      GROUPS.LOADER_ICON_URL = "https://s.yimg.com/dh/ap/groups/loader.gif";
      GROUPS.LOADER_ICON_URL16BY16 = "https://s.yimg.com/dh/ap/groups/loading-16x16.gif";
      GROUPS.DEFAULT_GROUPS_ICON = "https://s.yimg.com/dh/ap/groups/groups-icon.png";
      GROUPS.HTTP_PROTOCOL = "https://";
      GROUPS.UNIFIED_SEARCH_ENABLED = true;
      GROUPS.ASSET_VERSION = "0.9.17";
      GROUPS.HOST_LEVEL = "2";
      GROUPS.ADULT_COOKIE = "";
      GROUPS.ADULT_GROUP = "";
      GROUPS.IS_BOT = "";
      GROUPS.ADULT_CATEGORY = {"id":1600083764,"name":"Adult","catPath":"\/Romance & Relationships\/Adult\/","adult":true,"intl":"us"};
      GROUPS.SHOW_PINBOARD_POPUP = "";
            var use = GROUPS.Y.use;
      GROUPS.Y.use = function () {
            var arr = Array.prototype.slice.call(arguments),
                len = arguments.length,
                cb = arguments[len -1];

            if (Y.Lang.isFunction(cb)) {
                arr[len-1] = function () {
                    try{
                        return cb.apply(this, arguments);
                    } catch (err) {
                        try{
                            trackYGJSError(err.message, err.fileName, err.lineNumber);
                        }catch(e){}
                    }
                };
            }
            use.apply(this, arr);
      };
            GROUPS.PAGE = new Y.Groups.Page({"mbAdsEnabled":0});
      try {
        GROUPS.INSTR_CONFIG = {"rapidEnabled":"true","bucket":"NEO","project_id":1000714451879,"hostname":"y.analytics.yahoo.com","mtest":"GB0","spaceId":1705083388,"debug":"false","pct":"conversations","vt":"topics","login":0,"grpcat":"Number Theory","pcat1":"Science","pcat2":"Mathematics","pgrp":"primenumbers","pgrpst":"RESTRICTED"};
        GROUPS.INSTR = ( typeof GROUPS.INSTR == "undefined") ? new Y.Groups.Instrumentation(GROUPS.INSTR_CONFIG) : GROUPS.INSTR;
      } catch(e) {
          Y.log('could not initialize instrumentation');
      }
      // add  take a tour condition
      GROUPS.TOUR_IMAGES = {"1":"https:\/\/s.yimg.com\/dh\/ap\/groups\/prod_tour_1.jpg","2":"https:\/\/s.yimg.com\/dh\/ap\/groups\/prod_tour_2.jpg","3":"https:\/\/s.yimg.com\/dh\/ap\/groups\/prod_tour_3.jpg","4":"https:\/\/s.yimg.com\/dh\/ap\/groups\/prod_tour_4.jpg","5":"https:\/\/s.yimg.com\/dh\/ap\/groups\/prod_tour_5.jpg","6":"https:\/\/s.yimg.com\/dh\/ap\/groups\/prod_tour_6.jpg","7":"https:\/\/s.yimg.com\/dh\/ap\/groups\/prod_tour_7.jpg","8":"https:\/\/s.yimg.com\/dh\/ap\/groups\/prod_tour_8.jpg","9":"https:\/\/s.yimg.com\/dh\/ap\/groups\/prod_tour_9.jpg","10":"https:\/\/s.yimg.com\/dh\/ap\/groups\/prod_tour_10.jpg"};

      Y.on('load', function(){
          Y.Get.js("https://s1.yimg.com/zz/combo?kx/yucs/uh3s/uh/414/js/uh-min.js&kx/yucs/uh2/common/145/js/jsonp-super-cached-min.js&kx/yucs/uh3s/uh/379/js/escregex-min.js&kx/yucs/uh3s/uh/376/js/persistence-min.js&kx/yucs/uh3s/uh/401/js/menu_group_plugin-min.js&kx/yucs/uh3s/uh/430/js/menu-plugin-min.js&kx/yucs/uh3s/uh/463/js/menu_handler_v2-min.js&kx/yucs/uh3s/uh/376/js/gallery-jsonp-min.js&kx/yucs/uh3s/uh/408/js/logo_debug-min.js&kx/yucs/uh3/uh/js/958/localeDateFormat-min.js&kx/yucs/uh3s/uh/409/js/timestamp_library-min.js&kx/yucs/uh3s/uh/376/js/usermenu_v2-min.js&kx/yucs/uh3/signout-link/10/js/signout-min.js&kx/yucs/uhc/rapid/50/js/uh_rapid-min.js&kx/eol/1/js/meta-min.js&kx/yucs/uh3/disclaimer/388/js/disclaimer_seed-min.js&kx/yucs/uh3s/top-bar/137/js/top_bar_v2-min.js&kx/yucs/uh3s/top-bar/139/js/home_menu-min.js&kx/yucs/uh3s/search/379/js/search-min.js&pj/inproduct/v26s/js/yui/yhelp-bootstrap.js&kx/yucs/uh3s/help/81/js/help_menu_v4-min.js&/rq/darla/3-13-0/js/g-r-min.js", function(err) {
            if (!err) {
                if (typeof initialize_darla_config == 'function') {
                    initialize_darla_config();
                }
                          }
          });
            if(window.LH){
      if(!window.LH.isInitialized){
    LH.init({
        LH_debug: false,
        spaceid: YAHOO.i13n.SPACEID
    });
      }
      Y.Get.js("https://s.yimg.com/zz/combo?os/mit/media/p/content/content-aft-min-b090b26.js&os/mit/media/p/content/content-aft-report-min-cc62833.js", function(err) {
        if (!err) {
            var yaftConfig = {
                modules: GROUPS.INSTR.getTrackedMods(),
                maxWaitTime: 5000,
                canShowVisualReport: true,
                useNormalizeCoverage: true
            };
            YAFT.init(yaftConfig, function(data,error) { //callback
                if (!error) {
                    window.LH.record('AFT', {name: 'AFT', type: 'mark', startTime: Math.round(data.aft), duration: 0});
                    window.LH.record('VIC', {name: 'VIC', type: 'mark', startTime: Math.round(data.visuallyComplete), duration: 0});
                }
            });
        }
      });
  }      }, window);


    });
  </script>
</body>
</html>
<!-- SID:YHOO:groups.yahoo.com:2019-11-12-09-28-33-J9u5QPxLsCvLzUNgwi2pPQ==-->

<!-- neo012.grp.bf1.yahoo.com Tue Nov 12 01:28:33 PST 2019 -->
