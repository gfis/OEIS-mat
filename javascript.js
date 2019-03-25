/*  Common JavaScript functions
    @(#) $Id: 88667e65444bc371cffa8f7cf036a20068f652bf $
    2019-01-03: generalLink(url, show, target)
    2016-04-30: mailToLink with up to 3 parameters
    2016-02-09: code.jquery.com commented out; telLink
    2015-04-25: loadPage
    2014-11-10: showImage
    2010-11-26: Dr. Georg Fischer
*/

function upper() {
} // raise

function lower(field) {
    var result = this.form1.prefix.value.toLowerCase();
    this.form1.prefix.value = result;
} // raise

function showImage(imagename, width) {
    document.write('<img src="' + imagename + '" width="' + width + '" title="' + imagename + '" />');
} // showImage

function mailtoLink(mailAddr, subject, body) { // surround a mail address by an <a href="mailto:..."> tag
    if (mailAddr != "undefined" && mailAddr.length > 0) { // non-empty
        document.write('<a href="mailto:' + mailAddr);
        if (subject != "undefined") {
            document.write("?subject=" + subject);
            if (body != "undefined") {
                document.write("\&body=" + body);
            } // with body
        } // with subject
        document.write('">' + mailAddr + '</a>');
    } // with mailAddr
} // mailtoLink

function facebookLink(fbName) { // surround a Facebook name by an <a href="https://www.facebook.com/..."> tag
    if (fbName != "undefined" && fbName.length > 0) { // non-empty
        document.write('<a target="_blank" href="https://www.facebook.com/' + fbName + '">' + fbName + '</a>');
    } // non-empty
} // facebookLink

function url(link, show, target, style) { // surround an URL by an <a href="..."> tag
    if (show   === undefined || show.length   == 0) {
        show   = link;
    }
    if (link   !== undefined && link.length     > 0) { // non-empty
        if (style !== undefined && style.length   > 0) { 
            document.write('<span class="' + style + '">');
        }
        document.write('<a href="' + link);
        if (false) {
        } else if (target === undefined) {
            document.write('" target="_blank');
        } else if (target.length > 0) {
            document.write('" target="' + target);
        } else { // length == 0
            // ignore, "" -> no target
        }
        document.write('">' + show + '</a>');
        if (style !== undefined && style.length   > 0) { 
            document.write('</span>');
        }
    } // non-empty
} // generalLink

function sep1000(decNum) { // insert thousand's separators in a decimal number
    var num = new String(decNum);
    var th3 = 6;
    // 123456789.01  length=11
    // 012345678901
    //       >>>>>> 
    // 123 456 789.01
    while (num.length > th3) {
        num = num.substring(0, num.length - th3) + ' ' + num.substring(num.length - th3, num.length);
        th3 += 4;
    } // while th3
    document.write(num);
} // sep1000

function telLink(localPrefix, telNo) { // surround a telephone number by an <a href="tel:..."> tag
    var intlTelNo = new String(telNo);
    intlTelNo = intlTelNo.replace(/[ \.\-]/g, "");
    if (intlTelNo != "undefined" && intlTelNo.length > 0) { // non-empty
        if (! intlTelNo.match(/^[0\+]/)) {
            intlTelNo = localPrefix + intlTelNo;
        } else if (intlTelNo.match(/^[0]/)){
            intlTelNo = intlTelNo.replace(/^0/, "+49");
        }
        document.write('<a href="tel:' + intlTelNo + '">' + telNo + '</a>');
    } // non-empty
} // telLink

/*
<script src="//code.jquery.com/jquery-1.10.2.js"></script>
function loadPage(pageRef, ref, breakAfter) {
    jQuery(document).ready(function(){
        jQuery("#ref" + ref).load("servlet?spec=fibu.kontenblatt&amp;fibukto=" + ref);
    });
    document.write('<p id="ref' + ref + '"></p>');
} // loadPage
*/
