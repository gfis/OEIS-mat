: # Hypercalc, Copyright (C) 1998-2020 Robert P. Munafo  *-*-perl-*-*
  eval 'exec perl -S  $0 ${1+"$@"}' 
    if 0;  # if running under some shell

# This is the 2020 Mar 26 version of Hypercalc.

my $bapropos = q@
hypercalc(1r)      - interpreted calculator with special provisions
                     to avoid overflow
@;

#                              RHTF NOTE
#
#           If this file is in rhtf/src, it is read-only.
#
#  The file rhtf/.../hypercalc.txt is derived from .../bin/hypercalc
#               and copied automatically by misc.per
#

use IO::Handle;
use IO::File;
use IPC::Open2;

$format_debug = 0;
$g_min_mant_digits = 3;

$HC_BANNER = q@

    Hypercalc, Copyright (C) 1998-2020 Robert P. Munafo.
    This is the 2020 Mar 26 version of Hypercalc.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License (immediately following this text) for
    more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    For more perl goodness, go to mrob.com/pub/perl

@; $HC_MANPAGE = q`
NAME

  hypercalc        - interpreted calculator with special provisions
                     to avoid overflow

DESCRIPTION

#hypercalc# is an interactive calculator program with command history,
variable substitution, and a programming language similar to BASIC.
Its most distinctive feature is that it uses an internal representation
of numbers that avoids overflow by supporting arbitrarily high "towers"
of exponents.

For more information and complete descriptions of #hypercalc# expression
syntax, variables, programming, etc. start hypercalc with no argument
and then type "help" at the prompt.

`; $GPL_VERSION_3 = q`

                   GNU GENERAL PUBLIC LICENSE

                     Version 3, 29 June 2007

Copyright (c) 2007 Free Software Foundation, Inc. <http://fsf.org/>

Everyone is permitted to copy and distribute verbatim copies of this
license document, but changing it is not allowed.

Preamble

The GNU General Public License is a free, copyleft license for
software and other kinds of works.

The licenses for most software and other practical works are designed
to take away your freedom to share and change the works. By contrast,
the GNU General Public License is intended to guarantee your freedom
to share and change all versions of a program--to make sure it remains
free software for all its users. We, the Free Software Foundation, use
the GNU General Public License for most of our software; it applies
also to any other work released this way by its authors. You can apply
it to your programs, too.

When we speak of free software, we are referring to freedom, not
price. Our General Public Licenses are designed to make sure that you
have the freedom to distribute copies of free software (and charge for
them if you wish), that you receive source code or can get it if you
want it, that you can change the software or use pieces of it in new
free programs, and that you know you can do these things.

To protect your rights, we need to prevent others from denying you
these rights or asking you to surrender the rights. Therefore, you
have certain responsibilities if you distribute copies of the
software, or if you modify it: responsibilities to respect the freedom
of others.

For example, if you distribute copies of such a program, whether
gratis or for a fee, you must pass on to the recipients the same
freedoms that you received. You must make sure that they, too, receive
or can get the source code. And you must show them these terms so they
know their rights.

Developers that use the GNU GPL protect your rights with two steps:
(1) assert copyright on the software, and (2) offer you this License
giving you legal permission to copy, distribute and/or modify it.

For the developers' and authors' protection, the GPL clearly explains
that there is no warranty for this free software. For both users' and
authors' sake, the GPL requires that modified versions be marked as
changed, so that their problems will not be attributed erroneously to
authors of previous versions.

Some devices are designed to deny users access to install or run
modified versions of the software inside them, although the
manufacturer can do so. This is fundamentally incompatible with the
aim of protecting users' freedom to change the software. The
systematic pattern of such abuse occurs in the area of products for
individuals to use, which is precisely where it is most unacceptable.
Therefore, we have designed this version of the GPL to prohibit the
practice for those products. If such problems arise substantially in
other domains, we stand ready to extend this provision to those
domains in future versions of the GPL, as needed to protect the
freedom of users.

Finally, every program is threatened constantly by software patents.
States should not allow patents to restrict development and use of
software on general-purpose computers, but in those that do, we wish
to avoid the special danger that patents applied to a free program
could make it effectively proprietary. To prevent this, the GPL
assures that patents cannot be used to render the program non-free.

The precise terms and conditions for copying, distribution and
modification follow.

TERMS AND CONDITIONS

0. Definitions.

"This License" refers to version 3 of the GNU General Public License.

"Copyright" also means copyright-like laws that apply to other kinds
of works, such as semiconductor masks.

"The Program" refers to any copyrightable work licensed under this
License. Each licensee is addressed as "you". "Licensees" and
"recipients" may be individuals or organizations.

To "modify" a work means to copy from or adapt all or part of the work
in a fashion requiring copyright permission, other than the making of
an exact copy. The resulting work is called a "modified version" of
the earlier work or a work "based on" the earlier work.

A "covered work" means either the unmodified Program or a work based
on the Program.

To "propagate" a work means to do anything with it that, without
permission, would make you directly or secondarily liable for
infringement under applicable copyright law, except executing it on a
computer or modifying a private copy. Propagation includes copying,
distribution (with or without modification), making available to the
public, and in some countries other activities as well.

To "convey" a work means any kind of propagation that enables other
parties to make or receive copies. Mere interaction with a user
through a computer network, with no transfer of a copy, is not
conveying.

An interactive user interface displays "Appropriate Legal Notices" to
the extent that it includes a convenient and prominently visible
feature that (1) displays an appropriate copyright notice, and (2)
tells the user that there is no warranty for the work (except to the
extent that warranties are provided), that licensees may convey the
work under this License, and how to view a copy of this License. If
the interface presents a list of user commands or options, such as a
menu, a prominent item in the list meets this criterion.

1. Source Code.

The "source code" for a work means the preferred form of the work for
making modifications to it. "Object code" means any non-source form of
a work.

A "Standard Interface" means an interface that either is an official
standard defined by a recognized standards body, or, in the case of
interfaces specified for a particular programming language, one that
is widely used among developers working in that language.

The "System Libraries" of an executable work include anything, other
than the work as a whole, that (a) is included in the normal form of
packaging a Major Component, but which is not part of that Major
Component, and (b) serves only to enable use of the work with that
Major Component, or to implement a Standard Interface for which an
implementation is available to the public in source code form. A
"Major Component", in this context, means a major essential component
(kernel, window system, and so on) of the specific operating system
(if any) on which the executable work runs, or a compiler used to
produce the work, or an object code interpreter used to run it.

The "Corresponding Source" for a work in object code form means all
the source code needed to generate, install, and (for an executable
work) run the object code and to modify the work, including scripts to
control those activities. However, it does not include the work's
System Libraries, or general-purpose tools or generally available free
programs which are used unmodified in performing those activities but
which are not part of the work. For example, Corresponding Source
includes interface definition files associated with source files for
the work, and the source code for shared libraries and dynamically
linked subprograms that the work is specifically designed to require,
such as by intimate data communication or control flow between those
subprograms and other parts of the work.

The Corresponding Source need not include anything that users can
regenerate automatically from other parts of the Corresponding Source.

The Corresponding Source for a work in source code form is that same
work.

2. Basic Permissions.

All rights granted under this License are granted for the term of
copyright on the Program, and are irrevocable provided the stated
conditions are met. This License explicitly affirms your unlimited
permission to run the unmodified Program. The output from running a
covered work is covered by this License only if the output, given its
content, constitutes a covered work. This License acknowledges your
rights of fair use or other equivalent, as provided by copyright law.

You may make, run and propagate covered works that you do not convey,
without conditions so long as your license otherwise remains in force.
You may convey covered works to others for the sole purpose of having
them make modifications exclusively for you, or provide you with
facilities for running those works, provided that you comply with the
terms of this License in conveying all material for which you do not
control copyright. Those thus making or running the covered works for
you must do so exclusively on your behalf, under your direction and
control, on terms that prohibit them from making any copies of your
copyrighted material outside their relationship with you.

Conveying under any other circumstances is permitted solely under the
conditions stated below. Sublicensing is not allowed; section 10 makes
it unnecessary.

3. Protecting Users' Legal Rights From Anti-Circumvention Law.

No covered work shall be deemed part of an effective technological
measure under any applicable law fulfilling obligations under article
11 of the WIPO copyright treaty adopted on 20 December 1996, or
similar laws prohibiting or restricting circumvention of such
measures.

When you convey a covered work, you waive any legal power to forbid
circumvention of technological measures to the extent such
circumvention is effected by exercising rights under this License with
respect to the covered work, and you disclaim any intention to limit
operation or modification of the work as a means of enforcing, against
the work's users, your or third parties' legal rights to forbid
circumvention of technological measures.

4. Conveying Verbatim Copies.

You may convey verbatim copies of the Program's source code as you
receive it, in any medium, provided that you conspicuously and
appropriately publish on each copy an appropriate copyright notice;
keep intact all notices stating that this License and any
non-permissive terms added in accord with section 7 apply to the code;
keep intact all notices of the absence of any warranty; and give all
recipients a copy of this License along with the Program.

You may charge any price or no price for each copy that you convey,
and you may offer support or warranty protection for a fee.

5. Conveying Modified Source Versions.

You may convey a work based on the Program, or the modifications to
produce it from the Program, in the form of source code under the
terms of section 4, provided that you also meet all of these
conditions:

  a) The work must carry prominent notices stating that you modified
     it, and giving a relevant date.

  b) The work must carry prominent notices stating that it is released
     under this License and any conditions added under section 7. This
     requirement modifies the requirement in section 4 to "keep intact
     all notices".

  c) You must license the entire work, as a whole, under this License
     to anyone who comes into possession of a copy. This License will
     therefore apply, along with any applicable section 7 additional
     terms, to the whole of the work, and all its parts, regardless of
     how they are packaged. This License gives no permission to
     license the work in any other way, but it does not invalidate
     such permission if you have separately received it.

  d) If the work has interactive user interfaces, each must display
     Appropriate Legal Notices; however, if the Program has
     interactive interfaces that do not display Appropriate Legal
     Notices, your work need not make them do so.

A compilation of a covered work with other separate and independent
works, which are not by their nature extensions of the covered work,
and which are not combined with it such as to form a larger program,
in or on a volume of a storage or distribution medium, is called an
"aggregate" if the compilation and its resulting copyright are not
used to limit the access or legal rights of the compilation's users
beyond what the individual works permit. Inclusion of a covered work
in an aggregate does not cause this License to apply to the other
parts of the aggregate.

6. Conveying Non-Source Forms.

You may convey a covered work in object code form under the terms of
sections 4 and 5, provided that you also convey the machine-readable
Corresponding Source under the terms of this License, in one of these
ways:

  a) Convey the object code in, or embodied in, a physical product
     (including a physical distribution medium), accompanied by the
     Corresponding Source fixed on a durable physical medium
     customarily used for software interchange.

  b) Convey the object code in, or embodied in, a physical product
     (including a physical distribution medium), accompanied by a
     written offer, valid for at least three years and valid for as
     long as you offer spare parts or customer support for that
     product model, to give anyone who possesses the object code
     either (1) a copy of the Corresponding Source for all the
     software in the product that is covered by this License, on a
     durable physical medium customarily used for software
     interchange, for a price no more than your reasonable cost of
     physically performing this conveying of source, or (2) access to
     copy the Corresponding Source from a network server at no charge.

  c) Convey individual copies of the object code with a copy of the
     written offer to provide the Corresponding Source. This
     alternative is allowed only occasionally and noncommercially, and
     only if you received the object code with such an offer, in
     accord with subsection 6b.

  d) Convey the object code by offering access from a designated place
     (gratis or for a charge), and offer equivalent access to the
     Corresponding Source in the same way through the same place at no
     further charge. You need not require recipients to copy the
     Corresponding Source along with the object code. If the place to
     copy the object code is a network server, the Corresponding
     Source may be on a different server (operated by you or a third
     party) that supports equivalent copying facilities, provided you
     maintain clear directions next to the object code saying where to
     find the Corresponding Source. Regardless of what server hosts
     the Corresponding Source, you remain obligated to ensure that it
     is available for as long as needed to satisfy these requirements.

  e) Convey the object code using peer-to-peer transmission, provided
     you inform other peers where the object code and Corresponding
     Source of the work are being offered to the general public at no
     charge under subsection 6d.

A separable portion of the object code, whose source code is excluded
from the Corresponding Source as a System Library, need not be
included in conveying the object code work.

A "User Product" is either (1) a "consumer product", which means any
tangible personal property which is normally used for personal,
family, or household purposes, or (2) anything designed or sold for
incorporation into a dwelling. In determining whether a product is a
consumer product, doubtful cases shall be resolved in favor of
coverage. For a particular product received by a particular user,
"normally used" refers to a typical or common use of that class of
product, regardless of the status of the particular user or of the way
in which the particular user actually uses, or expects or is expected
to use, the product. A product is a consumer product regardless of
whether the product has substantial commercial, industrial or
non-consumer uses, unless such uses represent the only significant
mode of use of the product.

"Installation Information" for a User Product means any methods,
procedures, authorization keys, or other information required to
install and execute modified versions of a covered work in that User
Product from a modified version of its Corresponding Source. The
information must suffice to ensure that the continued functioning of
the modified object code is in no case prevented or interfered with
solely because modification has been made.

If you convey an object code work under this section in, or with, or
specifically for use in, a User Product, and the conveying occurs as
part of a transaction in which the right of possession and use of the
User Product is transferred to the recipient in perpetuity or for a
fixed term (regardless of how the transaction is characterized), the
Corresponding Source conveyed under this section must be accompanied
by the Installation Information. But this requirement does not apply
if neither you nor any third party retains the ability to install
modified object code on the User Product (for example, the work has
been installed in ROM).

The requirement to provide Installation Information does not include a
requirement to continue to provide support service, warranty, or
updates for a work that has been modified or installed by the
recipient, or for the User Product in which it has been modified or
installed. Access to a network may be denied when the modification
itself materially and adversely affects the operation of the network
or violates the rules and protocols for communication across the
network.

Corresponding Source conveyed, and Installation Information provided,
in accord with this section must be in a format that is publicly
documented (and with an implementation available to the public in
source code form), and must require no special password or key for
unpacking, reading or copying.

7. Additional Terms.

"Additional permissions" are terms that supplement the terms of this
License by making exceptions from one or more of its conditions.
Additional permissions that are applicable to the entire Program shall
be treated as though they were included in this License, to the extent
that they are valid under applicable law. If additional permissions
apply only to part of the Program, that part may be used separately
under those permissions, but the entire Program remains governed by
this License without regard to the additional permissions.

When you convey a copy of a covered work, you may at your option
remove any additional permissions from that copy, or from any part of
it. (Additional permissions may be written to require their own
removal in certain cases when you modify the work.) You may place
additional permissions on material, added by you to a covered work,
for which you have or can give appropriate copyright permission.

Notwithstanding any other provision of this License, for material you
add to a covered work, you may (if authorized by the copyright holders
of that material) supplement the terms of this License with terms:

  a) Disclaiming warranty or limiting liability differently from the
     terms of sections 15 and 16 of this License; or

  b) Requiring preservation of specified reasonable legal notices or
     author attributions in that material or in the Appropriate Legal
     Notices displayed by works containing it; or

  c) Prohibiting misrepresentation of the origin of that material, or
     requiring that modified versions of such material be marked in
     reasonable ways as different from the original version; or

  d) Limiting the use for publicity purposes of names of licensors or
     authors of the material; or

  e) Declining to grant rights under trademark law for use of some
     trade names, trademarks, or service marks; or

  f) Requiring indemnification of licensors and authors of that material
     by anyone who conveys the material (or modified versions of it)
     with contractual assumptions of liability to the recipient, for
     any liability that these contractual assumptions directly impose on
     those licensors and authors.

All other non-permissive additional terms are considered "further
restrictions" within the meaning of section 10. If the Program as you
received it, or any part of it, contains a notice stating that it is
governed by this License along with a term that is a further
restriction, you may remove that term. If a license document contains
a further restriction but permits relicensing or conveying under this
License, you may add to a covered work material governed by the terms
of that license document, provided that the further restriction does
not survive such relicensing or conveying.

If you add terms to a covered work in accord with this section, you
must place, in the relevant source files, a statement of the
additional terms that apply to those files, or a notice indicating
where to find the applicable terms.

Additional terms, permissive or non-permissive, may be stated in the
form of a separately written license, or stated as exceptions; the
above requirements apply either way.

8. Termination.

You may not propagate or modify a covered work except as expressly
provided under this License. Any attempt otherwise to propagate or
modify it is void, and will automatically terminate your rights under
this License (including any patent licenses granted under the third
paragraph of section 11).

However, if you cease all violation of this License, then your license
from a particular copyright holder is reinstated (a) provisionally,
unless and until the copyright holder explicitly and finally
terminates your license, and (b) permanently, if the copyright holder
fails to notify you of the violation by some reasonable means prior to
60 days after the cessation.

Moreover, your license from a particular copyright holder is
reinstated permanently if the copyright holder notifies you of the
violation by some reasonable means, this is the first time you have
received notice of violation of this License (for any work) from that
copyright holder, and you cure the violation prior to 30 days after
your receipt of the notice.

Termination of your rights under this section does not terminate the
licenses of parties who have received copies or rights from you under
this License. If your rights have been terminated and not permanently
reinstated, you do not qualify to receive new licenses for the same
material under section 10.

9. Acceptance Not Required for Having Copies.

You are not required to accept this License in order to receive or run
a copy of the Program. Ancillary propagation of a covered work
occurring solely as a consequence of using peer-to-peer transmission
to receive a copy likewise does not require acceptance. However,
nothing other than this License grants you permission to propagate or
modify any covered work. These actions infringe copyright if you do
not accept this License. Therefore, by modifying or propagating a
covered work, you indicate your acceptance of this License to do so.

10. Automatic Licensing of Downstream Recipients.

Each time you convey a covered work, the recipient automatically
receives a license from the original licensors, to run, modify and
propagate that work, subject to this License. You are not responsible
for enforcing compliance by third parties with this License.

An "entity transaction" is a transaction transferring control of an
organization, or substantially all assets of one, or subdividing an
organization, or merging organizations. If propagation of a covered
work results from an entity transaction, each party to that
transaction who receives a copy of the work also receives whatever
licenses to the work the party's predecessor in interest had or could
give under the previous paragraph, plus a right to possession of the
Corresponding Source of the work from the predecessor in interest, if
the predecessor has it or can get it with reasonable efforts.

You may not impose any further restrictions on the exercise of the
rights granted or affirmed under this License. For example, you may
not impose a license fee, royalty, or other charge for exercise of
rights granted under this License, and you may not initiate litigation
(including a cross-claim or counterclaim in a lawsuit) alleging that
any patent claim is infringed by making, using, selling, offering for
sale, or importing the Program or any portion of it.

11. Patents.

A "contributor" is a copyright holder who authorizes use under this
License of the Program or a work on which the Program is based. The
work thus licensed is called the contributor's "contributor version".

A contributor's "essential patent claims" are all patent claims owned
or controlled by the contributor, whether already acquired or
hereafter acquired, that would be infringed by some manner, permitted
by this License, of making, using, or selling its contributor version,
but do not include claims that would be infringed only as a
consequence of further modification of the contributor version. For
purposes of this definition, "control" includes the right to grant
patent sublicenses in a manner consistent with the requirements of
this License.

Each contributor grants you a non-exclusive, worldwide, royalty-free
patent license under the contributor's essential patent claims, to
make, use, sell, offer for sale, import and otherwise run, modify and
propagate the contents of its contributor version.

In the following three paragraphs, a "patent license" is any express
agreement or commitment, however denominated, not to enforce a patent
(such as an express permission to practice a patent or covenant not to
sue for patent infringement). To "grant" such a patent license to a
party means to make such an agreement or commitment not to enforce a
patent against the party.

If you convey a covered work, knowingly relying on a patent license,
and the Corresponding Source of the work is not available for anyone
to copy, free of charge and under the terms of this License, through a
publicly available network server or other readily accessible means,
then you must either (1) cause the Corresponding Source to be so
available, or (2) arrange to deprive yourself of the benefit of the
patent license for this particular work, or (3) arrange, in a manner
consistent with the requirements of this License, to extend the patent
license to downstream recipients. "Knowingly relying" means you have
actual knowledge that, but for the patent license, your conveying the
covered work in a country, or your recipient's use of the covered work
in a country, would infringe one or more identifiable patents in that
country that you have reason to believe are valid.

If, pursuant to or in connection with a single transaction or
arrangement, you convey, or propagate by procuring conveyance of, a
covered work, and grant a patent license to some of the parties
receiving the covered work authorizing them to use, propagate, modify
or convey a specific copy of the covered work, then the patent license
you grant is automatically extended to all recipients of the covered
work and works based on it.

A patent license is "discriminatory" if it does not include within the
scope of its coverage, prohibits the exercise of, or is conditioned on
the non-exercise of one or more of the rights that are specifically
granted under this License. You may not convey a covered work if you
are a party to an arrangement with a third party that is in the
business of distributing software, under which you make payment to the
third party based on the extent of your activity of conveying the
work, and under which the third party grants, to any of the parties
who would receive the covered work from you, a discriminatory patent
license (a) in connection with copies of the covered work conveyed by
you (or copies made from those copies), or (b) primarily for and in
connection with specific products or compilations that contain the
covered work, unless you entered into that arrangement, or that patent
license was granted, prior to 28 March 2007.

Nothing in this License shall be construed as excluding or limiting
any implied license or other defenses to infringement that may
otherwise be available to you under applicable patent law.

12. No Surrender of Others' Freedom.

If conditions are imposed on you (whether by court order, agreement or
otherwise) that contradict the conditions of this License, they do not
excuse you from the conditions of this License. If you cannot convey a
covered work so as to satisfy simultaneously your obligations under
this License and any other pertinent obligations, then as a
consequence you may not convey it at all. For example, if you agree to
terms that obligate you to collect a royalty for further conveying
from those to whom you convey the Program, the only way you could
satisfy both those terms and this License would be to refrain entirely
from conveying the Program.

13. Use with the GNU Affero General Public License.

Notwithstanding any other provision of this License, you have
permission to link or combine any covered work with a work licensed
under version 3 of the GNU Affero General Public License into a single
combined work, and to convey the resulting work. The terms of this
License will continue to apply to the part which is the covered work,
but the special requirements of the GNU Affero General Public License,
section 13, concerning interaction through a network will apply to the
combination as such.

14. Revised Versions of this License.

The Free Software Foundation may publish revised and/or new versions
of the GNU General Public License from time to time. Such new versions
will be similar in spirit to the present version, but may differ in
detail to address new problems or concerns.

Each version is given a distinguishing version number. If the Program
specifies that a certain numbered version of the GNU General Public
License "or any later version" applies to it, you have the option of
following the terms and conditions either of that numbered version or
of any later version published by the Free Software Foundation. If the
Program does not specify a version number of the GNU General Public
License, you may choose any version ever published by the Free
Software Foundation.

If the Program specifies that a proxy can decide which future versions
of the GNU General Public License can be used, that proxy's public
statement of acceptance of a version permanently authorizes you to
choose that version for the Program.

Later license versions may give you additional or different
permissions. However, no additional obligations are imposed on any
author or copyright holder as a result of your choosing to follow a
later version.

15. Disclaimer of Warranty.

THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY
APPLICABLE LAW. EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT
HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM "AS IS" WITHOUT
WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND
PERFORMANCE OF THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE
DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR
CORRECTION.

16. Limitation of Liability.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MODIFIES AND/OR
CONVEYS THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES,
INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES
ARISING OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT
NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR
LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM
TO OPERATE WITH ANY OTHER PROGRAMS), EVEN IF SUCH HOLDER OR OTHER
PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

17. Interpretation of Sections 15 and 16.

If the disclaimer of warranty and limitation of liability provided
above cannot be given local legal effect according to their terms,
reviewing courts shall apply local law that most closely approximates
an absolute waiver of all civil liability in connection with the
Program, unless a warranty or assumption of liability accompanies a
copy of the Program in return for a fee.

END OF TERMS AND CONDITIONS
`;

$GPLNOTICE = "
Hypercalc is distributed under the terms and conditions of the
GNU General Public License, version 3, June 2007. Type 'help gpl'
at the Hypercalc prompt for details.
";

sub date1
{
  my($offset) = @_;
  my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst);
  my($cn_date);

  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)
                                                 = localtime(time + $offset);
  $year += 1900;
  $cn_date = sprintf("%04d%02d%02d", $year, $mon+1, $mday);
  return $cn_date;
}

sub fdate2
{
  my($dt1) = @_;
  my($yyyy, $mm, $dd);
  my @months = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );

  if ($dt1 =~ m/^([0-9]{4})([0-9]{2})([0-9]{2})$/) {
    $yyyy = $1; $mm = $2; $dd = $3;
    $dt1 = "$yyyy " . $months[$mm-1] . " $dd";
  }
  return $dt1;
}

sub subst_global_tags
{
  my($l) = @_;

  if ($g_dth eq '') {
    $g_dth = &fdate2(&date1(0));
  }

  $l =~ s|BWEBD[_]SUBST_AUTODATE_TAG|$g_dth|g;
  return $l;
}

#
# hypercalc -- interpreted calculator with special provisions to avoid
#              overflow
#

$tagline = &subst_global_tags("
       Hypercalc by Robert Munafo, 2020 Mar 26
      Go ahead -- just TRY to make me overflow!
           _ _
           |_| . . ._   _  ._  _ ._  |  _
           | | | | | ) (-` |  (  ,-| | (
           ~ ~  7  |~   ~' ~   ~ `~` ~  ~
               -'   mrob.com/hypercalc

     Enter expressions, or type 'help' for help.
"); # )) balance parens in ASCII banner

#
#  Which is bigger:  27 ^ (86 !)  or  (27 ^ 86) !
#  Most calculators can't even give the value of 27^86 or of 86!.
#
#  With HyperCalc you can see that 27^86 is 1.251076x10^123,
#  and 86! is 2.422709x10^130. Some calculators can handle that --
#  the current record-holder is AlCalc for the Pilot, which goes
#  as high as 10^32767 and can handle 9274! (9274 factorial)
#
#  But no other calculator can tell you that
#
#    (27 ^ 86) !  =  10 ^ (1.534607.. x 10 ^ 125)
#
#  or that
#
#    27 ^ (86!)   =  10 ^ (3.467778.. x 10 ^ 130)
#
#  (in other words, the first has over 10^125 digits and the second,
#  with over 10^130 digits is "just a little bit" larger.)


#                        Project notes follow
$ignored_block_comment = qq@

Hypercalc is an open-source interpreted calculator program designed to
calculate extremely large numbers (such as your phone number raised to
the power of the factorial of the Federal budget deficit) without
overflowing.

It does this by using a modified form of the level-index number system
with a radix of 1.0e300

  Performance stats for other calculators

  Year Make and model  Overflow   Digits      sin/cos
                                  (pi, e)     radians
  1973 TI SR-50        1.0e100    589,459     ?

  1980 Sharp EL-5100   1.0e100    12?         ?

  1989 Casio fx-7500G  1.0e100    59,459      1.57e8

  ?    Casio fx-115D   1.0e100    6,45        1.57e8 = 1/2 * 1e8 * pi

  1995 Casio CFX-9800G 1.0e100    5898,45904  1.57e8 = 1/2 * 1e8 * pi

  1997 Pilot AlCalc    1.0e32768  32?         n/a

  1998 Casio fx-260    1.0e100    6,45        1.57e8 = 1/2 * 1e8 * pi
  1998 Casio 9850      1.0e100    5898,45904  1.57e8 = 1/2 * 1e8 * pi
  1998 Casio 7400      1.0e100    5898,45904  1.57e8 = 1/2 * 1e8 * pi
  1998 Sharp EL-531L   1.0e100    58,44       1.7453e8 = 5/9 * 1e8 * pi
  1998 TI-85           1.0e1000   5898.459    1.0e12
  1998 TI-92           1.0e1000   5898,459    1.0e13

  1999 TI-89           1.0e1000   5898,459

  ?    Mathematica     1.44e323228010 n/a     ?

  1998 Hypercalc       32768pt300 58979,45905 1.35e10 = 2^32 * pi
       (for Palm)
  1999 Hypercalc       (10^10)pt300 300       1.35e10 = 2^32 * pi
       (for UNIX)

 The overflow value for Hypercalc is so large it can't be represented
 in the standard way. If we use Hypercalc's internal "PT" format it's
 easy.

 Hypercalc handles numbers with absolute value greater than the range
 supported by the floating point library by storing the numbers in
 many different formats. When the numbers are within normal
 floating-point range (less than 10^300) they are stored in the normal
 floating-point format. Between 10^300 and 10^(10^300) they are stored
 as logarithms, and Logarithmic Number System (LNS) algorithms are
 used. When the logarithm gets too big to store as a floating point
 number, the log is taken again, and so on. An integer field is used
 to keep track of how many times the log has been taken. Here are some
 examples:

    pt-notation    pt    val     represents
    0pt1.0         0     1.0     1.0
    0pt3.45e10     0     3.45e10 3.45 x 10^10
    0pt1.0e299     0     1.0e299 1.0 x 10^299
    0pt9.9e299     0     9.9e299 9.9 x 10^299
    1pt300.0       1     300.0   1.0 x 10^300
    1pt300.301     1     300.301 2.0 x 10^300
    1pt301.0       1     301.0   1.0 x 10^301
    1pt834.173     1     834.173 1.489 x 10^834
    2pt79.0        2     79.0    10^(10^79)
    3pt34.0        3     34.0    10^(10^(10^34))
    254pt1.0e10    254   1.0e10  10^(10^(10^(10^ ... ^(10^10) ... ))), where
                                   there are 256 10's
    32767pt1.0e300 32767 1.0e300 10^(10^(... ^(10^300) ...)), with 32768
                                   10's; the highest number Hypercalc can
                                   handle (on the Palm platform; UNIX
                                   Hypercalc can go to about (10^10)PT1.0e300)
    (To read about even larger numbers, go to www.mrob.com and click
    on "Large Numbers".)


  Each time we transition from the top of one pt range to the bottom of the
  next, about 2 1/2 digits of precision are lost as the information formerly
  stored in the exponent has to be absorbed by the mantissa. Then, as we
  proceed up the range digits are gradually gained back until we reach the
  top of the range and we once again have a 2.5 digit exponent. So, for
  example at the top of the pt=0 range the values are things like
  1.23456789012345 x 10^299, and there are 53 binary digits of precision in
  the mantissa, or almost 16 decimal digits. Then we cross over into the pt1
  range and store the log instead, which becomes a value like
  301.456789012345 -- we still have 15+ digits to work with, but the first
  three correspond to the exponent of the number and there are only 12+ or
  13 digits left for expressing the mantissa. Of course as we keep going up
  we get to values like 123456.789012345 (which represents 6.15 x 10^123456)
  we lose even more mantissa digits to exponent, but eventually we'll get to
  values like 123456789012345000000 = 1.2345... x 10^20, which represents
  10^(1.2345... x 10^20) and as we go on up to even bigger numbers we see
  that since the exponent needs to be printed it once again holds information
  equivalent to 2 1/2 digits.

  This entire issue of variable numer of digits and the associated
  problems it causes with nonintuitive roundoff performance would be
  avoided if one used a "natural" PT storage format, where e is the
  base and the representation is such that the floating point value is
  always in the range [1.0, e]. So, for example, the number 143 would
  be represented as {2, 1.601979...} because e^(e^1.601979) is 143.
  Such a format would be unwieldy for normal calculations, however,
  because you'd have to keep doing e^x and ln(x) all over the place
  when doing simple calculations like 25 + 2.

@;

$hypercalc_revision_history = qq|

REVISION HISTORY

Hypercalc is one of my oldest projects; it began in 1998 as a Palm
Pilot program in C. To creat the Perl version, I hand-converted most
of the actual calculation functions to Perl and added a command-line
interpreter.

  Revision history for PalmPilot version of Hypercalc:

 1998101x Start project from "SampleCalc" example.
 19981018 Fairly complete scientific calculator, except trig functions
 19981021 Start implementing PT functions, get pt.exp and pt.mul working.
 19981022 Implement add/subtract, pow, pow10/log10, and gamma.
 19981024 Pretty much complete on the PT functions; they even handle
infinities properly. Also, add a "tiny" font to print exponents when
using the stdFont.
 19981025 Refine the formatting code for PT1's and higher so it
computes exactly how many digits of mantissa can be shown. Add some
more buttons, but most not implemented yet. Implement rounding
(incredibly complex!). Add arc, hyp, sto, rcl, 2nd, and 1/x keys (but
only implement 1/x)
 19981026 Add the same formatting refinements to PT0's, so it can
print contents of memories (which have fewer pixels available).
Implement Sto and Rcl keys.
 19981028 Add hyperbolic functions and inverse trig (but not inverse
hyperbolic trig)
 19981030 Add inverse hyperbolic functions.
 19981031 Put f_xxx and pt_xxx routines in their own files. Implement
floating-point square root based on the grammar school algorithm
(greatly increases speed of inverse trig functions).

 Revision history for Perl implementation of HyperCalc:

 19990610 Start writing a simple Perl calculator program using a new
concept: expression evaluation via regular expressions (I got the idea
while writing the #top100# movie statistics program). Right now it
just does + and @ (kind oflike *).
 19990701 Break '+' operator out into a separate subroutine add1
(eventually all operators will be done this way)
 19990720? Add all the code from the Pilot Hypercalc, to eventually
merge and translate into Perl.
 19970721 Parsing routine is fairly complete and now includes nested
loop to handle parentheses. Subroutines for all four operators +, -, *
and /. "e" and "%" in an expression represent 2.71828... and previous
result, respectively.
 19990725 Add splt() and start writing first operator that handles PT
types: p_add, pt.add, pt.addpos.
 19990727.2125 Do lots of porting work: put all routines in "proper"
(Pascal) order; lots of global replaces to change things like "x.pt"
to "$x_pt"; replace Taylor and Newton algorithms with builtin
functions where available; minimum work to get pt.addpos working. It
now properly adds 1e300 + 1e300 (and gets 1pt300.3010299...)
 19990727.2154 pt.add fully works; pt.div works.
 19990727.2235 pt.sub and pt.mul work now. Output formatting handles
some of the special cases to print values like 1p2345.6789 as 4.77 *
10^2345 rather than as "1 PT 2345.6789"
 19990727.2722 pt.ln works; parser handles ln() and log().
 19990728.1333 It now handles exp() and pow(), so I can compute really
big values without lots of repetitious keystrokes.
 19990728.25xx eval2() now stores all operator results into an array,
and stores the array index into the expression string. This is to
avoid numbers getting converted from strings into floating point and
back again, and that dramatically reduces roundoff error.
 19990729 Start editing all the f_xxx routines so the primitive
floating-point type can be changed easily later. This involves
implementing a minimal set of "primitives" like f_int, f_le, f_neg,
f.mul, etc. and making all the other f_xxx routines do all their
operations by calling these primitives. Also, inline constants like
"10" are replaced with globals.
 19990801 &pt.root and &pt.log_n work. All of the &f_xxx routines are
'primitivized', but &pt_xxx routines still need some work.
 19990801.2529 Add "debug" command. Put most of &f_xxx primitives
inside $f64_prim so they can be defined and redefined via &exec.
Create $g_pt_inf to distinguish uses of infinity in PT field from its
uses in VAL field. A few other changes to support switching VAL
primitive precision. Make it auto-promote inlines like "23e456".
 19990802 Pretty much finished making the &pt_xxx routines call &f_xxx
routines explicitly.
 1999080x Use open2() to launch #bc#. Write bce.
 19990805 Write &fbc_fix2sci, &fbc_split, &f.cmp, comparison primitives,
&f_neg, &me_magcompare, &m_truncround, &me_addpos, &f_add, &f.sub.
&fbc_encode renamed to &fbc.sci2fix. Redirect stderr when launching
#bc#.
 1999080x Write &me_subpos
 19990811 Add HC_LOG debug log, lots of calls to dbg1. Fix lots of
bugs. Write bc version of &f.mul and &f_div.
 19991015 Fix bug that caused small PT1's to be printed as e.g. 10 ^
301.30103. Make dbg1flag a bitmask to allow debugging functions,
expression parsing, or both.
 19991017 Add variables (currently limited to all-alphabetic starting
with "v")
 19991018 Change single-letter function abbreviations and special
letters like 'e', 'p' etc. to uppercase, to clear the lowercase
namespace for use by user variables.
 19991019 Fix some bugs relating to infinity handling and conversion
in fbc routines. Four basic functions almost work (subtraction still
seems to have problems)
 19991117 Variables no longer need to start with 'v'. Add 'sqrt'
function.
 19991124 Combine parsing of e/pi/phi with the variable and function
parsing; add error-check for undefined variables.
 20000120 Write fbc versions of f_ln and f.exp; fix bugs in fix2sci
and sci2fix; it now correctly computes 2^100 in scale 30. Fix bugs in
switching back and forth between f64 and fbc.
 20000206 Fix bug that prevented "sqrt(1+2)" from working
 20000304 sqrt now goes through f_sqrt. Fix bugs that made bc hi.init
not compute g_pi properly.
 20000728 Remove dependency on "rpmlib.pl"
 20010102 Add ERASE_BS test.
 20010103 Clean up internals of eval.2. Fix "right-to-left precedence
bug": "4-3-2" used to give "3", and "4/3/2" used to give "2.66667". I
am deliberately leaving exponents that way: 4^3^2 still gives 262144.
 20010107 Fix bugs: 2+2/(1+1) gave 2; 7^-1 didn't parse; scale
50,27^27 printed in scientific notation. Write &pt.roundup. Fix &prnt1
handling of high PT1's. fbc-based PT calculation is actually usable
now!
 20010108 Add history array and define_hist. Conversion across scale
changes works, at least in the cases I checked. Fix bug in eval.2:
sqrt() and other functions had become broken as a result of
yesterday's fixes. Clean up fbc version of f.gamma a little, but it
still suffers from a fundamental limit of the Stirling formula method,
which basically requires that the number being factorialed must be at
least as big as the 15th root of 10^curscale. Combined with the current
limit of 1.0e300 for the fbc float data type, that means we can't get
more than 33 digits of accuracy out of the f.gamma function. Increasing
the exponent limit would fix it, but that poses another problem with
the scaling loop -- for 50 digits of accuracy, the scaling loop has to
loop 2154 times (because 2154 = 10^(50/15)).
 2001010x Finish implementing #format# command.
 20010109 Fix bug that made history list usable only for first 9 items.
 20010115 Write init_pi_2, which calculates g_pi much more quickly.
Decrease gammalim.
 20010116 Add input history.
 20010117 Change letters I/H for input and output history to C/R
(commands and results).
 20010210 Fix "c2" in case where c2 is a variable assignment, and add
';' symbol to separate commands.
 20010216 Add ability to take "1e9" as input (used to require "1.e9")
 20010521 Make 'x' a synonym for '*'. This works pretty well, in fact
you can even define a variable 'x', and the expressions '2 x 4', '2 x
x' and 'x x x' all do the right thing! But, that's not recommended.
Also, change default output format to format 1, and make it print
multiplication as 'x' because it looks better.
 20010521 Map [] in input to (). This almost solves the problem of
having output and input formats match -- the one missing piece is
allowing the user to type 'PT', such as '3 PT 1.2 x 10^45'.
 20010530 Almost fix the ambiguity of '!!': You can now type "4!!" and
it will give you (4!)!, rather than '4' followed by the previous typed
line.
 20010601 When ';' is present in input, print each of the commands
with its 'C# =' label as they're being added to input_history.
 20010610 Detect presence of UNIX and doesn't try to run #bc# if not
on UNIX.
 20010613 Fix some of the bugs in handling of '-'. Add &pt_negate
 20011026 Fix some bugs in command history expansion.
 20011104 Add autodetect of ^H and call stty erase if they type it
(Unix only)
 20020129 Move automatic stty erase fix to subroutine fixerase.
 20020301 Read first expression from command line.
 20020305 Fix some bugs in rounding and pr.nt2 -- but it still has the
problem that "scale=15" prints the same number of digits as the
default "scale=14"
 20020306 Now can put multiple commands including 'scale=' and 'quit'
on command line
 20020711 Convert tabs to spaces in input

 20051228 Begin to implement BASIC interpreter
 20051229 Add OLD, SAVE and indenting
 20050102 Disambiguate input like "10 x = 2" and "10 x 2" (the first
is a BASIC line, the second is a calculation)

 20060716 Add &format4 and &format6.
 20060719 Add &format5.
 20061112 In canon_sci, remove trailing zeros from mantissa. (This
affects format5, and might not be what we want in all cases, but it
fixes cases like 10^27)
 20061126 FOR..NEXT works enough to compute, e.g. the value of Mega.
Also add CAT and rudimentary version of PRINT.
 20061129 Try to fix broken "x = x + 1"; this might cause other bugs.
Make "old" and "save" conscious of current file name.

 20070513 Add #help debug#; slight changes aimed at an eventual merge
of f64_prim and fbc_prim
 20070621 Fix a flaw in format5
 20070624 Add mantissa precision to range 1e5..1e7 in format5
 20070629 Add BASIC help
 20070809 Make format5's output a little more useful

 20071224 Add ability to input time in HH:MM:SS.frac format, and
format7 to print out in that format.
 20080204 Fix bug that prevented nested loops from working. Make BASIC
statements not print if they are followed by a semicolon.
 20080215 Accept abbreviated PT notation (e.g. "2P100" for Googolplex)
in input.
 20080508 A couple fixes intended to make negative exponents in
scientific notation (like "1.23e-4") work again.

 20081001 Slight improvements to #help var#

 20100113 Add #help format#. Add a missing pair of {} in prnt1 case p2_e.
Remove extra () and [] from most formats.
 20100204 Add a check for Cygwin and treat it as UNIX (for now; we
really need to also check for #bc# on all "Unix" systems)
 20100221 Fix a couple bugs related to creating and using directories.
Eliminate reference to my personal environment variable FROMWORK.
 20100318 Upgrade PRINT statement to support literal strings and
multiple arguments separated either by comma or semicolon (the latter
suppresses the trailing newline). Also, a trailing semicolon on
ordinary statements, LET and FOR suppresses printing of the value that
has been computed.
 20100329 Add $pt_str; handle $apt greater than 9 in &for.mat5.
 20100601 &do.cmd3: Don't allow user to "set" the constants pi, e or phi
 20100603 &do.cmd3: setvar errors now stop BASIC; detect setting r1, etc.
 20100611 Add $format.debug and several changes to &splt, &pr.nt2,
&canon_sci, &for.mat5, and &prnt1 which collectively make for.mat5
labels more accurate, correctly handle denormalised scientific
notation input like "13.72e9", and properly deal with infinity (e.g.
from inputting "1/0"). Also, &BASIC_old now allows whitespace blank
lines anywhere in its input.
 20100612 Allow '_' in variable names and program names.
 20100614 Turn most commands to lowercase (except lines inserted into
BASIC programs, and quoted strings in PRINT statements).
 20100705 Bug fix in mantissa rounding in &canon_sci.
 20100916 Add sine, cosine and tangent
 20101108 HC_LOG is now $g_logfile; use IO::Handle->flush operator to
flush log output before each input prompt.
  Several bug fixes: fbc_split now handles '+inf' and '-inf'; compound
statements in BASIC work again; detect wrong variable name on NEXT
statement.

 20110821 BASIC 'old' and 'new' now print a message if/when they do
nothing because the user did not give a name.
 20110822 Allow bare REM statement; print line number on "unrecognised
variable/function" error.
 A couple bug fixes in parsing '!!' and 'x' for multiplication; some
preparations for uncertainty (error) component. Bug fixes in handling
statement separators ':' and ';' (which had already been broken and
which I broke a little more in today's changes).
 20110823 More groundwork for uncertainty, mostly in &normalise (which
is now used for all number literals, even when not specified in "1.23e5"
format). Fix bugs in fbc.sci2fix (parsing mising sign), fbc version of
f.exp (negative exponents)
 20110828 A little cleanup in &eval.1; add &init_ir
 20110829 Begin work on handling uncertainty: changes to pt.add,
pt.addpos, pt.subpos; add pt.addlog.
 20110830 Add and subtract now handle uncertainty (for PT0 results
only). Rename pr.nt2 to "prnt3"; &pr.nt2 is now a wrapper for prnt3 that
inserts the uncertainty digits into the output.
  &pt.mul and &pt.div now handle uncertainty.
  &pt.log10, &pt.pow10, &pt.exp, &pt.pow and pt.sqrt now handle uncertainty.
  Some rewriting and expansion of built-in help text
  Add &cv.60_10 and make HH:MM:SS (sexagesimal) input work again.
 20110831 Get uncertainty calculations working in #bc# mode; also use
native floating point for most uncertainty calculations, since their
precision never needs to be more than that. A couple changes to ensure
uncertainty is always positive.
  Add &insert_uncertainty to encapsulate most of the new code in &pr.nt2,
mainly so I can use it elsewhere e.g. in format7.
 20110901 Get format7 to display uncertainty; fix a bug with
uncertainty exponent in normalise case 0.D
 20110902 Add uncertainty calculation to the remaining functions
(pt.gamma, pt_log_n, pt_root, and the trig functions). Fix a couple
bugs with infinity handling in prnt1 and prnt3. Consolidate TTD notes
on Gamma precision issues.
 20110908 Fix a couple bugs related to uncertainty and base-60 with
fractions.
 20120102 Fix handling of "1.23e-4" when using #bc# primitives (labels
are still broken in format 5)
 20120109 Rework the Gamma function code, adding more terms (suitable for
31-digit precision) and computing the cutoff values and precision levels
for a more informative "factorial will give only..." message. Also,
fix broken handling of "1.23e45" in #bc# primitives (a bug produced
by the "1.23e-4" fix)
 20120111 BASIC changes: Loop ranges can be a simple variable (e.g.
"for x=a to b"); single-quote "'" is now a synonym for "rem" to mark
comments.
 Use f.mul instead of explicit multiplication in division's
uncertainty calculation.
 20120204 Fix formatting of "39.37" when format=5
 20120422 Fix a number of Perl warnings (as suggested by Michael Samos)
(add "use warnings;" at top of file to see any remaining warnings).
 20120426 Stop trying to use f.gamma for large values when scale>14.
 20120610 Show more digits in format.5 for values in the range (1e5..1e10)
 20120612 Expand range of base-60 input and output.
 20120613 Fix a bug with parentheses in expand_C_hist and define.Chist.
 20121023 Return "nan" (not a number, i.e. undefined) for 1/0, 0^-1,
and several other similar cases.
 20121028 Add automatic multi-page help (like in #mira#)
 20121101 Fix bugs in fbc f_div that caused 1/inf to give 1einf, which
was interpreted as 1e0, rather than giving 0. This caused Gamma
accuracy problems for huge numbers of digits. For example,
"scale=200", "(10^100)!" gave an answer starting with 2.20515, but the
correct answer starts with 1.629404332. The Gamma value is too small
by a factor of e^2. Taking the factorial of 10^50 gives an answer too
small by a factor of e.
 20121102 Add &set.var and predefined variables "vigintillion",
"googol", etc. for some commonly-known big numbers. These should work
at all precisions.
 20121103 Add &is.nan, &is.inf, etc. and use them in most places,
hopefully to get more consistent handling of special cases. Work a
while on fixing the inconsistencies, e.g. for a while 1/0 gave NAN at
scale=14 but Inf at scale=200.
 20121209 Add g_BASIC.unsaved variable, accept single-quote REM
statements on immediate input.
 20130118 Fix bug in parsing OLD command
 20130208 Handle the syntax error that comes if you type "1+2t" where t
is a valid variable.
 20130224 &define.Chist does nothing when BASIC is running. &BASIC.save
sets g_BASIC.unsaved to 0.
 20130604 Add date to splash screen
 20131212 Add force_ee param to prnt3 and pr.nt2, use it in prnt1 when
we're printing any PT1 or higher, to tell it we need the Mx10^E form.
Add g_min_mant_digits constant (currently set to 5). Here is a
comparison of selected lines of the output of 'vals.basic':

    -------------before-------------      ---------------after---------------
    3.6846676 x 10 ^ 30102999             3.6846676 x 10 ^ 30102999
    4.613 x 10 ^ 301029995                4.613 x 10 ^ 301029995
    4.36353 x 10 ^ 3010299956             10 ^ ( 3.0102999566398 x 10 ^ 9 ) 
    2.5021 x 10 ^ 30102999566             10 ^ ( 3.0102999566398 x 10 ^ 10 ) 
    9.626 x 10 ^ 301029995663             10 ^ ( 3.0102999566398 x 10 ^ 11 ) 
    6.88 x 10 ^ 3010299956639             10 ^ ( 3.0102999566398 x 10 ^ 12 ) 
    10 ^ ( 30102999566398 )               10 ^ ( 3.0102999566398 x 10 ^ 13 ) 
    10 ^ ( 3.0102999566398 x 10 ^ 24 )    10 ^ ( 3.0102999566398 x 10 ^ 24 ) 
    ...
    10 ^ ( 1.388651 x 10 ^ 301029995 )    10 ^ ( 1.388651 x 10 ^ 301029995 ) 
    10 ^ ( 1.31355 x 10 ^ 3010299956 )    10 ^ [ 10 ^ ( 3.0102999561184 x 10 ^ 9 ) ] 
    10 ^ ( 7.5321 x 10 ^ 30102999565 )    10 ^ [ 10 ^ ( 3.0102999565876 x 10 ^ 10 ) ] 
    10 ^ ( 2.897 x 10 ^ 301029995663 )    10 ^ [ 10 ^ ( 3.0102999566346 x 10 ^ 11 ) ] 
    10 ^ ( 2.07 x 10 ^ 3010299956639 )    10 ^ [ 10 ^ ( 3.0102999566393 x 10 ^ 12 ) ] 
    10 ^ [ 10 ^ ( 30102999566397 ) ]      10 ^ [ 10 ^ ( 3.0102999566397 x 10 ^ 13 ) ] 

 20131217 Reduce g_min_mant_digits to 3 and make the
mantissa-truncation algorithms a bit more accuate.
  As a convenience for #bc# users and those with numeric keypads, a
bare '.' is now a synonym for '%', and '**' is a synonym for '^'.
 20131218 Add a lot to the built-in help
 20140123 Print the "factorial will give only XX digits" warning only when
the scale changes (so if you do "scale 50" twice in a row you only get the
warning once).
 20140715 Add comparison operators; add demotion to &splt so that
e.g. '1p1.000(1)e2' is converted to '0p1.00(26)e100'; add comments in
TO DO section outlining plans for a more complete BASIC language
 20140717 Add GOTO, catch ^C so user can stop a runaway BASIC program.
Add IF..THEN (one-line goto variant) and STOP; print statistics when
program finishes running.
 20140718 Add READ and DATA
 20140719 SQR is now an alias for SQRT; change the marker character in
eval.1/2 to single-quote (previously it was backtick and before that
pipe). BASIC implementation is now pretty much on par with the October
1968 version, except for the lack of DEF FN_ and MAT statements.
 20140720 Add INPUT statement.
 20140722 Add block comment section describing how the parsing and
evaluation work; remove unused 'showeach' parameter in a few places.
 20140723 Start writing qualify.basic and fix a few bugs revealed by it
(most notably,'0.00(1)' works now).
 20140904 Add Chuquet names million through nonillion
 20141208 Switch to GPL v3.
 20160317 Fix a couple bugs in parsing of PRINT statement arguments
 20160520 Allow 0s at beginning of a large number input.
 20180105 Format=5 now includes input expression, which is often useful
 20180208 fix.erase now removes any remaining non-ASCII characters,
this is to avoid messing up the screen when the user enters "up-arrow"
as input (and without having defined the variable 'a'), causing
normalise to print "ESC ( 0" which renders the terminal unusable.
 20181025 Add -h/--help and 'help manpage'
 20190212 Allow direct input of 'U' in numbers (e.g. 1.23U1); rename
&split() to &splt() to avoid confusion with the Perl builtin
 20190314 A little more margin in pt.mul's check against scale in the
PT2*PT2 case; add comments in pt.div about unhandled cases
 20190319 Suppress printing messages when setting 'scale' if there is
a semicolon; useful for BASIC programs that need higher precision but
don't actually use the gamma function.
 20190327 Avoid printing unneeded "1 x " before "10 ^"
 20190328 Add notes about stuctured IF; avoid saving a file as
"foo.basic.basic"
 20180330 Fix PRINT tab and newline after a string; structured multiline
IF .. ELSE .. END IF now works.
 20190409 Make pt.roundup do nothing if the input is an integer and
has fewer digits than scale. This fixes imprecise result in j from the
statement "j=1e5000". pt.div() now does integer precise 10^N in cases
like 1p5000/1p4900 (a test of an idea I want to do more of). Replace a
lot of f.mul calls with literal multiplcation in the f64 (native)
versions.
 20190411 Add boolean operators AND, OR, NOT and equivalent symbols &,
\|, ~ or !. For now, the first two also function as cheap bitwise
operators. ! is now overloaded: !6 is logical NOT, 6! is factorial.
 20190413 Implement GOSUB and RETURN; add RND() function.
 20190414 Improve parsing of variables and functions in eval.1() to
prepare for user-defined functions and arrays.
 20190415 More eval.1 changes, add constants true and false.
 20190418 Add reading of array values (but still can't set an array value)
 20190419 Track lvalues throughout expression evaluation (including
calls to define_ir and splt) and determine if an application of the '='
operator can be interpreted as an assignment; only eval_3 needs to be
changed to make it possible to assign to an array element.
 20190420 add pvu.sint, p.1d_lookup and p.2d_lookup; 1D and 2D arrays
now work (after refactoring assignment, IF evaluation, and a few other
things); eliminate use of 'A' for arctan.
 20190421 Add RESTORE statement
 20190422 Several fixes (e.g. READing array elements) to facilitate
wumpus.basic
 20190504 Add 'pragma' command
 20190505 Support out-of-order NEXT (happens when a GOTO exits a loop
causing a different NEXT to be reached)
 20190907 Add p.mod and pt.mod, and some changes to try to overload
'%' as both a "variable" and an operator. Programs rubik.basic and
bb2.basic demonstrate it.
 20190911 'run' rommand now accepts an argument, it will load and run
the specified program. Trace is now off by default.
 20190927 Increase g.gammalim to 101 and add a little more debugging;
add simple.nint and use it in f.gamma, pt.gamma
 20190928 Add intgam and return exact values for factorial when scale>14
and argument is in [1..164]
 20190929 fbc primitives for add, sub, mul, and div now preserve
simple.int property whenever possible. Modulo now works when scale>14.

|; # End of revision history

$ignored_block_comment = qq@

BUGS, TTD / TO DO and FUTURE IMPROVEMENTS

Modulo (%) does not work when scale is 15 or more (i.e. when using fbc
as native type). I think fixing this would require not always normalising
'17' to '1.7e1'.

Add pragma modes for sloppy NEXT and strict NEXT. Add ALTAIR (or
MSFT?) pragma which implies sloppy NEXT. If in strict NEXT mode, also
prohibit GOTO from exiting a loop scope.

"INPUT A(I)" does not work because it only recognizes plain variables.
To handle this I need to do the same thing that assignment does:
evaluate the argument of INPUT to discover if it is an lvalue and
get its lvalue key if so.

When loading a BASIC program, reset scale, format, pragma to defaults
(but the program or the user can then change any of these)

Arguments to LIST command to show parts of a program (have it do a full
BASIC_parse to get the indentation, saving the lines of text to a temp
array, from which the partial listing can be generated)

Try to unify and improve the format and content of the common parsing
errors. Here are two examples:
  C1 = 4!0!6
  *** Cannot parse '4!0!6' (nrm1)
  C2 = b=4;d=6;b!0!d
  *** Invalid syntax; I was left with 'I5!0!I4' (ev1)
In the (ev1) case I'd like to have it substitute I5 and I4 before
displaying to the user. The code near the end of eval.1 shows how to
recognise and convert 'I5'. The same would be useful in other error
messages such as "Illegal array index 'I4'"

Add int(a/b) with \ (as in VB).

Exact integer exponentiation -- might need a faster int function in bc
(the current f_int does fbc.fix2sci(fbc.sci2fix(x)) ) Look at the place
in pt_div that calls simple.int() and note the limited range of cases
(start with quick tests base and exponent both integers, 1<exponent<1024)

Expand BASIC implementation towards the goal of full compatibility
with the original Dartmouth BASIC:
 * Allow expressions in FOR limits
 * Add custom functions by DEF FNA(X)=... which can be implemented in
a similar way to the existing input history substitution (the
difference is, that any argument(s) should be evaluated as far as
possible before doing the substitution). The 'rnd()' function shows how
and where to handle function calls. To "define" fnx(a,b), detect
"fnx(a,b) = ..." in do.cmd3
 * Add ABS and INT functions; ATN synonym for existing arctan
 * Add arrays. The syntax is like a function: 'a(3)' or 'b(3,7)'.
Assigning to an array element requires recognising a new syntax,
consider input "a(rnd(2)+3) = 7"
 * Add DIM, which can be a no-op.

Additional BASIC improvements for version 2's CARDBASIC
 * Add preprocessing step that maps EQU to '=', LSS to '<', etc.
 * Matrix operations: MAT var = name OP name

BASIC version 4 (196801, see "19680101 BASIC 4th_Edition.pdf"):
 * ON .. GOTO
 * Strings and CHANGE keyword (which converts between a Pascal-like string
and an array of integers)

Later BASIC enhancements:
 * Don't allow GOTO or IF..THEN <line-number> to jump out of a loop.
This can be done in BASIC.parse by creating a new "scope-zone" with
each FOR statement, remembering the scope-zone of each non-FOR line,
and making sure control never transfers into a different scope zone.
NEXT statement should be tagged with the scope-zone that was created
by its FOR, so you can GOTO the NEXT statement from within the loop,
and a FOR should have the scope-zone of the loop it's inside (or 0 if
it's at the top level)
 * Generalize IF to allow IF .. THEN FOO for any keyword FOO
 * It's okay to overload bitwise and logical operations onto the same
symbols (that's what VB does)
 * 1970's extensions by Microsoft:
   - strings and functions ASC, CHR$, LEFT$, LEN, MID$, RIGHT$, SPC,
     STR, TAB, VAL
   - single-character input with GET
   - SGN function (returns sign -1 0 or 1)
   - STEP parameter in FOR loops
 * (see also error messages at www.vintage-basic.net/downloads/Vintage_BASIC_Users_Guide.html)

Other BASIC ideas of my own:
 * PRAGMA command to select different BASIC compatibility modes

Write some BASIC programs to test Hypercalc. For example, a program
that tests all branches of the pt.gamma code.

Add is.nan and isinf routines and use them to standardize the tests for
Infinity and NAN throughout all the functions (like f_div and pt.div).

Currently the uncertainty field is forced to zero whenever a PT1 or
higher quantity is computed. This is based on the idea that a computed
answer is useless if the uncertainty is a lot larger than the value.
But actually, such values are useful for computing something like the
number of possible universe-histories.
  But if I am going to extend uncertainties to PT1 and higher quantities,
I need to address two issues:
  * How to transition gracefully from a ratio-based limit similar
to what I am doing now, to a ratio-of-logarithm limit for PT1s, and a
ratio of log-log limit for PT2, etc.
  * How to display quantities with very large uncertainties. Consider
these examples:
    1.12e100 to 1.34e100 : "1.23(11)e100"   (uncertainty is in the mantissa)
    1.0e100  to 2.3e101  : ???
    1.00e101 to 1.00e103 : "1e102(1)"       (uncertainty is in the exponent)

Add Lambert W function. Based on the paper "Corless 1996 Lambert.pdf"
(pp. 21 and 27) the function can be computed by Halley's method
iteration, as in this example:
  C1 = ln(10)-ln(ln(10))
  R1 = 1.4685526477461
  C2 = %-(%*e^%-10)/(e^%*(1+%)-(%+2)*(%*e^%-10)/(2*%+2))
  R2 = 1.7416030169899
  C3 = !!
  !!: %-(%*e^%-10)/(e^%*(1+%)-(%+2)*(%*e^%-10)/(2*%+2))
  R3 = 1.7455279920176
  C4 = !!
  R4 = 1.7455280027407
  C5 = !!
  R5 = 1.7455280027407
  C6 = %*e^%
  R6 = 10

Presently, 10^10^7 prints "1.00000012{x}10^{10000000}". The erroneous
low-order digits can be eliminated by the following method:
  Choose an epsilon e.
  Convert (x-e), x, and (x+e) to strings
  Compare "(x-e)" to "x" and keep all digits that are identical.
  Compare "x" to "(x+e)" and keep all digits that are identical.
  Keep whichever of the preceding strings yields more digits.
  When a value "rolls over" from one PT level to the next (for
example, when multiplying 10^299 by 100) the number of mantissa bits
diminishes (or increases) by about 10 bits (because the rollover
cutoff value is approximately 2^2^10). Error introduced during such an
operation can propagate from intermediate results into any final
result, so th epsilon should be chosen as if the mantissa precision is
43 bits, rather than the actual precision of 53 bits.
  If the above doesn't always work, use a slightly bigger epsilon.
  Regardless of what is displayed, retain all the bits of each result
for use in subsequent calculations (I think hypercalc already does
this)

For more precision in f.gamma and pt.gamma, perhaps I can use the
Lanczos series given in A090674 and A090675. Details and analysis are
in "Pugh 2004 Analysis.pdf". There is a good practical explanation at:
  www.vttoth.com/CMS/projects/41-the-lanczos-approximation
    Source code is in "viktor-toth-lanczos-gamma-function.tgz"
    Documentation in "VT Toth Gamma web page.rtfd"
    (old URL: www.rskey.org/lanczos.htm)
  en.wikipedia.org/wiki/Lanczos_approximation


I might also want to look at PARI's implementation (mpgamma() and
mplngamma() in src/basemath/trans2.c)
  NOTE: To evaluate accuracy of gamma, compare "ln(299!)" in Hypercalc
to "lngamma(300.0)" in PARI/GP.

The following method to compute gamma(z) might work better:

   Gamma(z) = x^z e^(-x) SIGMA[ n=0..K, x^n/(z(z+1)(z+2)...(z+n)) ] + R
            = x^z e^(-x) SIGMA[ n=0..K, x^n/PI[ i=0..n, z+i ] ] + R

   where R, the "residual", is an integral that is always less than x e^(-x)

Thus we can approximate gamma(z) by the following steps:

  * Given D = the number of digits that are needed
  * Determine x such that x e^-x is less than 10^-D (and thus R is less
    than 10^-D). For example, if D=30, x is about 73 because 73*e^-73 is
    about 10^-30. A good quick approximation is x = D ln(10) + ln(D) + 1
  * Determine K such that the Kth term of the SIGMA is 10^D times smaller
    than the initial term. For example, if D=30 and z=0 (the smallest z
    we need to deal with), K is about 256, because 73^256/256! is about
    10^-30. For this step the Sterling approximation can be used for the
    factorial function.
      (Alternately, and to avoid doing more terms than we need when z is
    larger, just keep adding terms until the next term is less than 10^-D
    times the sum)

The drawback of this approach is the huge number of terms that need to
be added together. In this example there would be about 32000
multiplications to do the nested SIGMA and PI the simple way.
Obviously the partial product PI[i=0..n, z+i] can be carried from
one term of the SIGMA to the next, but it's still a lot of work.


OVERVIEW OF OPERATION

  mainloop
    BASIC_run
      docmd10
        (calls docmd6)
    docmd6
      docmd4
        docmd3
          expand_ih2
          set_var, hi.init, printing and formatting routines
          eval_1
            eval_2
              p_add, p_sub, p_mul, p_sqrt, p_negate, p_fact, p_ln, p_logn etc.
                pt_add, pt_sub, pt_mul, pt_sqrt, pt_negate, etc.
                  pt_addpos, pt_addlog, etc.
                    f.add, f.sub, f.mul, f.sqrt, f_neg, etc.
                      ("f64 version" uses built-in functions;
                       "fbc version" uses a child #bc# process)

Lexing and parsing are all done by string manipulation. To illustrate,
consider the following sequence of input: ("3+4", "j = 17",
"c1*ln(pi+j)"). Here the actions needed for the third input are
described in detail; each description starts with the literal value of
the string currently being evaluated.

C1 = 3+4
  'c1' is defined to be the string '3+4'
C2 = j = 17
  'j' is defined to be 17
C3 = c1*ln(pi+j)
  In do.cmd3, 'c1' is replaced with '(3+4)'
(3+4)*ln(pi+j)
  In do.cmd3, this string "(3+4)*ln(pi+j)" is stored into command history C4.
  In eval.1, single-quotes are placed around the whole expression
'(3+4)*ln(pi+j)'
  In eval.1, the value of 'j', "0 PT 1.70E1(0)", is stored in intermediate
  value I5
'(3+4)*ln(pi+I5)'
  In eval.1, the value of 'pi' is replaced with I2 (which is always pi)
'(3+4)*ln(I2+I5)'
  In eval.1, the predefined function name 'ln' is replaced with its
  abbreviation 'K'
'(3+4)*K(I2+I5)'
  The expression is now in canonical form ready for processing by eval.2.
  In eval.2, the first part '(3+4)*K(' and the final part ')' are "held"
  so that it can work on the section 'I2+I5' which contains no parentheses
'I2+I5'
  In eval.2, the addition is recognized and performed, the result
  "0 PT 20.1415926535898(0)" is stored in I6
'I6'
  In eval.2, the "held" parts of the expression are restored. Since the first
  part ends in a function name, the original parentheses are replaced with
  curly braces
'(3+4)*K{I6}'
  In eval.2, now the '(' and ')*K{I6}' are "held" to work on "3+4"
'3+4'
  The addition is performed and result "0 PT 7(0)" stored in I7
'I7'
  The "held" parts are restored; this time the parentheses are not part of
  a function so they are dropped.
'I7*K{I6}'
  There are now no more parentheses, so no further "holding" is needed.
  in eval.2, the 'K{I6}' is recognized and the ln function of I6 is computed,
  with the result "0 PT 3.00278696328944(0)"  stored into I8
'I7*I8'
  eval.2 recognizes a multiplication and performs it, storing the
  result "0 PT 21.0195087430261(0)" in I9
'I9'
  The expression is now a single atom, which eval_2 returns to eval.1.
  eval.1 removes the single-quotes and substitutes the value of I9
0P21.0195087430261
  do.cmd3 assigns this result to the results array R4.
  prnt1 (via various subroutines, usually pr.nt2 and prnt3) formats and prints
  the result "21.019508743026"


OLD NOTES

There is a discrepancy vs. Wolfram Alpha on large factorials:

                   Wolfram|Alpha          Hypercalc        error
 Cases where W|A gives N^N as the answer for N!
  (10^100)!     3p2.008600171761918   3p2.0085921235101  -0.000008
  (10^20)!      3p1.328400603937241   3p1.3282061673145  -0.00019
  (10^10)!      3p1.041392685158225   3p1.0406306991294  -0.00076

 Mystery (truncated Stirling series?):
  (10^8)!       2p8.878849437722037   2p8.878849435655   -2.06e-9
  (10^7)!       2p7.817281446362576   2p7.8172814258513  -2.05e-8
  (10^6)!       2p6.745520692234177   2p6.7455204892842  -2.03e-7

 Cases where W|A gives Gamma[N] as the answer fo N!
  100000!       2p5.659505898232984   2p5.6595106542789  +0.0000048
  30000!        2p5.083799800996968   2p5.0838158325409  +0.000016
  10000!        2.8462596809e35659    2.846259682e35659     OK
  1000!         4.02387260077e2567    4.02387260088e2567    OK

Oddly, Wolfram Alpha seems to be in error. For 20000!, it gives the
answer in two forms:

  Input:
    20000!
  Decimal approximation:
    1.8192063202303451348276... x 10^77337
  Power of 10 representation:
    10^10^4.888364627124846

We can check the conversion from the 1.819e77337 form to the
2p4.888... form by calculating log(77337+log(1.81920632023)).
Hypercalc and Mathematica agree that the answer is about
4.8883887806252, showing that the error is in Wolfram Alpha's
conversion to "Power of 10 representation".
  {Later I computed the ratio of the two Wolfram answers, which is
20000, making it clear that the wrong answer is actually Gamma[20000].
Meeussen Wouter responded to my math-fun posting with the same
discovery.}
  20130228: For (10^10)! and the larger cases, WolframAlpha is using
the approximation n! ~ n^n. Thus, their answer for (10^10)! is
10^10^11. The 10^20 and 10^100 cases are also n^n.
  For some intermediate values of N including 10^6 and 10^8, the
error is much smaller; it is clearly not giving Gamma[N] or N^N,
and yet there is still an error.


Steps that I took to implement % (modulo) operator:
  Get it to a point where variable values are set without being
normalised unless the value requires it (negative exponent of 10 i.e.
absolute value less than 1, or PT greater than 0).
  Make splt() leave the value alone if it is a simple integer. As it
stands now, '17' gets turned into '1.70E1'. The change will need to
happen inside normalise() because that routine is currently
responsible for taking user input "1e5000" and promoting it to
1P5.0E3. It still needs to do that or something equivalent (1P5000
would be okay) but it also needs to leave '1000' alone and preferably
turn '1e3' into '1000'.
  Make sure that plain integers make it into operator functions like
p_mul or pt_mul.
  Try to move handling of '%' so that it can be overloaded in a way
similar to how 'x' is overloaded now. This means allowing '%' to be
recognised as a variable name. I made '%' both an argument and a non-argument
(as defined by p_arg and p_nonarg)


@;

$hd = $ENV{"HOME"};

$p_progname = "[a-z][-a-z_0-9]*[a-z0-9]";
$p_fname = "[A-Z_0-9]+";
$p_var = "[a-z][a-z_0-9]*";
$p_multvars = "[a-z_0-9, ]*";
$p_nonvar = "[^a-z_0-9]";
# Note that '%' is both an argument and a non-argument
$p_arg =     "\%|[0-9.EINPRU]+";
$p_nonarg = "[^0-9.EINPRU]";
$p_na2 = "[^0-9._A-Z]";

$p_rawarg = "[-.0-9EP()]+"; # For parsing INPUT and DATA statements
$p_rawargs = "[-.0-9EP(), ]+";

# The special letters are: (addfunc: choose a new letter here)
#
# A
# B  - cos()
# C  - input history string (during input only)
# D
# E  - for scientific notation
# F  - defined functions, function parameters (future, reserved)
# G
# H
# I  - intermediate result
# J
# K  - ln()
# L
# M  - logn()
# N  - negative (a minus sign within a number)
# O
# P  - PT (the power-tower part of a number)
# Q  - sqrt()
# R  - history result
# S  - sin()
# T  - tan()
# U  - uncertainty (the error part of a number's mantissa)
# V  - root()
# W  - lambert() (future, reserved)
# X  - exp()
# x  - Synonym for * (multiplication)
# Z

# Print a prompt and wait for a Y or N answer.
sub yorn
{
  my($prompt) = @_;
  my($ans);

  $ans = "";
  while ($ans eq "") {
    print $prompt;
    $ans = <>; chomp $ans;
    $ans =~ tr/A-Z/a-z/;
    if ($ans =~ m/^y/) {
      return 1;
    } elsif ($ans =~ m/^n/) {
      return 0;
    }
    print "Please answer Y or N.\n";
    $ans = "";
  }
}

sub seterase
{
  # Note: These environment variables are nonstandard. I really need to find
  # a standard way to test which stty erase needs to be set. It depends
  # on your operating system and what type of terminal connection you're
  # running in (xterm, telnet, ssh, etc.) Suggestions are welcome!
  $erase_bs = $ENV{"ERASE_BS"};
  $erase_del = $ENV{"ERASE_DEL"};
  if ($erase_del) {
    system("stty erase '^?'");
  } elsif ($erase_bs) {
    system("stty erase '^H'");
  } else {
    system("stty erase '^?'");
  }
}

# This is from #mira#; it automatically detects and handles improper
# setting of the backspace or delete erase character
sub fixerase
{
  my($l) = @_;

  if ($l =~ m/\010/) {
    # The user's input contains ^H characters.

    # First, perform the intended deletion
    while ($l =~ m/.\010/) {
      $l =~ s/.\010//;
    }

    # Then fix it by setting ^H to be the erase character.
    print "stty erase ^H\n";
    system "stty erase '^H'";
  } elsif ($l =~ m/\177/) {
    # The user's input contains delete (^?) characters.

    # First, perform the intended deletion
    while ($l =~ m/.\177/) {
      $l =~ s/.\177//;
    }

    # Then fix it by setting ^? to be the erase character.
    print "stty erase ^?\n";
    system "stty erase '^?'";
  }

  $l =~ s/\011/ /g;

  # Convert any remaining illegal characters to something printable
  $l =~ s/([^\010 -~])/sprintf("\\0%o",ord($1))/ge;

  return $l;
}

sub dbg1
{
  my($a, $mask) = @_;

#  $a =~ s/\'//g;
  $a .= "\n";

  if ($dbg1flag & $mask) {
    print $a;
  }

  print $g_logfile $a;
}

sub isnan { my($a) = @_; return($a =~ m/nan/i); }
sub isinf { my($a) = @_; return($a =~ m/inf/i); }
sub isninf { my($a) = @_; return($a =~ m/[-n]inf/i); }
sub ispinf { my($a) = @_; return((&isinf($a) && (!(&isninf($a))))); }
sub finite { my($a) = @_; return(!($a =~ m/inf/i)); }

# Return true iff the argument is a positive integer with $sc ("scale")
# digits or fewer.
sub simple_int
{
  my($x, $sc) = @_;
  $x =~ s/\.0*$//;
  if (($x =~ m/^[0-9]+$/) && (length($x) <= $sc)) {
    return length($x);
  }
  return 0;
}

# Return true iff the argument is an integer (negative or positive)
# with $sc ("scale") digits or fewer.
sub simple_nint
{
  my($x, $sc) = @_;
  $x =~ s/\.0*$//;
  $x =~ s/^[-]//;
  if (($x =~ m/^[0-9]+$/) && (length($x) <= $sc)) {
    return length($x);
  }
  return 0;
}

#--------------------------------------------------- F64 primitives
#
# These routines, originally from "hcfloat.c", perform primitive
# functions on floating-point values. In most cases the function
# is built-in to perl, but we do lots of special checks for
# things like infinity and arguments that generate imaginary or
# complex answers.
#
# perl provides: abs, atan2, cos, exp, int, log, sin, sqrt

$g_f64_nan = nan;
$g_f64_inf = inf;
$g_f64_ninf = -inf;

# Two f64 primitives are explicit so they can be used efficiently
# for e.g. the uncertainty calculations

# This divide routine catches the divide by zero case.
sub f64_div
{
  my($n, $d) = @_;

  if (&isnan($n) || &isnan($d)) {
    &dbg1("f64.div NAN/NAN : NAN]]", 32);
    return $g_f64_nan;
  } elsif (&f_eq($d, $g_0)) {
    &dbg1("f64.div K/0 : NAN", 32);
    return $g_f64_nan;
  }
  return ($n / $d);
}

# Our ln routine is strange -- it accepts negative arguments and returns
# the magnitude of the answer. It also special-cases infinities and zero.
sub f64_ln
{
  my($x) = @_;
  my($v);

  &dbg1("f64_ln $x", 1);

  # Handle 0 and infinities first
  if ($x == 0.0) {
    &dbg1("f64_ln(0) : ninf", 32);
    return $g_f64_ninf;
  } elsif (&isinf($x)) {
    &dbg1("f64_ln(inf) : inf", 32);
    return $g_f64_inf;
  } elsif (&isnan($x)) {
    &dbg1("f64_ln(NAN) : NAN", 32);
    return $g_f64_nan;
  }

  # If the argument is negative we make it positive, because
  # we want to return the real component of the logarithm of the number,
  # and for any complex number, the real component of the log is the log
  # of the number's magnitude.
  if ($x < 0.0) {
    $x = - $x;
  }

  $v = log($x);
  return $v;
}


$f64_prim = <<'endquote';
# These are the full primitives
sub f_int                    # f64 version
{
  my($a) = @_;

  return int($a);
}

sub f_lt                    # f64 version
{
  my($a, $b) = @_;

  return ($a < $b);
}

sub f_le                    # f64 version
{
  my($a, $b) = @_;

  return ($a <= $b);
}

sub f_eq                    # f64 version
{
  my($a, $b) = @_;

  return ($a == $b);
}

sub f_ge                    # f64 version
{
  my($a, $b) = @_;

  return ($a >= $b);
}

sub f_gt                    # f64 version
{
  my($a, $b) = @_;

  return ($a > $b);
}

sub f_ne                    # f64 version
{
  my($a, $b) = @_;

  return ($a != $b);
}

sub f_neg                    # f64 version
{
  my($a) = @_;

  return (- $a);
}

sub f_add                    # f64 version
{
  my($a, $b) = @_;

  return ($a + $b);
}

sub f_mul                    # f64 version
{
  my($a, $b) = @_;

  return ($a * $b);
}

# This divide routine catches the divide by zero case.
sub f_div                    # f64 version
{
  my($n, $d) = @_;

  if (&isnan($n) || &isnan($d)) {
    &dbg1("f_div NAN/NAN : NAN", 32);
    return $g_nan;
  }
  if (&finite($n)) {
    # finite numerator
    if (&f_eq($d, $g_0)) {
      # Anything/0 = NAN
      &dbg1("f_div K/0 : NAN", 32);
      return $g_nan;
    } elsif (&isinf($d)) {
      # Anything/infinity = 0
      &dbg1("f_div K/inf : 0", 32);
      return $g_0;
    }
  } else {
    # infinite numerator
    if (&finite($d)) {
      if (&f_lt($n, 0)) {
        &dbg1("f_div inf/-K : ninf", 32);
        return &f_neg($n);
      }
      &dbg1("f_div inf/K : inf", 32);
      return $n;
    } else {
      # inf/inf
      &dbg1("f_div inf/inf : NAN", 32);
      return $g_nan;
    }
  }

  return ($n / $d);
}

# following are the partial primitives.

sub f_sub                    # f64 version
{
  my($a, $b) = @_;

  &dbg1("f.sub $a - $b", 32);

  return ($a - $b);
# return &f_add($a, &f_neg($b));
}

# Following are the non-primitives

# Our exp routine tests the infinity and overflow cases itself, just in
# case the library function doesn't.
sub f_exp                    # f64 version
{
  my($x) = @_;
  my($v);

  &dbg1("$curprim f.exp $x", 1);

  # Handle infinities first
  if (&isnan($x)) {
    &dbg1("f.exp(nan) : nan", 32);
    return $g_nan;
  } elsif (&ispinf($x)) {
    &dbg1("f.exp(inf) : inf", 32);
    return $g_inf;
  } elsif (&isninf($x)) {
    &dbg1("f.exp(ninf) : 0", 32);
    return $g_0;
  }

  # Handle the extreme overflow cases.
  if (&f_lt($x, $g_n2000)) {
    &dbg1("f.exp(< -2000) : return $g_0", 32);
    return $g_0;
  } elsif (&f_gt($x, $g_2000)) {
    &dbg1("f.exp(> 2000) : return $g_inf", 32);
    return $g_inf;
  }

  $v = exp($x);
  return $v;
} # End of f.exp

# Our ln routine is strange -- it accepts negative arguments and returns
# the magnitude of the answer. It also special-cases infinities and zero.
sub f_ln                    # f64 version
{
  my($x) = @_;
  my($v);

  &dbg1("$curprim f.ln $x", 1);

  # Handle 0 and infinities first
  if (&isnan($x)) {
    &dbg1("f.ln(nan) : nan", 32);
    return $g_nan;
  } elsif (&f_eq($x, $g_0)) {
    &dbg1("f.ln(0) : ninf", 32);
    return $g_ninf;
  } elsif (&isinf($x)) {
    &dbg1("f.ln(inf) : inf", 32);
    return $g_inf;
  }

  # If the argument is negative we make it positive, because
  # we want to return the real component of the logarithm of the number,
  # and for any complex number, the real component of the log is the log
  # of the number's magnitude.
  if (&f_le($x, $g_0)) {
    $x = &f_neg($x);
  }

  $v = log($x);
  return $v;
}

sub f_pow10                    # f64 version
{
  my($n) = @_;

  &dbg1("$curprim f.pow10 $n", 1);

  return &f_exp($g_ln_10 * $n);
}

sub f_log_n                    # f64 version
{
  my($n, $b) = @_;

  &dbg1("$curprim f.log_n v{ $b } $n", 1);

  return &f_div(&f_ln($n), &f_ln($b));
}

sub f_log10                    # f64 version
{
  my($n) = @_;

  &dbg1("$curprim f_log10 $n", 1);

  return (&f_ln($n) * $g_log10_e);
}

# sqrt(2 pi n) * n^n * e^(-n) * e^(1/12n)
# 1/2 ln(2 pi n) + n ln(n) - n + 1/12n - 1/1260 n^3 + ...
# t = n - 1;
# l = 1/2 ln(2 pi) + (n + 1/2) ln(n) - n + 1/(12 n) - 1/(360 n^3) + ...
# g = e^l
#
# %%% Accuracy is not good enough for scale>20. See notes in header.
sub f_gamma                    # f64 version
{
  my($n) = @_;
  my($l, $scal1, $n2, $np);

  &dbg1("$curprim f_gamma $n", 1);

  if (&isnan($n)) {
    &dbg1("f_gamma(nan) : nan", 32);
    return $g_nan;
  }

  # For very low negative arguments, the gamma function is so
  # close to zero that we treat it as zero. However, for negative
  # integers it's infinite, so we handle that case explicitly.
  if (&f_lt($n, $g_n50)) {
    if (&f_eq($n, &f_int($n))) {
      &dbg1("f_gamma(-N) : inf", 32);
      return $g_inf;
    }
    return $g_0;
  }

  # Our approximation formula doesn't work well for small values, so
  # we use the recurrence relation gamma(n+1) = n gamma(n).
  $scal1 = $g_1;
  while ($n < $g_10) {  # "10" depends on precision
    $scal1 = $scal1 * $n;
    $n = &f_add($n, $g_1);
  }

  # Since we're using Stirling's series for factorials, we have
  # to subtract 1 to make it be a gamma function series.
  $n = &f_sub($n, $g_1);

  $l = $g_05_ln_2pi;
  $l = &f_add($l, &f_add($n, $g_0_5) * &f_ln($n));
  $l = &f_sub($l, $n);
  $n2 = $n * $n;
  $np = $n;
  $l = &f_add($l, &f_div($g_1, $g_12 * $np));
  $np = $np * $n2;
  $l = &f_sub($l, &f_div($g_1, $g_360 * $np));
  $np = $np * $n2;
  $l = &f_add($l, &f_div($g_1, $g_1260 * $np));
  $np = $np * $n2;
  $l = &f_sub($l, &f_div($g_1, $g_1680 * $np));
  $np = $np * $n2;
  $l = &f_add($l, &f_div($g_1, $g_1188 * $np));
  $np = $np * $n2;
  $l = &f_sub($l, &f_div($g_691, $g_360360 * $np));
  $np = $np * $n2;
  $l = &f_add($l, &f_div($g_7, $g_1092 * $np));
  $np = $np * $n2;
  $l = &f_sub($l, &f_div($g_3617, $g_122400 * $np));

  return (&f_div(&f_exp($l), $scal1));
}

# square root routine handles infinities and negative arguments properly
sub f_sqrt                    # f64 version
{
  my($x) = @_;

  &dbg1("$curprim f_sqrt $x", 1);

  if (&isnan($x)) {
    &dbg1("f_sqrt(nan) : nan", 32);
    return $g_nan;
  }

  # If the argument is negative we return 0, because 0 is
  # the real component of the square root of a negative number.
  if (&f_lt($x, $g_0)) {
    &dbg1("f_sqrt(-X) : 0", 32);
    return $g_0;
  } elsif (&isinf($x)) {
    &dbg1("f_sqrt(inf) : inf", 32);
    return $g_inf;
  }

  return sqrt($x);
}

# The sine algorithm uses the identity
#     sin(a+b) = sin a cos b + cos a sin b
# The value being sin'd is broken into two pieces one of which is a multiple
# of pi/16 and the other is between -pi/32 and pi/32. Then we can use the
# Taylor series to get the sin of the latter part and a table for the
# first part
sub f_sin                    # f64 version
{
  my($x) = @_;

  &dbg1("$curprim f_sin $x", 1);

  if (&isnan($x)) {
    &dbg1("f_sin(nan) : nan", 32);
    return $g_nan;
  }

  # Handle arguments out of range
  # Note: The best way to handle things like this is to extend the
  # numeric representation to include an "error" term, expressing the
  # standard deviation of the computed value vs. the actual value.
  # Then, the error of the sin function is the error of the argument
  # times the cosine, but converging on +-1.0 when the error of the
  # argument is 2 pi or larger. In the limit case the computed value
  # will be expressed as 0.0 and the error as 1.0.
  #
  # Just for fun, I went to an office supply store and tested 5
  # current-model scientific calculators (covering all price ranges)
  # to see what they did when you take sin or cos of larger and larger
  # numbers. Each calculator had a different cutoff value, but all
  # seemed to choose a value that was related to the calculator's
  # internal precision. The five cutoff values were:
  #    5*10^7 pi
  #    4.45*10^9
  #    1*10^10
  #    1*10^12
  #    1*10^13
  if (&f_gt($x, $g_sin_limit)) {
    return $g_0;
  } elsif (&f_lt($x, &f_neg($g_sin_limit))) {
    return $g_0;
  }

  return sin($x);
}

sub f_cos                    # f64 version
{
  my($x) = @_;

  &dbg1("$curprim f_cos $x", 1);

  if (&isnan($x)) {
    &dbg1("f_cos(nan) : nan", 32);
    return $g_nan;
  }

  # Handle out-of-range
  if (&f_gt($x, $g_sin_limit)) {
    return $g_1;
  } elsif (&f_lt($x, &f_neg($g_sin_limit))) {
    return $g_1;
  }

  return cos($x);
}

sub f_tan                    # f64 version
{
  my($x) = @_;

  &dbg1("$curprim f_tan $x", 1);

  if (&isnan($x)) {
    &dbg1("f_tan(nan) : nan", 32);
    return $g_nan;
  }

  # Handle out-of-range
  if (&f_gt($x, $g_sin_limit)) {
    return $g_inf;
  } elsif (&f_lt($x, &f_neg($g_sin_limit))) {
    return $g_inf;
  }

  return &f_div(sin($x),cos($x));
}

# Arctangent function.
#
# Av{0} = 1 / sqrt(1 + x^{2})  ,  Bv{0} = 1
# Av{n+1} = (Av{n} + Bv{n}) / 2  ,
#           Bv{n+1} = sqrt(Av{n+1} * Bv{n})
# arctan(x) = LIMIT [x * Av{0} / Av(n)]
sub f_arctan                    # f64 version
{
  my($x) = @_;
  my($a, $b, $a0, $ao, $i);

  &dbg1("$curprim f_arctan $x", 1);

  if (&isnan($x)) {
    &dbg1("f_arctan(nan) : nan", 32);
    return $g_nan;
  }

  # A few special cases, the x==0 case is just for speed
  if (&f_eq($x, $g_0)) {
    return $g_0;
  } elsif (&ispinf($x)) {
    &dbg1("f_arctan(inf) : pi/2", 32);
    return &f_div($g_pi, $g_2);
  } elsif (&isninf($x)) {
    &dbg1("f_arctan(-inf) : -pi/2", 32);
    return &f_div($g_pi, $g_n2);
  }

  $a0 = &f_div($g_1, &f_sqrt(&f_add($g_1, $x * $x)));
  $a = $a0;
  $b = $g_1;

  # Set up ao to be different from a so the loop has a chance to start
  $ao = &f_sub($a, $g_1);
  for($i=0; ($i<25) && (&f_ne($a, $ao)); $i++) {
    $ao = $a;
    $a = &f_div(&f_add($a, $b), $g_2);
    $b = &f_sqrt($a * $b);
  }
  return &f_div($x * $a0, $a);
}

# arcsin(x) = arctan(x / sqrt(1 - x*x))
sub f_arcsin                    # f64 version
{
  my($x) = @_;
  my($a);

  &dbg1("$curprim f_arcsin $x", 1);

  if (&isnan($x)) {
    &dbg1("f_arcsin(nan) : nan", 32);
    return $g_nan;
  }

  $a = $x * $x;
  if (&f_gt($a, $g_1)) {
    return $g_0;
  }
  return &f_arctan(&f_div($x, &f_sqrt(&f_sub(1, $a))));
}

# arccos(x) = pi/2 - arctan(x / sqrt(1 - x*x))
sub f_arccos                    # f64 version
{
  my($x) = @_;
  my($a);

  &dbg1("$curprim f_arccos $x", 1);

  if (&isnan($x)) {
    &dbg1("f_arccos(nan) : nan", 32);
    return $g_nan;
  }

  $a = $x * $x;
  if (&f_gt($a, $g_1)) {
    return $g_0;
  }
  return &f_div($g_pi, $g_2)
                   - &f_arctan(&f_div($x, &f_sqrt(&f_sub($g_1, $a))));
}

# pow function is more complex than exp and pow10, because
# it has to deal with any base. Specifically, if the base is negative
# it computes the angle and magnitude of the complex answer
# so it can calculate the real component.
sub f_pow                    # f64 version
{
  my($b, $e) = @_;
  my($mag, $scal2);

  &dbg1("$curprim f_pow $b $e", 1);

  if (&isnan($b) || &isnan($e)) {
    &dbg1("f_pow(nan) : nan", 32);
    return $g_nan;
  }

  # Handle negative bases
  if (&f_lt($b, $g_0)) {
    # The angle of the base is pi, so the angle of the
    # exponent will be pi * e. Take cosine of this to
    # determine how much of the answer will be in the
    # real component.
    $b = &f_neg($b);
    $scal2 = &f_cos($g_pi * $e);
  } else {
    $scal2 = $g_1;
  }

  # Compute magnitude of answer
  &dbg1("f_pow : mag = exp(mul(ln($b), $e)", 32);
  $mag = &f_exp(&f_ln($b) * $e);

  # If we got an overflow, we might be able to salvage
  # the computation by using logarithms. This happens when we compute
  # -20.0 to the power of 238.49999999999 (exactly 10 9's there)
  # The magnitude is 1.97e310, which overflows, but the scale
  # is 3.1416e-10 so the answer is actually well within
  # range (and even within PT0 range)
  &dbg1("f_pow test $mag > $g_ovr1", 32);
  if (&ispinf($mag) || &f_gt($mag, $g_ovr1)) {
    &dbg1("  : true", 32);
    if (&f_gt($scal2, $g_0)) {
      $mag = &f_add(&f_ln($b) * $e, &f_ln($scal2));
      &dbg1("f_pow : return exp($mag)", 32);
      return &f_exp($mag);
    } else {
      $mag = &f_add(&f_ln($b) * $e, &f_ln(&f_neg($scal2)));
      &dbg1("f_pow : return neg(exp($mag))", 32);
      return &f_neg(&f_exp($mag));
    }
  } else {
    &dbg1("  : false", 32);
    # Return real component of answer
    &dbg1("f_pow : return mul($scal2, $mag)", 32);
    return ($scal2 * $mag);
  }
} # End of f_pow

# Root function contains the same complexity (pun intended) as
# the pow function.
sub f_root                    # f64 version
{
  my($b, $r) = @_;
  my($mag, $scal3);

  &dbg1("$curprim f_root $r v/ $b", 1);

  if (&isnan($b) || &isnan($r)) {
    &dbg1("f_root(nan) : nan", 32);
    return $g_nan;
  }

  # Handle negative bases
  if (&f_lt($b, $g_0)) {
    # The angle of the base is pi, so the angle of the
    # answer will be pi / r. Take cosine of this to
    # determine how much of the answer will be in the
    # real component.
    $b = &f_neg($b);
    $scal3 = &f_cos(&f_div($g_pi, $r));
  } else {
    $scal3 = $g_1;
  }

  $mag = &f_exp(&f_div(&f_ln($b), $r));

  return ($scal3 * $mag);
}
endquote


sub f64_init
{
  eval($f64_prim);
  my($t);

  # These constants are mostly used by the various transcendental functions
  $g_0 = 0.0;
  $g_0_5 = 0.5;
  $g_1 = 1.0;
  $g_n1 = -1.0;
  $g_2 = 2.0;
  $g_n2 = -2.0;
  $g_4 = 4.0;
  $g_5 = 5.0;
  $g_6 = 6.0;
  $g_7 = 7.0;
  $g_8 = 8.0;
  $g_10 = 10.0;
  $g_12 = 12.0;
  $g_16 = 16.0;
  $g_n50 = -50.0;
  $g_360 = 360.0;
  $g_691 = 691.0;
  $g_1092 = 1092.0;
  $g_1188 = 1188.0;
  $g_1260 = 1260.0;
  $g_1680 = 1680.0;
  $g_n2000 = -2000.0;
  $g_2000 = 2000.0;
  $g_3617 = 3617.0;
  $g_122400 = 122400.0;
  $g_360360 = 360360.0;
  $g_2p32m1 = 4294967295.0;

  $g_pi = 3.1415926535897932;

  # Initialize infinities using Perl's built-in multiply (which should
  # work provided it is using IEEE 64-bit double precision).
  $t = 1.0e300;
  $t=$t*$t; $t=$t*$t; $t=$t*$t; $t=$t*$t; $t=$t*$t; $t=$t*$t; $t=$t*$t;
  $g_inf = $t;
  $g_ninf = -$t;
  $g_nan = $g_inf+$g_ninf;
}

sub f64_close
{
#  undef(&f_int);
#  undef(&f_lt);
}

# --------------------------------------------------- FBC primitives

# bce is the "engine" that feeds problems to the running #bc# process
# and gets results.
sub bce
{
  my($expr, $expect_response) = @_;
  my($result, $l);

  print $bc_out ($expr . "\n");
  $l = ($expect_response ? "\\" : "");
  while ($l =~ m|\\$|) {
    $l = <$bc_in>; chomp $l;
    $result .= $l;
    $result =~ s|\\$||;
  }
  &dbg1("bce : $expr => $result", 4);
  return $result;
}

# fbc.norm normalises a number in scientific format. For example, it converts
# "0.02e3" to "2.0e1", and "23e45" to "2.3e46".
# It does not use &bce, so it can be used by non-bc routines as well.
sub fbc_norm
{
  my($x) = @_;
  my($xs, $xm, $xe);
  my($s, $xi, $xf);
  my($mi, $mf, $e);

  &dbg1("fbc_norm $x", 1);

  if (&isinf($x)) {
    &dbg1("fbc_norm inf: $x", 33);
    return $x;
  } elsif (&isnan($x)) {
    &dbg1("fbc_norm nan: $x", 33);
    return $x;
  }

  # make sure there is a sign
  if (!($x =~ m/^[-+]/)) {
    $x = "+" . $x;
  }

  # extract the three parts of the number
  if ($x =~ m|^([+-])([0-9.]+)E([-+0-9]+)$|) {
    $xs = $1; $xm = $2; $xe = $3;
  } elsif ($x =~ m|^([+-])([0-9.]+)$|) {
    $xs = $1; $xm = $2; $xe = 0;
  } else {
    &dbg1("fbc_norm illegal input |$x|", 1);
  }

  # Make sure there is a decimal point
  if (!($xm =~ m|\.|)) {
    $xm .= ".0";
  }

  # make sure it doesn't start with a bare decimal point
  if ($xm =~ m/^\./) {
    $xm = "0" . $xm;
  }

  # extract integer and fraction portions
  if ($xm =~ m|^([0-9]+)\.([0-9]+)$|) {
    $xi = $1; $xf = $2;
    &dbg1("fbc_norm xi $xi xf $xf", 1);
  } else {
    print "fbc_norm illegal mantissa |$x|\n";
  }

  # handle cases where mantissa was less than 1 (normalise by decreasing
  # exponent)
  if ($xi == 0) {
    $x = $xi . $xf;
    if ($x =~ m|^(0+[1-9])([0-9]*)$|) {
      $mi = $1; $mf = $2;
      $e = 1 - length($mi);
      $mi =~ s|^0+||;
      $x = $xs . $mi . "." . $mf . "E" . ($e + $xe);
      &dbg1("fbc_norm a: $x", 1);
      return $x;
    }
    # else, it was zero
    $x = "0.0E0";
    &dbg1("fbc_norm b: $x", 1);
    return $x;
  }

  # else
  $e = length($xi) - 1;
  $x = $xi . $xf;
  $x =~ s|^([0-9])|$1\.|;

  $e = $e + $xe;

  # check for overflow
  if ($e > 300) {
    $x = $xs . "inf";
    &dbg1("fbc_norm e: $x", 1);
    return $x;
  }

  $x = $xs . $x . "E" . $e;
  &dbg1("fbc_norm c: $x", 1);
  return $x;
}

# fix2sci converts from fixed-point to scientific notation. It's very simple
# because all the hard work is done by fbc_norm
# It does not use &bce, so it can be used by non-bc routines as well.
sub fbc_fix2sci
{
  my($x) = @_;

  &dbg1("fbc_fix2sci in: $x", 1);

  $x =~ s/e/E/g;
  $x =~ s/ //g;

  if (&isinf($x)) {
    &dbg1("fbc_fix2sci inf: $x", 33);
    return $x;
  } elsif (&isnan($x)) {
    &dbg1("fbc_fix2sci nan: $x", 33);
    return $x;
  }

  if (!($x =~ m/E/)) {
    $x = $x . "E+0";
  }

  $x = &fbc_norm($x);

  &dbg1("fbc_fix2sci b: $x", 1);

  return $x;
}

# fbc.split takes a number in any format and returns the sign, mantissa and
# exponent that it would have if expressed in normalised scientific notation.
# It is used by most of the nontrivial #bc# primitives.
# It does not use &bce, so it can be used by non-bc routines as well.
sub fbc_split
{
  my($x) = @_;
  my($s, $m, $e);

  &dbg1("fbc_split in: '$x'", 1);

  $x =~ s/ //g;

  # map infinity %%% might want to just return "inf" in the exponent field
  # and make callers check for infinity
  if (&isninf($x)) {
    &dbg1("fbc_split ninf: ( - , 1 , $x )", 1);
    return("-", 1, $x);
  } elsif (&isinf($x)) {
    &dbg1("fbc_split +inf: ( + , 1 , $x )", 1);
    return("+", 1, $x);
  } elsif (&isnan($x)) {
    &dbg1("fbc_split nan: ( + , 1 , $x )", 1);
    return("+", 1, $x);
  }

  # Convert to scientific if appropriate
  if (!($x =~ m/E/)) {
    $x = &fbc_fix2sci($x);
  }

  # Make sure it has a sign
  if (!($x =~ m|^[+-]|)) {
    $x = "+" . $x;
  }

  # get sign, mantissa and exponent
  if ($x =~ m|^([+-])([0-9.]+)E([-+0-9]+)$|) {
    $s = $1; $m = $2; $e = $3;
  } else {
    &dbg1("fbc.split illegal input |$x|", 1);
  }

  &dbg1("fbc.split -> ( $s , $m , $e )", 1);
  return($s, $m, $e);
} # End of fbc.split

# sci2fix converts from 1.23e10 format to something like
# 12300000000.0
#
# Despite the name, it takes input with or without an 'e' and exponent.
# It doubles as an int function, pass nonzero in the 2nd parameter.
sub fbc_sci2fix
{
  my($x, $intonly) = @_;
  my($s, $m, $mi, $mf, $e);
  my($ri, $rf, $rv);

  &dbg1("fbc.sci2fix $x $intonly", 1);

  # get sign, mantissa and exponent
  if ($x =~ m|^([+-]?)([.0-9]+)[eE]([+-][0-9]+)$|) {
    $s = $1; $m = $2; $e = $3;
  } elsif ($x =~ m|^([+-]?)([.0-9]+)[eE]([0-9]+)$|) {
    $s = $1; $m = $2; $e = $3;
  } elsif ($x =~ m|^([+-]?)([.0-9]+)$|) {
    $s = $1; $m = $2; $e = 0;
  } elsif ($x =~ m|^([.0-9]+)$|) {
    $s = "+"; $m = $1; $e = 0;
  } else {
    print "fbc.sci2fix illegal input |$x|\n";
  }
  if ($s eq '') {
    $s = '+';
  }

  # Get integer and fractional parts
  if ($m =~ m|^([0-9]+)\.([0-9]*)$|) {
    $mi = $1; $mf = $2;
  } else {
    $mi = $m; $mf = "";
  }

  # check sign of exponent
  if ($e > 0) {
    # positive exponent - append some digits
    if (length($mf) < $e) {
      $ri = $mi . $mf . ("0" x ($e - length($mf)));
      $rf = "";
    } elsif (length($mf) > $e) {
      $ri = $mi . substr($mf, 0, $e);
      $rf = substr($mf, $e);
    } else {
      $ri = $mi . $mf;
      $rf = "";
    }
  } elsif ($e < 0) {
    # negative exponent - take digits from mantissa integer and transfer over
    # into fraction
    $e = 0 - $e;
    if (length($mi) < $e) {
      $ri = "0";
      $rf = ("0" x ($e - length($mi))) . $mi . $mf;
    } elsif (length($mi) > $e) {
      $ri = substr($mi, 0 - $e);
      $rf = substr($mi, 0, 0 - $e) . $mf;
    } else {
      $ri = "0";
      $rf = $mi . $mf;
    }
  } else {
    # zero exponent - the mantissa is the result
    $ri = $mi; $rf = $mf;
  }

  if ($intonly) {
    $rv = $s . $ri;
  } else {
    $rv = $s . $ri . "." . $rf;
  }

  &dbg1("fbc.sci2fix: $rv", 1);
  return $rv;
} # End of fbc.sci2fix

# fbc_prim defines the primitives for BC-based floating point.
$fbc_prim = <<'endquote';
# These are the full primitives
sub f_int                    # fbc version
{
  my($a) = @_;

  return &fbc_fix2sci(&fbc_sci2fix($a, 1));
}

# This function does what the <=> operator does for normal Perl numbers.
# All the comparative routines (f_lt, f_ge, f_ne etc) call this and compare
# the result to 0.
sub f_cmp                    # fbc version
{
  my($a, $b) = @_;
  my($as, $am, $ae, $bs, $bm, $be);

  &dbg1("$curprim f.cmp $a <=> $b", 1);

  ($as, $am, $ae) = &fbc_split($a);
  ($bs, $bm, $be) = &fbc_split($b);
  $as .= "1"; $bs .= "1";

  # handle the easy cases
  if ($as < $bs) {
    &dbg1("$curprim f.cmp a: -1", 1);
    return -1;
  } elsif ($as > $bs) {
    &dbg1("$curprim f.cmp b: 1", 1);
    return 1;
  }

  # zero has to be handled as a special case
  if (($am == 0) && ($bm == 0)) {
    &dbg1("$curprim f.cmp h: 0", 1);
    return 0;
  } elsif ($am == 0) {
    &dbg1("$curprim f.cmp f: " . (-1 * $bs), 1);
    return (-1 * $bs);
  } elsif ($bm == 0) {
    &dbg1("$curprim f.cmp g: $as", 1);
    return ($as);
  }

  # They're the same sign. From here on we treat them both as positive
  # but multiply our return value by the sign

  # Infinity is the simplest case at this point
  if (&isinf($ae) && &isinf($be)) {
    &dbg1("$curprim f.cmp i: 0", 1);
    return 0;
  } elsif (&isinf($ae)) {
    &dbg1("$curprim f.cmp j: $as", 1);
    return ($as);
  } elsif (&isinf($be)) {
    &dbg1("$curprim f.cmp k: " . (-1 * $as), 1);
    return (-1 * $as);
  }

  # Exponents are another easy compare
  if ($ae < $be) {
    &dbg1("$curprim f.cmp c: " . (-1 * $as), 1);
    return (-1 * $as);
  } elsif ($ae > $be) {
    &dbg1("$curprim f.cmp d: " . $as, 1);
    return $as;
  }

  # Finally we have to compare the mantissas. We use a string order compare
  # for this.

  # It won't catch equals if trailing zeros differ
  $am =~ s/0+$//;
  $bm =~ s/0+$//;

  $as = $as * ($am cmp $bm);

  &dbg1("$curprim f.cmp e: " . $as, 1);
  return $as;
}

sub f_lt                    # fbc version
{
  my($a, $b) = @_;

  &dbg1("$curprim f.lt $a < $b", 1);

  return (&f_cmp($a, $b) < 0);
}

sub f_le                    # fbc version
{
  my($a, $b) = @_;

  &dbg1("$curprim f_le $a <= $b", 1);

  return (&f_cmp($a, $b) <= 0);
}

sub f_eq                    # fbc version
{
  my($a, $b) = @_;

  &dbg1("$curprim f_eq $a == $b", 1);

  return (&f_cmp($a, $b) == 0);
}

sub f_ge                    # fbc version
{
  my($a, $b) = @_;

  &dbg1("$curprim f_ge $a >= $b", 1);

  return (&f_cmp($a, $b) >= 0);
}

sub f_gt                    # fbc version
{
  my($a, $b) = @_;

  &dbg1("$curprim f_gt $a > $b", 1);

  return (&f_cmp($a, $b) > 0);
}

sub f_ne                    # fbc version
{
  my($a, $b) = @_;

  &dbg1("$curprim f_ne $a != $b", 1);

  return (&f_cmp($a, $b) != 0);
}

# Negate is about as easy as they get. The sign is just a character at the
# beginning of the string, so we can perform the operation without asking #bc#.
sub f_neg                    # fbc version
{
  my($a) = @_;

  &dbg1("$curprim f_neg $a", 1);

  if (&isninf($a)) {
    &dbg1("$curprim f_neg(ninf) : inf", 32);
    $a = $g_inf;
  } elsif (&isinf($a)) {
    &dbg1("$curprim f_neg(inf) : ninf", 32);
    $a = $g_ninf;
  } elsif (&isnan($a)) {
    &dbg1("$curprim f_neg(nan) : nan", 32);
    $a = $g_nan;
  } elsif ($a =~ m/^-/) {
    $a =~ s/^-//;
  } else {
    $a = "-" . $a;
    $a =~ s/-\+/-/;
  }
  &dbg1("$curprim f_neg a: $a", 1);
  return ($a);
} # End of f.neg

# me_magcompare
sub me_magcompare                    # fbc version
{
  my($am, $ae, $bm, $be) = @_;

  if ($ae > $be) {
    return 1;
  } elsif ($ae < $be) {
    return -1;
  }

  return ($am cmp $bm);
}

# m_truncround is currently just a placeholder in case I want to explicitly
# do roundoff at all stages in my computations. For now, I just rely on the
# fact that bc rounds for me.
sub m_truncround                    # fbc version
{
  my($x) = @_;

  return $x;
}

# me_addpos adds two positive floating-point numbers, already split into
# mantissa and exponent.
sub me_addpos                    # fbc version
{
  my($am, $ae, $bm, $be) = @_;
  my($ed);

  # put the bigger one first
  if (&me_magcompare($am, $ae, $bm, $be) < 0) {
    ($am, $ae, $bm, $be) = ($bm, $be, $am, $ae);
  }

  # eliminate any difference in exponents
  $ed = $ae - $be;
  if ($ed > 0) {
    $bm =~ s/\.//;
    $bm = "0." . ("0" x ($ed - 1)) . $bm;
    $be = $ae;
  }

  # time to add
  $am = &bce("$am + $bm", 1);

  # truncate and round
  $am = &m_truncround($am);

  # append exponent and normalise
  $am = $am . "E" . $ae;
  $am = &fbc_norm($am);

  return $am;
}

# me_subpos takes two positive floating-point numbers, already split into
# mantissa and exponent. The first one is known to be larger. It subtracts
# the second from the first and returns the answer.
sub me_subpos                    # fbc version
{
  my($am, $ae, $bm, $be) = @_;
  my($ed, $zp, $rest);

  # eliminate any difference in exponents
  $ed = $ae - $be;
  if ($ed > 0) {
    $bm =~ s/\.//;
    $bm = "0." . ("0" x ($ed - 1)) . $bm;
    $be = $ae;
  }

  # time to subtract
  $am = &bce("$am - $bm", 1);

  # truncate and round
  $am = &m_truncround($am);

  # append exponent and normalise
  $am = $am . "E" . $ae;
  $am = &fbc_norm($am);

  return $am;
}

sub f_add                    # fbc version
{
  my($a, $b) = @_;
  my($as, $am, $ae, $bs, $bm, $be);
  my($mc);

  &dbg1("$curprim f_add $a + $b", 1);

  if (&simple_nint($a, $curscale-1) && &simple_nint($a, $curscale-1)) {
    return &bce("$a + $b", 1);
  }

  ($as, $am, $ae) = &fbc_split($a);
  ($bs, $bm, $be) = &fbc_split($b);
  $as .= "1"; $bs .= "1";

  if (&isnan($ae) || &isnan($be)) {
    &dbg1("$curprim f_add(nan+nan) : nan", 32);
    return $g_nan;
  }

  # if signs are equal, call addpos. Else use subpos.
  if ($as == $bs) {
    if ($as < 0) {
      return &f_neg(&me_addpos($am, $ae, $bm, $be));
    } else {
      return &me_addpos($am, $ae, $bm, $be);
    }
  }

  # Signs are opposite, so it's a - b or b - a. We have to figure out
  # which is bigger so we can put it first in the call to me_subpos
  $mc = &me_magcompare($am, $ae, $bm, $be);
  if ($mc < 0) {
    # a smaller than b
    if ($bs > 0) {
      # big positive, small negative; answer is positive
      return &me_subpos($bm, $be, $am, $ae);
    } else {
      # big one is negative, answer will be negative
      return &f_neg(&me_subpos($bm, $be, $am, $ae));
    }
  } else {
    # b smaller than a
    if ($as > 0) {
      # big positive, small negative; answer is positive
      return &me_subpos($am, $ae, $bm, $be);
    } else {
      # big one is negative, answer will be negative
      return &f_neg(&me_subpos($am, $ae, $bm, $be));
    }
  }
}

# fbc version of f.mul.
sub f_mul                    # fbc version
{
  my($a, $b) = @_;
  my($as, $am, $ae, $bs, $bm, $be);

  &dbg1("$curprim f.mul $a * $b", 1);

  if (($as=&simple_nint($a, $curscale))
   && ($bs=&simple_nint($b, $curscale))
   && ($as+$bs <= $curscale)) {
    return &bce("$a * $b", 1);
  }

  ($as, $am, $ae) = &fbc_split($a);
  ($bs, $bm, $be) = &fbc_split($b);
  $as .= "1"; $bs .= "1";

  if (&isnan($ae) || &isnan($be)) {
    &dbg1("$curprim f.mul(nan) : nan", 32);
    return $g_nan;
  }

  if (($am == 0) || ($bm == 0)) {
    &dbg1("$curprim f.mul a: $g_0", 1);
    return $g_0;
  }

  # handle infinities
  if (($ae > 300) || ($be > 300)) {
    if ($as * $bs > 0) {
      &dbg1("$curprim f.mul b: inf", 1);
      return "inf";
    }
    &dbg1("$curprim f.mul c: Ninf", 1);
    return "Ninf";
  }

  $am = &bce("$am * $bm", 1);
  $ae = $ae + $be;
  if ($as * $bs > 0) {
    $as = "+";
  } else {
    $as = "-";
  }
  $a = $as . $am . "E" . $ae;
  $a = &fbc_norm($a);

  &dbg1("$curprim f.mul d: " . $a, 1);

  return $a;
} # End of f.mul

# This divide routine catches the divide by zero case.
sub f_div                    # fbc version
{
  my($a, $b) = @_;
  my($as, $am, $ae, $bs, $bm, $be);

  &dbg1("$curprim f_div $a / $b", 1);

  if ( ($as=&simple_nint($a, $curscale))
    && ($bs=&simple_nint($b, $curscale))
    && ($as>=$bs) ) {
    return &bce("$a / $b", 1);
  }

  if (&isnan($a) || &isnan($b)) {
    &dbg1("$curprim f_div(nan) : nan", 32);
    return $g_nan;
  }
  if (&finite($a)) {
    # finite numerator
    if (&f_eq($b, $g_0)) {
      # Anything/0 = NAN
      &dbg1("$curprim f_div(X/0) : nan", 32);
      return $g_nan;
    } elsif (&isinf($b)) {
      # Anything/infinity = 0
      &dbg1("$curprim f_div(X/inf) : 0", 32);
      return $g_0;
    }
  } else {
    # infinite numerator
    if (&finite($b)) {
      if (&f_lt($b, $g_0)) {
        &dbg1("$curprim f_div(inf/-X) : ninf", 32);
        return &f_neg($a);
      }
      &dbg1("$curprim f_div(inf/X) : inf", 32);
      return $a;
    } else {
      # inf/inf
      &dbg1("$curprim f_div(inf/inf) : nan", 32);
      return $g_nan;
    }
  }

  ($as, $am, $ae) = &fbc_split($a);
  ($bs, $bm, $be) = &fbc_split($b);
  $as .= "1"; $bs .= "1";

  $am = &bce("$am / $bm", 1);
  $ae = $ae - $be;
  if ($as * $bs > 0) {
    $as = "+";
  } else {
    $as = "-";
  }
  $a = $as . $am . "E" . $ae;
  $a = &fbc_norm($a);

  &dbg1("$curprim f_div b: " . $a, 1);

  return $a;
}

# Our exp routine tests the infinity and overflow cases itself, just in
# case the library function doesn't.
sub f_exp                    # fbc version
{
  my($x) = @_;
  my($nf);

  &dbg1("$curprim f_exp $x", 1);

  # Handle infinities first
  if (&isninf($x)) {
    &dbg1("$curprim f_exp(ninf) : 0", 32);
    return $g_0;
  } elsif (&isinf($x)) {
    &dbg1("$curprim f_exp(inf) : inf", 32);
    return $g_inf;
  } elsif (&isnan($x)) {
    &dbg1("$curprim f_exp(nan) : nan", 32);
    return $g_nan;
  }

  $nf = 0;
  # Handle the extreme overflow cases.
  if (&f_lt($x, $g_n2000)) {
    return $g_0;
  } elsif (&f_gt($x, $g_2000)) {
    return $g_inf;
  } elsif (&f_lt($x, $g_0)) {
    # #bc# loses precision when we evaluate e.g. e^-30 at scale 20, which
    # gives a value like ".00000000000000123...". So we negate the argument
    # and take the reciprocal of the result.
    $nf = 1;
    $x = &f_neg($x);
  }

  $x = &fbc_sci2fix($x);
  $x =~ s/\+//g;
  $x = &bce("e( $x )", 1);
  $x = &fbc_fix2sci($x);

  if ($nf) {
    $x = &f_div($g_1, $x);
  }

  &dbg1("$curprim f_exp e: " . $x, 1);
  return $x;
} # End of f.exp

# Our ln routine is strange -- it accepts negative arguments and returns
# the magnitude of the answer. It also special-cases infinities and zero.
sub f_ln                    # fbc version
{
  my($x) = @_;
  my($xs, $xm, $xe);

  &dbg1("$curprim f_ln $x", 1);

  ($xs, $xm, $xe) = &fbc_split($x); $xs .= "1";

  if (&isnan($xe)) {
    &dbg1("$curprim f_ln(nan) : nan", 32);
    return $g_nan;
  }

  # If the argument is negative we make it positive, because
  # we want to return the real component of the logarithm of the number,
  # and for any complex number, the real component of the log is the log
  # of the number's magnitude.
  if ($xs < 0) {
    $x = &f_neg($x);
  }

  # Handle 0 and infinities first
  if ($xm == 0.0) {
    &dbg1("$curprim f_ln(0): " . $g_ninf, 33);
    return $g_ninf;
  } elsif (&isinf($xe)) {
    &dbg1("$curprim f_ln(inf): " . $g_inf, 33);
    return $g_inf;
  }

  $x = &fbc_sci2fix($x);
  $x =~ s/\+//g;
  $x = &bce("l( $x )", 1);
  $x = &fbc_fix2sci($x);

  &dbg1("$curprim f_ln d: " . $x, 1);
  return $x;
}

# following are the partial primitives.

sub f_sub                    # fbc version
{
  my($a, $b) = @_;

  &dbg1("$curprim f_sub $a - $b", 1);

  $a = &f_add($a, &f_neg($b));

  &dbg1("$curprim f_sub: " . $a, 1);
  return $a;
}

# Following are the non-primitives

sub f_pow10                    # fbc version
{
  my($n) = @_;

  &dbg1("$curprim f.pow10 $n", 1);

  $n = &f_exp(&f_mul($g_ln_10, $n));
  &dbg1("$curprim f.pow10: " . $n, 1);
  return $n;
}

sub f_log_n                    # fbc version
{
  my($n, $b) = @_;

  &dbg1("$curprim f.log_n v{ $b } $n", 1);

  return &f_div(&f_ln($n), &f_ln($b));
}

sub f_log10                    # fbc version
{
  my($n) = @_;

  &dbg1("$curprim f_log10 $n", 1);

  $n = &f_mul(&f_ln($n), $g_log10_e);
  &dbg1("$curprim f_log10: " . $n, 1);
  return $n;
}

# sqrt(2 pi n) * n^n * e^(-n) * e^(1/12n)
# 1/2 ln(2 pi n) + n ln(n) - n + 1/12n - 1/1260 n^3 + ...
# t = n - 1;
# l = 1/2 ln(2 pi) + (n + 1/2) ln(n) - n + 1/(12 n) - 1/(360 n^3) + ...
# g = e^l
#
# %%% Accuracy is not good enough for scale>20. See notes in header.
sub f_gamma                    # fbc version
{
  my($n) = @_;
  my($l, $scal4, $n2, $np);

  &dbg1("$curprim f_gamma $n", 2);

  if (&isnan($n)) {
    &dbg1("$curprim f_gamma(nan) : nan", 32);
    return $g_nan;
  }

  # For very low negative arguments, the gamma function is so
  # close to zero that we treat it as zero. However, for negative
  # integers it's an infinite jump discontinuity, so we handle that case
  # explicitly.
  if (&f_lt($n, $g_n50)) {
    if (&simple_nint($n, $curscale)) {
      &dbg1("$curprim f_gamma(-int) : nan", 32);
      return $g_nan;
    } elsif (&f_eq($n, &f_int($n))) {
      &dbg1("$curprim f_gamma(-N) : nan", 32);
      return $g_nan;
    }
    return $g_0;
  }

  # Our approximation formula doesn't work well for small values, so
  # we use the recurrance relation gamma(n+1) = n gamma(n).
  $scal4 = $g_1;
  while (&f_lt($n, $gamma_minarg)) {  # scale up to our current precision
    $scal4 = &f_mul($scal4, $n);
    $n = &f_add($n, $g_1);
  }
  &dbg1("  f_gamma: minarg = $gamma_minarg; n scaled to $n", 2);

  if ($dbg1flag & 2) {
    my ($est1) = &f_div("657931.0", &f_mul("300.0", &f_pow($n, "25.0")));
    &dbg1("           with new n, residual = $est1", 2);
  }

  # Since we're using Stirling's series for factorials, we have
  # to subtract 1 to make it be a gamma function series.
  $n = &f_sub($n, $g_1);

  $l = $g_05_ln_2pi; # %%%
  $l = &f_add($l, &f_mul(&f_add($n, $g_0_5), &f_ln($n)));
  $l = &f_sub($l, $n);
  $n2 = &f_mul($n, $n);
  $np = $n;
&dbg1("  f_gamma: l = $l", 2);
  $l = &f_add($l, &f_div($g_1, &f_mul($g_12, $np)));  # N^-1 term
  $np = &f_mul($np, $n2);
  $l = &f_sub($l, &f_div($g_1, &f_mul($g_360, $np)));  # N^-3 term
  $np = &f_mul($np, $n2);
  $l = &f_add($l, &f_div($g_1, &f_mul($g_1260, $np)));  # N^-5
  $np = &f_mul($np, $n2);
  $l = &f_sub($l, &f_div($g_1, &f_mul($g_1680, $np)));  # N^-7
  $np = &f_mul($np, $n2);
  $l = &f_add($l, &f_div($g_1, &f_mul($g_1188, $np)));  # N^-9
  $np = &f_mul($np, $n2);
  $l = &f_sub($l, &f_div($g_691, &f_mul($g_360360, $np)));  # N^-11
  $np = &f_mul($np, $n2);
  $l = &f_add($l, &f_div($g_7, &f_mul($g_1092, $np))); # N^-13
  $np = &f_mul($np, $n2);
  $l = &f_sub($l, &f_div($g_3617, &f_mul($g_122400, $np)));  # N^-15
  $np = &f_mul($np, $n2);
  $l = &f_add($l, &f_div("43867.0", &f_mul("244188.0", $np)));  # N^-17
  $np = &f_mul($np, $n2);
  $l = &f_sub($l, &f_div("174611.0", &f_mul("125400.0", $np)));  # N^-19
  $np = &f_mul($np, $n2);
  $l = &f_add($l, &f_div("77683.0", &f_mul("5796.0", $np)));  # N^-21
  $np = &f_mul($np, $n2);
  $l = &f_sub($l, &f_div("236364091.0", &f_mul("1506960.0", $np)));  # N^-23
  # The residual is less than the subsequent term, which is
  #        +               657931 /      (     300 N^25  )
  # and the term after that is:
  #        -           3392780147 /      (   93960 N^27  )

  # The last term is 3617/(122400 N^15), where N is the argument of
  # the factorial function being approximated. For scale=50, 27!
  # produces N=60, so the last term is about 6e-29. That's only enough
  # for 29 digits of accuracy!

  return (&f_div(&f_exp($l), $scal4));
}

# square root routine handles infinities and negative arguments properly
sub f_sqrt                    # fbc version
{
  my($x) = @_;
  my($xs, $xm, $xe);

  &dbg1("$curprim f_sqrt $x", 1);

  ($xs, $xm, $xe) = &fbc_split($x); $xs .= "1";

  # If the argument is negative we return 0, because 0 is
  # the real component of the square root of a negative number.
  if ($xs < 0) {
    &dbg1("$curprim f_sqrt(-X) : 0", 32);
    return $g_0;
  } elsif (&isninf($x)) {
    &dbg1("$curprim f_sqrt(ninf) : 0", 32);
    return $g_0;
  } elsif (&isinf($x)) {
    &dbg1("$curprim f_sqrt(inf) : inf", 32);
    return $g_inf;
  } elsif (&isnan($x)) {
    &dbg1("$curprim f_sqrt(nan) : nan", 32);
    return $g_nan;
  } elsif ($xm == 0.0) {
    &dbg1("$curprim f_sqrt a: " . $g_0, 1);
    return $g_0;
  }

  $x = &fbc_sci2fix($x);
  $x =~ s/\+//g;
  $x = &bce("e(l( $x )/2)", 1);
  $x = &fbc_fix2sci($x);

  &dbg1("$curprim f_sqrt d: " . $x, 1);
  return $x;
}

# The sine algorithm uses the identity
#     sin(a+b) = sin a cos b + cos a sin b
# The value being sin'd is broken into two pieces one of which is a multiple
# of pi/16 and the other is between -pi/32 and pi/32. Then we can use the
# Taylor series to get the sin of the latter part and a table for the
# first part
sub f_sin                    # fbc version
{
  my($x) = @_;

  &dbg1("$curprim f_sin $x", 1);

  if (&isnan($x)) {
    &dbg1("$curprim f_sin(nan) : nan", 32);
    return $g_nan;
  }

  # Handle arguments out of range
  # Note: The best way to handle things like this is to extend the
  # numeric representation to include an "error" term, expressing the
  # standard deviation of the computed value vs. the actual value.
  # Then, the error of the sin function is the error of the argument
  # times the cosine, but converging on +-1.0 when the error of the
  # argument is 2 pi or larger. In the limit case the computed value
  # will be expressed as 0.0 and the error as 1.0.
  #
  # Just for fun, I went to an office supply store and tested 5
  # current-model scientific calculators (covering all price ranges)
  # to see what they did when you take sin or cos of larger and larger
  # numbers. Each calculator had a different cutoff value, but all
  # seemed to choose a value that was related to the calculator's
  # internal precision. The five cutoff values were:
  #    5*10^7 pi ~= 1.57*10^8
  #    4.45*10^9
  #    1*10^10
  #    1*10^12
  #    1*10^13
  if (&f_gt($x, $g_sin_limit)) {
    return $g_0;
  } elsif (&f_lt($x, &f_neg($g_sin_limit))) {
    return $g_0;
  }

  $x = &fbc_sci2fix($x);
  $x =~ s/\+//g;
  $x = &bce("s( $x )", 1);
  $x = &fbc_fix2sci($x);

  &dbg1("$curprim f_sin : $x", 1);

  return $x;
}

sub f_cos                    # fbc version
{
  my($x) = @_;

  &dbg1("$curprim f_cos $x", 1);

  if (&isnan($x)) {
    &dbg1("$curprim f_cos(nan) : nan", 32);
    return $g_nan;
  }

  # Handle out-of-range
  if (&f_gt($x, $g_sin_limit)) {
    return $g_1;
  } elsif (&f_lt($x, &f_neg($g_sin_limit))) {
    return $g_1;
  }

  $x = &fbc_sci2fix($x);
  $x =~ s/\+//g;
  $x = &bce("c( $x )", 1);
  $x = &fbc_fix2sci($x);

  &dbg1("$curprim f_cos : $x", 1);

  return $x;
}

sub f_tan                    # fbc version
{
  my($x) = @_;

  &dbg1("$curprim f_tan $x", 1);

  if (&isnan($x)) {
    &dbg1("$curprim f_tan(nan) : nan", 32);
    return $g_nan;
  }

  # Handle out-of-range
  if (&f_gt($x, $g_sin_limit)) {
    return $g_inf;
  } elsif (&f_lt($x, &f_neg($g_sin_limit))) {
    return $g_inf;
  }

  $x = &f_div(f_sin($x),f_cos($x));

  &dbg1("$curprim f_tan : $x", 1);

  return $x;
}

# Arctangent function.
#
# Av{0} = 1 / sqrt(1 + x^{2})  ,  Bv{0} = 1
# Av{n+1} = (Av{n} + Bv{n}) / 2  ,
#           Bv{n+1} = sqrt(Av{n+1} * Bv{n})
# arctan(x) = LIMIT [x * Av{0} / Av(n)]
sub f_arctan                    # fbc version
{
  my($x) = @_;
  my($a, $b, $a0, $ao, $i);

  if (&isnan($x)) {
    &dbg1("$curprim f_arctan(nan) : nan", 32);
    return $g_nan;
  }

  # A few special cases, the x==0 case is just for speed
  if (&f_eq($x, $g_0)) {
    return $g_0;
  } elsif (&ispinf($x)) {
    &dbg1("$curprim f_arctan(inf) : pi/2", 32);
    return &f_div($g_pi, $g_2);
  } elsif (&isninf($x)) {
    &dbg1("$curprim f_arctan(ninf) : -pi/2", 32);
    return &f_div($g_pi, $g_n2);
  }

  $a0 = &f_div($g_1, &f_sqrt(&f_add($g_1, &f_mul($x, $x))));
  $a = $a0;
  $b = $g_1;

  # Set up ao to be different from a so the loop has a chance to start
  $ao = &f_sub($a, $g_1);
  for($i=0; ($i<25) && (&f_ne($a, $ao)); $i++) {
    $ao = $a;
    $a = &f_div(&f_add($a, $b), $g_2);
    $b = &f_sqrt(&f_mul($a, $b));
  }
  return &f_div(&f_mul($x, $a0), $a);
}

# arcsin(x) = arctan(x / sqrt(1 - x*x))
sub f_arcsin                    # fbc version
{
  my($x) = @_;
  my($a);

  if (&isnan($x)) {
    &dbg1("$curprim f_arcsin(nan) : nan", 32);
    return $g_nan;
  }

  $a = &f_mul($x, $x);
  if (&f_gt($a, $g_1)) {
    return $g_0;
  }
  return &f_arctan(&f_div($x, &f_sqrt(&f_sub(1, $a))));
}

# arccos(x) = pi/2 - arctan(x / sqrt(1 - x*x))
sub f_arccos                    # fbc version
{
  my($x) = @_;
  my($a);

  if (&isnan($x)) {
    &dbg1("$curprim f_arccos(nan) : nan", 32);
    return $g_nan;
  }

  $a = &f_mul($x, $x);
  if (&f_gt($a, $g_1)) {
    return $g_0;
  }
  return &f_div($g_pi, $g_2)
                   - &f_arctan(&f_div($x, &f_sqrt(&f_sub($g_1, $a))));
}

# pow function is more complex than exp and pow10, because
# it has to deal with any base. Specifically, if the base is negative
# it computes the angle and magnitude of the complex answer
# so it can calculate the real component.
sub f_pow                    # fbc version
{
  my($b, $e) = @_;
  my($mag, $scal5);

  &dbg1("$curprim f_pow $b $e", 1);

  if (&isnan($b) || &isnan($e)) {
    &dbg1("$curprim f_pow(nan) : nan", 32);
    return $g_nan;
  }

  # Handle negative bases
  if (&f_lt($b, $g_0)) {
    # The angle of the base is pi, so the angle of the
    # exponent will be pi * e. Take cosine of this to
    # determine how much of the answer will be in the
    # real component.
    $b = &f_neg($b);
    $scal5 = &f_cos(&f_mul($g_pi, $e));
  } else {
    $scal5 = $g_1;
  }

  # Compute magnitude of answer
  $mag = &f_exp(&f_mul(&f_ln($b), $e));

  # If we got an overflow, we might be able to salvage
  # the computation by using logarithms. This happens when we compute
  # -20.0 to the power of 238.49999999999 (exactly 10 9's there)
  # The magnitude is 1.97e310, which overflows, but the scale
  # is 3.1416e-10 so the answer is actually well within
  # range (and even within PT0 range)
  if (&f_gt($mag, $g_ovr1)) {
    if (&f_gt($scal5, $g_0)) {
      $mag = &f_add(&f_mul(&f_ln($b), $e), &f_ln($scal5));
      return &f_exp($mag);
    } else {
      $mag = &f_add(&f_mul(&f_ln($b), $e), &f_ln(&f_neg($scal5)));
      return &f_neg(&f_exp($mag));
    }
  } else {
    # Return real component of answer
    return &f_mul($scal5, $mag);
  }
}

# Root function contains the same complexity (pun intended) as
# the pow function.
sub f_root                    # fbc version
{
  my($b, $r) = @_;
  my($mag, $scal6);

  if (&isnan($b) || &isnan($r)) {
    &dbg1("$curprim f_root(nan) : nan", 32);
    return $g_nan;
  }

  # Handle negative bases
  if (&f_lt($b, $g_0)) {
    # The angle of the base is pi, so the angle of the
    # answer will be pi / r. Take cosine of this to
    # determine how much of the answer will be in the
    # real component.
    $b = &f_neg($b);
    $scal6 = &f_cos(&f_div($g_pi, $r));
  } else {
    $scal6 = $g_1;
  }

  $mag = &f_exp(&f_div(&f_ln($b), $r));

  return &f_mul($scal6, $mag);
} # End of f.root

# addfunc: new functions can go here
endquote


sub fbc_init
{
  my($init_scale) = @_;
  my($BCIN, $BCOUT);

  if (!($bc_running)) {
    $BCIN = new IO::File;
    $BCOUT = new IO::File;

    # Before spawning, disable SIGINT so that a ^C won't kill the #bc#
    # process (this also allows BASIC.run to catch ^C allowing the user
    # to get out of infinite loops)
    $SIG{INT} = 'IGNORE';

    $pid = open2($BCIN, $BCOUT, 'bc -l 2>&1');
    die "Can't open2 bc -l" unless ($pid);

    $bc_in = $BCIN; $bc_out = $BCOUT;
    &dbg1("open2 gave: $pid $bc_in $bc_out", 4);

    $init_scale += 2;
    &bce("scale=$init_scale", 0);

    &bce("3*4", 1);

    &bce("27^143", 1);

    $bc_running = 1;
  }

  # Define the primitives
  eval($fbc_prim);

  # These constants are mostly used by the various transcendental functions
  $g_0 = "0";
  $g_0_5 = "0.5";
  $g_1 = "1";
  $g_n1 = "-1";
  $g_2 = "2";
  $g_n2 = "-2";
  $g_4 = "4";
  $g_5 = "5";
  $g_6 = "6";
  $g_7 = "7";
  $g_8 = "8";
  $g_10 = "10";
  $g_12 = "12";
  $g_16 = "15";
  $g_16 = "16";
  $g_n50 = "-50";
  $g_360 = "360";
  $g_691 = "691";
  $g_1092 = "1092";
  $g_1188 = "1188";
  $g_1260 = "1260";
  $g_1680 = "1680";
  $g_n2000 = "-2000";
  $g_2000 = "2000";
  $g_3617 = "3617";
  $g_122400 = "122400";
  $g_360360 = "360360";
  $g_2p32m1 = "4294967295";
}

sub fbc_rescale
{
  my($newscale) = @_;

  $newscale += 2;
  &bce("scale=$newscale", 0);
}

sub fbc_close
{
  &dbg1("fbc_close", 4);
  close($bc_out);
  while(<$bc_in>) { }
  close($bc_in);
  $bc_running = 0;
}

#--------------------------------------------------- hybrids
#
# These routines operate on top of both sets of primitives, but aren't
# full PT routines. They're used for conversion and formatting.

# pvu.sint is like simple.int but takes a PT and unc as well (it just makes
# sure they are zero and calls simple.int)
sub pvu_sint
{
  my($xp, $xv, $xu, $sc) = @_;
  return (($xp == 0) && ($xu == 0) && (&simple_int($xv, $sc)));
}

# normalise works on string-format floating-point numbers of the form
# [+-]1.23e[+-]456 and [+-]1.234u12e[+-]456, and works over either type
# of primitive operators.
# Its main function is to promote values like "23e456" to a PT1, and as
# such it returns a PT tuple as a result.
sub normalise
{
  my($x) = @_;
  my($m, $m1, $m2, $m3, $e, $s, $t1, $t2, $t3);
  my($unc, $u1, $u2, $eu);

  &dbg1("nrm01 x $x", 8);

  if (&simple_int($x, $curscale)) {
    return (0, $x, 0);
  }

  # Extract mantissa part (which includes uncertainty if any)
  if ($x =~ m|^([-+0-9.U]+)E([-+0-9]+)$|i) {
    # 1.02E34, 1.02U1E34, etc.
    $m = $1; $e = $2;
    &dbg1("nrm02 m $m e $e", 8);
  } elsif ($x =~ m|^([-+0-9.U]+)$|i) {
    # 1.02, 1.02U1, etc.
    $m = $1; $e = 0;
    &dbg1("nrm03 m $m e $e", 8);
  } else {
    print STDERR "*** Cannot parse '$x' (nrm1)\n";
    return(0, $g_0, '0');
  }

  # Make sure mantissa has an uncertainty component (add one if not present)
  $m =~ s/u/U/g;
  if ($m =~ m/U.+U/) {
    print STDERR ("*** Cannot parse multiple U components: '$x' (nrm3)\n");
    return(0, $g_0, '0');
  } elsif ($m =~ m/U[0-9]+$/) {
    # Okay
  } elsif ($m =~ m/U$/) {
    $m .= "0";
    &dbg1("nrm04 m $m", 8);
  } elsif ($m =~ m/U/) {
    print STDERR ("*** Cannot parse U component of '$x' (nrm4)\n");
    return(0, $g_0, '0');
  } else {
    $m .= "U0";
    &dbg1("nrm05 m $m", 8);
  }

  $m1 = $m2 = "";

  # Now extract the first mantissa digit and eliminate any extra zeros
  if (0) {
  } elsif ($m =~ m|^([-+]?)0*[.](0+)([1-9])([0-9]*)U([0-9]+)$|) {
    # 000.|0|1||, .|0|1||, 0.|00|1|23|, or .|00|1|23|
    $s = $1; $t1 = $2; $t2 = $3; $t3 = $4; $u1 = $5;
    &dbg1("nrm06 0.0  s $s t1 $t1 t2 $t2 t3 $t3 u1 $u1", 8);
    $m1 = "$s$t2";
    $e = $e - (1 + length($t1));
    $eu = $e - length($t3);
    $m2 = $t3 . "0";
  } elsif ($m =~ m|^([-+]?)0*[.]([1-9])([0-9]*)U([0-9]+)$|) {
    # 0.|1||, .|1||, 0.|1|23|, or .|1|23|
    $s = $1; $t1 = $2; $t2 = $3; $u1 = $4;
    &dbg1("nrm07 0.D  s $s t1 $t1 t2 $t2 u1 $u1", 8);
    $m1 = "$s$t1";
    $e--;
    $eu = $e - length($t2);
    $m2 = $t2 . "0";
  } elsif ($m =~ m|^([-+]?)(0*[1-9])[.]([0-9]*)U([0-9]+)$|) {
    # |01|.||, |1|.||, |01|.|23|, or |1|.|23|
    $s = $1; $m1 = $2; $m2 = $3; $u1 = $4;
    &dbg1("nrm08 D.  s $s m1 $m1 m2 $m2 u1 $u1", 8);
    $eu = $e - length($m2);
    $m2 = $m2 . "0"; # Make sure m2 has at least 1 digit
  } elsif ($m =~ m|^([-+]?0*[1-9])([0-9]+)[.]([0-9]*)U([0-9]+)$|) {
    # |01|2|.||, |1|2|.||, |01|2|.|34|, or |1|2|.|34|
    $m1 = $1; $m2 = $2; $m3 = $3; $u1 = $4;
    &dbg1("nrm09 DD.  m1 $m1 m2 $m2 m3 $m3 u1 $u1", 8);
    $eu = $e - length($m3);
    $e += length($m2);
    $m2 = $m2 . $m3;
  } elsif ($m =~ m|^([-+]?0*[1-9])([0-9]*)U([0-9]+)$|) {
    # |01||, |1||, |01|2|, or |1|2|
    $m1 = $1; $m2 = $2; $u1 = $3;
    &dbg1("nrm10 D  m1 $m1 m2 $m2 u1 $u1", 8);
    $eu = $e;
    $e += length($m2);
    $m2 = $m2 . "0"; # Make sure m2 has at least 1 digit
  } elsif ($m =~ m|^[-+]?0*[.](0+)U([0-9]+)$|) {
    # decimal point and 1 or more zeros and no exponent: .0 or 0.00, etc.
    # Sign does not matter.
    $m1 = '0'; $m2 = $1; $u1 = $2;
    $eu = $e - length($m2);
    &dbg1("nrm11 .0 or 0.00 : m1 $m1 m2 $m2 u1 $u1 eu $eu", 8);
    #   %%% Eventually we'll want to be smarter about cases where the
    # uncertainty is larger than the value, and report errors when a
    # calculation that makes the uncertainty distribution nonlinear,
    # e.g. computing e^4(1).
  } elsif ($m =~ m|^[-+]?0+[.]U([0-9]+)$|) {
    # 000. or 0.
    $m1 = '0'; $m2 = ''; $u1 = $1;
    $eu = $e;
    &dbg1("nrm12 0. or 000. : m1 $m1 m2 '' u1 $u1 eu $eu", 8);
  } elsif ($m =~ m|^[-+]?0+U([0-9]+)$|) {
    # 0 or 00 with no decimal point; the uncertainty is an integer.
    #  %%% Again, we do not try to retain any uncertainty here.
    &dbg1("nrm13   0 or 00", 8);
    &dbg1("nrm14 :: 0 PT $g_0 (0)", 8);
    return(0, $g_0, '0');
  } else {
    print STDERR ("*** Cannot parse '$m' (nrm2)\n");
    return(0, $g_0, '0');
  }
  # Rebuild the mantissa in a normal 1.23 format
  $m = "$m1.$m2";
  # Append the exponent, to get the full number as "1.23E5" or "-1.23E-5"
  $x = $m . "E" . $e;
  # Uncertainty is constructed the same way
  if ($u1 eq '0') {
    $um = $u1;
    $unc = $u1;
    &dbg1("nrm15 um $um unc $unc", 8);
  } elsif ($u1 =~ m/^([1-9])$/) {
    # Single-digit uncertainty
    $um = $u1;
    $unc = $u1 . "E" . $eu;
    &dbg1("nrm16 um $um unc $unc", 8);
  } elsif ($u1 =~ m/^([0-9])([0-9]+)$/) {
    # Multi-digit uncertainty. Turn "123e7" into "1.23e9"
    $u1 = $1; $u2 = $2;
    $eu += length($u2);
    $um = $u1 . "." . $u2;
    $unc = $um . "E" . $eu;
    &dbg1("nrm17 um $um unc $unc", 8);
  } else {
    print STDERR ("*** Cannot rebuild unc from '$u1' (nrm5)\n");
    return(0, $g_0, '0');
  }

  # At this point $x and $unc are properly formatted to pass as arguments
  # to either of the f_xxx libraries. However their components ($m, $e,
  # $um and $eu) are used below if we need to promote

  if ($e < -300) {
    # %%% Here is another spot we have to change if/when we support
    # uncertainty greater than the value.
    &dbg1("nrm18 :: 0 PT $g_0 (0)", 8);
    return(0, $g_0, '0');
  } elsif ($e > 300) {
    # Need to promote. First, extract sign
    if ($m < 0) {
      $s = -1;
      $m = &f_neg($m);
    } else {
      $s = 1;
    }
    # take log. Note, we will call whichever f_xxx routines are
    # current and that's the right thing to do.

    # New uncertainty is u/(x ln(10)) where u is the old uncertainty.
    # Example: 1.0000(10)e310  x=1e310 unc=1e307
    #        1 PT 310.000434   unc 0.000434
    # The way we divide by x is by subtracting the exponent $e and
    # dividing by the mantissa $m. We do the exponent part first, create
    # a properly formatted number then use f_xxx routines to divide out
    # the mantissa of X and ln(10).
    $eu = $eu - $e;
    $unc = $um . "E" . $eu;
    $unc = &f_div($unc, &f_mul($m, $g_ln_10));
    &dbg1("nrm19 eu $eu um $um unc $unc", 8);

    # Now we can rebuild the value of X. Since we're promoting it to a
    # PT1, the new value is the old exponent plus the log10 of the old
    # mantissa.
    # At this point it is no longer a pure "mantissa", as it is greater than
    # 9.999; likewise $unc might be less than 1.0 or greater than 9.999
    $x = &f_add($e, &f_log10($m));

    # put sign back in
    $x = &f_mul($s, $x);

    &dbg1("nrm20 :: 1 PT $x ($unc)", 8);
    return (1, $x, $unc);
  }
  # else

  # no promote necessary
  &dbg1("nrm21 :: 0 PT $x ($unc)", 8);
  return (0, $x, $unc);
} # end of normalise

# splt takes string numbers of the format "2P[+-]3.4E[+-]56", or simple
# floating-point numbers like "[+-]3.4E[+-]56", plain numbers like "234.56",
# or IR inlines like "I17", performs the appropriate conversion or
# value retrieval and returns a PT tuple result.
sub splt
{
  my($x) = @_;
  my($i);
  my($xv_pt, $xv_val, $xv_unc);  # for normalizing, if string is for example
                                 # "1.2e345" or "2pt1.2e345"
  my($t1);

  &dbg1("splt($x)", 32);

  # Recognize '.' as a synonym for '%' ('.' is from #bc#, '%' is from #maxima#)
  if ($x eq '.') {
    return ($a2_pt, $a2_val, $a2_unc, '');
  }

  if ($x =~ m|^I([0-9]+)|) {
    # retrieve a stored intermediate result
    $i = $1;
    &dbg1("  I -> ($ir_pt[$i], $ir_val[$i], $ir_unc[$i], $ir_lvk[$i])", 32);
    return($ir_pt[$i], $ir_val[$i], $ir_unc[$i], $ir_lvk[$i]);
  } elsif ($x =~ m|^R([0-9]+)|) {
    # retrieve a stored history result
    $i = $1;
    &dbg1("  R -> ($h_pt[$i], $h_val[$i], $h_unc[$i], '')", 32);
    return($h_pt[$i], $h_val[$i], $h_unc[$i], '');
  } elsif ($x =~ m|^\%|) {
    # retrieve last result
    &dbg1("  % -> ($h_pt[$i], $h_val[$i], $h_unc[$i], '')", 32);
    return($a2_pt, $a2_val, $a2_unc, '');
  } elsif ($x =~ m|^(.+)P(.+)$|) {
    my($x_pt, $x_val, $x_unc);

    # convert an inline PT number.
    # first, assume it's legal, i.e. the val part is within range
    $x_pt = $1;
    $x_val = $2;
    print "splt 2 $x : " if ($format_debug);
    $x_val =~ s|N|-|g;
    # Now check if the val is out of range. If so, add additional levels
    # to the power-tower. This is where "1P1E310" gets turned into 2P310.
    ($xv_pt, $xv_val, $xv_unc) = &normalise($x_val);
    if ($xv_pt > 0) {
      $x_pt += $xv_pt;
    } elsif (($x_pt > 0) && ($xv_val < 300)) {
      # Handle the other kind of denormalised values, where the PT is
      # too high. For example, '1p1.000(1)e2' is converted to '0p1.00(26)e100'
      $t1 = &f_pow10($xv_val);
      $xv_unc = &f_pow10($xv_val+$xv_unc) - $t1;
      $xv_val = $t1;
      $x_pt -= 1;
    }
    print "$x_pt $xv_val $xv_unc\n" if ($format_debug);
    return ($x_pt, $xv_val, $xv_unc, '');
  }

  # else, this is a normal number "1.23" or "-23.45", or scientific notation
  # "1.23E45". This is where "1E5000" gets turned into 1P5000.
  print "splt 1 $x : " if ($format_debug);
  $x =~ s|N|-|g;
  ($xv_pt, $xv_val, $xv_unc) = &normalise($x);
  print "$xv_pt $xv_val $xv_unc\n" if ($format_debug);
  return ($xv_pt, $xv_val, $xv_unc, '');
} # End of splt

#--------------------------------------------------- hcfloat.h
#
# This is the data type used for user calculations. The first field "pt"
# is an integer representing how many times we've taken the logarithm
# (base 10) of the value being represented. The "val" field is
# the value, or the log of the value, or the log of the log of the
# value, etc.  If the value being represented is negative, the "val"
# field is negative.
#
# typedef struct {
#   unsigned int  pt;
#   double      val;
# } pt_real;


#------------------------------------------------------ hcpt.c
#
# These routines, originally from "hcpt.c", do all the calculation
# functions and operate on "PT" format values.

# Return the logarithm of the sum of the antilog of two numbers. For example,
# If the inputs are 301.0 and 299.0, it returns 301.004321, because
# 10^301 + 10^299 = 10^301.004321. This is used for adding PT1's and for
# multiplying PT2's. For subtraction and division use pt.sublog
#
# To compute the log of the answer, we take the log of the two inputs
# and subtract, then take 10 to the power of that value, take the
# antilog, add to 1 and take the log again:
#
#   To compute: 10^301 + 10^299
#
#       inputs:  301.0, 299.0
#     subtract:  -2.0
#      antilog:  0.01
#     add to 1:  1.01
#          log:  0.004321
#          add:  301.004321
#
#       Answer:  10^301.004321... = 1.01e301
#
sub pt_addlog
{
  my($lar, $sm) = @_;
  my($t);

  &dbg1("pt.addlog $lar + $sm", 32);

  $t = &f_sub($sm, $lar);           # -2.0
  $t = &f_add($g_1, &f_pow10($t));  # 1.01
  $t = &f_add($lar, &f_log10($t));  # 301.004321

  return $t;
}

# A similar operation for subtraction
sub pt_sublog
{
  my($lar, $sm) = @_;
  my($t);

  &dbg1("pt.sublog $lar - $sm", 32);

  $t = &f_sub($sm, $lar);           # -2.0
  $t = &f_sub($g_1, &f_pow10($t));  # 0.99
  $t = &f_add($lar, &f_log10($t));  # 300.995635

  return $t;
}

# Addition and subtraction are done through two intermediate routines,
# addpos and subpos. addpos adds any two positive values (not necessarily
# with the largest first) and subpos subtracts a positive value from another
# positive value, where the result is known to be positive or zero. These
# two routines combined with appropriate sign manipulation cover all the
# cases of addition and subtraction.
sub pt_addpos
{
  my($x_pt, $x_val, $x_unc, $y_pt, $y_val, $y_unc) = @_;
  my($xpt, $xv, $xu, $ypt, $yv, $yu);
  my($s1, $u1);
  my($ans_pt, $ans_val, $ans_unc);

  # Put bigger argument first, so we have fewer cases to handle
  if ($x_pt > $y_pt) {
    $xpt = $x_pt; $ypt = y_pt;
    $xv = $x_val; $yv = $y_val;
    $xu = $x_unc; $yu = $y_unc;
  } elsif (($x_pt == $y_pt) && &f_gt($x_val, $y_val)) {
    $xpt = $x_pt; $ypt = $y_pt;
    $xv = $x_val; $yv = $y_val;
    $xu = $x_unc; $yu = $y_unc;
  } else {
    $xpt = $y_pt; $ypt = $x_pt;
    $xv = $y_val; $yv = $x_val;
    $xu = $y_unc; $yu = $x_unc;
  }

  # Deal with infinities.
  if (&f_eq($xv, $g_inf)) {
    return ($g_pt_inf, $g_inf, 0);
  } elsif (&f_eq($xv, $g_nan)) {
    return ($g_pt_nan, $g_nan, 0);
  }

  if ($xpt == 0) {
    # both are simple numbers, add and test for promote
    $s1 = &f_add($xv, $yv);
    $u1 = $xu + $yu; # &f_add($xu, $yu);
    if (&f_gt($s1, $g_ovr1)) {
      # Sum overflowed, promote to PT1
      $ans_pt = 1;
      $ans_val = &f_log10($s1);
      # %%% $ans_unc = $ans_val - &f_log10($s1-$u1);
      return ($ans_pt, $ans_val, 0);
    } else {
      $ans_pt = 0;
      $ans_val = $s1;
      $ans_unc = $u1;
      return ($ans_pt, $ans_val, $ans_unc);
    }
  } elsif ($xpt == 1) {
    # Adding a PT0 to a PT1, answer will usually be x, except in cases like
    # {1, 301.0} + {0, 1.0e299} => {1, 301.004321}
    #   Adding two PT1's is similar, and usually reduces to just returning X.
    # The only difference is that we don't have to take the log of y.
    if ($ypt == 0) {
      # PT1 plus PT0
      # print "pt_addlog($xv, f_log10($yv))\n";
      $ans_val = &pt_addlog($xv, &f_log10($yv));
    } else {
      # PT1 plus PT1
      # print "pt_addlog($xv, $yv)\n";
      $ans_val = &pt_addlog($xv, $yv);
    }
    # $ans_unc = $xu    %%% this is wrong, it will actually be bigger
    return (1, $ans_val, 0);
  }

  # else: X is PT2 or larger. Answer is always uncomputably larger than X.
  return ($xpt, $xv, 0);
} # End of pt_addpos

# pt_negate is trivial, but is implemented as a separate routine to try to
# simplify the work that would be entailed if I change the method of
# representing sign in PT's.
sub pt_negate
{
  my($x_pt, $x_val, $x_unc) = @_;
  my($ans_val);

  $ans_val = &f_neg($x_val);
  return ($x_pt, $ans_val, $x_unc);
}

# Subtract a smaller positive value from a larger positive value, to give
# a positive result.
sub pt_subpos
{
  my($x_pt, $x_val, $x_unc, $m_pt, $m_val, $m_unc) = @_;
  my($xpt, $xv, $mpt, $mv, $s1, $u1);
  my($ans_pt, $ans_val, $ans_unc);

  &dbg1("pt.subpos ($x_pt, $x_val, $x_unc) - ($m_pt, $m_val, $m_unc)", 32);

  $xpt = $x_pt; $mpt = $m_pt;
  $xv = $x_val; $mv = $m_val;

  # The uncertainty of a sum is the sum of the uncertainties.
  $u1 = $x_unc + $m_unc; # &f_add($x_unc, $m_unc);

  # Deal with infinities. If it's +inf + -inf, +inf wins.
  if (&f_eq($xv, $g_inf)) {
    return ($g_pt_inf, $g_inf, 0);
  } elsif (&f_eq($xv, $g_nan)) {
    return ($g_pt_nan, $g_nan, 0);
  }

  # If args are equal, answer is 0
  if (($xpt == $mpt) && (&f_eq($xv, $mv))) {
    return (0, $g_0, $u1);
  }

  # If m is zero, answer is x (but uncertainty still needs to be xu+mu)
  if (($mpt == 0) && (&f_eq($mv, $g_0))) {
    return ($x_pt, $x_val, $u1);
  }

  if ($xpt == 0) {
    # both are simple numbers, subtract -- no demote is possible
    $s1 = &f_sub($xv, $mv);
    return (0, $s1, $u1);
  } elsif (($xpt == 1) && ($mpt == 0)) {
    # Subtracting a PT0 from a PT1. Answer will usually be x, but in a few
    # cases like {1, 301.0} - {0, 1.0e299} => {1, 300.995678}
    # To compute the log of the answer, we take the log of the two inputs
    # and subtract, then take 10 to the power of that value, take the
    # antilog, add to 1 and take the log again
    #       inputs:  {1, 301.0} - {0, 1.0e299}
    #         logs:  301.0, 299.0
    #     subtract:  -2.0
    #      antilog:  0.01
    #   sub from 1:  0.99
    #          log:  -0.004321
    #          add:  300.995678
    # final answer:  {1, 300.995678}
    # In addition, we check for demote to a PT0 answer.
    $s1 = &f_sub(&f_log10($mv), $xv);
    $s1 = &f_sub($g_1, &f_pow10($s1));
    $s1 = &f_add($xv, &f_log10($s1));
    if (&f_gt($s1, $g_log10_ovr1)) {
      $ans_unc = $x_unc; # %%% will actually be bigger
      return (1, $s1, 0);
    }
    # else
    return (0, &f_pow10($s1), 0);
  } elsif ($xpt == 1) {
    # This is the case where both are PT1's. We actually do the same thing as
    # in the previous case (although it usually reduces to just returning X)
    # the only difference being that we don't have to take the log of y.
    $s1 = &f_sub($mv, $xv);
    $s1 = &f_sub($g_1, &f_pow10($s1));
    $s1 = &f_add($xv, &f_log10($s1));
    if (&f_gt($s1, $g_log10_ovr1)) {
      $ans_unc = $x_unc; # %%% will actually be bigger
      return (1, $s1, 0);
    }
    # else, demote
    $xv = &f_pow10($s1);
    # $u1 = $xv - &f_pow10($s1 - $x_unc);  %%% this needs work
    return(0, $xv, 0);
  } else {
    # X is PT2 or larger. No matter what Y is, the answer is X because X is
    # bigger.
    return ($xpt, $xv, $x_unc);
  }
}

$unused1 = q@
# Compare routine -- right now it isn't used anywhere.
int pt_compare(pt_real x, pt_real y)
{
  int  neg;

  if (($x_val < 0) && ($y_val > 0)) {
    return -1;
  } elsif (($x_val > 0) && ($y_val < 0)) {
    return 1;
  }

  # Both are of same sign. Force to both positive
  if ($x_val < 0) {
    $x_val = - $x_val;
    $y_val = - $y_val;
    neg = -1;
  } else {
    neg = 1;
  }

  # check difference in PTs
  if ($x_pt > $y_pt) {
    return neg * 1;
  } elsif ($x_pt < $y_pt) {
    return neg * -1;
  }

  # check difference in values
  if ($x_val > $y_val) {
    return neg * 1;
  } elsif ($x_val < $y_val) {
    return neg * -1;
  }

  # If they made it through all this, they're equal!
  return 0;
}
@;

# Normal comparison -- returns -1, 0, or 1 according as x<y, x==y or x>y
# Use pt_magcompare to ignore sign
sub pt_compare
{
  my($x_pt, $x_val, $y_pt, $y_val) = @_;
  my($xv, $yv, $neg);

  $xv = $x_val; $yv = $y_val;

  if (&f_lt($xv, $g_0) && &f_gt($yv, $g_0)) {
    return -1;
  } elsif (&f_gt($xv, $g_0) && &f_lt($yv, $g_0)) {
    return 1;
  }

  # Both are of same sign. Force to both positive
  if (&f_lt($xv, $g_0)) {
    $xv = &f_neg($xv);
    $yv = &f_neg($yv);
    $neg = -1;
  } else {
    $neg = 1;
  }

  # check difference in PTs
  if ($x_pt > $y_pt) {
    return $neg;
  } elsif ($x_pt < $y_pt) {
    return $neg * -1;
  }

  # check difference in values
  if (&f_gt($xv, $yv)) {
    return $neg;
  } elsif (&f_lt($xv, $yv)) {
    return $neg * -1;
  }

  # If they made it through all this, they're equal!
  return 0;
}


# Magnitude compare -- tells you which is "larger" as in further from 0.
# Use pt.compare for standard compare.
sub pt_magcompare
{
  my($x_pt, $x_val, $y_pt, $y_val) = @_;
  my($xv, $yv);

  $xv = $x_val; $yv = $y_val;

  if (&f_lt($xv, $g_0)) {
    $xv = &f_neg($xv);
  }
  if (&f_lt($yv, $g_0)) {
    $yv = &f_neg($yv);
  }

  # check difference in PTs
  if ($x_pt > $y_pt) {
    return 1;
  } elsif ($x_pt < $y_pt) {
    return -1;
  }

  # check difference in values
  if (&f_gt($xv, $yv)) {
    return 1;
  } elsif (&f_lt($xv, $yv)) {
    return -1;
  }

  # If they made it through all this, they're equal!
  return 0;
}

# Now, finally, we can do addition. There are four cases of positive and
# negative arguments, and in addition if the signs are different there are
# two cases corresponding to which is of greater magnitude. This routine
# dispatches each of the 6 cases using the two compare routines to figure
# out which case is present and the two arithmetic routines to generate
# answers, with pt_negate to massage the signs of arguments and results
# where necessary.
sub pt_add
{
  my($x_pt, $x_val, $x_unc, $y_pt, $y_val, $y_unc) = @_;

  # Deal with infinities. If it's +inf and -inf, +inf wins.
  if (&isninf($x_val)) {
    &dbg1("pt_add ninf + X: ninf", 32);
    return ($g_pt_inf, $g_ninf, 0);
  } elsif (&isninf($y_val)) {
    &dbg1("pt_add X + ninf: ninf", 32);
    return ($g_pt_inf, $g_ninf, 0);
  } elsif (&isinf($x_val)) {
    &dbg1("pt_add inf + X: inf", 32);
    return ($g_pt_inf, $g_inf, 0);
  } elsif (&isinf($y_val)) {
    &dbg1("pt_add X + inf: inf", 32);
    return ($g_pt_inf, $g_inf, 0);
  } elsif (&isnan($x_val)) {
    &dbg1("pt_add nan + X: nan", 32);
    return ($g_pt_nan, $g_nan, 0);
  } elsif (&isnan($y_val)) {
    &dbg1("pt_add X + nan: nan", 32);
    return ($g_pt_nan, $g_nan, 0);
  }

  if (&f_ge($x_val, $g_0)) {
    if (&f_ge($y_val, $g_0)) {
      # Both positive
      return &pt_addpos($x_pt, $x_val, $x_unc, $y_pt, $y_val, $y_unc);
    } else {
      # +X, -Y
      if (&pt_magcompare($x_pt, $x_val, $y_pt, $y_val) > 0) {
        # X is of greater magnitude
        return &pt_subpos($x_pt, $x_val, $x_unc,
               &pt_negate($y_pt, $y_val, $y_unc));
      } else {
        return &pt_negate(&pt_subpos(&pt_negate($y_pt, $y_val, $y_unc),
                                                $x_pt, $x_val, $x_unc));
      }
    }
  } elsif (&f_ge($y_val, $g_0)) {
    # -X, +Y
    if (&pt_magcompare($x_pt, $x_val, $y_pt, $y_val) > 0) {
      # X is of greater magnitude
      return &pt_negate(&pt_subpos(&pt_negate($x_pt, $x_val, $x_unc),
                                              $y_pt, $y_val, $y_unc));
    } else {
      return &pt_subpos($y_pt, $y_val, $y_unc,
             &pt_negate($x_pt, $x_val, $x_unc));
    }
  } else {
    # Both negative
    return &pt_negate(&pt_addpos(&pt_negate($x_pt, $x_val, $x_unc),
                                 &pt_negate($y_pt, $y_val, $y_unc)));
  }
}

# After going to all that work to do addition, subtraction is easy!
sub pt_sub
{
  my($x_pt, $x_val, $x_unc, $m_pt, $m_val, $m_unc) = @_;

  return &pt_add($x_pt, $x_val, $x_unc,
      &pt_negate($m_pt, $m_val, $m_unc));
}

# We define PT versions of pow10 and log10 next, because
# the multiply and divide routines use them to reduce certain cases to adds.

# pt.log10 is very simple, because it's a single function argument and
# there are no strange boundary conditions where we demote or promote.
sub pt_log10
{
  my($x_pt, $x_val, $x_unc) = @_;
  my($ans_pt, $ans_val, $ans_unc);

  # Handle 0 and infinities first
  if (&f_eq($x_val, $g_0)) {
    &dbg1("pt_log10(0): ninf", 32);
    return ($g_pt_inf, $g_ninf, 0);
  } elsif (&ispinf($x_val)) {
    &dbg1("pt_log10(inf): inf", 32);
    return ($g_pt_inf, $g_inf, 0);
  } elsif (&isninf($x_val)) {
    &dbg1("pt_log10(ninf): 0", 32);
    return (0, $g_0, 0);
  } elsif (&isnan($x_val)) {
    &dbg1("pt_log10(nan): nan", 32);
    return ($g_pt_nan, $g_nan, 0);
  }

  if (&f_lt($x_val, $g_0)) {
    # Real component of log of negative number is the log of the magnitude
    $x_val = &f_neg($x_val);
  }

  if ($x_pt == 0) {
    # Call normal log10 function
    $ans_pt = 0;
    $ans_val = &f_log10($x_val);
    # d(log10(u)) = du/(ln(10) u)
    # We don't need to take abs(x_val) because we just made x_val positive.
    $ans_unc = &f64_div($x_unc, $k_ln_10 * $x_val); # &f_div($x_unc, &f_mul($g_ln_10, $x_val));
    return ($ans_pt, $ans_val, $ans_unc);
  }

  # else
  # Just subtract 1 from PT
  $ans_pt = $x_pt - 1;
  $ans_val = $x_val;
  return ($ans_pt, $ans_val, 0);
}

# pt.pow10 is almost as simple as pt.log10, and for similar reasons.
sub pt_pow10
{
  my($x_pt, $x_val, $x_unc) = @_;
  my($ans_pt, $ans_val, $ans_unc);

  # Handle infinities first
  if (&ispinf($x_val)) {
    &dbg1("pt_pow10(inf): inf", 32);
    return ($g_pt_inf, $g_inf, 0);
  } elsif (&isninf($x_val)) {
    &dbg1("pt_pow10(ninf): 0", 32);
    return (0, $g_0, 0);
  } elsif (&isnan($x_val)) {
    &dbg1("pt_pow10(nan): nan", 32);
    return ($g_pt_nan, $g_nan, 0);
  }

  if ($x_pt == 0) {
    # Handle all negative PT0's and any positive PT0's for which
    # the answer is in PT0 range.
    if (&f_lt($x_val, $g_log10_ovr1)) {
      $ans_pt = 0;
      $ans_val = &f_pow10($x_val);
      # d(10^u) = ln(10) 10^u du
      $ans_unc = $k_ln_10 * $ans_val * $x_unc;
      return ($ans_pt, $ans_val, $ans_unc);
    }
  }

  # Now handle negative PT1's, etc. We only have to test $x_val here,
  # because the negative PT0 case was already handled.
  if (&f_lt($x_val, $g_0)) {
    return (0, $g_0, 0);
  }

  # All other cases: simple promote
  $ans_pt = $x_pt + 1;
  $ans_val = $x_val;
  return ($ans_pt, $ans_val, 0);
} # End of pt.pow10

# The multiply routine is implemented fully from primitives, with
# 12 separate cases for all the combinations of PT class of the
# two arguments and the result. It's this way because the
# multiply was implemented before the add, and it is left as-is
# for accuracy and speed.
sub pt_mul
{
  my($px_pt, $px_val, $px_unc, $py_pt, $py_val, $py_unc) = @_;
  my($x_pt, $x_val, $x_unc, $y_pt, $y_val, $y_unc);
  my($xpt, $xv, $xu, $ypt, $yv, $yu);
  my($p1, $d1, $sign);
  my($ans_pt, $ans_val, $ans_unc);

  $x_pt = $px_pt; $y_pt = $py_pt;
  $x_val = $px_val; $y_val = $py_val;
  $x_unc = $px_unc; $y_unc = $py_unc;

  if (&isnan($x_val) || &isnan($y_val)) {
    &dbg1("pt.mul(nan): nan", 32);
    return ($g_pt_nan, $g_nan, 0);
  }

  # Enforce positive arguments and remember sign.
  $sign = $g_1;
  if (&f_lt($x_val, $g_0)) {
    $sign = &f_neg($sign);
    $x_val = &f_neg($x_val);
  }
  if (&f_lt($y_val, $g_0)) {
    $sign = &f_neg($sign);
    $y_val = &f_neg($y_val);
  }

  # Put bigger argument first, so we have fewer cases to handle
  if (&pt_magcompare($x_pt, $x_val, $y_pt, $y_val) > 0) {
    $xpt = $x_pt; $ypt = $y_pt;
    $xv = $x_val; $yv = $y_val;
    $xu = $x_unc; $yu = $y_unc;
  } else {
    $xpt = $y_pt; $ypt = $x_pt;
    $xv = $y_val; $yv = $x_val;
    $xu = $y_unc; $yu = $x_unc;
  }

  if (&f_eq($yv, $g_0) && &f_eq($yu, $g_0)) {
    # don't need to test $ypt because $yv==0 only happens when $ypt==0
    # trivial case
    return (0, $g_0, 0);
  } elsif (&f_eq($xv, $g_inf)) {
         # don't need to test pt field, val==inf only occurs when pt==MAXINT
    if (&f_gt($sign, 0)) {
      return ($g_pt_inf, $g_inf, 0);
    } else {
      return ($g_pt_inf, $g_ninf, 0);
    }
  } elsif ($xpt == 0) {
    # %%% it would be good to avoid the overflow before it happens
    # Simple case: both are plain numbers
    $p1 = &f_mul($xv, $yv);
    &dbg1("pt.mul got: " . $p1, 1);

    if (&f_ge($p1, $g_ovr1)) {
      # Overflowed range of pt0: recompute product as a pt1
      $p1 = &f_add(&f_log10($xv), &f_log10($yv));
      $ans_pt = 1;
      $ans_val = &f_mul($sign, $p1);
      return ($ans_pt, $ans_val, 0);
    } else {
      # It fits in a PT0
      $ans_pt = 0;
      $ans_val = &f_mul($sign, $p1);
      # Product rule: d(uv) = u dv + v du
      # xv and yv are both positive because of sign handling above
      $ans_unc = $xv * $yu + $xu * $yv;
      return ($ans_pt, $ans_val, $ans_unc);
    }
  } elsif (($xpt == 1) && ($ypt == 0)) {
    # X is PT1 and Y is PT0.
    #   We don't worry about promoting to
    # pt2 because that can only happen if X is near {1, 1e300}
    # and if it were, we're calculating log(answer) = 1e100
    # plus log(y), and since log(y) can be no bigger than 300
    # the answer would always be 1e300.
    #   However, we do have to worry about demoting to PT0.
    $p1 = &f_add($xv, &f_log10($yv));
    if (&f_gt($p1, $g_log10_ovr1)) {
      $ans_pt = 1;
      $ans_val = &f_mul($sign, $p1);
      return ($ans_pt, $ans_val, 0);
    } else {
      $ans_pt = 0;
      $ans_val = &f_mul($sign, &f_pow10($p1));
      return ($ans_pt, $ans_val, 0);
    }
  } elsif ($xpt == 1) {
    # Both are PT1's -- just add the logs.
    $d1 = &f_add($xv, $yv);
    if (&f_gt($d1, $g_ovr1)) {
      # Promote to PT2
      $ans_pt = 2;
      $ans_val = &f_mul($sign, &f_log10($d1));
      return ($ans_pt, $ans_val, 0);
    } elsif (&f_gt($d1, $g_log10_ovr1)) {
      $ans_pt = 1;
      $ans_val = &f_mul($sign, $d1);
      return ($ans_pt, $ans_val, 0);
    } else {
      # Demote to PT0
      $ans_pt = 0;
      $ans_val = &f_mul($sign, &f_pow10($d1));
      return ($ans_pt, $ans_val, 0);
    }
  } elsif (($xpt == 2) && ($ypt < 2)) {
    # X is PT2 and Y is PT0 or PT1. The answer is always equal to the larger, which is x.
    $ans_pt = $xpt;
    $ans_val = &f_mul($sign, $xv);
    return ($ans_pt, $ans_val, 0);
  } elsif ($xpt == 2) {
    # Both are PT2's. In this case, the product is equal to the larger
    # except in cases like {2, 312.0} * {2, 308.0} where the two
    # values are within +- scale or so, where we have to do the
    # log(sum(exp(diff))) thing.
    #       inputs:  {2, 312.0} * {2, 308.0}
    #         logs:  312.0, 308.0
    #     subtract:  -4.0
    #      antilog:  0.0001 = 1.0e-4
    #     add to 1:  1.0001
    #          log:  0.000043
    #          add:  312.000043
    # final answer:  {2, 312.000043}
    #
    $d1 = &f_sub($xv, $yv);
    if (&f_lt($d1, ($curscale+3))) {
      # x is a little bigger
      $ans_pt = 2;
      $ans_val = &f_pow10(&f_sub($yv, $xv));
      $ans_val = &f_add($g_1, $ans_val);
      $ans_val = &f_add($xv, &f_log10($ans_val));
      $ans_val = &f_mul($sign, $ans_val);
      return ($ans_pt, $ans_val, 0);
    } else {
      # x is way bigger
      $ans_pt = 2;
      $ans_val = &f_mul($sign, $xv);
      return ($ans_pt, $ans_val, 0);
    }
  } elsif ($xpt > 2) {
    # For anything with X bigger than a PT2, the product is the
    # larger of the two.
    $ans_pt = $xpt;
    $ans_val = &f_mul($sign, $xv);
    return ($ans_pt, $ans_val, 0);
  }

  # default fall-through
  return (0, $g_0, 0);
} # End of pt.mul

sub pt_div
{
  my($an_pt, $an_val, $an_unc, $ad_pt, $ad_val, $ad_unc) = @_;
  my($n_pt, $n_val, $n_unc, $d_pt, $d_val, $d_unc);
  my($ans_pt, $ans_val, $ans_unc);
  my($sign, $p1);

  $n_pt = $an_pt; $d_pt = $ad_pt;
  $n_val = $an_val; $d_val = $ad_val;
  $n_unc = $an_unc; $d_unc = $ad_unc;

  if (&isnan($n_val) || &isnan($d_val)) {
    &dbg1("pt_div(nan/nan) : nan", 32);
    return ($g_pt_nan, $g_nan, 0);
  }

  # Handle divide by zero case first, it's easy
  if ($d_val == 0) {
    &dbg1("pt_div(K/0) : nan", 32);
    return ($g_pt_nan, $g_nan, 0);
  }

  # Enforce positive arguments and remember sign.
  $sign = $g_1;
  if (&f_lt($n_val, $g_0)) {
    $sign = &f_neg($sign);
    $n_val = &f_neg($n_val);
  }
  if (&f_lt($d_val, $g_0)) {
    $sign = &f_neg($sign);
    $d_val = &f_neg($d_val);
  }

  # Deal with infinities.
  if (&isinf($n_val)) {
    if (&f_gt($sign, $g_0)) {
      &dbg1("pt_div(inf/K) : inf", 32);
      return ($g_pt_inf, $g_inf, 0);
    } else {
      &dbg1("pt_div(inf/-K) : ninf", 32);
      return ($g_pt_inf, $g_ninf, 0);
    }
  }

  if (($n_pt == 0) && ($d_pt == 0)) {
    # Simple case: both are plain numbers. Divide and check
    # for promote (which happens when dividing 1e200 by 1e-200,
    # for example)
    $p1 = &f_div($n_val, $d_val);

    if (&f_ge($p1, $g_ovr1)) {
      # Overflowed range of pt0: promote to pt1
      $p1 = &f_sub(&f_log10($n_val), &f_log10($d_val));
      $ans_pt = 1;
      $ans_val = &f_mul($sign, $p1);
      &dbg1("pt_div a got: " . $ans_val, 1);
      return ($ans_pt, $ans_val, 0);
    } else {
      $ans_pt = 0;
      $ans_val = &f_mul($sign, $p1);
      &dbg1("pt_div b got: " . $ans_val . " , d_val $d_val", 1);
      # Quotient rule: d(u/v) = (v du - u dv) / v^2
      #   We add instead of subtracting here, because (unlike a derivative)
      # the uncertainty increases just as much when the numerator and
      # denominator both increase, as it would if one increases while the other
      # decreases.
      #   Use of the abs() function is not needed because $n_val and $d_val
      # were made positive above.
      $ans_unc = &f64_div($d_val * $n_unc + $n_val * $d_unc,
                          &f_mul($d_val, $d_val));
          # &f_div(
          # &f_add(&f_mul($d_val, $n_unc), &f_mul($n_val, $d_unc)),
          # &f_mul($d_val, $d_val));
      return ($ans_pt, $ans_val, $ans_unc);
    }
  } elsif (($n_pt == 1) && ($d_pt == 0)) {
    # Dividing a PT1 by a PT0. Need to check for demote, but promote
    # isn't possible.
    $p1 = &f_sub($n_val, &f_log10($d_val));
    if (&f_lt($p1, $g_log10_ovr1)) {
      $ans_pt = 0;
      $ans_val = &f_mul($sign, &f_pow10($p1));
      return ($ans_pt, $ans_val, 0);
    } else {
      $ans_pt = 1;
      $ans_val = &f_mul($sign, $p1);
      return ($ans_pt, $ans_val, 0);
    }
  } elsif (($n_pt == 0) && ($d_pt == 1)) {
    # Dividing a PT0 by a PT1. If the PT0 is something like 1e200
    # and the PT1 is say 1e305, the answer is 1e-105 which is a
    # valid nonzero PT0. So, we have to compute an answer.
    $p1 = &f_sub(&f_log10($n_val), $d_val);
    $ans_pt = 0;
    $ans_val = &f_mul($sign, &f_pow10($p1));
    return ($ans_pt, $ans_val, 0);
  } elsif (($n_pt == 1) && ($d_pt == 1)) {
    # Both arguments are PT1. Subtract the logs and check for demote.
    $p1 = &f_sub($n_val, $d_val);
    if (&f_lt($p1, $g_log10_ovr1)) {
      # We can demote. The new value should be 10 to the power of the
      # difference p1. We handle two common integer cases to avoid doing an
      # inexact pow10. %%% I'd rather do this inside f_pow10 but I want to
      # think about it first.
      $ans_pt = 0;
      if (&simple_int($p1, $curscale)) {
        if ($p1 < $curscale) {
          $p1 = '1' . ('0' x $p1);
        } else {
          $p1 = '1e' . int($p1);
        }
      } else {
        $p1 = &f_pow10($p1);
      }
    } else {
      $ans_pt = 1;
    }
    $ans_val = &f_mul($sign, $p1);
    return ($ans_pt, $ans_val, 0);
  } elsif ($n_pt < $d_pt) {
    # In all the other cases, if the arguments are of different
    # PT types the answer is simple.
    return (0, $g_0, 0);
  } elsif ($n_pt > $d_pt) {
    # In these cases the answer is the numerator.
    # %%% not so - consider 10^10^301 / 10^10^299, should be 10^(9.9x10^300)
    $ans_pt = $n_pt;
    $ans_val = &f_mul($sign, $n_val);
    return ($ans_pt, $ans_val, 0);
  } else {
    # %%% Here's where we need to handle (10^10^1000.2) / (10^10^1000.1)
    # Numerator and denominator of same PT type, PT2 or greater.
    # Ratio uncomputably differs from:
    #     0 if D is of greater magnitude,
    #     N if N is of greater magnitude
    #     1.0 or -1.0 if they are equal.
    if (&f_lt($n_val, $d_val)) {
      return (0, $g_0, 0);
    } elsif (&f_eq($n_val, $d_val)) {
      $ans_pt = 0;
      $ans_val = $sign;
      return ($ans_pt, $ans_val, 0);
    } else {
      $ans_pt = $n_pt;
      $ans_val = &f_mul($sign, $n_val);
      return ($ans_pt, $ans_val, 0);
    }
  }
} # End of pt.div

sub pt_mod
{
  my($an_pt, $an_val, $an_unc, $ad_pt, $ad_val, $ad_unc) = @_;
  my($n_pt, $n_val, $n_unc, $d_pt, $d_val, $d_unc);
  my($sign, $p1, $p2, $p3, $p4, $p5, $p6);

  &dbg1("pt.mod |$an_pt|$an_val|$an_unc| % |$ad_pt|$ad_val|$ad_unc|", 32);

  $n_pt = $an_pt; $d_pt = $ad_pt;
  $n_val = $an_val; $d_val = $ad_val;
  $n_unc = $an_unc; $d_unc = $ad_unc;

  if (&isnan($n_val) || &isnan($d_val)) {
    &dbg1("pt.mod(nan/nan) : nan", 32);
    return ($g_pt_nan, $g_nan, 0);
  }

  # Handle divide by zero case first, it's easy
  if ($d_val == 0) {
    &dbg1("pt.mod(K/0) : nan", 32);
    return ($g_pt_nan, $g_nan, 0);
  }

  # Enforce positive arguments and remember sign.
  $sign = $g_1;
  if (&f_lt($n_val, $g_0)) {
    $sign = &f_neg($sign);
    $n_val = &f_neg($n_val);
  }
  if (&f_lt($d_val, $g_0)) {
    &dbg1("pt.mod(n%-K) : 0", 32);
    return (0, 0, 0);
  }

  # Deal with infinities.
  if (&isinf($n_val)) {
    &dbg1("pt.mod(inf%d) : 0", 32);
    return (0, 0, 0);
  } elsif (&isinf($d_val)) {
    &dbg1("pt.mod(n%inf) : 0", 32);
    return ($n_pt, $n_val, $n_unc);
  }

  if ($n_pt > 0) {
    &dbg1("pt.mod(pt1%d) : 0", 32);
    return (0, 0, 0);
  }

  if ($d_pt > 0) {
    &dbg1("pt.mod(n%pt1) : 0", 32);
    return (0, 0, 0);
  }

  if (!(&simple_int($n_val, $curscale))) {
    &dbg1("pt.mod(nonint%d) : 0", 32);
    return (0, 0, 0);
  }

  if (!(&simple_int($d_val, $curscale))) {
    &dbg1("pt.mod(n%nonint) : 0", 32);
    return (0, 0, 0);
  }

  $p1 = &f_div($n_val, $d_val);
  &dbg1("pt.mod p1 = $p1", 32);
  if ($p1 =~ m/^(\d+)/) {
    $p2 = $1;
    &dbg1("pt.mod p2a = $p2", 32);
  } elsif ($p1 =~ m/^\+(\d+)\.\d+E0$/) {
    $p2 = $1;
    &dbg1("pt.mod p2b = $p2", 32);
  } else {
    &dbg1("pt.mod(n/d) got '$p1' : 0", 32);
    return (0, 0, 0);
  }
  $p3 = &f_mul($p2, $d_val);
  &dbg1("pt.mod p3 = $p3", 32);
  if (!(&simple_int($p3, $curscale))) {
    &dbg1("pt.mod(n/d) n/d*d not int : 0", 32);
    return (0, 0, 0);
  }
  $p4 = &f_sub($n_val, $p3);
  &dbg1("pt.mod p4 = $p4", 32);

  $p5 = &f_add($p4, 0.5);
  &dbg1("pt.mod p5 = $p5", 32);
  if ($p5 =~ m/^\+?(\d+)/) {
    $p5 = $1;
  } else {
    &dbg1("pt.mod(n/d) n-(n/d*d) not int : 0", 32);
    return (0, 0, 0);
  }
  $p6 = &f_mul($sign, $p5);
  &dbg1("pt.mod -> $p6", 32);
  return(0, $p6, 0);
} # End of pt.mod

$unused1 = q|
# The Palm version of Hypercalc had a percent key, which multiplied an
# argument by a given percentage. For example, with inputs (12,50) it
# returns 6 because that's 50% of 12.
pt_real pt_percent(pt_real p, pt_real x)
{
  my($ans_pt, $ans_val);
  pt_real  ans;

  $ans_pt = 0;
  $ans_val = 100.0;

  ans = &pt_div(p, ans);
  ans = &pt_mul(ans, x, 0);

  return ($ans_pt, $ans_val);
}
|;

sub pt_exp
{
  my($x_pt, $x_val, $x_unc) = @_;
  my($ans_pt, $ans_val, $ans_unc);
  my($l1);

  # Handle infinities first
  if (&ispinf($x_val)) {
    &dbg1("pt_exp(inf): inf", 32);
    return ($g_pt_inf, $g_inf, 0);
  } elsif (&isninf($x_val)) {
    &dbg1("pt_exp(ninf): 0", 32);
    return (0, $g_0, 0);
  } elsif (&isnan($x_val)) {
    &dbg1("pt_exp(nan): nan", 32);
    return ($g_pt_nan, $g_nan, 0);
  }

  if ($x_pt == 0) {
    # There are three cases; the third (involving promotion to PT2)
    # only happens when we're called from pt.gamma with an argument
    # like {0, 7e302}, which is about as high as it will ever get.
    if (&f_lt($x_val, $g_ln_ovr1)) {
      # Simple case: answer is within PT0 range
      $ans_pt = 0;
      $ans_val = &f_exp($x_val);
      # d(e^x) = e^x dx
      $ans_unc = $ans_val * $x_unc; # &f_mul($ans_val, $x_unc);
      return ($ans_pt, $ans_val, $ans_unc);
    } elsif (&f_lt(&f_div($x_val, $g_ln_10), $g_ovr1)) {
      # Promote to PT1
      $ans_pt = 1;
      $ans_val = &f_div($x_val, $g_ln_10);
      return ($ans_pt, $ans_val, 0);
    } else {
      # Promote to PT2
      $ans_pt = 2;
      $ans_val = &f_log10(&f_div($x_val, $g_ln_10));
      return ($ans_pt, $ans_val, 0);
    }
  }

  # Now handle the rest of the negative cases
  if (f_lt($x_val, $g_0)) {
    return (0, $g_0, 0);
  }

  # Now handle positive PT1
  if ($x_pt == 1) {
    # e^(10^X) = 10^(log10(e) * 10^X) = 10^(10^(log10(log10(e)) + X ))
    # X is from:
    #    10^300  -- answer is 10^(10^(300+logloge)) = 10^(10^299.637) = 10^(4.342e299)
    # to
    #    10^(1e300)  -- answer is 10^(10^(10^300+logloge)).
    # Since log10(log10(e)) is negative, we sometimes have to produce
    # a PT1 answer.
    $l1 = &f_add($x_val, $g_log10_log10_e);
    if (&f_lt($l1, $g_log10_ovr1)) {
      $ans_pt = 1;
      $ans_val = &f_mul($g_log10_e, &f_pow10($x_val));
      return ($ans_pt, $ans_val, 0);
    } else {
      return (2, $l1, 0);
    }
  } else {
    # X is PT2 or greater. e^X is uncomputably larger than 10^x, so we
    # just promote to the next higher PT with the same val.
    return ($x_pt + 1, $x_val, 0);
  }

  # default fall-through (never reached)
  return (0, $g_0, 0);
} # End of pt.exp

sub pt_ln
{
  my($x_pt, $x_val, $x_unc) = @_;
  my($l1);
  my($ans_pt, $ans_val, $ans_unc);

  # Handle 0 and infinities first
  if (&isnan($x_val)) {
    &dbg1("pt_ln(nan): nan", 32);
    return ($g_pt_nan, $g_nan, 0);
  } elsif (&f_eq($x_val, $g_0)) {
    &dbg1("pt_ln(0): ninf", 32);
    return ($g_pt_inf, $g_ninf, 0);
  } elsif (&ispinf($x_val)) {
    &dbg1("pt_ln(inf): inf", 32);
    return ($g_pt_inf, $g_inf, 0);
  } elsif (&isninf($x_val)) {
    &dbg1("pt_ln(ninf): 0", 32);
    return (0, $g_0, 0);
  }

  if (&f_lt($x_val, $g_0)) {
    # Real component of log of negative number is the log of the magnitude
    $x_val = &f_neg($x_val);
  }

  if ($x_pt == 0) {
    # Call normal ln function
    $ans_pt = 0;
    $ans_val = &f_ln($x_val);
    # d(ln(u)) = du/u
    # We made x_val non-negative, but need to use f_div because it still
    # might be zero
    $ans_unc = &f64_div($x_unc, $x_val);
    return ($ans_pt, $ans_val, $ans_unc);
  } elsif ($x_pt == 1) {
    # ln(x) = log10(x) / log10(e) = $x_val / log10(e) = $x_val * $g_ln_10
    $l1 = &f_mul($x_val, $g_ln_10);
    if (&f_lt($l1, $g_ovr1)) {
      return (0, $l1, 0);
    } else {
      $ans_pt = 1;
      $ans_val = &f_log10($l1);
      return ($ans_pt, $ans_val, 0);
    }
  } elsif ($x_pt == 2) {
    # Have to subtract log10(log10(e))
    $l1 = &f_sub($x_val, $g_log10_log10_e);
    if (&f_lt($l1, $g_log10_ovr1)) {
      $ans_pt = 0;
      $ans_val = &f_pow10($l1);
      return ($ans_pt, $ans_val, 0);
    } else {
      return (1, $l1, 0);
    }
  } else {
    $ans_pt = $x_pt - 1;
    $ans_val = $x_val;
    return ($ans_pt, $ans_val, 0);
  }
} # End of pt.ln

# A routine that breaks out all the cases explicitly would be a little
# more accurate and a little faster -- but it's not enough to be of
# immediate concern for the usability of the calculator.
sub pt_pow
{
  my($ab_pt, $ab_val, $ab_unc, $ae_pt, $ae_val, $ae_unc) = @_;
  my($b_pt, $b_val, $b_unc, $e_pt, $e_val, $e_unc);
  my($p1, $scal7);
  my($ans_pt, $ans_val);

  &dbg1("pt_pow( $ab_pt:$ab_val($ab_unc) ^ ($ae_pt:$ae_val($ae_unc)) )", 32);

  $b_pt = $ab_pt; $e_pt = $ae_pt;
  $b_val = $ab_val; $e_val = $ae_val;
  $b_unc = $ab_unc; $e_unc = $ae_unc;

  if (&isnan($b_val) || &isnan($e_val)) {
    &dbg1("pt_pow(nan): nan", 32);
    return ($g_pt_nan, $g_nan, 0);
  }

  # Handle 0's, 1's, and infinities first. Some of these are handled
  # quickly as a speed optimization, and others because they're special
  # cases.
  #    Here is a table illustrating the special cases; a total of 19
  # special cases are handled. Any entry that says "." is computed
  # the normal way, but the others are special cases. For the "C*i"
  # cases we actually compute the cosine of the exponent to determine
  # the sign of infinity that should result. The rows/columns labeled
  # -5, -0.5, 0.5 and 5 represent any typical numbers (there is nothing
  # special about -5 -0.5, 0.5 or 5)
  #       +--------------EXPONENT---------------
  #   pow |ninf -5  -1  -0.5 0 0.5   1   5   inf
  # +-----+-------------------------------------
  # |  inf|  0   0   0    0  1 inf  inf inf  inf
  # |    5|  0   .   .    .  1  .    5   .   inf
  # B    1|  1   1   1    1  1  1    1   1    1
  # A  0.5| inf  .   .    .  1  .   0.5  .    0
  # S    0| nan nan nan  nan 1  0    0   0    0
  # E -0.5| inf  .   .    .  1  .  -0.5  .    0
  # |   -1|  1   .   .    .  1  .   -1   .    1
  # |   -5|  0   .   .    .  1  .   -5   .   inf
  # | ninf|  0   0   0    0  1 C*i ninf C*i  inf

  if (&f_eq($e_val, $g_0)) {
    return (0, 1, 0);
  } elsif (&f_eq($b_val, $g_1)) {
    return (0, 1, 0);
  } elsif (&f_eq($e_val, $g_1)) {
    return ($ab_pt, $ab_val, $ab_unc);
  } elsif (&isinf($b_val)) {
    # Don't have to check exponent == 0 because it's already been checked
    if (&f_gt($e_val, $g_0)) {
      &dbg1("pt_pow(inf^X): inf", 32);
      return ($g_pt_inf, $g_inf, 0);
    } else {
      &dbg1("pt_pow(inf^-X): 0", 32);
      return (0, $g_0, 0);
    }
  } elsif (&f_eq($b_val, $g_0)) {
    # Don't have to check exponent == 0 because it's already been checked
    if (&f_gt($e_val, $g_0)) {
      return (0, $g_0, 0);
    } else {
      &dbg1("pt_pow(0^-X): nan", 32);
      return ($g_pt_nan, $g_nan, 0);
    }
  }
  $p1 = &f_mul($b_val, $b_val);
  if (&ispinf($e_val)) {
    if (&f_gt($p1, $g_1)) {
      &dbg1("pt_pow(X^inf): inf", 32);
      return ($g_pt_inf, $g_inf, 0);
    } elsif (&f_eq($p1, $g_1)) {
      &dbg1("pt_pow(1^inf): 1", 32);
      return (0, $g_1, 0);
    } else {
      &dbg1("pt_pow((x<1)^inf): 0", 32);
      return (0, $g_0, 0);
    }
  } elsif (&isninf($e_val)) {
    if (&f_gt($p1, $g_1)) {
      &dbg1("pt_pow(X^ninf): 0", 32);
      return (0, $g_0, 0);
    } elsif (&f_eq($p1, $g_1)) {
      &dbg1("pt_pow(1^ninf): 1", 32);
      return (0, $g_1, 0);
    } else {
      &dbg1("pt_pow((x<1)^ninf): inf", 32);
      return ($g_pt_inf, $g_inf, 0);
    }
  } elsif (&isninf($b_val)) {
    if (&f_lt($e_val, $g_0)) {
      &dbg1("pt_pow(ninf^-x): 0", 32);
      return (0, $g_0, 0);
    } elsif (&f_eq($e_val, $g_1)) {
      &dbg1("pt_pow(ninf^1): ninf", 32);
      return ($g_pt_inf, $g_ninf, 0);
    } elsif (&ispinf($e_val)) {
      &dbg1("pt_pow(ninf^inf): inf", 32);
      return ($g_pt_inf, $g_inf, 0);
    }

    $p1 = &f_cos(&f_mul($e_val, $g_pi));
    if (&f_gt($p1, $g_0)) {
      &dbg1("pt_pow(ninf^X): inf", 32);
      return ($g_pt_inf, $g_inf, 0);
    } elsif (&f_eq($p1, $g_0)) {
      &dbg1("pt_pow(ninf^X): 0", 32);
      return (0, $g_0, 0);
    } else {
      &dbg1("pt_pow(ninf^X): ninf", 32);
      return ($g_pt_inf, $g_ninf, 0);
    }
  }

  # extract sign and scale information
  if (&f_lt($b_val, $g_0)) {
    # raising a negative base to a power
    if ($e_pt == 0) {
      # Compute the real component of the angle
      $scal7 = &f_cos(&f_mul($e_val, $g_pi));
    } else {
      # It'll round off to a multiple of 2pi, so just scale
      # by 1.
      $scal7 = $g_1;
    }
    $b_val = &f_neg($b_val);
  } else {
    $scal7 = $g_1;
  }

  # Now $b_val is positive, so it's okay to take the log of it if we need to.

  if (($b_pt == 0) && ($e_pt == 0)) {
    # Since this is the most common case, we will try to compute it using
    # native operations

    # To avoid overflow we should first compute the log of the answer
    $p1 = &f_mul(&f_log10($b_val), $e_val);
    &dbg1("mul(log10($b_val), $e_val) : $p1", 32);
    if (&f_lt($p1, $g_log10_ovr1)) {
      &dbg1("   -> not overflow", 32);
      # It's safe to compute it for real
      $p1 = f_pow($b_val, $e_val);

      $ans_pt = 0;
      $ans_val = &f_mul($scal7, $p1);
      # d(b^p) = b^p (ln(b) dp + p db/b)
      # b_val is positive but e_val might still be negative
      $ans_unc = $p1 * (log($b_val) * $e_unc
                                      + abs($e_val) * &f_div($b_unc, $b_val));
                # &f_mul($p1,
                #   &f_add(
                #     &f_mul(&f_ln($b_val), $e_unc),
                #     &f_mul($e_val, &f_div($b_unc, $b_val))
                #   )
                # );
      return ($ans_pt, $ans_val, $ans_unc);
    }
    &dbg1("   -> oops, overflow", 32);

    # Overflowed on direct computation, so compute it by logs instead.
    # p1 is still f_mul(f_log10(b_val), e_val)
    if (&f_lt($p1, $g_ovr1)) {
      $ans_pt = 1; # %%% bug here: if scale is small it can bring answer back into PT0 range
      if (&f_eq($scal7, $g_1)) {
        $ans_val = $p1;
      } elsif (&f_gt($scal7, $g_0)) {
        $ans_val = &f_add($p1, &f_log10($scal7));
      } else {
        $ans_val = &f_neg(&f_add($p1, &f_log10(&f_neg($scal7))));
      }
      return ($ans_pt, $ans_val, 0);
    } else {
      # This case happens for e.g. {0, 1e10} to the power of {0, 5e299}
      # The answer is {1, 5e300} which must be promoted to {2, 300.698}
      # The contribution of scale is uncomputable, except for its sign.
      $ans_pt = 2;
      $p1 = &f_log10($p1);
      if (&f_gt($scal7, $g_0)) {
        $ans_val = $p1;
      } else {
        $ans_val = &f_neg($p1);
      }
      return ($ans_pt, $ans_val, 0);
    }
  }

  # For the remaining cases, it seems that we should be able to
  # just use powers and logs.
  ($ans_pt, $ans_val, $ans_unc) = &pt_pow10(
                      &pt_mul(&pt_log10($b_pt, $b_val, $b_unc),
                             $e_pt, $e_val, $e_unc));

  # Factor in the scale.
  # So I can take -1e2000 to the power of 0.25 and it will get 7.07e500
  $b_pt = 0;
  $b_val = $scal7;
  ($ans_pt, $ans_val, $ans_unc) = &pt_mul($ans_pt, $ans_val, $ans_unc,
                                          $b_pt, $b_val, 0);

  return ($ans_pt, $ans_val, $ans_unc);
} # End of pt.pow

# There is a lot of similarity with the pt_pow routine because pt.root
# is just dividing the log by the exponent rather than multiplying.
#
# r-th root of b = pow(b, 1.0 / r)
#    = exp(ln(b) / r)
#    = exp(exp(ln(ln(b)) - ln(r)))
sub pt_root
{
  my($ab_pt, $ab_val, $ab_unc, $ar_pt, $ar_val, $ar_unc) = @_;
  my($ans_pt, $ans_val, $ans_unc);
  my($b_pt, $b_val, $b_unc, $r_pt, $r_val, $r_unc);
  my($p1, $scal8);

  ($b_pt, $b_val, $b_unc, $r_pt, $r_val, $r_unc)
                       = ($ab_pt, $ab_val, $ab_unc, $ar_pt, $ar_val, $ar_unc);

  if (&isnan($b_val) || &isnan($r_val)) {
    &dbg1("pt_root(nan): nan", 32);
    return ($g_pt_nan, $g_nan, 0);
  }

  # Deal with 0th root, which is like raising to the power of infinity
  if (&f_eq($r_val, $g_0)) {
    if (&f_eq($b_val, $g_0)) {
      # 0th root of 0 is 0
      &dbg1("pt_root(0, 0): 0", 32);
      return (0, $g_0, 0);
    } elsif (&f_gt($b_val, $g_n1) && &f_lt($b_val, $g_1)) {
      # 0th root of a number less than 1
      &dbg1("pt_root((x<1), 0): 1", 32);
      return (0, $g_1, 0);
    } else {
      &dbg1("pt_root((x>1), 0): inf", 32);
      return ($g_pt_inf, $g_inf, 0);
    }
  }

  # extract sign and scale information
  if (&f_lt($b_val, $g_0)) {
    if ($r_pt == 0) {
      # We can calculate sin
      $scal8 = &f_cos(&f_div($g_pi, $r_val));
    } else {
      # We're raising to a power that's very very close to 0,
      # so close that the cosine is essentially 1.0
      $scal8 = $g_1;
    }
    $b_val = &f_neg($b_val);
  } else {
    $scal8 = $g_1;
  }

  # Now $b_val is non-negative, so it's okay to take the log of it if we
  # need to.

  if (($b_pt == 0) && ($r_pt == 0)) {
    # Compute the root directly. This will overflow if we're taking say
    # the 0.1th root of 1e100, which is like taking 1e100 to the 10th
    # power.
    $p1 = &f_root($b_val, $r_val);
    if (&f_lt($p1, $g_ovr1)) {
      $ans_pt = 0;
      $ans_val = &f_mul($scal8, $p1);
      # d(b^(1/r)) = b^(1/r) (db / b r - ln(b) dr / r^2)
      $ans_unc = $p1 * (abs($b_unc / ($b_val * $r_val))
                      + abs(&f64_ln($b_val) * $r_unc / ($r_val * $r_val)));
      return ($ans_pt, $ans_val, $ans_unc);
    }

    # Overflowed on direct computation, so compute it by logs instead.
    $p1 = &f_div(&f_log10($b_val), $r_val);
    if (&f_lt($p1, $g_ovr1)) {
      # %%% bug here: if scale is small it can bring answer back into PT0 range
      $ans_pt = 1;
      if (&f_eq($scal8, 1.0)) {
        $ans_val = $p1;
      } elsif (&f_gt($scal8, $g_0)) {
        $ans_val = &f_add($p1, &f_log10($scal8));
      } else {
        $ans_val = &f_neg(&f_add($p1, &f_log10(&f_neg($scal8))));
      }
      return ($ans_pt, $ans_val, 0);
    } else {
      # This case happens when taking e.g. the {0, 2e-300} root of {0, 1e10},
      # which is equivalent to raising {0, 1e10} to the power of {0, 5e299}
      # The answer is {1, 5e300} which must be promoted to {2, 300.698}
      # The contribution of scale is uncomputable, except for its sign.

      $ans_pt = 2;
      $p1 = &f_log10($p1);
      if (&f_gt($scal8, $g_0)) {
        $ans_val = $p1;
      } else {
        $ans_val = &f_neg($p1);
      }
      return ($ans_pt, $ans_val, 0);
    }
  }

  # For the remaining cases, it seems that we should be able to
  # just use powers and logs.
  ($ans_pt, $ans_val, $ans_unc) = &pt_pow10(
                         &pt_div(&pt_log10($b_pt, $b_val, 0),
                                 $r_pt, $r_val, 0));

  # Factor in the scale.
  # So I can take the 4th root of -1e2000 and it will get 7.07e500
  ($ans_pt, $ans_val, $ans_unc) = &pt_mul($ans_pt, $ans_val, $ans_unc,
                                          0, $scal8, 0);

  return ($ans_pt, $ans_val, $ans_unc);
} # end of pt.root

# log base b of n = log(n) / log(b)
#    == pow10(log(log(n)) - log(log(b)))
#
# By the way, this function is a better match for being the analogue of the
# divide function because of the symmetry of the formula for computing it.
sub pt_log_n
{
  my($n_pt, $n_val, $n_unc, $b_pt, $b_val, $b_unc) = @_;
  my($ans_pt, $ans_val, $ans_unc, $bl);

  # Handle 0 and infinities first
  if (&f_eq($n_val, $g_0)) {
    &dbg1("pt_log_n(0): ninf", 32);
    return ($g_pt_inf, $g_ninf, 0);
  } elsif (&ispinf($n_val)) {
    &dbg1("pt_log_n(inf): inf", 32);
    return ($g_pt_inf, $g_inf, 0);
  } elsif (&isninf($n_val)) {
    &dbg1("pt_log_n(ninf): 0", 32);
    return (0, $g_0, 0);
  } elsif (&isnan($n_val) || &isnan($b_val)) {
    &dbg1("pt_log_n(nan): nan", 32);
    return ($g_pt_nan, $g_nan, 0);
  }

  # Real component of log of a negative number is the log of the magnitude
  if (&f_lt($n_val, $g_0)) {
    $n_val = &f_neg($n_val);
  }

  if ($n_pt == 0) {
    if ($b_pt == 0) {
      # Both arguments are PT0. The biggest the answer can possibly be is
      # somewhere around 1.0e19 (which happens when you take the log of 1e300
      # to base 1.0000...001), definitely well within PT0 bounds.
      $ans_pt = 0;
      $ans_val = &f_log_n($n_val, $b_val);
      # diff(ln(n)/ln(b)) = (b ln(b) dn - n ln(n) db) / n b ln(b)^2
      $bl = &f64_ln($b_val);
      $ans_unc = &f64_div(abs($b_val * $n_unc * $bl)
                        + abs($n_val * $b_unc * &f64_ln($n_val))
                  , abs($b_val * $n_val * $bl * $bl));
      return ($ans_pt, $ans_val, $ans_unc);
    }
  }
  # Otherwise we just defer to the primitives.
  # %%% This needs to be changed; right now it only works if b is greater
  # than 0
  return &pt_div(&pt_log10($n_pt, $n_val, $n_unc),
                 &pt_log10($b_pt, $b_val, $b_unc));
} # End of pt.log_n

sub intgam
{
  my($n) = @_;
  my($i, $rv);

  if (!($n =~ m/^\d+$/)) {
    return 0;
  }
  if (($n <= 0) || ($n >= 168)) {
    return 0;
  }
  if ($igv[$n] ne '') {
    return $igv[$n];
  }
  $igv[1] = 1;
  for ($i=2; $i<=$n; $i++) {
    if ($igv[$i] eq '') {
      $igv[$i] = &f_mul($i-1, $igv[$i-1]);
    }
  }
  return $igv[$n];
} # End of int.gam

# t = n - 1
# l = 1/2 ln(2 pi) + (t + 1/2) ln(t) - t + 1/(12 t) - 1/(360 t^3) + ...
# gamma(x) = e^l
#
# %%% Accuracy is not good enough for scale>20. See notes in header.
sub pt_gamma
{
  my($n_pt, $n_val, $n_unc) = @_;
  my($ans_pt, $ans_val, $ans_unc, $t, $l, $l2, $adj, $n2, $np, $u1);

  &dbg1("pt.gamma($n_pt|$n_val|$u_unc)", 32);

  # Handle infinities first
  if (&ispinf($n_val)) {
    &dbg1("pt.gamma(inf): inf", 32);
    return ($g_pt_inf, $g_inf, 0);
  } elsif (&isninf($n_val)) {
    &dbg1("pt.gamma(ninf): 0", 32);
    return (0, $g_0, 0);
  } elsif (&isnan($n_val)) {
    &dbg1("pt.gamma(nan): nan", 32);
    return ($g_pt_nan, $g_nan, 0);
  }

  # Now handle negatives
  if (&f_lt($n_val, $g_0)) {
    if ($n_pt > 0) {
      &dbg1("pt.gamma(-X): inf", 32);
      return ($g_pt_inf, $g_inf, 0);
    } elsif (&simple_nint($n_val, $curscale)) {
      &dbg1("pt.gamma(-int): inf", 32);
      return ($g_pt_inf, $g_inf, 0);
    } else {
      $ans_pt = 0;
      $ans_val = &f_gamma($n_val);
      # The uncertainty calculation is a finite differential rather than
      # an infinitesimal derivative, because it's just too much of a pain
      # to implement the true derivative of gamma
      if (&f_gt($n_unc, $g_0)) {
        $ans_unc = abs($ans_val - &f_gamma($n_val + $n_unc));
      } else {
        $ans_unc = $g_0;
      }
      return ($ans_pt, $ans_val, $ans_unc);
    }
  }

  if ($n_pt == 0) {
   # # Handle integer argument
   # if (&simple_int($n_val, $curscale) && ($n_val >= 0) && ($n_val < 167)) {
   #   $ans_pt = 0;
   #   $ans_val = &intgam($n_val);
   #   &dbg1("pt.gamma($n_val): intgam -> $ans_val", 32);
   #   $ans_unc = $g_0;
   #   return ($ans_pt, $ans_val, $ans_unc);
   # }

    # NOTE: All the following commented-out debugging prints are computing
    # the same things that are now in the set.scale code inside hi.init.
    if (0) {
      my($est1, $nvm1);
      $nvm1 = &f_sub($n_val, "1.0");
      # Calculate size of N^-25 term using this value of N
      print "curscale = $curscale; n_val-1 = $nvm1, gammalim = $g_gammalim\n";
      $est1 = &f_div("657931.0", &f_mul("300.0",
                                 &f_pow($nvm1, "25.0")));
      print "residual at this arg $nvm1: est1 = $est1\n";

      # Calculate size of N^-25 term using $g_gammalim
      $est1 = &f_div("657931.0", &f_mul("300.0",
                                 &f_pow($g_gammalim, "25.0")));
      $est1 = int(&f_neg(&f_log10($est1)));
      print "min digits: $est1\n";

      # Same two calculations with the N^-9 term, which tells us what the
      # error will be if we use the "shorter Stirling" code below.
      #
      $est1 = &f_div("43867.0", &f_mul("244188.0", &f_pow($nvm1, "17.0")));
      print "8-term residual at this arg $nvm1: $est1\n";
      $est1 = &f_div("43867.0", &f_mul("244188.0", &f_pow($g_gammalim, "17.0")));
      print "8-term residual at minarg $g_gammalim: $est1\n";

      # Same two calculations with the N^-9 term, which tells us what the
      # error will be if we use the "shorter Stirling" code below.
      #
      $est1 = &f_div("1.0", &f_mul("1188.0", &f_pow($nvm1, "9.0")));
      print "6-term residual at this arg $nvm1: $est1\n";
      $est1 = &f_div("1.0", &f_mul("1188.0", &f_pow($g_gammalim, "9.0")));
      print "6-term residual at minarg $g_gammalim: $est1\n";
    }

    # Dispatch sufficiently small values to f_gamma
    if (&f_lt($n_val, $g_gammalim)) {
      &dbg1("pt.gamma using f_gamma", 2);
      $ans_pt = 0;
      $ans_val = &f_gamma($n_val);
      # As noted above, finite differential because derivative is too hard
      if (&f_gt($n_unc, $g_0)) {
        $ans_unc = abs($ans_val - &f_gamma($n_val + $n_unc));
      } else {
        $ans_unc = $g_0;
      }
      return ($ans_pt, $ans_val, $ans_unc);
    }

    &dbg1("pt.gamma using shorter Stirling", 2);

    # Start computing terms of log(gamma)
    # The "lower" and "upper" show the range of values we are likely to have
    # Note that n=167 corresponds to the factorial of 166 and 166!=9e297
    #                           lower           upper
    $t = &f_sub($n_val, $g_1);  # 166.0           1.0e300
    $l = $g_05_ln_2pi;          #       0.918938533...

    &dbg1("pt.gamma: 1  $l", 2);

    $l = &f_add($l, &f_mul(&f_add($t, $g_0_5), &f_ln($t)));
                                # 852.0649...     6.907e302

    &dbg1("pt.gamma: 2  $l", 2);

    $l = &f_sub($l, $t);        # 686.0649...     6.897e302

    &dbg1("pt.gamma: 3  $l", 2);

    $n2 = &f_mul($t, $t);
    $np = $t;
    $lm = &f_mul($g_12, $np);
    &dbg1("pt.gamma: term 4 lm = $lm", 2);
    $adj = &f_div($g_1, $lm);
                                # 5.02e-4         0.0
    $l2 = &f_add($l, $adj);
    if (&f_eq($l2, $l)) {
      # We're so big that the first 3 terms are enough. So, we're ready to
      # call exp! (This happens when n is bigger than about 1.0e7)
      return &pt_exp(0, $l, 0);
    }

    &dbg1("pt.gamma more Stirling", 2);

    # No, keep going for a while...
    $l = $l2;
    &dbg1("pt.gamma: 4  $l", 2);

    $np = &f_mul($np, $n2);
    $lm = &f_mul($g_360, $np);
    &dbg1("pt.gamma: term 5 lm = $lm", 2);
    $adj = &f_div($g_1, $lm);
                                # 6.0e-10         0.0
    $l2 = &f_sub($l, $adj);
    if (&f_eq($l2, $l)) {
      # For values of n greater than about 1e4, this is as
      # far as we need to go.
      return &pt_exp(0, $l, 0);
    }

    &dbg1("pt.gamma 3 more Stirling", 2);

    # Alright, add in 3 more terms (the most it would ever take)
    # and then call exp.
    $l = $l2;
    &dbg1("pt.gamma: 5  $l", 2);

    $np = &f_mul($np, $n2);
    $lm = &f_mul($g_1260, $np);
    &dbg1("pt.gamma: term 6 lm = $lm", 2);
    $lt = &f_div($g_1, $lm);
    &dbg1("pt.gamma: term 6 = $lt", 2);
    $l = &f_add($l, $lt);
    &dbg1("pt.gamma: 6  $l", 2);
    $np = &f_mul($np, $n2);
    $lm = &f_mul($g_1680, $np);
    &dbg1("pt.gamma: term 6 lm = $lm", 2);
    $lt = &f_div($g_1, $lm);
    &dbg1("pt.gamma: term 7 = $lt", 2);
    $l = &f_sub($l, $lt);
    &dbg1("pt.gamma: 7  $l", 2);

    return &pt_exp(0, $l, 0);
  } elsif ($n_pt == 1) {
    # N is PT1.
    # The t = n+1 is irrelevant now, as are other similar additive
    # elements of the formula, so the formula reduces to
    # l = n ln(n) - n, gamma(x) = e^l
    # We convert this to l = n (ln(n) - 1) because otherwise the
    # error in the subtract would dominate.
    # There's enough robustness in pt.exp and the other pt_ops
    # that we can do the calculations directly.

    #                               lower            upper
    $ans_pt = $n_pt;                # 1.0e300          10^(1.0e300)
    $ans_val = $n_val;

    ($ans_pt, $ans_val, $u1)
      = &pt_ln($ans_pt, $ans_val, 0);# 690.775          2.302e300

    # Notice: n ln(n) would be      6.90775e302      10^(1.0e300)
    # and n ln(n) - n would be      6.89775e302      0.0!

    ($ans_pt, $ans_val, $u1)
      = &pt_sub($ans_pt, $ans_val, 0,
                 0, $g_1, 0);       # 689.775          2.302e300

    ($ans_pt, $ans_val)
      = &pt_mul($n_pt, $n_val, 0,
          $ans_pt, $ans_val, 0);    # 6.89775e302      10^(1.0e300)

    return &pt_exp($ans_pt, $ans_val, 0);
  } else {
    # N is PT2 or higher.
    # As seen in the upper limit case of the PT1 code above,
    # for sufficiently large values gamma(n) reduces to pt.exp(n).
    return &pt_exp($n_pt, $n_val, 0);
  }
} # End of pt.gamma

# sqrt is done differently from pow(x, 0.5) because there is a builtin
# sqrt routine (which is faster) and because sqrt of a negative number
# should have a real component of exactly 0.
sub pt_sqrt
{
  my($x_pt, $x_val, $x_unc) = @_;
  my($ans_pt, $ans_val, $ans_unc, $v1);

  if (&isnan($x_val)) {
    &dbg1("pt_sqrt(nan): nan", 32);
    return ($g_pt_nan, $g_nan, 0);
  }

  # First handle negatives (including negative infinity), 'cause they're easy
  # The square root of any negative quantity is imaginary, i.e. the real
  # component is zero
  if (&f_le($x_val, $g_0)) {
    return (0, $g_0, 0);
  }

  # Handle infinity
  if (&ispinf($x_val)) {
    &dbg1("pt_sqrt(inf): inf", 32);
    return ($g_pt_inf, $g_inf, 0);
  }

  if ($x_pt == 0) {
    # X is PT0, just call normal square root routine.
    $ans_val = &f_sqrt($x_val);
    # d(sqrt(u)) = du / 2 sqrt(u)
    $ans_unc = &f64_div($x_unc, 2.0 * $ans_val);
      # &f_div($x_unc, &f_mul($g_2, $ans_val));
    return (0, $ans_val, $ans_unc);
  } elsif ($x_pt == 1) {
    # X is PT1. Divide value by 2 and check for demote.
    $v1 = &f_div($x_val, $g_2);
    if (&f_lt($v1, $g_log10_ovr1)) {
      # demote to PT0
      return (0, &f_pow10($v1), 0);
    } else {
      return (1, $v1, 0);
    }
  } elsif ($x_pt == 2) {
    # X is PT2. Subtract log of 2 and check for demote.
    $v1 = &f_sub($x_val, $g_log10_2);
    if (&f_lt($v1, $g_log10_ovr1)) {
      # demote to PT1
      return (1, &f_pow10($v1), 0);
    } else {
      return (2, $v1, 0);
    }
  }

  # else

  # X is PT3 or higher. Square root is uncomputably smaller.
  return ($x_pt, $x_val, 0);
} # End of pt_sqrt

# Sine and cosine are very simple.
sub pt_sin
{
  my($x_pt, $x_val, $x_unc) = @_;
  my($ans_unc);

  if (&isnan($x_val)) {
    &dbg1("pt_sin(nan): nan", 32);
    return ($g_pt_nan, $g_nan, 0);
  }

  if ($x_pt == 0) {
    # X is PT0, just call normal sine routine.
    $ans_unc = abs(cos($x_val)) * $x_unc;
    return (0, &f_sin($x_val), $ans_unc);
  }
  # else, X is too big for us to calculate the sine accurately, just return 0
  return (0, 0, 0);
}

sub pt_cos
{
  my($x_pt, $x_val, $x_unc) = @_;
  my($ans_unc);

  if (&isnan($x_val)) {
    &dbg1("pt_cos(nan): nan", 32);
    return ($g_pt_nan, $g_nan, 0);
  }

  if ($x_pt == 0) {
    # X is PT0, just call normal cosine routine.
    $ans_unc = abs(sin($x_val)) * $x_unc;
    return (0, &f_cos($x_val), $ans_unc);
  }
  # else, X is too big, just return 0
  return (0, 0, 0);
}

sub pt_tan
{
  my($x_pt, $x_val, $x_unc) = @_;
  my($ans_unc, $v1);

  if (&isnan($x_val)) {
    &dbg1("pt_tan(nan): nan", 32);
    return ($g_pt_nan, $g_nan, 0);
  }

  if ($x_pt == 0) {
    # X is PT0, just call normal tangent routine.
    # d(tan(u)) = sec^2(u) du    { where sec(x) = 1/cos(x) }
    $v1 = cos($x_val);
    $ans_unc = $x_unc / ($v1 * $v1);
    return (0, &f_tan($x_val), $ans_unc);
  }
  # else, X is too big, just return 0
  return (0, 0, 0);
} # End of pt.tan

$unused1 = q|
# sinh(x) = (e^x - e^-x) / 2
# outside [-40..40] this reduces to - e^-x / 2 or e^x / 2
# and for PT1 and higher arguments it's just - e^-x (negative argument) or e^x
pt_real pt_sinh(pt_real x)
{
  my($x_pt, $x_val) = @_;
  return &pt_div(&pt_sub(&pt_exp(x), &pt_exp(&pt_negate(x))), (0, 2));
}

# cosh(x) = (e^x + e^-x) / 2
pt_real pt_cosh(pt_real x)
{
  my($x_pt, $x_val) = @_;
  return &pt_div(&pt_add(&pt_exp(x), &pt_exp(&pt_negate(x))), (0, 2));
}

# tanh(x) = (e^2x - 1) / (e^2x + 1). Outside the PT0 range it's always
# 1.0 or -1.0
sub pt_tanh
{
  my($x_pt, $x_val) = @_;
  my($ans_pt, $ans_val);
  my($e2x);

  # All PT1's and higher and PT0's outside the range [-20..20] have a tanh
  # of -1 or 1.
  if (&f_lt($x_val, -20.0)) {
    return (0, $g_n1);
  } elsif (&f_gt($x_val, 20.0)) {
    return (0, $g_1);
  }

  # For the remaining values, we compute the function. The e^2x part is
  # used twice in the formula for tanh. The answer is always PT0.
  $e2x = &f_exp(&f_mul($g_2, $x_val));
  $ans_pt = 0;
  $ans_val = ($e2x - 1.0) / ($e2x + 1.0);
  return ($ans_pt, $ans_val);
}

# arcsinh(x) = ln(x + sqrt(X^2 + 1))
pt_real pt_arcsinh(pt_real x)
{
  my($x_pt, $x_val) = @_;

  # Since we'd have to handle all the PT's separately and since arcsinh
  # isn't used that much, we just don't bother to implement this function
  # with discrete code.
  return &pt_ln(&pt_add(x, &pt_sqrt(&pt_add(&pt_mul(x, x), (0, 1)))));
}

# arccosh(x) = ln(x + sqrt(X^2 - 1))
# undefined if argument is less than 1
pt_real pt_arccosh(pt_real x)
{
  my($x_pt, $x_val) = @_;

  if ($x_val < 1.0) { # catches all negative PTs as well
    return (0, 0);
  }

  # We don't use discrete code for same reason as with arcsinh.
  return &pt_ln(&pt_add(x, &pt_sqrt(&pt_sub(&pt_mul(x, x), (0, 1)))));
}

# arctanh(x) = 1/2 ln((-x-1) / (x-1))
# undefined outside [-1, 1]
sub pt_arctanh
{
  my($x_pt, $x_val) = @_;
  my($ans_pt, $ans_val);

  if ($x_val < -1.0) {  # automatically catches negative PT1's etc.
    return (0, 0);
  } elsif ($x_val > 1.0) {  # automatically catches PT1's etc.
    return (0, 0);
  }

  # The answer is always a PT0, because the biggest ratio we can have
  # is approximately 1::2^54 (i.e. the precision ratio)
  $ans_pt = 0;
  $ans_val = &f_ln((-$x_val - 1.0) / ($x_val - 1.0)) / 2.0;
  return ($ans_pt, $ans_val);
}

pt_real pt_arcsin(pt_real x)
{
  my($x_pt, $x_val) = @_;
  my($ans_pt, $ans_val);

  if ($x_pt > 0) {
    return (0, 0);
  }

  $ans_pt = 0;
  $ans_val = f_arcsin($x_val);

  return ($ans_pt, $ans_val);
}

pt_real pt_arccos(pt_real x)
{
  my($x_pt, $x_val) = @_;
  my($ans_pt, $ans_val);

  if ($x_pt > 0) {
    return (0, 0);
  }

  $ans_pt = 0;
  $ans_val = f_arccos($x_val);

  return ($ans_pt, $ans_val);
}
|;

# %%% Arctan doesn't do uncertainty yet
sub pt_arctan
{
  my($x_pt, $x_val) = @_;
  my($ans_pt, $ans_val);

  if (&isnan($x_val)) {
    &dbg1("pt_arctan(nan): nan", 32);
    return ($g_pt_nan, $g_nan, 0);
  }

  if (&f_eq($x_val, $g_0)) {
    return (0, $g_0);
  } elsif (&f_gt($x_pt, $g_0)) {
    $ans_pt = 0;
    if (&f_gt($x_val, $g_0)) {
      $ans_val = &f_div($g_pi, $g_2);
    } else {
      $ans_val = &f_div($g_pi, $g_n2);
    }
    return ($ans_pt, $ans_val);
  }

  $ans_pt = 0;
  $ans_val = &f_arctan($x_val);

  return ($ans_pt, $ans_val);
} # End of pt.arctan

# Perform rounding of e.g. "234.999992742" or "235.000007232" to "235",
# by adding an amount that is bug enough to make the 999's turn to 000's,
# but small enough so the resulting erroneous digits all get truncated.
# %%% This routine is only used by prnt1(), which only does the truncation
# in one place, so perhaps the code should be moved there.
sub pt_roundup
{
  my($x_pt, $x_val) = @_;
  my($a_val, $ptsave, $u1);

  &dbg1("pt.roundup($x_pt, $x_val)", 32);

  if (&isnan($x_val) || &isinf($x_val)) {
    &dbg1("pt.roundup(nan): nan", 32);
    return ($x_pt, $x_val);
  }

  if (&simple_int($x_val, $curscale)) {
    &dbg1("pt.roundup(integer)", 32);
    return ($x_pt, $x_val);
  }

  if ($doround) {
    # Temporarily coerce to PT0
    $ptsave = $x_pt;
    $x_pt = 0;

    # Calculate adjust amount. This is a cheat -- it correctly accounts for
    # sign but does not set proper rounding amount for round-to-nearest.
    # It should actually be sign(x_val) * 0.5 * 10^(x_exponent - curscale)
    $a_val = &f_mul($x_val, $roundprec);

    ($x_pt, $x_val, $u1) = &pt_add($x_pt, $x_val, 0, 0, $a_val, 0);

    # Add the saved PT back in (because the roundup might have increased
    # the PT)
    $x_pt += $ptsave;
  }

  return($x_pt, $x_val);
} # End of pt.roundup

# addfunc: new functions can go here



#------------------------------------------------- hypercalc.c



# comment for the Pilot version:
# f8_decomp1 takes a double and returns its sign, mantissa and exponent
# as separate quantities (integer, double, integer respectively). It is
# used for output formatting.

# test patterns
$unused1 = q@

-20 ^ 238.4999999999    -- currently gives 6.2e300 as a PT1. Don't know
what it *should* give, there's a lot of error because the complex
vector is close to the imaginary axis.

0.0001 * (10^151 * 10^151)  -- Should give 1e298, as a PT0 not PT1

-- for testing formatting of small numbers in stack display
E ^ 30
E ^ 300
E ^ 3e3
E ^ 3e4
E ^ 3e5

E^(E^30)
E^(E^300)
E^(E^3e3)
E^(E^3e4)
E^(E^3e5)

E^(E^(E^30))
E^(E^(E^300))
E^(E^(E^3e3))
E^(E^(E^3e4))
E^(E^(E^3e5))

E^(E^(E^(E^30)))
(etc...)

A simple "iterative" way to keep generating larger values (for display
testing) is to repeat "%^ln(%)" over and over again.

-1*10^1e200        -- should give -1e2000
   4 root %        -- should give 7.07e500

1e10 ^ 5e299       -- should give 10^(5e300) as a PT2

20 ^ 238.4999999999  -- should give 1.975e310
-20 ^ 238.49999999999   -- should give 6.2e299, as a PT0 (NOT a PT1)

-- for testing infinities
1 ent 0 /          -- should give Infinity
2 ent 1 logxY      -- should give Infinity
0 ent 1 logxY      -- could give -Infinity or Infinity, I don't care which
1 ent 0 / 1 x      -- Infinity times 1 should be infinity

20 ent E299 x eX   -- should give approx. 10^(10^300)
  lnx              -- should give 2e300
e200 eX +- eX      -- should give 0

scale = 120
27^(10^1e100)      -- should give 2 PT 1.000...000155e100, with about 103 zeros

scale=50
5^2*4   - gives 9.9999999, etc. Should round up and increment exponent

#Non-Intuitive Results When Working With Huge Numbers#

If you spend a while exploring the ranges of huge numbers HyperCalc
can handle, you will probably start noticing some paradoxical results
and might even start to think the calculator is giving wrong answers.

For example, try calculating 27 to the power of *googolplex* (a
googolplex is 10 to the power of *googol* and a googol is
10^{100}). Key in:

    27^(10^(10^100))

and it prints

    10^(10^(1.00 x 10^100))

so the calculator thinks that

    27^(10^(10^100))  =  10^(10^(10^100))

This is clearly wrong -- and it doesn't even seem to be a good
approximation. What's going on?

Let's try calculating the correct answer ourselves.  We need to
express the answer as 10 to the power of 10 to the power of something,
because that's the standard format the calculator is using, and we're
going to see how much of an error it made. So, we want to compute

      27^{10^{10^{100}}}

as a tower of powers of 10. The first step is express the power of 27
as a power of 10 with a product in the exponent, using the formula
x^{y} = 10^{(log(x) ^{.} y)} :

      27^{10^{10^{100}}} = 10^{(logv{10}27 ^{.} 10^{10^{100}})}

logv{10}27 is about 1.43, so we have

      27^{10^{10^{100}}} = 10^{1.43 ^{.} 10^{10^{100}}}

Now we have a base of 10 but the exponent still needs work.  The next
step is to express the product as a sum in the next-higher exponent;
this time the formula we use is x ^{.} y = 10^{(log(x) + log(y))} :

      10^{1.43 ^{.} 10^{10^{100}}} = 10^{10^{(logv{10}1.43 + 10^{100})}}

logv{10}1.43 is about 0.155, and if we add this to 10^{100} we get

      10^{10^{(0.155 + 10^{100})}}
                    = 10^{10^{1000...000.155}}
                    = 10^{10^{(1.000...000155 ^{.} 10^{100})}}

where there are 94 more 0's in place of each of the "...". So our
final answer is:

      27^{10^{10^{100}}} = 10^{10^{(1.000...000155 ^{.} 10^{100})}}

Now that we've expressed the value of 27^*googolplex* precisely enough
to see the calculator's error -- look how small the error is!  The
calculator would need to have at least 104 digits of precision to be
able to handle the value "1.000...000155" accurately -- but it only
has 16 digits of accuracy.  Those 16 digits are taken up by the 1 and
the first 15 0's -- so when the calculator gets to the step where
we're adding 0.155 to 1.0^{.}10^{100}, it just rounds off the answer
to 1.0^{.}10^{100} -- and produces the answer we saw when we performed
the calculation:

                        10^(10^(1.00 x 10^{100}))

Even if it did have the precision, it wouldn't have room to print the
whole 104 digits on the screen, so the answer you *see* would look the
same. And no matter how many digits of accuracy we try to give the
calculator, there's always another even bigger number it wouldn't be
able to handle. For example, the calculator would need slightly over a
*million* digits of accuracy to distinguish

      27^{10^{10^{1000000}}}  from  10^{10^{10^{1000000}}}

and if we just add one more #10# to that tower of exponents, all hope
of avoiding roundoff is lost.


# 2^(2^(2+27)) = 2.048696 * 10^161614248


*/

more tests:

To check each of the special cases in output formatting:
  143^143
  %!
  %!
  %!

  143!
  %!
  %!
  %!

to check promotion of inlines:
  10^23e456

@;



#----------------------------------------------- "p_" routines
#
# each of these routines does the same thing -- converts one
# or two arguments in string PT format to separate PT and VAL values,
# then calls the corresponding "pt_" routine, then converts
# the answer back to string PT format.
#

sub define_ir
{
  my($pt, $val, $unc, $lvalue_key) = @_;

  $ir_n++;
  $ir_pt[$ir_n] = $pt; $ir_val[$ir_n] = $val; $ir_unc[$ir_n] = $unc;
  $ir_lvk[$ir_n] = $lvalue_key;

  &dbg1("I$ir_n := $pt PT $val($unc)", 2);

  return "I$ir_n";
} # End of define.ir

sub define_R_hist
{
  my($pt, $val, $unc) = @_;

  $h_n++;
  $h_pt[$h_n] = $pt; $h_val[$h_n] = $val; $h_unc[$h_n] = $unc;

  &dbg1("R$h_n := $pt PT $val($unc)", 2);

  return "R$h_n";
}

sub p_add
{
  my($x, $y) = @_;
  my($x_pt, $x_val, $x_unc, $y_pt, $y_val, $y_unc);

  ($x_pt, $x_val, $x_unc) = &splt($x);
  ($y_pt, $y_val, $y_unc) = &splt($y);

  ($x_pt, $x_val, $x_unc) = &pt_add($x_pt, $x_val, $x_unc,
                                    $y_pt, $y_val, $y_unc);

  return &define_ir($x_pt, $x_val, $x_unc, '');
} # End of p.add

sub p_sub
{
  my($x, $y) = @_;
  my($x_pt, $x_val, $x_unc, $y_pt, $y_val, $y_unc);

# print "p_sub $x $y\n";

  ($x_pt, $x_val, $x_unc) = &splt($x);
  ($y_pt, $y_val, $y_unc) = &splt($y);

  ($x_pt, $x_val, $x_unc) = &pt_sub($x_pt, $x_val, $x_unc,
                                    $y_pt, $y_val, $y_unc);

  return &define_ir($x_pt, $x_val, $x_unc, '');
} # End of p.sub

# This currently ignores uncertainty; if we wanted to handle uncertainty
# we would have to decide what to do when the result of a comparison is
# inconclusive (when comparing overlapping ranges). Alternatively, <= could
# be defined as in: Bohlender, Gerd, and Ulrich Kulisch. "Definition of
# the Arithmetic Operations and Comparison Relations for an Interval
# Arithmetic Standard." Reliable Computing 15 (2011): 37. which effectively
# considers either of a>=b and a<=b to be true unless one interval is a
# proper subset of the other.
sub p_op_compare
{
  my($op, $x, $y) = @_;
  my($x_pt, $x_val, $x_unc, $y_pt, $y_val, $y_unc);
  my($rv, $x_lvk, $y_lvk);

  &dbg1("p.op_compare $x $op $y", 32);
  ($x_pt, $x_val, $x_unc, $x_lvk) = &splt($x);
  ($y_pt, $y_val, $y_unc) = &splt($y);

  $rv = &pt_compare($x_pt, $x_val,  $y_pt, $y_val);
  # print "$x <=> $y == $rv\n";

  if ( (($op eq '<') && ($rv < 0))
    || (($op eq '<=') && ($rv <= 0)) # less or equal
    || (($op eq '>') && ($rv > 0))
    || (($op eq '>=') && ($rv >= 0)) # greater or equal
    || (($op eq '<>') && ($rv != 0)) # less or greater, i.e. not equal
    || (($op eq '==') && ($rv == 0)) # equal (official Hypercalc syntax)
    || (($op eq '=') && ($rv == 0))  # equal (BASIC compatibility syntax)
  ) {
    $rv = 1;
  } else {
    $rv = 0;
  }

  # Set globals to indicate lvalue and assignment values, to be used by
  # eval.2
  $poc_isassign = 0;
  if ($op eq '=') {
    # possible assignment (if left side is an lvalue)
    if ($x_lvk ne '') {
      # This comparison could be interpreted as an assignment operator.
      # We'll remember the lvalue's variable name (key) and the right
      # side's pt/val/unc tuple
      $poc_isassign = 1;
      $poc_lvk = $x_lvk;
      $poc_rv_pt = $y_pt;
      $poc_rv_val = $y_val;
      $poc_rv_unc = $y_unc;
&dbg1("p_oc1 vars[$poc_lvk] := ($poc_rv_pt, $poc_rv_val, $poc_rv_unc)", 2);
    }
  }

  return &define_ir(0, $rv, 0, '');
} # End of p.op_compare

# Boolean AND. This is really a bitwise operation that only works on
# integer arguments, but meant to be used only on results from
# p.op_compare.
sub p_and
{
  my($x, $y) = @_;
  my($x_pt, $x_val, $x_unc, $y_pt, $y_val, $y_unc, $r);

  ($x_pt, $x_val, $x_unc) = &splt($x);
  ($y_pt, $y_val, $y_unc) = &splt($y);
  $r = ($x_val + 0) & ($y_val + 0);
  return &define_ir(0, $r, 0, '');
} # End of p.and

# Boolean OR, just as limited as p.and
sub p_or
{
  my($x, $y) = @_;
  my($x_pt, $x_val, $x_unc, $y_pt, $y_val, $y_unc, $r);

  ($x_pt, $x_val, $x_unc) = &splt($x);
  ($y_pt, $y_val, $y_unc) = &splt($y);
  $r = ($x_val + 0) | ($y_val + 0);
  return &define_ir(0, $r, 0, '');
} # End of p.or

# Boolean NOT. The same limitations apply as for p.and; also the result
# is always 0 or 1 so it is not useful as a bitwise (1's complement)
# operation.
sub p_not
{
  my($x) = @_;
  my($x_pt, $x_val, $x_unc, $r);

  ($x_pt, $x_val, $x_unc) = &splt($x);
  $r = ($x_val + 0) ? 0 : 1;
  return &define_ir(0, $r, 0, '');
} # End of p.not

# Integer-argument random number function. For compatibility with old BASICS
# if the argument is 0, it gives a real number in the range [0,1). Larger
# arguments give an integer result, for example rnd(6) picks an integer in
# [0..5].
sub p_rnd
{
  my($x) = @_;
  my($x_pt, $x_val, $x_unc, $r);

  ($x_pt, $x_val, $x_unc) = &splt($x);
  $r = int($x_val + 0);
  if ($r <= 0) {
    $r = rand(1.0);
  } else {
    $r = int(rand($r));
  }
  return &define_ir(0, $r, 0, '');
} # End of p.rnd

# Entry point for modulo
sub p_mod
{
  my($x, $y) = @_;
  my($x_pt, $x_val, $x_unc, $y_pt, $y_val, $y_unc);

  &dbg1("p_mod1 '$x' % '$y'", 32);

  ($x_pt, $x_val, $x_unc) = &splt($x);
  ($y_pt, $y_val, $y_unc) = &splt($y);

  &dbg1("p_mod2 ($x_pt, $x_val, $x_unc) % ($y_pt, $y_val, $y_unc)", 32);

  ($x_pt, $x_val, $x_unc) = &pt_mod($x_pt, $x_val, $x_unc,
                                    $y_pt, $y_val, $y_unc);

  return &define_ir($x_pt, $x_val, $x_unc, '');
} # End of p.mod

# Entry point for multiply
sub p_mul
{
  my($x, $y) = @_;
  my($x_pt, $x_val, $x_unc, $y_pt, $y_val, $y_unc);

  &dbg1("p_mul1 '$x' * '$y'", 32);

  ($x_pt, $x_val, $x_unc) = &splt($x);
  ($y_pt, $y_val, $y_unc) = &splt($y);

  &dbg1("p_mul2 ($x_pt, $x_val, $x_unc) * ($y_pt, $y_val, $y_unc)", 32);

  ($x_pt, $x_val, $x_unc) = &pt_mul($x_pt, $x_val, $x_unc,
                                    $y_pt, $y_val, $y_unc);

  return &define_ir($x_pt, $x_val, $x_unc, '');
} # End of p.mul

sub p_div
{
  my($x, $y) = @_;
  my($x_pt, $x_val, $x_unc, $y_pt, $y_val, $y_unc);

  ($x_pt, $x_val, $x_unc) = &splt($x);
  ($y_pt, $y_val, $y_unc) = &splt($y);

  ($x_pt, $x_val, $x_unc) = &pt_div($x_pt, $x_val, $x_unc,
                                    $y_pt, $y_val, $y_unc);

  return &define_ir($x_pt, $x_val, $x_unc, '');
} # End of p.div

sub p_negate
{
  my($x) = @_;
  my($x_pt, $x_val, $x_unc);

  ($x_pt, $x_val, $x_unc) = &splt($x);

  ($x_pt, $x_val) = &pt_negate($x_pt, $x_val, $x_unc);

  return &define_ir($x_pt, $x_val, $x_unc, '');
} # End of p.negate

sub p_exp
{
  my($x) = @_;
  my($x_pt, $x_val, $x_unc);

  ($x_pt, $x_val, $x_unc) = &splt($x);

  ($x_pt, $x_val, $x_unc) = &pt_exp($x_pt, $x_val, $x_unc);

  return &define_ir($x_pt, $x_val, $x_unc, '');
} # End of p.exp

sub p_ln
{
  my($x) = @_;
  my($x_pt, $x_val, $x_unc);

  ($x_pt, $x_val, $x_unc) = &splt($x);

  ($x_pt, $x_val, $x_unc) = &pt_ln($x_pt, $x_val, $x_unc);

  return &define_ir($x_pt, $x_val, $x_unc, '');
} # End of p.ln

sub p_arctan
{
  my($x) = @_;
  my($x_pt, $x_val, $x_unc);

  ($x_pt, $x_val, $x_unc) = &splt($x);

  ($x_pt, $x_val) = &pt_arctan($x_pt, $x_val);

  return &define_ir($x_pt, $x_val, $x_unc, '');
} # End of p.arctan

sub p_log10
{
  my($x) = @_;
  my($x_pt, $x_val, $x_unc);

  ($x_pt, $x_val, $x_unc) = &splt($x);

  ($x_pt, $x_val, $x_unc) = &pt_log10($x_pt, $x_val, $x_unc);

  return &define_ir($x_pt, $x_val, $x_unc, '');
} # End of p.log10

sub p_pow
{
  my($x, $y) = @_;
  my($x_pt, $x_val, $x_unc, $y_pt, $y_val, $y_unc);

  ($x_pt, $x_val, $x_unc) = &splt($x);
  ($y_pt, $y_val, $y_unc) = &splt($y);

  ($x_pt, $x_val, $x_unc) = &pt_pow($x_pt, $x_val, $x_unc,
                                    $y_pt, $y_val, $y_unc);

  return &define_ir($x_pt, $x_val, $x_unc, '');
} # End of p.pow

# %%% Accuracy is not good enough for scale>20. See notes in header.
sub p_fact
{
  my($x) = @_;
  my($x_pt, $x_val, $x_unc);

  # Handle integer argument
  if (&simple_int($x, $curscale) && ($x >= 0) && ($x < 167)) {
    $x_pt = 0;
    $x_val = &intgam($x+1);
    &dbg1("p.fact($x): intgam -> $x_val", 32);
    $x_unc = $g_0;
  } else {
    ($x_pt, $x_val, $x_unc) = &splt($x);
    ($x_pt, $x_val, $x_unc) = &pt_gamma(&pt_add($x_pt, $x_val, $x_unc,
                                              0, $g_1, 0));
  }
  return &define_ir($x_pt, $x_val, $x_unc, '');
} # End of p.fact

sub p_sqrt
{
  my($n) = @_;
  my($n_pt, $n_val, $n_unc);

  ($n_pt, $n_val, $n_unc) = &splt($n);

  ($n_pt, $n_val, $n_unc) = &pt_sqrt($n_pt, $n_val, $n_unc);

  return &define_ir($n_pt, $n_val, $n_unc, '');
} # End of p.sqrt

sub p_sin
{
  my($n) = @_;
  my($n_pt, $n_val, $n_unc);

  ($n_pt, $n_val, $n_unc) = &splt($n);

  ($n_pt, $n_val, $n_unc) = &pt_sin($n_pt, $n_val, $n_unc);

  return &define_ir($n_pt, $n_val, $n_unc, '');
} # End of p.sin

sub p_cos
{
  my($n) = @_;
  my($n_pt, $n_val, $n_unc);

  ($n_pt, $n_val, $n_unc) = &splt($n);

  ($n_pt, $n_val, $n_unc) = &pt_cos($n_pt, $n_val, $n_unc);

  return &define_ir($n_pt, $n_val, $n_unc, '');
} # End of p.cos

sub p_tan
{
  my($n) = @_;
  my($n_pt, $n_val, $n_unc);

  ($n_pt, $n_val, $n_unc) = &splt($n);

  ($n_pt, $n_val, $n_unc) = &pt_tan($n_pt, $n_val, $n_unc);

  return &define_ir($n_pt, $n_val, $n_unc, '');
} # End of p.tan

sub p_root
{
  my($r, $n) = @_;
  my($r_pt, $r_val, $r_unc, $n_pt, $n_val, $n_unc);

  ($r_pt, $r_val, $r_unc) = &splt($r);
  ($n_pt, $n_val, $n_unc) = &splt($n);

  ($r_pt, $r_val, $r_unc) = &pt_root($n_pt, $n_val, $n_unc,
                                     $r_pt, $r_val, $r_unc);

  return &define_ir($r_pt, $r_val, $r_unc, '');
} # End of p.root

sub p_1d_lookup
{
  my($op, $a) = @_;
  my($a_pt, $a_val, $a_unc);
  my($rv, $lvk);

  &dbg1("pal1 $op($a)", 32);

  ($a_pt, $a_val, $a_unc) = &splt($a);
  # &dbg1("pal ($a_pt, $a_val, $a_unc)", 32);

  $rv = '0';
  if (&pvu_sint($a_pt, $a_val, $a_unc, 14)) {
    # Create lvalue key
    $lvk = "$op($a_val)";
    if ($vars_pt{$lvk} ne "") {
      $rv = &define_ir($vars_pt{$lvk}, $vars_val{$lvk},
                                          $vars_unc{$lvk}, $lvk);
    } else {
      # not defined (yet) so we'll just use 0.
      $rv = &define_ir(0, 0, 0, $lvk);
    }
  } else {
    print STDERR ("*** Illegal array index '$a' in $op($a)"
               . ( ($BASIC_running) ? " in line $g_BASIC_pc" : "")
               . "\n");
  }

  return $rv;
} # End of p.1d.lookup

sub p_2d_lookup
{
  my($op, $a, $b) = @_;
  my($a_pt, $a_val, $a_unc, $b_pt, $b_val, $b_unc);
  my($rv, $lvk);

  &dbg1("pal $op($a,$b)", 32);

  ($a_pt, $a_val, $a_unc) = &splt($a);
  ($b_pt, $b_val, $b_unc) = &splt($b);
  # &dbg1("pal ($a_pt, $a_val, $a_unc), ($b_pt, $b_val, $b_unc)", 32);

  $rv = '0';
  if (&pvu_sint($a_pt, $a_val, $a_unc, 14)) {
    if (&pvu_sint($b_pt, $b_val, $b_unc, 14)) {
      # Create lvalue key
      $lvk = "$op($a_val,$b_val)";
      if ($vars_pt{$lvk} ne "") {
        $rv = &define_ir($vars_pt{$lvk}, $vars_val{$lvk},
                                          $vars_unc{$lvk}, $lvk);
      } else {
        # not defined (yet) so we'll just use 0.
        $rv = &define_ir(0, 0, 0, $lvk);
      }
    } else {
      print STDERR ("*** Illegal array index '$b'"
               . ( ($BASIC_running) ? " in line $g_BASIC_pc" : "")
               . "\n");
    }
  } else {
    print STDERR ("*** Illegal array index '$a'"
               . ( ($BASIC_running) ? " in line $g_BASIC_pc" : "")
               . "\n");
  }

  return $rv;
} # End of p.2d.lookup

sub p_logn
{
  my($b, $n) = @_;
  my($b_pt, $b_val, $b_unc, $n_pt, $n_val, $n_unc);

  ($b_pt, $b_val, $b_unc) = &splt($b);
  ($n_pt, $n_val, $n_unc) = &splt($n);

  ($n_pt, $n_val, $n_unc) = &pt_log_n($n_pt, $n_val, $n_unc,
                                      $b_pt, $b_val, $b_unc);

  return &define_ir($n_pt, $n_val, $n_unc, '');
} # End of p.logn

# addfunc: new functions can go here


<<endquote;

  phrase: term
          term [+|-] phrase

  term: factor
        factor [*|/] term

  factor: bexp
          bexp ^ factor

  bexp: - bexp
        bexp !
        !!
        variable
        result
        constant

endquote

#----------------------------------------- parsing and evaluation
#
# These routines do all the parsing to calculate values of complex
# expressions. It's all done with regular expressions, checking for all
# possible operation in precedence order, and taking advantage if the
# number-string duality in Perl. It works remarkably well.
#
sub eval_2
{
  my($e) = @_;
  my($going);
  my($pre, $a, $op, $b, $post);
  my($holdleft, $holdright, $hf, $lvk);

  &dbg1("ev2a $e", 2);

  # expand.ihist sometimes leaves an expression that has an extra
  # set of parens around it
  $e =~ s|^\((.*)\)$|$1|;

  &dbg1("ev2b $e", 2);

  # beginning of parenthesis loop
  $going = 1; $hf = 0;
  $g_possible_assign = 0;
  while($going) {
    &dbg1("ev2c $e", 2);
    # Evaluate inside parentheses
    if ($e =~ m|^(.+)\(([^\(\)]+)\)(.+)$|) {
      # The middle part is a subexpression inside parenthesis, which itself
      # has no parentheses. We take the left and right parts and hold them,
      # keeping only the middle part. Then we continue looping until there
      # is nothing left to do (no operators, etc.). Then a test for $hf at
      # the bottom of this case statement puts the left and right parts back
      # on
      $holdleft = $1; $e = "'" . $2 . "'"; $holdright = $3;
      $hf = 1;
      &dbg1("ev2d hold: $holdleft   ( $e )   $holdright", 2);
    } elsif
    # operator ! (factorial)
    ($e =~ m|^(.*$p_nonarg)($p_arg)([!])($p_nonarg.*)$|) {
      $pre = $1; $a = $2; $op = $3; $post = $4;
      &dbg1("ev2e $pre $a ! $post", 2);
      if ($op eq "!") {
        $e = $pre . &p_fact($a) . $post;
      }
      $e =~ s| ||g;
      $g_possible_assign = 0;

    } elsif
    # operator - (N, unary minus) without parentheses
    ($e =~ m|^(.*$p_na2)([N])($p_arg)($p_nonarg.*)$|) {
      $pre = $1; $op = $2; $a = $3; $post = $4;
      &dbg1("ev2f $pre N $a $post", 2);
      if ($op eq "N") {
        $e = $pre . &p_negate($a) . $post;
      }
      $e =~ s| ||g;
      $g_possible_assign = 0;

    } elsif
    # single-parameter functions: arctan, cosine, ...
      # addfunc: add a symbol here
    ($e =~ m|^(.*$p_nonarg)([CKNQTX])\{($p_arg)\}($p_nonarg.*)$|) {
      $pre = $1; $op = $2; $a = $3; $post = $4;
      &dbg1("ev2g $pre $op" . "{ $a } $post", 2);
      if ($op eq "X") {
        $e = $pre . &p_exp($a) . $post;
      } elsif ($op eq "C") {
        $e = $pre . &p_cos($a) . $post;
      } elsif ($op eq "K") {
        $e = $pre . &p_ln($a) . $post;
      } elsif ($op eq "N") {
        # Unary negate with parentheses (without parens is handled above)
        $e = $pre . &p_negate($a) . $post;
      } elsif ($op eq "Q") {
        $e = $pre . &p_sqrt($a) . $post;
      } elsif ($op eq "T") {
        $e = $pre . &p_tan($a) . $post;

      # addfunc: new functions can go here
      } else {
        print "eval.2 unrecog single-param symbol '$op', replacing with 0\n";
        $e = $pre . "0" . $post;
      }
      $e =~ s| ||g;
      $g_possible_assign = 0;

    } elsif
    ($e =~ m|^(.*$p_na2)([A-Z]+)\{($p_arg)\}($p_nonarg.*)$|) {
      $pre = $1; $op = $2; $a = $3; $post = $4;
      &dbg1("ev2h $pre $op" . "{ $a } $post", 2);
      if (0) {
      # addfunc: 1-argument functions go here
      } elsif ($op eq "ARCTAN") {
        $e = $pre . &p_arctan($a) . $post;
      } elsif ($op eq "LOG") {
        $e = $pre . &p_log10($a) . $post;
      } elsif ($op eq "RND") {
        $e = $pre . &p_rnd($a) . $post;
      } elsif ($op eq "SIN") {
        $e = $pre . &p_sin($a) . $post;
      } else {
        # Treat it as a 1-D array access
        # %%% user-defined multiletter functions would also go here
        &dbg1("ev2j $pre $op( $a ) $post", 2);
        $e = $pre . &p_1d_lookup($op, $a) . $post;

      # %%% addfunc: rest of standarrd multi-letter functions go here

      }
      $e =~ s| ||g;
      $g_possible_assign = 0;

    } elsif
    # two-argument functions root and log_n
    ($e =~ m|^(.*$p_nonarg)([MV])\{($p_arg),($p_arg)\}($p_nonarg.*)$|) {
      $pre = $1; $op = $2; $a = $3; $b = $4; $post = $5;
      &dbg1("ev2i $pre $op( $a , $b ) $post", 2);
      if ($op eq "V") {
        $e = $pre . &p_root($a, $b) . $post;
      } elsif ($op eq "M") {
        $e = $pre . &p_logn($a, $b) . $post;
      }
      $e =~ s| ||g;
      $g_possible_assign = 0;

    } elsif
    ($e =~ m|^(.*$p_nonarg)($p_fname)\{($p_arg),($p_arg)\}($p_nonarg.*)$|) {
      # try to treat it as a 2-D array read
      $pre = $1; $op = $2; $a = $3; $b = $4; $post = $5;
      &dbg1("ev2j $pre $op( $a , $b ) $post", 2);
      $e = $pre . &p_2d_lookup($op, $a, $b) . $post;
      $g_possible_assign = 0;

#      if (&simple_int($a, 14) && &simple_int($b, 14)) {
#        # Create lvalue key
#        $lvk = "$op($a,$b)";
#        if ($vars_pt{$lvk} ne "") {
#          $e = $pre . &define_ir($vars_pt{$lvk}, $vars_val{$lvk},
#                                            $vars_unc{$lvk}, $lvk) . $post;
#          $e =~ s| ||g;
#        } else {
#          # not defined (yet) so we'll just use 0.
#          $e = $pre . &define_ir(0, 0, 0, $lvk) . $post;
#        }
#      } elsif (&simple_int($a, 14)) {
#        print STDERR ("*** Illegal array index '$b'"
#                   . ( ($BASIC_running) ? " in line $g_BASIC_pc" : "")
#                   . "\n");
#        $e = $pre . '0' . $post;
#      } else {
#        print STDERR ("*** Illegal array index '$a'"
#                   . ( ($BASIC_running) ? " in line $g_BASIC_pc" : "")
#                   . "\n");
#        $e = $pre . '0' . $post;
#      }

    } elsif
    # exponents
    ($e =~ m/^(.*$p_nonarg)($p_arg)(\^|\*\*)($p_arg)($p_nonarg.*)$/) {
      $pre = $1; $a = $2; $op = $3; $b = $4; $post = $5;
      &dbg1("ev2k $pre $a $op $b $post", 2);
      if (($op eq '^') || ($op eq '**')) {
        $e = $pre . &p_pow($a,$b) . $post;
      } else {
        # Unrecognised op
        print STDERR ("*** Unrecognised operator '$op'"
                   . ( ($BASIC_running) ? " in line $g_BASIC_pc" : "")
                   . "\n");
        $e = $pre . $a . $post;
      }
      $e =~ s| ||g;
      $g_possible_assign = 0;

    } elsif
    # multiplication, division, modulo
    ($e =~ m|^(.*[-+><=~&\|\(\',])($p_arg)([\%x*/])($p_arg)($p_nonarg.*)$|) {
      $pre = $1; $a = $2; $op = $3; $b = $4; $post = $5;
      &dbg1("ev2l $pre $a $op $b $post", 2);
      if (($op eq "*") || ($op eq "x")) {
        $e = $pre . &p_mul($a,$b) . $post;
      } elsif ($op eq '/') {
        $e = $pre . &p_div($a,$b) . $post;
      } else {
        $e = $pre . &p_mod($a,$b) . $post;
      }
      $e =~ s| ||g;
      $g_possible_assign = 0;

    # %%% integer divide (quotient) to be added here
    # for bc_xxx see trunc() function in ~/bin/calc-in (I need to set
    # scale to 0, then restore it)

    } elsif
    # addition and subtraction
    ($e =~ m|^(.*[><=~&\|\(\',])($p_arg)([-+])($p_arg)($p_nonarg.*)$|) {
      $pre = $1; $a = $2; $op = $3; $b = $4; $post = $5;
      &dbg1("ev2m $pre $a $op $b $post", 2);
      if ($op eq "+") {
        $e = $pre . &p_add($a,$b) . $post;
      } else {
        $e = $pre . &p_sub($a,$b) . $post;
      }
      $e =~ s| ||g;
      $g_possible_assign = 0;

    # %%% >> and << (bit shifts) would go here. Conveniently they go right
    # before the other uses of '<' and '>' in precenence order.
    # Their implementation in 300-digit precision is equivalent to multiply
    # and quotient with an integer power of 2 as argument; and the right
    # argument of a bit-shift operator needs to be converted to
    # int(x) == x\1; so I should probably implement quotient n\d and
    # integer exponent first.

    } elsif
    # comparison operators. Note that '=' and '==' both represent equality
    ($e =~ m/^(.*[~&\|\(\',])($p_arg)(<|>|<=|>=|<>|=|==)($p_arg)($p_nonarg.*)$/) {
      $pre = $1; $a = $2; $op = $3; $b = $4; $post = $5;
      &dbg1("ev2n $pre $a $op $b $post", 2);
      $e = $pre . &p_op_compare($op, $a, $b) . $post;
      $e =~ s| ||g;

      $g_possible_assign = $poc_isassign;
      $g_assign_lvk = $poc_lvk;
      $g_assign_pt = $poc_rv_pt;
      $g_assign_val = $poc_rv_val;
      $g_assign_unc = $poc_rv_unc;

    } elsif
    # Boolean NOT
    ($e =~ m/^(.*$p_nonarg)([~!])($p_arg)($p_nonarg.*)$/) {
      $pre = $1; $op = $2; $b = $3; $post = $4;
      &dbg1("ev2o $pre $op $b $post", 2);
      $e = $pre . &p_not($b) . $post;
      $e =~ s| ||g;
      $g_possible_assign = 0;

    } elsif
    # Boolean (and sort of bitwise) AND
    ($e =~ m/^(.*[\|\(\',])($p_arg)([&])($p_arg)($p_nonarg.*)$/) {
      $pre = $1; $a = $2; $op = $3; $b = $4; $post = $5;
      &dbg1("ev2p $pre $a $op $b $post", 2);
      $e = $pre . &p_and($a, $b) . $post;
      $e =~ s| ||g;
      $g_possible_assign = 0;

    } elsif
    # Boolean (and sort of bitwise) OR
    ($e =~ m/^(.*[\(\',])($p_arg)(\|)($p_arg)($p_nonarg.*)$/) {
      $pre = $1; $a = $2; $op = $3; $b = $4; $post = $5;
      &dbg1("ev2q $pre $a $op $b $post", 2);
      $e = $pre . &p_or($a, $b) . $post;
      $e =~ s| ||g;
      $g_possible_assign = 0;

    # %%% all of the boolean operators (bitwise and logical) to be
    # added here. Bitwise could be used for logical (as in Visual
    # BASIC); but if I decide to make those separate there need to be
    # more levels of precedence.
    #  ~ bitwise complement
    #  & bitwise AND
    #  | bitwise OR
    #  !/~~/NOT logical NOT
    #  &&/AND logical AND
    #  ||/OR logical OR
    # Also note that 300-digit precision bitwise is nontrivial to implement;
    # nothing useful is provided by #bc# so I'd have to do a series of
    # operations in base 2^40 or something like that.

    } elsif
    # then reduce parentheses
    ($hf) {
      &dbg1("ev2r restore: $holdleft $e $holdright", 2);
      $e =~ s/\'//g;
      # addfunc: add a symbol here
      if ($holdleft =~ m|[_a-zA-Z0-9]$|) {
        # The parentheses contained a function or array argument(s); make
        # parens into {} for subsequent matching above
        $e = $holdleft . "{" . $e . "}" . $holdright;
      } else {
        # The parentheses were to override precedence
        $e = $holdleft . $e . $holdright;
      }
      $hf = 0;
    } else {
      $going = 0;
    }
  }

  &dbg1("ev2s $e", 2);
  if ($g_possible_assign) {
    &dbg1("ev2t vars[$g_assign_lvk] := ($g_assign_pt, $g_assign_val, $g_assign_unc)", 2);
  }

  return $e;
} # End of eval.2

# addfunc: modify this string
$g_function_symbols = ":cos.C:inf.I:ln.K:logn.M:"
                     . "pt.P:sqrt.Q:sqr.Q:tan.T:root.V:exp.X:";

# eval.1 was the original main function for evaluating an input expression,
# before command history substitution was added.
sub eval_1
{
  my($e) = @_;
  my($s, $pct, $pre, $v, $post, $p1);

  # init intermediate-result counter
  $ir_n = $ir_in;

  # Add an otherwise-unused single-quote character to both ends of the
  # expression; these make regexp matching a bit simpler.
  $e = "'" . $e . "'";

  &dbg1("ev1a $e", 1);

  # map all alphabetics to lower case. %% This is also done in BASIC.print
  # and in do.cmd6, so it shouldn't be necessary here
  if ($e =~ m/[A-Z]/) {
    $e = lc($e);
    &dbg1("e1.02 -> $e", 8);
  }

  # Substitute "%" with previous answer
  # %%% to allow % as an operator (modulo) we'll need to not do this mapping
  # here and instead allow '%' to be recognised as a variable name
  if ($e =~ m|\%|) {
    # (a2_pt, a2_val, a2_unc) hold result of last call to this eval.1 routine
    $pct = &define_ir($a2_pt, $a2_val, $a2_unc, '');
    &dbg1("e1.04 define pct = $pct", 1);
  }

  # Encode uncertainties in number literals using the reserved character 'U'.
  # This needs to be done before variable substution because the
  # parentheses around the uncertainty are too hard to deal with in
  # the rest of the parser.
  #   The resulting pattern "3U7" will not occur because of the uppercase U
  # (it is similar to part of a variable name like "v3U7", but that will
  # have been mapped onto lowercase "v3u7" by now).
  if ($e =~ m|([^_a-z0-9][0-9]*p?[.0-9]+)\(([0-9]+)\)|) {
    $e =~ s|([^_a-z0-9][0-9]*p?[.0-9]+)\(([0-9]+)\)|$1."U".$2|ge;
    &dbg1("e1.06 -> $e", 8);
  }

  &dbg1("e1.07 $e", 8);

  # Substitute function names, variables and predefined constants
  # e, pi and phi
  while ($e =~ m|^(.*$p_nonvar)($p_var)($p_nonvar.*)$|) {
    $pre = $1; $v = $2; $post = $3;
    "$post'" =~ m/^ *([^ ])/; $p1 = $1;
    &dbg1("e1.08 |$pre|$v|$post|", 1);
    if (0) {

    # function and array names must be followed by '('

    } elsif (($p1 eq '(') && ($g_function_symbols =~ m|\:$v\.(.)\:|)) {
      $s = $1;
    } elsif (($p1 eq '(') && ($v eq 'rnd')) {
      # random function - leave alone
      $s = uc($v);
    } elsif ($p1 eq '(') {

#      # %%% any user-defined arrays and functions would fall here
#      print STDERR ("*** Unrecognised function name $v"
#                 . ( ($BASIC_running) ? " in line $g_BASIC_pc" : "")
#                 . "\n");
#      $s = " "; # Replace with something that won't match $p_var
      $s = uc($v);

    # variable-like tokens cannot be followed by '('
    # Variables $s_e, $s_pi, etc. were created by &init_ir

    } elsif (($p1 ne '(') && ($v eq "e")) {
      $s = $s_e;
    } elsif (($p1 ne '(') && ($v eq "false")) {
      $s = 0;
    } elsif (($p1 ne '(') && ($v eq "pi")) {
      $s = $s_pi;
    } elsif (($p1 ne '(') && ($v eq "phi")) {
      $s = $s_phi;
    } elsif (($p1 ne '(') && ($v eq "true")) {
      $s = 1;
    } elsif (($p1 ne '(') && ($v =~ m|^r([0-9]+)$|)) {
      # result history item -- leave it alone
      $s = "R" . $1;
    } elsif (($p1 ne '(') && ($v eq '%')) {
      $s = $pct;

#    } elsif (($p1 ne '(') && ($vars_pt{$v} ne "")) {
    } elsif ($p1 ne '(') {
      $s = &define_ir($vars_pt{$v}, $vars_val{$v}, $vars_unc{$v}, $v);

    # operators made of letters have already been converted to non-letter
    # equivalents (this is done in expand.ih2() )

    } else {
      print STDERR ("*** Unrecognised name $v"
                 . ( ($BASIC_running) ? " in line $g_BASIC_pc" : "")
                 . "\n");
      $s = " 0 "; # Replace with something that won't match $p_var
#      $s = uc($v);
    }
    $e = $pre . $s . $post;
    &dbg1("e1.09 -> |$e|", 1);
  } # end of while (match special vars)

  &dbg1("e1.10 $e", 1);

  # now it's safe to eliminate spaces
  if ($e =~ m| |) {
    $e =~ s| ||g;
    &dbg1("e1.12 -> $e", 8);
  }

  # put numbers in standard form
  if ($e =~ m|([-\(\'\/%*xe+,^<>=])-|) { # ) balance
    $e =~ s|([-\(\'\/%*xe+,^<>=])-|$1N|g; # ) balance
    &dbg1("e1.14 -> $e", 8);
  }
  if ($e =~ m|([0-9.])e([N+0-9.])|) {
    $e =~ s|([0-9.])e([N+0-9.])|$1E$2|g;
    &dbg1("e1.15 -> $e", 8);
  }
  if ($e =~ m|([0-9])p([N+0-9.])|) {
    $e =~ s|([0-9])p([N+0-9.])|$1P$2|g;
    &dbg1("e1.16 -> $e", 8);
  }
  if ($e =~ m|([0-9])u([0-9])|) {
    $e =~ s|([0-9])u([0-9])|$1U$2|g;
    &dbg1("e1.17 -> $e", 8);
  }

  &dbg1("e1.20 $e", 1);

  # do the actual parsing and evaluation
  $e = &eval_2($e);

  &dbg1("e1.22 $e", 1);

  $e =~ s/\'//g;

  &dbg1("e1.24 $e", 1);

  if ($e =~ m|^I([0-9]+)$|) {
    # result is a single IR
    $e = $1;
    $a2_pt = $ir_pt[$e];
    $a2_val = $ir_val[$e];
    $a2_unc = $ir_unc[$e];
    dbg1("e1.26 res I$e = $a2_pt" . "P$a2_val", 2);
  } elsif ($e =~ m|^I[0-9]|) {
    # We have an IR followed by other unevaluated stuff
    print STDERR ("*** Invalid syntax; I was left with '$e' (ev1)\n");
  } else {
    # result is a literal
    ($a2_pt, $a2_val, $a2_unc) = &splt($e);
    dbg1("e1.28 lit $a2_pt" . "P$a2_val", 2);
  }

  dbg1("e1.30 $a2_pt" . "P$a2_val", 2);

  return ($a2_pt, $a2_val, $a2_unc);
} # End of eval.1

#--------------------------------------------------- main
#
# initialization, main command loop, help, etc.

# Print a value that is in floating-point or scientific notation, converting
# if necessary to floating-point and adding or truncating mantissa digits
# to match the current scale.
sub prnt3
{
  my($x, $paren, $force_ee, $suppress_1) = @_;
  my($m1, $e, $s, $m2, $m3, $s2, $output, $e1, $e2);

  print "prnt3 01($x, $paren)\n" if ($format_debug);

  $output = "";

  # Special cases
  if ($x =~ m/inf/) {
    print "prnt3 02: Infinity\n" if ($format_debug);
    return((($x =~ m/-/) ? "- " : "") . "Infinity");
  } elsif ($x =~ m/nan/) {
    print "prnt3 02: NAN\n" if ($format_debug);
    return("Undefined");
  }

  # Change "1.23e+21" to "1.23e21"
  $x =~ s|\+||g;
  print "prnt3 03a: $x\n" if ($format_debug);

  # If it's in fixed format, but has more digits than the current precision
  # allows, convert to floating-point
  if (!($x =~ m|[eE]|)) {
    # extract sign
    if ($x =~ m/\-/) {
      $s = "-";
      $x =~ s/\-//;
    } else {
      $s = "";
    }

    print "prnt3 03b $x $g_ee_b4\n" if ($format_debug);

    if ($force_ee || &f_gt($x, $g_ee_b4)) {
      if ("$x.0" =~ m/^([0-9])([0-9]*)\.([0-9]+)/) {
        $m1 = $1; $m2 = $2; $m3 = $3;
        $e = length($m2);
        if ($e > 0) {
          $x = $m1 . "." . $m2 . $m3 . "e" . $e;
        }
      } else {
        print "prnt3 error converting fixed to EE: |$x|\n";
      }
    }

    $x = $s . $x;
    print "prnt3 04: $x\n" if ($format_debug);
  }

  if ($x =~ m|[eE]|) {
    # Translate scientific notation to something prettier

    if ($x =~ m|^(-?)([0-9]+)\.([0-9]*)[eE]([-0-9]+)$|) {
      $s = $1; $m1 = $2; $m2 = $3; $e = $4;
    } elsif ($x =~ m|^(-?)([0-9]+)[eE]([-0-9]+)$|) {
      $s = $1; $m1 = $2; $m2 = "0"; $e = $3;
    } elsif ($x =~ m|[eE]|) {
      print "error-0-01 Unhandled format: $x\n";
      exit 0;
    }
    print "prnt3 05: |$s|$m1|$m2|$e|\n" if ($format_debug);

    # Turn "e-05" into "e-5"
    $e =~ s/-0/-/;

    $s2 = $curscale - 1;
    if ($m2 eq "") {
      $m2 = "0";
    }

    # We should never have "12.34e56"
    if (length($m1) > 1) {
      print("error-0-02 Badformat mantissa: $s$m1.$m2" . "e$e\n");
      exit 0;
    }

    # truncate mantissa
    if (length($m2) > $s2) {
      $m2 =~ m|^([0-9]{$s2})|;
      $m2 = $1;
      print "prnt3 06a: m2 '$m2'\n" if ($format_debug);
    }

    $output .= $p1_lstr if ($paren);

    print "prnt3 06b: |$m1|$m2|$e| s2 $s2\n" if ($format_debug);

    # Decide whether to print as a normal number
    if (($force_ee == 0) && ($e >= 0) && ($e <= $s2)) {
      # Take appropriate number of digits off of mantissa
      $takedig = $e;
      while(length($m2) < $takedig) {
        $m2 .= "0";
      }
      $m2 =~ m|^([0-9]{$takedig})([0-9]*)$|;
      $m1 = $m1 . $1; $m2 = $2;
      $x = "$s$m1.$m2";
      $x =~ s|0+$||;
      $x =~ s|\.$||;
      $output .= $x;
      print "prnt3 07a: '$x'\n" if ($format_debug);
    } elsif (($force_ee == 0) && ($e < 0) && ($e > -5)) {
      # Small negative exponent. This happens when we use #bc#
      while ($e < 0) {
        $m2 = $m1 . $m2;
        $m1 = '0';
        $e++;
      }
      $x = "$s$m1.$m2";
      $x =~ s|0+$||;
      $x =~ s|\.$||;
      $output .= $x;
      print "prnt3 07b: '$x'\n" if ($format_debug);
    } else {
      # Format as mantissa x 10^ E
      $x = "$s$m1.$m2";
      $x =~ s|0+$||;
      $x =~ s|\.$||;
      print "prnt3 07c: '$x'\n" if ($format_debug);
      if (($suppress_1 == 0) || ($x ne '1')) {
        $output .= "$x$multstr";
      }
      $output .= "$k10$powstr$e_lstr$e$e_rstr";
    }
    $output .= $p1_rstr if ($paren);
  } else {
    # Just a plain number

    # Extract sign
    if ($x =~ m/\-/) {
      $s = "-";
      $x =~ s/\-//;
    } else {
      $s = "";
    }

    # Truncate digits to scale
    if ("$x.0" =~ m/^([0-9]+)\.([0-9]+)/) {
      $m1 = $1; $m2 = $2;
      $e1 = length($m1);
      $e2 = length($m2);
      $e = $curscale - $e1;
      if ($e2 > $e) {
        if ($m2 =~ m/^(.{$e})/) {
          $m2 = $1;
        } else {
          print "prnt3 error-2 truncating fixed to scale: |$x|\n";
        }

        $x = $m1 . "." . $m2;
      }
    } else {
      print "prnt3 error-1 truncating fixed to scale: |$x|\n";
    }

    # Discard any trailing ".000"
    if ($x =~ m|\.|) {
      $x =~ s|0+$||;
      $x =~ s|\.$||;
    }

    $output = $s . $x;
  }

  print "prnt3: $output\n" if ($format_debug);
  return $output;
} # End of prnt3

# Convert a floating-point value to the properly formatted form (for the
# current print format), then insert the uncertainty digits if needed.
sub prnt2
{
  my($x_val, $x_unc, $paren, $force_ee, $suppress_1) = @_;
  my($rv);

  print "prnt2($x_val, $x_unc, $paren, $force_ee, $suppress_1)\n" if ($format_debug);

  if ($x_unc != 0) {
    $suppress_1 = 0;
  }
  $rv = &prnt3($x_val, $paren, $force_ee, $suppress_1);

  if ($x_unc != 0) {
    $rv = &insert_uncertainty($rv, $x_val, $x_unc);
  }

  return $rv;
}

# Compute pi using the Baily-Plouffe hexadecimal series, which
# converges quite quickly
sub init_pi_1
{
  my($f1, $i, $d);

  &dbg1("init_pi_1", 2);
  $g_pi = $g_0;
  $f1 = $g_1;
  $i = $g_0;
  $d = $g_1;
  while (&f_gt($f1, $prec)) {
    $i_f = $i; $i_f = &f_mul($g_8, $i_f);
    $f1 =             &f_div($g_4, &f_add($i_f, $g_1));
    $f1 = &f_sub($f1, &f_div($g_2, &f_add($i_f, $g_4)));
    $f1 = &f_sub($f1, &f_div($g_1, &f_add($i_f, $g_5)));
    $f1 = &f_sub($f1, &f_div($g_1, &f_add($i_f, $g_6)));
    $f1 = &f_div($f1, $d);
    $d = &f_mul($d, $g_16);
    &dbg1("init.pi_1 g_pi term", 1);
    $g_pi = &f_add($g_pi, $f1);
    $i = &f_add($i, $g_1);
  }
  print "init_pi_1 pr $g_pi\n" if ($format_debug);
  $d = &prnt2($g_pi, 0, 0, 0, 0);
  &dbg1("init_pi_1 done: $d", 2);
} # End of init_pi_1

# Compute pi using a formula based on the Gauss arithmetic-geometric mean
# method. Number of digits doubles with each loop.
sub init_pi_2
{
  my($x, $y, $a, $b, $c, $ct, $i);

  &dbg1("init_pi_2", 2);

  $a = $x = $g_1; $b = &f_div($g_1, &f_sqrt($g_2)); $c = &f_div($g_1, $g_4);
  &dbg1("init_pi_2 a=$a, b=$b, c=$c", 2);
  for($i=1; $i<($curscale+2); $i*=2) {
    $y = $a;
    &dbg1("init_pi_2   y=$y", 2);
    $a = &f_div(&f_add($a, $b), $g_2);
    &dbg1("init_pi_2   a=$a", 2);
    $b = &f_sqrt(&f_mul($b, $y));
    &dbg1("init_pi_2   b=$b", 2);
    $ct = &f_sub($a, $y);
    &dbg1("init_pi_2   ct=$ct", 2);
    $c = &f_sub($c, &f_mul($x, &f_mul($ct, $ct)));
    &dbg1("init_pi_2   c=$c", 2);
    $x = &f_mul($x, $g_2);
    &dbg1("init_pi_2   x=$x", 2);
  }
  $ct = &f_add($a, $b);
  &dbg1("init_pi_2 ct=$ct", 2);
  $a = &f_mul($ct, $ct);
  &dbg1("init_pi_2 a=$a", 2);
  $b = &f_mul($g_4, $c);
  &dbg1("init_pi_2 b=$b", 2);
  $g_pi = &f_div($a, $b);
  &dbg1("init_pi_2 g_pi=$g_pi", 2);
  print "init_pi_2 pr $g_pi\n" if ($format_debug);
  $c = &prnt2($g_pi, 0, 0, 0, 0);
  &dbg1("init_pi_2 done: $c", 2);
} # End of init_pi_2

# Define intermediate results for predefined constants e, pi and phi
sub init_ir
{
  $ir_n = 0;

  $s_e = &define_ir(0, $g_e, 0, '');
  $s_pi = &define_ir(0, $g_pi, 0, '');
  $s_phi = &define_ir(0, $g_phi, 0, '');

  $ir_in = $ir_n;
}

sub set_var
{
  my ($vname, $lv_pt, $lv_val, $lv_unc) = @_;

  $vars_pt{$vname} = $lv_pt;
  $vars_val{$vname} = $lv_val;
  $vars_unc{$vname} = $lv_unc;
} # End of set.var

# This part of initialization is the same for both types of primitives.
sub hi_init
{
  my($prflag) = @_;
  my($i, $f);
  my($prec);
  my($f1, $i_f, $d);

  $g_ln_10 = &f_ln($g_10);
  $g_log10_e = &f_div($g_1, $g_ln_10);

  &dbg1("hi.init prec", 1);
  $prec = &f_div($g_1, &f_pow10($curscale + 2));
  $roundprec = &f_div($g_0_5, &f_pow10($curscale));
  # Constants used for handling roundoff, overflow, boundary
  # conditions, etc.
  $g_ovr1 = "+1.0E300";
  $g_log10_ovr1 = "300.0";

  # ln(10^300) = ln(10) * 300
  $g_ln_ovr1 = &f_mul($g_ln_10, $g_log10_ovr1);

  # Compute how big the argument of Gamma needs to be in order to guarantee
  # that we get the requested precision. The first neglected term in the
  # Stirling series is "+ 657931/(300 N^25)". For D digits of precision, we
  # want this to be smaller than 10^-D (this is a bit conservative, because
  # the largest term in the series is the initial "N ln(N)" and N will always
  # be at least as big as the value we're about to compute). Setting
  # 657931/(300 N^25) equal to 10^-D, we get:
  #   2193.10333.../N^25 = 1/10^D
  #   2193.10333... = N^25/10^D
  #   2193.10333... * 10^D = N^25
  #   N = (2193.10333... * 10^D)^(1/25)
  #     = 2193.10333...^(1/25) * 10^(D/25)
  #     = 1.360324... * 10^(D/25)
  $gamma_minarg = &f_mul("1.360324", &f_pow10(&f_div($curscale, "25.0")));
  &dbg1("hi.init gamma_minarg=" . sprintf("%f", $gamma_minarg), 32);

  # However, we don't want to be looping too many times in the iteration that
  # makes N bigger than gamma_minarg. So, if it's bigger than a "tolerable"
  # level, we report it.
  # %%% For possible fixes to the Gamma precision issue, see notes in header.
  $g_gammalim = "101.0";
  if (&f_gt($gamma_minarg, $g_gammalim)) {
    # We will set $gamma_minarg to $g_gammalim

    # So now we compute that first neglected term explicitly from the
    # minarg value we will actually use...
    $gammadig = &f_int(&f_neg(&f_log10(
                  &f_div("2193.10333", &f_pow($g_gammalim, "25.0"))
                )));
    # And if this turns out to be less precise than they asked for, we
    # can complain about it...
    if ($gammadig < $curscale) {
      if ($warned_gdsc != $curscale) {
        $msg1 = "Note: For all values less than " . ($g_gammalim-1)
              . ", factorial will give only " . &prnt2($gammadig, 0, 0, 0, 0)
              . " digits\n"
              . "      of accuracy; and for values less than "
              . sprintf("%.0f", $gamma_minarg + 1.0)
              . ", it will give fewer\n"
              . "      than the requested $curscale digits.\n";
        print $msg1 if ($prflag);
        $warned_gdsc = $curscale;
      }
    }

    $gamma_minarg = $g_gammalim;
  }

  # high-level constants

  # compute constant e
  $g_e = $g_1; $f = 1;
  for($i=1; ($i < 172) && (&f_gt($f, $prec)); $i++) {
    $f = &f_div($f, $i); $g_e = &f_add($g_e, $f);
  }

  # Compute pi using the Baily-Plouffe hexadecimal series, which
  # converges quite quickly
  &init_pi_2();
  $g_sin_limit = &f_mul($g_2p32m1, $g_pi);

  $g_phi = &f_div(&f_add(&f_sqrt($g_5), $g_1), $g_2);

  &dbg1("hi.init g_05_ln_2pi", 1);
  $g_05_ln_2pi = &f_mul($g_0_5, &f_ln(&f_mul($g_2, $g_pi)));

  $g_log10_log10_e = &f_log10($g_log10_e);
  $g_log10_2 = &f_log10($g_2);

  # recreate the native floating point infinities usinf f_mul. These count
  # on f_mul generating the infinite values.
  $g_inf = inf;
  $g_ninf = -inf;

  # PT Infinities have a native (double) infinity in the PT field
  $g_pt_inf = inf;
  $g_pt_nan = nan;

  # constants used for output formatting
  $g_ee_b4 =  &f_pow10($curscale - $g_min_mant_digits);

  &init_ir();

  # A few of the popular big numbers are pre-defined as variables.
  # These PT-Val tuples should work in all scales because the most
  # complex mantissa is the "3.000003" for milli-millillion.
  &set_var("million", 0, "1.0E6", 0);
  &set_var("billion", 0, "1.0E9", 0);
  &set_var("trillion", 0, "1.0E12", 0);
  &set_var("quadrillion", 0, "1.0E15", 0);
  &set_var("quintillion", 0, "1.0E18", 0);
  &set_var("sextillion", 0, "1.0E21", 0);
  &set_var("septillion", 0, "1.0E24", 0);
  &set_var("octillion", 0, "1.0E27", 0);
  &set_var("nonillion", 0, "1.0E30", 0);
  &set_var("decillion", 0, "1.0E33", 0);
  &set_var("vigintillion", 0, "1.0E63", 0);
  &set_var("googol", 0, "1.0E100", 0);
  &set_var("centillion", 1, "3.03E2", 0);
  &set_var("millillion", 1, "3.003E3", 0); # Conway-Wechsler's "millinillion"
  &set_var("milli_millillion", 1, "3.000003E6", 0);
  &set_var("sand_reckoner", 1, "1.0E16", 0);
  &set_var("googolplex", 1, "1.0E100", 0);
  &set_var("skewes", 2, "1.0E34", 0);
} # End of hi.init

# This routine inserts the uncertainty digits into the proper point in the
# mantissa portion of a text string representing a formatted value. The text
# string can have lots of extra formatting around the mantissa.
#
#  text                 val       unc       output
# '21.34'               21.34     1.0e-1   '21.34(10)'
# '21.34'               2.134e1   1.0e-1   '21.34(10)'
# '[ 1.23 x 10^{123} ]' 1.23e123  1e121    '[ 1.230(10) x 10^{123} ]'
sub insert_uncertainty
{
  my($text, $val, $unc) = @_;
  my($xs, $xm, $xe, $us, $um, $ue, $lead);
  my($c, $state, $numdig, $dot, $rd);

  # The number of mantissa digits we want to emit is the difference between
  # the exponents
  ($xs, $xm, $xe) = &fbc_split($val);
  ($us, $um, $ue) = &fbc_split($unc);
  $lead = $xe + 2 - $ue;
  # Convert uncertainty mantissa to standard form (two digits, no decimal,
  # with rounding)
  $um .= "00"; # Make sure there are at least 3 digits
  $um =~ s/[^0-9]//g; # Remove all non-digits
  if ($um =~ m/^([1-9][0-9])([0-9])/) {
    # Get 1st 2 digits plus rounding digit
    $um = $1; $rd = $2;
    if (($rd >= 5) && ($um < 99)) {
      $um++;
    }
  } else {
    # Perhaps first digit was a 0?
    print STDERR "*** Uncertainty parse error '$unc'\n";
    $um = '';
  }
  &dbg1("xs $xs xm $xm xe $xe um $um ue $ue lead $lead", 8);

  $rv = '';
  $state = $numdig = $dot = 0;
  $text .= ' ';
  foreach $c (split('', $text)) {
    # Advance state machine to recognize mantissa digits
    if ($c =~ m/[.0-9]/) {
      if ($state == 0) {
        $state = 1;
      }
    } else {
      if ($state == 1) {
        $state = 2;
      }
    }

    # Output the wanted significant digits
    if ($state == 1) {
      # If we get here, it is a mantissa digit or '.'
      if ($numdig && ($c =~ m/[0-9]/)) {
        $numdig++;
      } elsif ($c =~ m/[1-9]/) {
        # First nonzero digit
        $numdig++;
      } elsif ($c eq '.') {
        $dot = 1;
      }
      if ($numdig <= $lead) {
        $rv .= $c;
      } else {
        # This digit is beyond what we want -- but if we haven't seen the
        # decimal point yet we need to keep it
        if ($dot) {
          # don't output the digit
        } else {
          # Output the digit and add another uncertainty digit
          $rv .= $c;
          $um .= '0';
          $lead++;
        }
      }
      $c = '';
    }

    # If we got into state 2 without enough digits, add 0s
    if (($state == 2) && ($numdig < $lead)) {
      if (!($dot)) {
        $rv .= '.';
        $dot = 1;
      }
      while (($state == 2) && ($numdig < $lead)) {
        $rv .= '0';
        $numdig++;
      }
    }

    # Detect when it's time to add the uncertainty digits
    if (($state == 2) && ($um ne '')) {
      $rv = $rv . '(' . $um . ')';
      $um = ''; # prevent this from being done twice
    }

    # Now add the original character
    $rv .= $c;
  }

  # Remove any trailing space(s), including the one we added at the
  # beginning of the uncertainty handling.
  $rv =~ s/ +$//;

  return $rv;
} # End of insert.uncertainty

# Constants and functions used by the label formatting routines
$k_1e5 = 100000.0;
$k_1e6 = $k_million = 1000000.0;
$k_1e7 = 10000000.0;
$k_1e10 = 1.0e10;

# Constants used in uncertainty calculations
$k_ln_10 = log(10.0);

# Truncates a string to a given number of characters. Before doing so,
# pads the end with some character if desired.
sub trunc2
{
  my($x, $n, $extend) = @_;

  if ($extend ne "") {
    $x = $x . ($extend x $n);
  }
  if ($x =~ m/^(.{$n})/) {
    $x = $1;
  }
  return $x;
}

# This routine generates the old-style label for numbers.rhtf
#
# Examples:
#
# label         Internal form   Value
# l5390en44     0-pt-5.39e-44   5.390 x 10^-44
# l0_2078       0-pt-0.2078     0.2078
# l1_4142       0-pt-1.4142     1.4142
# l15_154       0-pt-15.154     15.154
# l127          0-pt-127        127
# l720720       0-pt-720720     720720
# l1419_c       0-pt-1419869    1419869
# l_1234e10     0-pt-1.234e10   12345654321 or 1.24 x 10^10
# l_1010e38     0-pt-1.010e38   1.010 x 10^38
# l_p1_340_792  1-pt-340.792    6.2 x 10^340
# l_p1_2098e6   1-pt-2.0989e6   4 x 10^2098959
# l_p1_1000e166 1-pt-1.0e166    10 ^ 10 ^ 166
# l_p2_4342e12  2-pt-4.342e12   10 ^ 10 ^ 4342944819032
# l_p3_36305    4-pt-36305.315  10 ^ 10 ^ 10 ^ 2.069 x 10^36305
sub format4
{
  my($apt, $av) = @_;
  my($rv, $as, $am, $ae);

  ($as, $am, $ae) = &fbc_split($av);

  if ($apt > 0) {
    if ($av >= $k_million) {
      # l_p1_1000e166
      $rv = "l_p" . $apt . "_" . &trunc2($am, 5, "0") . "e" . $ae;
      $rv =~ s/\.//;
    } else {
      # l_p1_340_792
      $rv = "l_p" . $apt . "_" . &trunc2($av, 7, "");
      $rv =~ s/\./_/;
    }
  } elsif ($av >= $k_1e10) {
    # l_1701e38
    $rv = $am;
    $rv =~ s/\.//;
    $rv = &trunc2($rv, 4, "0");
    $rv = "l_" . $rv . "e" . $ae;
  } elsif ($av >= $k_million) {
    # l1419_c
    $am =~ s/\.//;
    $rv = &trunc2($am, 4, "");
    $ae =~ tr/6789/cdef/;
    $rv = "l_" . $rv . "_" . $ae;
  } elsif ($av >= 0.1) {
    # l0_2078, l1_4142, l15_154, l127, l720720
    $rv = "l" . &trunc2($av, 6, "");
    if ($rv =~ m/\./) {
      $rv =~ s/\./_/;
      $rv = &trunc2($rv, 7, "0");
    }
  } else {
    $rv = $am;
    $rv =~ s/\.//;
    $rv = &trunc2($rv, 4, "0");
    $ae =~ s/-/n/;
    $rv = "l" . $rv . "e" . $ae;
  }

  return $rv;
} # End of format4

# Formats a real number with a given number of significant figures,
# with no scientific notation; then substitutes "." (if any) with "_".
sub canon_real
{
  my($v, $p) = @_;

  if ($v =~ m/^\./) { $v = "0" . $v; } # Ensure digit before decimal point
  $p++; if ($v =~ m/^([.0-9]{$p})/) { $v = $1; } # If too long, truncate
  $v =~ s/\./_/;
  $v =~ s/_0+$//; # Remove needless trailing 0's
  $t = $v . "_";
  if ($t =~ m/^[0-9][0-9]_/) { $v = "a" . $v; }
  if ($t =~ m/^[0-9]{3}_/) { $v = "b" . $v; }
  if ($t =~ m/^[0-9]{4}_/) { $v = "c" . $v; }
  if ($t =~ m/^[0-9]{5}_/) { $v = "d" . $v; }
  return $v;
} # End of canon_real

# Formats a scientific-notation number with a given number of
# exponent and mantissa digits for use within for.mat5 labels.
# Arguments:
#
#   $e     exponent
#   $pe    precision for exponent
#   $m     mantissa
#   $pm    precision for mantissa
#
# For example, if you want to format 6.02x10^23 with a precision of 3 in
# both parts, you would call &canon_sci("23", 3, "6.020", 3), which
# becomes 023_602
sub canon_sci
{
  my($e, $pe, $m, $pm) = @_;
  my($ra);

  print "canon_sci($e, $pe, $m, $pm)...\n" if ($format_debug);

  # Check for special cases
  if ($e eq 'inf') {
    print "$e\n" if ($format_debug);
    return($e);
  } elsif ($e eq 'nan') {
    print "$e\n" if ($format_debug);
    return($e);
  }

  # Handle leading 0's e.g. "01.2345..." in mantissa
  if ($m =~ m/^0+[1-9]/) {
    $m =~ s/^0+//;
  }

  # Handle exponent too small for desired field width (left-pad exponent with 0)
  if (!($e =~ m/[0-9]{$pe}/)) {
    $e = ("0" x $pe) . $e;
    if ($e =~ m/([0-9]{$pe})$/) {
      $e = $1;
    }
  }

  # truncate precision of mantissa to one leading digit plus $pm trailing
  # digits. (The extra digit will be removed during rounding)
  $m = $m . ("0" x $pm);
  if ($m =~ m/^([1-9][.][0-9]{$pm})/) {
    $m = $1;
  } else {
    print STDERR "canon_sci (e1): Cannot parse mantissa '$m'\n";
    exit(-1);
  }
  # Perform rounding
  $ra = "0." . ("0" x ($pm-1)) . "5";  # If $pm is 3, this will be "0.005"
  $ra += 0;
  if ($m + $ra < 10.0) {
    $m = $m + $ra;
  } else {
    # We leave "9.99998" alone so it is distinguishable from "10.00002"
  }
  # Truncate again to remove the rounding digit
  if ($m =~ m/^([1-9][0-9.]{$pm})/) {
    $m = $1;
  } elsif (($pm == 3) && ($m =~ m/^([1-9]\.[0-9])/)) {
    $m = $1;
  } else {
    print STDERR (
      "canon_sci (e2): Cannot re-truncate mantissa '$m'\n"
    . "    by pattern '^([1-9][0-9.]{$pm})'; consider adding another\n"
    . "    special case.\n");
    exit(-1);
  }
  # remove mantissa embedded '.'
  $m =~ s/\.//;
  # remove mantissa trailing 0's
  $m =~ s/0+$//;

  print ($e. "_$m\n") if ($format_debug);
  return ($e . "_" . $m);
} # End of canon_sci

# format5 implements the new-style labels that are completely alphabetizable:
#
#  l_234em34    2.34 x 10^-34
#  l0_1          0.1
#  l9_34         9.34
#  la10_2        10.2
#  lb256         256
#  lc1729        1729
#  ld19683       19683
#  le005_1       100000 = 1x10^5
#  le023_602     6.02 x 10^23
#  le299_9       9 x 10^299
#  lp1_b300_0    1 PT 300 = 1x10^300
#  lp1_c2345_6   1 PT 2345.6 {~=} 4x10^2345
#  lp1_e009_345  1 PT 3.45e9 = 10^(3.45*10^9)
#  lp1_e299_999  1 PT 9.99e299 = 10^(9.99x10^299)
#  lp2_b300_0    2 PT 300 = 10^(10^300)
#  lpa10_xxx     10 PT xxx
#  lpa99_xxx     99 PT xxx
#  lpb100_xxx    100 PT xxx
sub format5
{
  my($apt, $av) = @_;
  my($rv, $as, $am, $ae);

  print "format5($apt, $av)...\n" if ($format_debug);
  if ($av eq 'inf') {
    print "format5: = lz_inf\n" if ($format_debug);
    return("lz_inf");
  }

  ($as, $am, $ae) = &fbc_split($av);

  if ($apt > 9) {
    if ($av >= $k_1e5) {
      # l_pa12_e009_345
      $rv = "lp" . &canon_real($apt, 6) . "_e" . &canon_sci($ae, 3, $am, 3);
    } else {
      # l_pa12_c2345_6
      $rv = "lp" . &canon_real($apt, 6) . "_" . &canon_real($av, 6);
    }
  } elsif ($apt > 0) {
    # for now I'll skip the test for PT > 9
    if ($av >= $k_1e5) {
      # l_p1_e009_345
      $rv = "lp" . $apt . "_e" . &canon_sci($ae, 3, $am, 3);
    } else {
      # l_p1_c2345_6
      $rv = "lp" . $apt . "_" . &canon_real($av, 6);
    }
  } elsif ($av >= 1.0e10) {
    # le032_602
    $rv = "le" . &canon_sci($ae, 3, $am, 3);
  } elsif ($av >= 1.0e8) {
    # Use 4 digits of mantissa for 9-digit numbers; for example
    # 535252535 -> le008_5353
    $rv = "le" . &canon_sci($ae, 3, $am, 4);
  } elsif ($av >= 1.0e5) {
    # Use 5 digits of mantissa for 6-, 7- and 8-digit numbers; for example
    # 196560 -> le005_19656
    $rv = "le" . &canon_sci($ae, 3, $am, 5);
  } elsif ($av >= 0.1) {
    # l0_1, l9_34, la10_2, lb256, ld19683
    $av = &prnt3($av, 0, 0, 0);
    $rv = "l" . &canon_real($av, 6);
  } else {
    # Smaller than 0.1 -- not handling alphabetization yet
    $am =~ s/\.//; $ae =~ s/-//;
    $rv = "l_" . &trunc2($am, 3, "") . "em" . $ae;
  }

  print "format5: = $rv\n" if ($format_debug);
  return $rv;
} # End of format5

# format 6 just prints the internal representation of a number (PT and Val)
sub format6
{
  my($apt, $av, $au) = @_;
  my($rv);

  $rv = "|PT${apt}V${av}U$au|";
  return $rv;
} # End of format6

# Convert a (suitably small) number to HH:MM:SS.ff format
sub cv_10_60
{
  my($av) = @_;
  my($rv, $h, $m, $s, $f, $sign);

  # Add 0 to convert "1.3034E2" into "130.34"
  $av += 0;

  # If it still has an "E", it is too big (1.2e27) or too small (1.2e-5)
  if ($av =~ m/[eE]/) {
    return $av;
  }

  # Extract sign
  if ($av =~ m/^-/) {
    $av = - $av;
    $sign = '-';
  } else {
    $sign = '';
  }

  # If there is still a sign, WTF
  if ($av =~ m/-/) {
    print STDERR "*** cv_10_60 parse error '$av'\n";
    return "$sign$av";
  }

  # Extract fraction, preferably without using int function
  if ($av =~ m/^([0-9]+)\.([0-9]+)$/) {
    # Integer and a fraction
    $av = $1; $f = $2;
  } elsif ($av =~ m/^([0-9]+)$/) {
    # All integer
    $av = $1; $f = 0;
  } else {
    # This is the fallback, but i don't like to use it because it often
    # results in something like "0:02:10.340000000000003"
    $f = $av - int($av); $av = int($av);
  }

  # Convert integer portion to base 60
  $rv = '';
  while($av > 0) {
    $m = int($av / 60); $s = $av - (60 * $m);
    $rv = ":" . sprintf("%02d", $s) . $rv;
    $av = $m;
  }

  # Remove initial ":", make it "00" if it's 0
  $rv =~ s/^://;
  if ($rv == 0) {
    $rv = "00";
  }

  # Add the part of the fraction following a leading '0.'
  if ($f > 0) {
    $f =~ s/^ *0*\.//;
    $rv .= ".$f";
  }

  return "$sign$rv";
} # End of cv_10_60

# format 7 outputs small numbers in HH:MM:SS.ff format
sub format7
{
  my($apt, $av, $au) = @_;
  my($rv, $h, $m, $s, $f);

  # Anything more than 9 digits is printed in raw format.
  if (($apt > 0) || (abs($av) >= 1.0e10)) {
    return(&format6($apt, $av, $au));
  }

  if ($au == 0) {
    $rv = &cv_10_60($av);
  } elsif ($au < 60) {
    $m = int($av / 60); $s = $av - (60 * $m);
    $s = &prnt2(100+$s, $au, 0, 0, 0);
    if ($s =~ m/^1([0-9][0-9].*)$/) {
      $s = $1;
    } else {
      print STDERR "format7 cnnot recover seconds '$s'\n";
    }
    if ($m) {
      $rv = &cv_10_60($m) . ":" . $s
    } else {
      $rv = $s;
    }
  } else {
    $rv = &cv_10_60(int($av)) . "(" . &cv_10_60(int($au)) . ")";
  }

<< 'COMMENTED_OUT';
  # Add 0 to convert "1.3034E2" into "130.34"
  $av += 0;

  if ($av =~ m/^([0-9]+)\.([0-9]+)$/) {
    # Integer and a fraction
    $av = $1; $f = $2;
  } elsif ($av =~ m/^([0-9]+)$/) {
    # All integer
    $av = $1; $f = 0;
  } else {
    # This is the fallback, but i don't like to use it because it often
    # results in something like "0:02:10.340000000000003"
    $f = $av - int($av); $av = int($av);
  }

  $m = int($av / 60); $s = $av - (60 * $m);
  $h = int($m / 60); $m = $m - (60 * $h);

  $h = sprintf("%02d", $h);
  $m = sprintf("%02d", $m);
  $s = sprintf("%02d", $s);

  # Include hours only if they aren't "00"
  if ($h > 0) {
    $rv = "$h:$m:$s";
  } else {
    $rv = "$m:$s";
  }

  # Add the part of the fraction following a leading '0.'
  if ($f > 0) {
    $f =~ s/^ *0*\.//;
    $rv .= ".$f";
  }
COMMENTED_OUT

  return $rv;
} # End of format7

# print a PT, given its pt and val as separate arguments.
sub prnt1
{
  my($apt, $av, $au, $newline) = @_;
  my($avi, $avf, $avl, $avl2, $output);
  my($f5_lbl, $afm);

  print "prnt1($apt, $av, $au, $newline)...\n" if ($format_debug);

  if ($fmt_callproc eq "format4") {
    print(&format4($apt, $av) . "::   ");
  } elsif ($fmt_callproc eq "format5") {
    $f5_lbl = &format5($apt, $av);
    print("\n\n" . $f5_lbl . ":: #");
  } elsif ($fmt_callproc eq "format6") {
    print(&format6($apt, $av, $au) . "   ");
  } elsif ($fmt_callproc eq "format7") {
    print(&format7($apt, $av, $au) . "   ");
  }

  if ($doround) {
    # round up
    print "($apt, $av) -> round" if ($format_debug);
    ($apt, $av) = &pt_roundup($apt, $av);
    print " -> ($apt, $av)\n" if ($format_debug);
  }

  $output = "";
  if (&isninf($av)) {
    $output = "- Infinity";
  } elsif (&isinf($av)) {
    $output = "Infinity";
  } elsif (&isnan($av)) {
    $output = "Undefined";
  } elsif ($apt == 0) {
    # Format a PT0.
    print "prnt1 case la-le\n" if ($format_debug);
    $output = &prnt2($av, $au, 0, 0, 1);
  } else {
    # We need to print either "$apt PT $av" or "($apt-1) PT (10^$av)"
    # depending on whether or not $av is less than 10^scale

    if (&f_lt($av, $g_ee_b4)) {
      print "prnt1 n $av, $g_ee_b4\n" if ($format_debug);
      # $av is less than 10^scale -- we have a value like 4.677*10^2345,
      # which will arrive here with the representation 1P2345.67 or
      # 1P2.34567e3. We have to subtract 1 from pt and compute mantissa
      # of 10 ^ val
      # %%% 20190327: Note that this shares a lot of concepts with prnt3
      # and duplicates some functions; it might be nice to figure out how
      # to combine these.

      # get exponent
      $avi = &f_int($av);

      # figure out how many digits of mantissa we can print
      # %%% formerly: &f_int(&f_log10($avi)) + 1;  - 20190408
      $avl = int(log($avi)/log(10)) + 1;
      $avl = $curscale - $avl;
      $avl =~ s| ||g;
      $avl2 = $avl + 1; # 1 extra for decimal point (we'll remove sign)
      $avl2 =~ s| ||g;

      # compute mantissa
      &dbg1("prnt1a mant $av - $avi", 32);
      $avf = &f_pow10(&f_sub($av, $avi));
      &dbg1("prnt1b        -> $avf", 32);
      # remove leading + sign if any (present if fbc_xxx maths is being used)
      $avf =~ s/^[+]//;

      print "prnt1 avf $avf avi $avi avl2 $avl2\n" if ($format_debug);

      # discard insignificant digits of mantissa. We know $avf is
      # of the form D.DDDDDDDDD where D is a digit; and pt.roundup was already
      # used to deal with trailing "999"s so truncation is suitable here.
      if (length($avf) > $avl2) {
        $avf =~ m|^(.{$avl2})|;
        $avf = $1;
      }
      # Discard any trailing ".000"
      if ($avf =~ m|\.|) {
        $avf =~ s|0+$||;
        $avf =~ s|\.$||;
      }
      # Discard leading '+'
      $avf =~ s|^\+||;

      # Handle the "suppress_1" option
      $afm = "$avf$multstr";
      if ($afm eq "1$multstr") {
        $afm = "";
      }

      # Handle first three PT classes separately.
      if ($apt == 1) {
        # 10^1001
        print "prnt1 case p1_a\n" if ($format_debug);
        $output .= "$afm$k10$powstr$e_lstr"
                   . &prnt2($avi, 0, 0, 0, 0) . $e_rstr;
      } elsif ($apt == 2) {
        # 10 ^ ( 10 ^ 1001 )
        print "prnt1 case p2_a\n" if ($format_debug);
        $output .= "$k10$powstr$e_lstr$p1_lstr$afm$k10$powstr$e_lstr"
                    . &prnt2($avi, 0, 0, 0, 0) . "$e_rstr$p1_rstr$e_rstr";
      } elsif ($apt == 3) {
        print "prnt1 case p3_a\n" if ($format_debug);
        $output .= "$k10$powstr$e_lstr$p2_lstr$k10$powstr$e_lstr$p1_lstr"
                   . "$afm$k10$powstr$e_lstr" . &prnt2($avi, 0, 0, 0, 0)
                   . "$e_rstr$p1_rstr$e_rstr$p2_rstr$e_rstr";
      } else {
        print "prnt1 case p4_a\n" if ($format_debug);
        $apt -= 1;
        $output .= "$apt$pt_str$p1_lstr$afm$k10$powstr$e_lstr"
                   . &prnt2($avi, 0, 0, 0, 0) . "$e_rstr$p1_rstr";
      }
    } else {
      print "prnt1 case _e $av\n" if ($format_debug);
      $afm = &prnt2($av, 0, 1, 1, 1);
      if ($apt == 1) {
        print "prnt1 case p1_e\n" if ($format_debug);
        $output .= "$k10$powstr$e_lstr$afm$e_rstr";
      } elsif ($apt == 2) {
        print "prnt1 case p2_e\n" if ($format_debug);
        $output .= "$k10$powstr$e_lstr$p2_lstr$k10$powstr$e_lstr"
                    . "$afm$e_rstr$p2_rstr$e_rstr";
      } else {
        print "prnt1 case p3_e\n" if ($format_debug);
        $output .= "$apt$pt_str$afm";
      }
    }
  }
  $output =~ s| +| |g;
  while(length($output) > $lleft) {
    $output =~ m/^(.{$lleft})(.*)$/;
    print $1;
    print "\\\n";
    $lleft = 78;
    $output = $2;
  }
  print $output;
  if ($fmt_callproc eq "format5") {
    print("# = $lastc6in\n");
    print("  See also [$output|#$f5_lbl].");
  }
  if ($newline) {
    print "\n"; $lleft = 78;
  }
} # End of prnt1

# Sets the strings used to format numbers
sub format1
{
  my($fmt) = @_;

  $k10 = "10";

  # Handle the special types
  if ($fmt == 4) {
    $fmt_callproc = "format4";
    $fmt = 2;
  } elsif ($fmt == 5) {
    $fmt_callproc = "format5";
    $fmt = 2;
  } elsif ($fmt == 6) {
    $fmt_callproc = "format6";
    $fmt = 1;
  } elsif ($fmt == 7) {
    $fmt_callproc = "format7";
    $fmt = 1;
  } else {
    $fmt_callproc = "";
  }

  # 20100113: I decided to make p1_lstr, etc. null because () and []
  # seem superfluous when there is <sup> or {}
  if ($fmt == 3) {
    $multstr = "&times";
    $powstr = "";
    $e_lstr = "<sup>";
    $e_rstr = "</sup>";
    $p1_lstr = ""; # "(";
    $p1_rstr = ""; # ")";
    $p2_lstr = ""; # "[";
    $p2_rstr = ""; # "]";
    $pt_str = "&nbsp;PT&nbsp;";
  } elsif ($fmt == 2) {
    $multstr = "{x}";
    $powstr = "^";
    $e_lstr = "{";
    $e_rstr = "}";
    $p1_lstr = ""; # "(";
    $p1_rstr = ""; # ")";
    $p2_lstr = ""; # "[";
    $p2_rstr = ""; # "]";
    $pt_str = "\@pt\@";
  } else {
    $multstr = " x ";
    $powstr = " ^ ";
    $e_lstr = "";
    $e_rstr = "";
    $p1_lstr = " ( ";
    $p1_rstr = " ) ";
    $p2_lstr = " [ ";
    $p2_rstr = " ] ";
    $pt_str = " PT ";
  }
} # End of format1

# sub expand.ihist
# {
#   my($cmd) = @_;
#   my($rv);
#
#   $rv = $cmd;
#   while(" $rv " =~ m|^(.+)[cC]([0-9]+)([^0-9].*)$|) {
#     $rv = $1 . "(" . $input_history[$2] . ")" . $3;
#   }
#   return $rv;
# }
sub expand_C_hist
{
  my($e) = @_;
  my(%h);
  my($pre, $post, $tn, $te, $tv, $rv, $t2);

  $rv = $e;

  while(" $rv " =~ m|^(.*[^a-zA-Z_0-9])[cC]([0-9]+)([^0-9].*)$|) {
    $pre = $1; $tn = $2; $post = $3;
    if ($h{$tn} ne "") {
      $tv = $h{$tn};
    } else {
      $te = $input_history[$tn];
      $tv = &expand_C_hist($te);
      # Here we would want to actually evaluate $tv and get a string
      # numeric result, but that's too hard to do right now.
      $h{$tn} = $tv;
      # print "tn $tn te $te tv $tv\n";
    }
    if (!($BASIC_running)) {
      print "C$tn: $tv\n";
    }
    $lleft = 78;
    if ($tv =~ m/^\(.*\)$/) {
      # We already have parens
    } else {
      # Add parens
      $tv = "(" . $tv . ")";
    }
    $rv = $pre . $tv . $post;
    if (!($BASIC_running)) {
      $t2 = $rv;
      $t2 =~ s/^ +//;
      print "C$ihnum: $t2\n";
    }
  }

  return $rv;
} # End of expand.C_hist

# expand.ih2 interpolates commands like "c3" into the input string,
# and changes 'x' to '*' when appropriate.
sub expand_ih2
{
  my($e) = @_;
  my($rv);

  $rv = &expand_C_hist($e);

  # Pre-translate 'x' for multiplication when next to parentheses. These
  # are the cases where it is clearly not a variable 'x'.
  $rv =~ s| x\(| *\(|g;
  $rv =~ s|\)x\(|\)*\(|g;
  $rv =~ s|\)x |\)* |g;

  # Allow them to use 'x' to multiply if padded with spaces and next to
  # a variable.
  $rv =~ s|($p_var) x |$1 * |g;
  $rv =~ s| x ($p_var)| * $1|g;

  # Any operator made of letters needs to be remapped now
  $rv =~ s|\band\b|\&|g;
  $rv =~ s|\bmod\b|\%|g;
  $rv =~ s|\bnot\b|\~|g;
  $rv =~ s|\bor\b|\||g;

  # Now remove all remaining spaces
  $rv =~ s| +||g;

  return $rv;
} # End of expand.ih2

# Add a command to the command-history list.
sub define_Chist
{
  my($cmd) = @_;

  return if ($BASIC_running);

  $input_history[$ihnum] = $cmd;
  $ihnum++;
}

$pragma_any_next = 1;
$g_BASIC_trace = 0;

# do.cmd3 handles 'C[0-9]' substitution and '<var>=<expr>'; the rest
# is done by eval.1
#
# If $BASIC.running $prflag controls printing: 0 for none, 1 for just the
# number, 2 for surrounding formatting
sub docmd3
{
  my($cmd, $prflag, $allow_assign) = @_;
  my($pr, $sverr);
  my($lv_pt, $lv_val, $lv_unc);

  &dbg1("dc3.01 cmd '$cmd' $prflag $allow_assign", 16);

  if ($cmd eq "") {
    &dbg1("dc3.02 '$cmd'", 16);
    return;
  }

  if ($BASIC_running) {
    $pr = $prflag;
  } else {
    $pr = 2;
  }

  &dbg1("dc3.03 $cmd", 16);

  # First, save input string into input history
  # Expand first, to prevent infinite recursion
  $cmd = &expand_ih2($cmd);
  &dbg1("dc3.04 $cmd", 16);
  if ($pr) {
    &define_Chist($cmd);
  }

  &dbg1("dc3.05 $cmd", 16);

#  # Parse out variable assignment syntax, if any
#  # %%% most of this can go away, and be replaced by looking at
#  # $g_possible_assign and associated variables set by eval.2
#  $setvar = "";
#  if ($allow_assign == 0) {
#    # We're an rvalue expression, do not attempt to assign anything
#  } elsif ($cmd =~ m|^($p_var) *=([^=].*)$|) {
#    # var = expr
#    $setvar = $1;
#    $cmd = $2;
#    &dbg1("dc3.06 setvar2 $setvar $cmd", 16);
#  } elsif ($cmd =~ m|^\(($p_var) *=([^=].*)\)$|) {
#    # (var = expr)       (This form is seen after !! substitution)
#    $setvar = $1;
#    $cmd = $2;
#    &dbg1("dc3.07 setvar3 $setvar $cmd", 16);
#  }
#  $sverr = "";
#  if (($setvar eq 'pi') || ($setvar eq 'e') || ($setvar eq 'phi')) {
#    $sverr = "Attempt to set builtin constant";
#  } elsif ($setvar =~ m/^[cr][0-9]+$/) {
#    # %%% NOTE: command variables like "c1" have just been parsed out
#    # by the call to expand.ih2 above, so this currently only catches
#    # result vars like "r1"
#    $sverr = "Attempt to set history value";
#  }
#  if ($sverr ne "") {
#    if ($BASIC_running) {
#      print "*** ";
#    }
#    print "ERROR: $sverr '$setvar'\n";
#    $setvar = ""; $BASIC_running = 0;
#  }

  # Evaluate, and store result in LV (last value) registers.
  ($lv_pt, $lv_val, $lv_unc) = &eval_1($cmd);

  if ($allow_assign && $g_possible_assign) {
    # We just evaluated a valid assignment.
    ($lv_pt, $lv_val, $lv_unc) = ($g_assign_pt, $g_assign_val, $g_assign_unc);
    &set_var($g_assign_lvk, $lv_pt, $lv_val, $lv_unc);
  }

  if ($pr>1) {
    print "\n"; $lleft = 78;
  }

  if ($pr>1) {
    $hname = &define_R_hist($lv_pt, $lv_val, $lv_unc);
    print "$hname = ";
    $lleft -= length("$hname = ");
  }

#  if ($setvar ne "") {
#    &set_var($setvar, $lv_pt, $lv_val, $lv_unc);
#    if ($pr>1) {
#      print "$setvar: ";
#      $lleft -= length("$setvar: ");
#    }
#  }

  if (($pr > 1) && $allow_assign && $g_possible_assign) {
    print "$g_assign_lvk: ";
    $lleft -= length("$g_assign_lvk: ");
  }

  if ($pr) {
    &prnt1($lv_pt, $lv_val, $lv_unc, ($pr>1));

    # 20080204: The following seems to produce lots of superfluous
    # blank lines, so I removed it and added a newline just before
    # the command prompt in the main loop.
    # print "\n"; $lleft = 78;
  }
} # End of do.cmd3

# po.override provides a way for the 'tron' command and pragma settings
# to alter how much gets printed out. It is used to remap the value of
# $punc in relevant places.
$g_por_from = ":;";
$g_por_to   = ":;";

sub pr_override
{
  my($p) = @_;
  eval "\$p =~ tr/$g_por_from/$g_por_to/;";
  return $p;
} # End of pr.override

sub cmd_pragma
{
  my($args) = @_;
  my($arg, $rest, $pr);

  $pr = !($BASIC_running);
  $args =~ s/ //g;
  $args .= ',';
  while($args =~ m/^([^,]+),(.*)$/) {
    $arg = $1; $rest = $2;
    if (0) {
    } elsif ($arg eq 'notrace') {
      # Suppress printing line numbers and assignments (TROFF command)
      $g_por_to   = ":;";
      $g_BASIC_trace = 0;
      print "pragma: trace disabled, g_por_to = '$g_por_to'\n" if($pr);
    } elsif ($arg eq 'printassign') {
      # Print assignments, (including from READ and FOR..NEXT) unless
      # there is a ';'
      $g_por_to = ':;';
      print "pragma: normal mode, g_por_to = '$g_por_to'\n" if($pr);
    } elsif ($arg eq 'quiet') {
      # Never print assignments (normal behaviour for mose BASICs)
      $g_por_to = ';;';
      print "pragma: quiet mode, g_por_to = '$g_por_to'\n" if($pr);
    } elsif ($arg eq 'trace') {
      # Print all assignments (useful for a TRON command)
      $g_por_to = '::';
      $g_BASIC_trace = 1;
      print "pragma: trace enabled, g_por_to = '$g_por_to'\n" if($pr);
    }
    $args = $rest;
  }
} # End of cmd.pragma

sub setscale
{
  my($newscale, $prflag) = @_;

  undef @igv;

  if ($inunix) {
    # Limit the scale. This is important -- lots of fundamental
    # assumptions in the PT algorithms fail if the number of
    # significant digits in the mantissa is greater than the
    # exponent value at which promotion occurs. Since promotion
    # happens at 1.0e300, we have to limit the scale to a bit less
    # than this.
    if ($newscale > 295) {
      print "I am setting scale to 295, the maximum allowed.\n" if ($prflag);
      $newscale = 295;
    }
    $newprim = ($newscale > 14) ? "bc" : "nat";
    if ($newprim ne $curprim) {
      # close old functions
      if ($curprim eq "bc") {
        &fbc_close();
      } else {
        &f64_close();
      }

      # and open new ones
      if ($newprim eq "bc") {
        &fbc_init($newscale);
      } else {
        &f64_init();
      }
    } elsif ($newprim eq "bc") {
      # re-scale
      &fbc_rescale($newscale);
    }
    $curprim = $newprim;
    $curscale = $newscale;
    &hi_init($prflag);
  } else {
    print "Sorry precision (scale) can only be changed in UNIX.\n" if ($prflag);
  }
} # End of set.scale

# do.cmd4 handles special-variable setting (scale, debug, format) and passes
# everything else along to do.cmd3
#
# If $BASIC.running and $prflag is 0, printing is suppressed.
sub docmd4
{
  my($cmd, $prflag) = @_;
  my($cmdre, $a);

  &dbg1("dc4a: $cmd", 16);

  $cmdre = $cmd;
  $cmdre =~ s|[^0-9a-zA-Z]||g;

  # Special commands like #pragma# and #scale# go here
  if (0) {
  } elsif ($cmd =~ m|^pragma +(.+)$|) {
    $a = $1;
    &cmd_pragma($a);
  } elsif ($cmd =~ m|^scale *\= *([0-9]+)|) {
    $newscale = $1;
    &setscale($newscale, $prflag);
  } elsif ((length($cmdre) > 0) && ("quit" =~ m|^$cmdre|i)) {
    $g_mainl_going = 0;
  } else {
    &docmd3($cmd, $prflag, 1);
  }
} # End of do.cmd4

# Convert a number with ":" characters (sexagesimal integer) into a normal
# number
sub cv_60_10
{
  my($e) = @_;
  my($h, $m, $s);

  if ($e =~ m|^([0-9]+):([0-9]+):([0-9.]+)$|) {
    $h = $1; $m = $2; $s = $3;
    $e = ($h * 60 + $m) * 60 + $s;
  } elsif ($e =~ m|^([0-9]+):([0-9.]+)$|) {
    $m = $1; $s = $2;
    $e = $m * 60 + $s;
  }
  return $e;
} # End of cv.60_10

# do.cmd6 handles:
#   '!!' (double exclamation point) repeat last typed input
#   '[ ]' (square brackets) same as parentheses
#   ':' (colon) command separator, or sexagesimal fraction
#   ';' (semicolon) suppress printing the result
# and passes the rest to do.cmd4
sub docmd6
{
  my($cmd) = @_;
  my($c1, $c2, $c3, $showit, $punc, $prflag);

  # Map [] onto () (Note: [] are used internally within the eval
  # routines)
  $cmd =~ tr|\[\]|\(\)|;

  # map all alphabetics to lower case, so that we can use uppercase letters
  # as symbols for functions etc.
  $cmd = lc($cmd);

  # handle ":" within numbers (sexagesimal fraction)
  # NOTE: we only convert the integer portion, any fraction can be left as-is
  # This allows uncertainty to work, e.g. "1:23.4(12)" is equivalent to
  # "83.4(12)" which is 83.4 +- 1.2
  $cmd =~ s/([0-9]+:[0-9]+:[0-9]+:[0-9]+)/&cv_60_10($1)/ge;
  $cmd =~ s/([0-9]+:[0-9]+:[0-9]+)/&cv_60_10($1)/ge;
  $cmd =~ s/([0-9]+:[0-9:]+)/&cv_60_10($1)/ge;

  # Replace '!!' with previous typed command
  &dbg1("dc6a: $cmd", 16);
  $cmd = " " . $cmd;
  $didit = 0;
  while($cmd =~ m|^(.*)([- +*x/^(;:])\!\!(.*)$|) { # ) balance
    $c1 = $1; $c2 = $2; $c3 = $3;
    $cmd = "$c1$c2$lastc6in$c3";
    if (!($BASIC_running)) {
      if ($didit == 0) {
        print "!!: $lastc6in\n";
        $didit = 1;
      }
      print "C$ihnum: $cmd\n";
    }
  }
  $cmd =~ s/^ +//;
  $lastc6in = $cmd;
  &dbg1("dc6b: $cmd", 16);

  # Execute commands separated by ':' and/or ';'. A ';' separator prevents
  # the value from being printed.
  while($cmd =~ m|^([^:;]*)([:;])(.*)$|) {
    $c1 = $1;
    $punc = $2;
    $cmd = $3;
    $punc = &pr_override($punc);
    if (!($c1 =~ m/^ *$/)) {
      $showit = ($punc eq ':');
      $prflag = $showit ? 2 : 0;
      &docmd4($c1, $prflag);
    }
  }
  # Do the last one
  if (!($cmd =~ m/^ *$/)) {
    $punc = ($cmd =~ m|\;|) ? ';' : ':';
    $punc = &pr_override($punc);
    $showit = ($punc eq ':');
    $prflag = $showit ? 2 : 0;
    &docmd4($cmd, $prflag);
  }
} # End of do.cmd6

# PRINT: Loop on arguments, evaluate and print
sub BASIC_print
{
  my($c2) = @_;
  my($f1, $f2, $v);

  $c2 =~ s/ +$//;
  # Make sure the arguments end with a formatting-separator: if ',' or ';'
  # is not present, add "'" to signify a normal CRLF ending
  if (!($c2 =~ m/[,;]$/)) {
    $c2 .= "'";
  }
  $f2 = "";
  while($c2 ne "") {
    # print "Bpr1 c2 '$c2'\n";
    # Get atoms separated by , or ; or final single-quote which means the
    # print should end with a newline
    $v = $f2;
    if ($c2 =~ m|^ *"([^"]*)" *([,;'])(.*)$|) {
      # literal string
      $f1 = $1; $f2 = $2; $c2 = $3;
      # print "Bpr2 f1 '$f1' f2 '$f2' c2 '$c2'\n";
      print $f1;
      if ($f2 eq ',') {
        print "\t";
      } elsif ($f2 eq "'") {
        # We're at the end of the arguments and we want a CRLF.
        print "\n";
      }
    } elsif ($c2 =~ m|^($p_var\([^\)]+\))([,;'])(.*)$|i) {
      # Function or array reference with one set of parentheses
      $f1 = $1; $f2 = $2; $c2 = $3;
      # print "Bpr3 f1 '$f1' f2 '$f2' c2 '$c2'\n";
      $f1 =~ s|^ +||; $f1 =~ s| +$||;
      if ($f1 ne "") {
        # It's an expression

        # Map to lower case so we can use uppercase for functions, etc.
        $f1 = lc($f1);

        &docmd3($f1, 1, 0);
      }
      if ($f2 eq ',') {
        print "\t";
      } elsif ($f2 eq "'") {
        # We're at the end of the arguments and we want a CRLF.
        print "\n";
      }
    } elsif ($c2 =~ m|^([^,;']*)([,;'])(.*)$|) {
      # Something else, hopefully an expression
      $f1 = $1; $f2 = $2; $c2 = $3;
      # print "Bpr4 f1 '$f1' f2 '$f2' c2 '$c2'\n";
      $f1 =~ s|^ +||; $f1 =~ s| +$||;
      if ($f1 ne "") {
        # It's an expression

        # Map to lower case so we can use uppercase for functions, etc.
        $f1 = lc($f1);

        &docmd3($f1, 1, 0);
      }
      if ($f2 eq ',') {
        print "\t";
      } elsif ($f2 eq "'") {
        # We're at the end of the arguments and we want a CRLF.
        print "\n";
      }
    } else {
      $c2 = "";
    }
  }
} # End of BASIC.print

# Perform simple variable substitution for FOR loop limits. Only regular
# PT0 values with no uncertainty are allowed.
sub subst_var
{
  my($v) = @_;

  if ($vars_pt{$v} ne "") {
    if (($vars_pt{$v} == 0) && ($vars_unc{$v} == 0)) {
      $v = $vars_val{$v};
    } else {
      print "*** Illegal value '$v', in line $g_BASIC_pc\n";
      $BASIC_running = 0;
    }
  }
  return $v;
} # End of subst.var

sub remove_comments
{
  my($in) = @_;
  my($out, $p1, $p2);

  # print "remove_comments: '$in'\n";
  $out = '';
  while ($in ne '') {
    if ($in =~ m/^([^'"]+)(['"].*)$/) {
      # A piece, followed by ' or "
      $p1 = $1; $p2 = $2;
      # print "  rc1 '$p1'$p2'\n";
      $out .= $p1;
      $in = $p2;
    } elsif ($in =~ m/^' *pragma (.*)$/i) {
      # The rest is a pragma
      $in = $1;
      # print "  rc2 '$in\n";
      &cmd_pragma($in);
      $in = '';
    } elsif ($in =~ m/^'/) {
      # The rest is a comment
      # print "  rc3 '$in\n";
      $in = '';
    } elsif ($in =~ m/^("[^"]*")(.*)$/) {
      # Quoted string
      $p1 = $1; $p2 = $2;
      # print "  rc4 '$p1'$p2'\n";
      $out .= $p1; $in = $p2;
    } else {
      # Shouldn't happen, but we do this just in case
      $out .= $in;
      # print "  rcdflt '$in'\n";
      $in = '';
    }
  }
  return $out;
} # End of remove.comments

# Get one data item from a DATA statement and execute the assignment
# statement to put it into a variable
sub get_datum
{
  my($v, $punc) = @_;
  my($c2);

  $punc = &pr_override($punc);
  if ($BASIC_datum < $BASIC_ndat) {
    $c2 = "$v = $BASIC_data[$BASIC_datum] $punc"; $BASIC_datum++;
    &docmd6(lc($c2));
  } else {
    print "*** Out of data in line $g_BASIC_pc\n";
    $BASIC_running = 0;
    return -1;
  }
} # End of get.datum

# This routine handles the runtime BASIC commands, e.g. the no-ops like
# PRINT and LET and flow control ops like FOR..NEXT
sub docmd10
{
  my($cmd, $pc) = @_;
  my($c2, $v, $f1, $f2, $prflag, $nv, $punc);

  &dbg1("dc10a: $cmd", 16);

  $cmd = &remove_comments($cmd);

  if (0) {
  } elsif ($cmd =~ m/^ *$/) {
    # no-op; skip
  } elsif ($cmd =~ m/^ *rem\b/i) {
    # remark -- ignore
  } elsif ($cmd =~ m/^ *'/) {
    # remark -- ignore

  } elsif ($cmd =~ m/^ *data /i) {
    # DATA statements are not directly executed

  } elsif ($cmd =~ m/^def +fn($p_var)\(($p_var)\) *= *(.*)$/i) {
    $f1 = $1; $v = $2; $f2 = $3;
    $v = lc($v);
    # %%% for now this is simply ignored

  } elsif ($cmd =~ m/^dim +$p_var\( *[0-9]+ *\) *$/i) {
    # %%% for now we ignore, but we could theoretically remember the limits
    # and enforce
  } elsif ($cmd =~ m/^dim +$p_var\( *[0-9]+ *, *[0-9]+ *\) *$/i) {

  } elsif ($cmd =~ m/^ *end *$/i) {
    $BASIC_running = 0;

  } elsif ($cmd =~ m/^for +($p_var) *= *([0-9_a-z]+) +to +([0-9_a-z]+)(;?)/i) {
    $v = $1; $f1 = $2; $f2 = $3; $punc = $4;
    $v = lc($v);
    if ($punc eq '') { $punc = ':'; }
    $punc = &pr_override($punc);
    $prflag = ($punc eq ';') ? 0 : 2;

    $f1 = &subst_var($f1);
    $f2 = &subst_var($f2);

    # print "FOR $v $f1 $f2\n";
    $for_level++;
    $next_var[$for_level] = $v;
    # print "line $g_BASIC_pc next_var[$for_level] = '$v'\n";
    $next_limit[$for_level] = $f2;        $for_var_limit{$v} = $f2;
    $next_loopto[$for_level] = $pc;       $for_var_loopto{$v} = $pc;
    $next_prflag[$for_level] = $prflag;   $for_var_prflag{$v} = $prflag;

    # convert to LET
    $c2 = "$v = $f1";
    &docmd6("$c2$punc");

  } elsif ($cmd =~ m/^go ?to +([0-9]+) *$/i) {
    $f1 = $1;
    if ($BASIC{$f1} ne '') {
      return $f1;
    } else {
      print "*** Undefined line number in GOTO\n";
      $BASIC_running = 0;
      return 0;
    }

  } elsif ($cmd =~ m/^gosub +([0-9]+) *$/i) {
    $f1 = $1;
    if ($BASIC{$f1} ne '') {
      $substack[$gosub_level++] = $NEXT{$g_BASIC_pc};
      return $f1;
    } else {
      print "*** Undefined line number in GOSUB in line $g_BASIC_pc\n";
      $BASIC_running = 0;
      return 0;
    }

  } elsif ($cmd =~ m/^if +(.+) +then +([0-9]+) *$/i) {
    # Original IF..THEN format (one-line, implied GOTO)
    $f1 = $1; $f2 = $2;
    # Evaluate the expression
    &docmd6("if_result = ($f1);");
    if (&subst_var("if_result")) {
      # Take the branch
      if ($BASIC{$f2} ne '') {
        return $f2;
      } else {
        print "*** Undefined line number in IF..THEN in line $g_BASIC_pc\n";
        $BASIC_running = 0;
        return 0;
      }
    }

  } elsif (($cmd =~ m/^(if) +(.+) +then *$/i)
        || ($cmd =~ m/^(else) +if +(.+) +then *$/i)
  ) {
    # Structured multi-line IF
    $f1 = $1; $f2 = $2;
    if (lc($f1) eq 'if') {
      # This is the first block
      $IF_level++;
      $IF_didit[$IF_level] = 0;
    }
    if ($IF_didit[$IF_level]) {
      # We have already executed a section of this IF .. ELSE .. structure.
      # jump to the next (we'll keep doing to until we reach the END IF)
      $f1 = 0;
    } else {
      # Evaluate the expression
      &docmd6("if_result = ($f2);");
      $f1 = &subst_var("if_result");
    }
    if ($f1) {
      # We want to execute this block. Treat this line as a comment and
      # the caller (BASIC.run) goes to the following line.
      $IF_didit[$IF_level] = 1;
    } else {
      # Jump to the next ELSE or to the END IF
      $f2 = $IF_next{$pc};
      if ($BASIC{$f2} ne '') {
        return $f2;
      } else {
        print "*** IF clause at line $g_BASIC_pc lacks branch target (ELSE or END IF)\n";
        $BASIC_running = 0;
        return 0;
      }
    }

  } elsif ($cmd =~ m/^ *else *$/i) {
    # a bare ELSE clause always gets executed (unless we've already done a
    # block of the current IF..THEN)
    if ($IF_didit[$IF_level]) {
      # Jump to the next condition, or to END IF
      $f2 = $IF_next{$pc};
      if ($BASIC{$f2} ne '') {
        return $f2;
      } else {
        print "*** ELSE clause at line $g_BASIC_pc lacks END IF\n";
        $BASIC_running = 0;
        return 0;
      }
    }
    # Else we'll just drop through and execute this block
    $IF_didit[$IF_level] = 1;

  } elsif ($cmd =~ m/^ *end +if *$/i) {
    # END IF: If we got here we just treat it like a REM and the next line
    # will get executed
    if ($IF_level > 0) {
      $IF_level--;
    }

  } elsif ($cmd =~ m/^ *input +($p_multvars)(;?) *$/i) {
    # Input number(s) from TTY into variable(s). All input must be
    # valid Hypercalc-format numbers
    $f1 = $1 . ", "; $punc = $2; $f2 = '';
    if ($punc eq '') { $punc = ':'; }
    while ($f1 =~ m/^ *($p_var),($p_multvars)$/i) {
      $v = $1; $f1 = $2;
      if ($f2 eq '') {
        if ($punc ne ';') {
          # Normal INPUT prompt
          print "? ";
        }
        # We need to get more numbers from the user
        $f2 = <>; chomp $f2; $f2 .= ", ";
      }
      if ($f2 =~ m/^ *($p_rawarg),(.*)$/i) {
        $c2 = "$v = $1;"; $f2 = $2;
        &docmd6(lc($c2));
      } else {
        print "*** Bad format for INPUT in line $g_BASIC_pc\n";
        $BASIC_running = 0;
        return 0;
      }
      $f2 =~ s/^ *//;
    }
    $f1 =~ s/ +//;

    if ($f1 ne '') {
      print "*** Syntax error in line $g_BASIC_pc\n";
      $BASIC_running = 0;
      return 0;
    }

    if ($f2 ne '') {
      print "*** Too much input -- excess ignored\n";
    }

  } elsif ($cmd =~ m/^ *let +(.*)([:;]?)$/i) {
    $c2 = $1; $punc = $2;
    if ($punc eq '') { $punc = ':'; }
    $punc = &pr_override($punc);
    $c2 = lc($c2);
    &docmd6("$c2$punc");

  } elsif ($cmd =~ m/^ *next +($p_var) *([:;]?) *$/i) {
    # convert to LET
    $nv = $1; $punc = $2;
    $nv = lc($nv);
    if ($punc eq '') { $punc = ':'; }
    $punc = &pr_override($punc);
    $v = $next_var[$for_level];
    # print "   next $v (to $for_var_limit{$v})\n";
    if (($nv ne $v) && $pragma_any_next) {
      # We can do any NEXT that is currently pending...
      $v = $nv;
      if ($for_var_limit{$v} eq '') {
        # ... but we can't use this $v either, no loop is defined!
        print "*** NEXT without FOR in line $g_BASIC_pc\n";
        $BASIC_running = 0;
        return 0;
      }
    } elsif ($nv ne $v) {
      print "*** NEXT using wrong variable ($nv but expected $v) in line $g_BASIC_pc\n";
      $BASIC_running = 0;
      return 0;
    }

    # Check printing choice given in the FOR line
    $prflag = $for_var_prflag{$v};
    # %%% we now allow the NEXT's punctuation to govern. Formerly we
    # had:     $punc = &pr_override($prflag ? ':' : ';');    - 20190505
    $c2 = "$v = $v + 1";
    &docmd6("$c2$punc");

    # Evaluate the loop limit
    # %%% this will require a PRAGMA, some BASICs only evaluate the loop
    # limit once
    &docmd6("next_limit = ($for_var_limit{$v});");
    $f1 = &subst_var("next_limit");

    # test for overflow
    if ($vars_val{$v} > $f1) {
      # we're done
      $for_level--;
      $for_var_prflag{$v} = '';
    } else {
      # jump back to loop
      return $NEXT{$for_var_loopto{$v}};
    }

  } elsif ($cmd =~ m/^ *next +/i) {
    print "*** NEXT without variable, line $g_BASIC_pc: '$cmd'\n";
    $BASIC_running = 0;
    return 0;

  } elsif ($cmd =~ m/^ *print +(.*)$/i) {
    $c2 = $1;
    &BASIC_print($c2);

  # %%% RANDOMIZE function

  } elsif ($cmd =~ m/^ *read +(.+) *$/i) {
    $f1 = $1;
    if ($f1 =~ m/^(.+);$/) {
      $f1 = $1; $punc = ';';
    } else {
      $punc = ':';
    }
    $punc = &pr_override($punc);
    $f1 = $1 . ", "; $gg = 1;
    while($gg) {
      $gg = 0;
      if ($f1 =~ m/^ *([^,\(]+),(.+)$/i) {
        $v = $1; $f1 = $2; $gg = 1;
        if (&get_datum($v, $punc) < 0) { return 0; }
      } elsif ($f1 =~ m/^ *($p_var\([^\)]+\)),(.+)$/i) {
        $v = $1; $f1 = $2; $gg = 1;
        if (&get_datum($v, $punc) < 0) { return 0; }
      }
      $f1 =~ s/ +//;
    }
    if ($f1 ne '') {
      print "*** Syntax error in line $g_BASIC_pc\n";
      $BASIC_running = 0;
      return 0;
    }

  } elsif ($cmd =~ m/^ *restore *$/i) {
    # Restore DATA pointer, next READ statement will get the first datum
    $BASIC_datum = 0;

    # %%% RESTORE also had a variant that accepted a line number parameter

  } elsif ($cmd =~ m/^ *return *$/i) {
    if ($gosub_level <= 0) {
      print "*** RETURN without GOSUB\n";
      $BASIC_running = 0;
      return 0;
    } else {
      $f1 = $substack[--$gosub_level];
      return $f1;
    }

  } elsif ($cmd =~ m/^ *stop */i) {
    # STOP is the same as END
    $BASIC_running = 0;

  } else {
    # Anything else is taken as being a normal command.
    $cmd = lc($cmd);
    &docmd6($cmd);
  }

  return 0;
} # End of do.cmd10

# This routine scans through the BASIC program, setting up the pointers
# used for the flow control operators, indenting for LIST command, and a
# few simple error checks (like NEXT without FOR)
#   %%% NOTE: We parse IF .. THEN and ELSE IF, but these are not yet
# handled by do.cmd10
sub BASIC_parse
{
  my($ln, $prev, $cmd, $indent, $next_indent);
  my($v, $f1, $f2);

  # First we have to set up the next pointers
  $lleft = 78;
  $prev = "";
  $next_indent = 0;
  $IF_level = 0;
  undef %IF_next;
  @BASIC_data = ();
  $BASIC_ndat = 0;
  foreach $ln (sort {$a <=> $b} (keys %BASIC)) {
    $indent = $next_indent;
    if ($prev eq "") {
      $BASIC_first = $ln;
    } else {
      $NEXT{$prev} = $ln;
    }
    $prev = $ln;

    $cmd = $BASIC{$ln};
    $cmd =~ s/^ *//;
    $BASIC{$ln} = $cmd;

    if ($cmd eq "") {
      # no-op; skip

    } elsif ($cmd =~ m/^data +($p_rawargs)$/i) {
      # DATA statement: Parse and store values
      $f1 = $1 . ", ";
      while($f1 =~ m/^ *($p_rawarg),(.*)$/i) {
        $v = $1; $f1 = $2;
        $BASIC_data[$BASIC_ndat++] = $v;
      }
      $f1 =~ s/ +//;
      if ($f1 ne '') {
        print "*** Syntax error in DATA statement, line $ln\n";
        return $ln;
      }
    } elsif ($cmd =~ m/^data /i) {
      print "*** Syntax error in DATA statement, line $ln\n";
      return $ln;

    } elsif ($cmd =~ m/^for +($p_var) *= *([0-9a-z]+) +to +([0-9a-z]+)/i) {
      $next_indent++;
    } elsif ($cmd =~ m/^for /i) {
      print "*** Syntax error in FOR statement, line $ln\n";
      return $ln;
    } elsif ($cmd =~ m/^ *next /i) {
      if ($indent > 0) {
        $indent--;
      } else {
        print "*** NEXT without FOR in line $ln\n";
        return $ln;
      }
      $next_indent = $indent;

    } elsif ($cmd =~ m/^if +.* +then +[0-9]+ *$/i) {
      # One-liner IF..THEN, no change to indentation

    } elsif ($cmd =~ m/^if +/i) {
      $next_indent++;

      $IF_level++;
      $IF_ln[$IF_level] = $ln;
      $IF_matched[$IF_level] = 0;
    } elsif (($cmd =~ m/^else +if /i) || ($cmd =~ m/^else *$/i)) {
      if ($IF_level > 0) {
        $indent--; # Just this line will be unindented
      } else {
        print "*** ELSE without IF in line $ln\n";
        return $ln;
      }

      $IF_next{$IF_ln[$IF_level]} = $ln;
      $IF_ln[$IF_level] = $ln;

    } elsif ($cmd =~ m/^else/i) {
      print "*** Syntax error in line $ln\n";
      return $ln;

    } elsif ($cmd =~ m/^end +if *$/i) {
      if ($IF_level > 0) {
        $indent--;
      } else {
        print "*** END IF without IF in line $ln\n";
        return $ln;
      }
      $next_indent = $indent;

      $IF_next{$IF_ln[$IF_level]} = $ln;
      $IF_next{$ln} = 0;
      $IF_level--;
    } elsif ($cmd =~ m/^ *rem +/i) {
      # remark -- ignore
    } elsif ($cmd =~ m/^ *'/) {
      # remark -- ignore
    }

    $BASIC_indent{$ln} = $indent;
  }

  if ($next_indent > 0) {
    print "*** FOR without NEXT\n";
    return $prev;
  }

  return 0;
} # End of BASIC.parse

use Time::HiRes qw(gettimeofday);

sub BASIC_run
{
  my($cmd, $err, $next);
  my($t_start, $t_end, $n_cmds);

  # Scan through the program to establish line numbering, target jump
  # addresses for IF..THEN blocks, etc.
  $err = &BASIC_parse();
  if ($err) {
    return;
  }

  # We'll trap ^C so the user can get out of an infinite loop
  # NOTE: This does not work when we're using the #bc# module
  $SIG{'INT'} = sub {
    if ($BASIC_running) {
      print "\n\n*** BREAK by user at line $g_BASIC_pc\n";
      $BASIC_running = -1;
    }
    if ((time - $sigint_time) < 3) {
      # They did it two times quickly, so we should exit                          
      exit(-1);
    } else {
      print "(to force-quit Hypercalc, hit ^C again quickly)\n";
    }
    $sigint_time = time;
  };

  $g_BASIC_pc = $BASIC_first;
  $BASIC_running = 1;
  $n_cmds = 0; $t_start = gettimeofday;
  $BASIC_datum = 0;
  while($BASIC_running > 0) {
    if ($g_BASIC_trace) {
      print "BASIC line $g_BASIC_pc\n";
    }
    # Fetch instruction
    $cmd = $BASIC{$g_BASIC_pc};

    # Execute command
    $next = &docmd10($cmd, $g_BASIC_pc);
    $n_cmds++;

    # If we're still running, test for end of file
    if ($BASIC_running) {
      if ($next != 0) {
        # docmd10 has explicitly selected a line to run next
        $g_BASIC_pc = $next;
      } else {
        $g_BASIC_pc = $NEXT{$g_BASIC_pc};
      }
      if ($g_BASIC_pc eq "") {
        print "*** Reached end of file without 'END' statement\n";
        $BASIC_running = 0;
      }
    }
  }
  $t_end = gettimeofday;
  if ($BASIC_running < 0) {
    print "*** Break by user at line $g_BASIC_pc\n";
    $BASIC_running = 0;
  }
  print sprintf("Time: %.3f secs.\n", $t_end - $t_start);
  print "Steps: $n_cmds\n";
}

sub make_dir
{
  my($dir) = @_;
  my($d1, $d2);

  # print "make_dir : '$dir'\n";
  if (-d $dir) {
    # all set
    # print "'$dir' exists.\n";
  } elsif (-e $dir) {
    print STDERR "ERR03: Can't create directory $dir, file already there\n";
    exit -1;
  } else {
    if ($dir =~ m|^(.+)/([^/]+)$|) {
      $d1 = $1; $d2 = $2;
      # print "recursive md '$d1'\n";
      &make_dir($d1);
      $dir = $d2;
    }
    # print "mkdir $dir\n";
    system("mkdir $dir");
  }
  # At this point either the directory already exists or we just created it.
  # print "chdir '$dir'\n";
  chdir($dir);
} # End of make.dir

# Strip leading and trailing spaces from $pn, and if it is empty, prompt
# for a program name.
sub getprogname
{
  my($pn, $cmdname) = @_;

  $pn =~ s/^ *//; $pn =~ s/ *$//;
  if ($pn eq "") {
    print $cmdname; $pn = <>; chop $pn;

    $pn =~ s/^ *//; $pn =~ s/ *$//;

    if ($pn =~ m/^$p_progname$/i) {
      # okay
    } elsif ($pn eq '') {
      # They're just cancelling.
      return $pn;
    } else {
      print "*** Program name must be like 'a-bc_123'\n";
      return "";
    }
  }
  return $pn;
} # End of get.progname

sub go_basic_dir
{
  my($bd, $ans);

  $bd = "shared/proj/hypercalc";
  chdir;
  if (-d $bd) {
    chdir($bd);
  } else {
    print "In order to use this feature I need to create a directory at '$hd/$bd'.\n";
    print "Is this okay? (Y/N) : ";
    $ans = <>; chomp $ans; $ans =~ s/^[ \t]*//;
    if ($ans =~ m/^[yY]/) {
      &make_dir($bd);
    } else {
      print STDERR "Exiting.\n";
      exit(1);
    }
  }
} # End of go.basic.dir

sub BASIC_save
{
  my($pn) = @_;
  my($ln, $nl);

  if ($pn eq "") {
    $pn = $PROGNAME;
  }
  $pn = &getprogname($pn, "Name to save as: ");
  if ($pn eq "") {
    print "Not saving.\n";
    return;
  }
  $PROGNAME = $pn;

  &go_basic_dir();

  open(SAVE, "> $pn.basic");
  $nl = 0;
  foreach $ln (sort {$a <=> $b} (keys %BASIC)) {
    print SAVE "$ln $BASIC{$ln}\n";
    $nl++;
  }
  close SAVE;
  print "Saved $nl lines to $pn.basic\n";
  $g_BASIC_unsaved = 0;
} # End of BASIC.save

sub BASIC_cat
{
  my($l);

  &go_basic_dir();

  open(CAT, "ls |");
  while ($l = <CAT>) {
    chop $l;
    if ($l =~ m/\.basic$/) {
      print "$l\n";
    }
  }
  close CAT;
} # End of BASIC.cat

sub BASIC_old
{
  my($pn) = @_;
  my($l, $ln, $cmd, $nl);

  if ($pn eq "") {
    $pn = $PROGNAME;
  }
  $pn = &getprogname($pn, "Name of program to load: ");
  if ($pn eq "") {
    print "Not loading";
    $nl = scalar(keys(%BASIC));
    if ($nl) {
      print "; current program unchanged";
    }
    print ".\n";
    return;
  }

  &go_basic_dir();

  if ((-e $pn) && ($pn =~ m/^(.+)\.basic$/)) {
    $PROGNAME = $1;
  } elsif (-e "$pn.basic") {
    $PROGNAME = $pn;
    $pn = "$pn.basic";
  }

  if (-e $pn) {
    undef %BASIC; $nl = 0;
    open(my $OLD, $pn);
    while($l = <$OLD>) {
      chomp $l;
      $l =~ s/\t/ /g;
      $l =~ s/^ +//;
      $l =~ s/ +$//;
      if ($l eq '') {
      } elsif ($l =~ m/^([0-9]+) (.*)$/) {
        $ln = $1; $cmd = $2;
        $ln += 0;
        $BASIC{$ln} = $cmd; $nl++;
      } else {
        print "*** syntax error: '$l'\n";
      }
    }
    close $OLD;
    print "Loaded $nl lines from $pn\n";
  } else {
    print "*** OLD: '$pn' not found.\n";
  }
} # End of BASIC.old

sub mainloop
{
  my($err);

  $lleft = 78;

  print "$GPLNOTICE$tagline\n";
  $a2_pt = 0; $a2_val = 0; $a2_unc = 0;
  $dbg1flag = 0;
  $g_mainl_going = 1;
  $ihnum = 1;
  while($g_mainl_going) {
    $g_logfile->flush;
    print "\nC$ihnum = ";
    if ($cmdline eq "") {
      $cmd = <STDIN>; chop $cmd;
    } else {
      $cmd = $cmdline;
      $cmdline = "";
      print "$cmd\n";
    }
    if ($inunix) {
      $cmd = &fixerase($cmd);
    }
    &dbg1("ml.1: I$ihnum = $cmd", 16);
    $cmd =~ s|\t| |g;
    $cmd =~ s|^ +||;

    if ($cmd eq '') {
      $cmd = $default_command;
      $default_command = '';
    }

    $cmd =~ s|^\?|help |;

    $cmdre = $cmd;
    $cmdre =~ s|[+*?\(\)\`\'\[\]\{\}\\\|]||g;

    $not_yet_handled = 0;
    if ($cmdre eq "") {
      # nothing

    } elsif ($cmd =~ m/^ *help +gpl/i) {
      open(my $HELPOUT, "| more");
      print $HELPOUT $GPL_VERSION_3;
      close $HELPOUT;

    } elsif ($cmd =~ m/^ *help +manpage/i) {
      print $HC_MANPAGE;

    } elsif ($cmd =~ m/^ *help +syn/i) {
      print "
  Hypercalc syntax

  <input-line> := <command> [ ';' <input-line> ]

  <command> :=    '!!'
                | [ <variable> '=' ] <expression>
                | <BASIC-command>
                | <line-number> <command>
                | 'quit'

  <expression> :=    <variable>
                   | <number>
                   | <expression> <post-op>
                   | <pre-op> <expression>
                   | <expression> <op> <expression>
                   | '(' <expression> ')'
                   | <function-name> '(' <expression> ')'

  <variable> :=   'c' <integer>
                | 'r' <integer>
                | ('a'-'z') [ ('a'-'z', '0'-'9') ... ]
                | '.' | '%' | 'e' | 'pi' | 'phi'

  <number> := [ '-' ] [ <integer> 'p' ]
                               <integer> [ '.' ('0'-'9') ... ]
                                         [ '(' ('0'-'9') ... ')' ]
                                                         [ 'e' <integer> ]

  <post-op> := '!'

  <pre-op> := '-'

  <op> := '+' | '-' | '*' | 'x' | '/' | '^' | '**'

  Here's an example. This computes the solution of x^x=10 using Newton's
  Method. The labels 'c1:', 'c2:' etc. are assigned by HyperCalc, you
  don't type those:
   c1: x = 2
   c2: t = 10
   c3: y = x^x
   c4: dy = y * (1 + ln(x))
   c5: x = x + (t-y)/dy
   c6: c3
   c7: c4;c5
   c9: c3;c4;c5
   c12: !!
   c15: !!;!!

  Type 'help ops' for details on operators, 'help fun' for details on
  functions, and 'help var' for details on the special variables..
";
      $default_command = "help numbers";

    } elsif ($cmd =~ m/^ *help +num/i) {
      print "
There are several syntaxes for specifying numbers in Hypercalc.

Large numbers can be entered concisely using 'scientific notation':

  1.2e3456

Which means 1.2 times 10 to the power of 3456, as if you had typed:

  1.2 x 10 ^ 3456

Even larger numbers like googolplex and Skewes number can be entered
like this:

  2P100
  3p34

which are equivalent to:

  10 ^ 10 ^ 100
  10 ^ 10 ^ 10 ^ 34

The 'p' representing 'powers of 10' is used to insert multiple
instances of '10 ^' at the beginning of the number. Exponentiation is
right-associative, so when you input these numbers you get:

  10 ^ ( 1 x 10 ^ 100 ) 
  10 ^ [ 10 ^ ( 1 x 10 ^ 34 ) ]

You can also input numbers in base-60 (sexagesimal) using colons ':'
to separate the base-60 digits.

  12:34:56.78

This is equivalent to ((12*60)+34)*60+56.78 = 45296.78. For base-60
output, type 'format=7'.
";
      $default_command = "help op";

    } elsif ($cmd =~ m/^ *help +op/i) {
      print "
  Hypercalc operators, listed in precedence order:

    op   assoc  description
  -----  -----  ---------------------------------
   ()           parentheses around subexpression
    !           factorial or gamma(x+1)
    -           negation, as in 'sin(-x)'
  ** ^   right  exponent (** = ^)
  x * /  left   multiply (x = *) and divide
    %    left   modulo (remainder)
   + -   left   add and subtract
  < <=   left   less than, less or equal
  > >=   left   greater than, greater or equal
  <> ==  left   unequal, equal
   not          logical negation
   and          logical conjunction
   or           logical disjunction
    =           assign value to variable

  ^ is right-associative: a^b^c is equivalent to a^(b^c)
  others are left-associative: a-b-c is equivalent to (a-b)-c

  The comparison operators (<, <=, >, >=, <>, and ==) produce a value
  of 0 or 1 according as the comparison is false or true. For example,
  ''3>2'' gives the value 1 because 3 is greater than 2, and
  ''1p1e3>1.0e200'' gives the value of 0 because 10^10^3 is not greater than
  10^200.
";
      $default_command = "help fun";

    } elsif ($cmd =~ m/^ *help +fun/i) {
      print "
  Hypercalc functions:

  sqrt(x)       square root of x
  exp(x)        e to the power of x
  ln(x)         log base e of x
  log(x)        log base 10 of x
  logn(b,x)     log base b of x
  root(r,x)     r-th root of x
  sin(x)        sine of x (radians)
  cos(x)        cosine of x
  arctan(x)     arctangent of x

  See also 'help ops' (operator symbols)
";
      $default_command = "help var";

    } elsif ($cmd =~ m/^ *help +var/i) {
      print qq@
  Hypercalc has three predefined irrational constants:

    pi      3.141592653589...
    e       2.718281828459...
    phi     (1+sqrt(5))/2, the 'golden ratio'

  and several names for huge powers of 10:

    decillion          10^33
    vigintillion       10^63
    googol             10^100
    centillion         10^303
    millillion         10^3003
    milli_millillion   10^3000003
    sand_reckoner      10^(8*10^16)
    googolplex         10^(10^100)
    skewes             10^(10^(10^34))

  To define your own constants, type something like this:

    c = 2.99 * 10^8

  Constants can be changed, and used as variables in iterated commands
  (like the Newton's method example, see 'help syn') and in BASIC
  programs (see 'help basic')

  Hypercalc automatically defines 'history variables' every time you type
  a command and get a result. Type 'help hist' for details about these.

  The following special variables can be set:

    scale   Number of digits to use in calculations (normally 14). The digits
            are shared between the mantissa and exponent.
            Example: scale = 100

    format  Printout format (several options, 'help format' for a list)
            Example: format = 2

  The effect of setting a special variable inside a BASIC program
  is undefined.
@;
      $default_command = "help history";

    } elsif ($cmd =~ m/^ *help +hist/i) {
      print "
  History variables:

  Commands are assigned to the variables 'c1', 'c2', 'c3', etc. in the
  order you give them. A 'command' is a single assignment or calculation,
  and note there can be multiple commands in a line of input separated
  by ':' and ';'. Thus if you type

     t = 7 ; t ^ t

  Hypercalc will define 'c1' to be 't = 27' and 'c2' to be 't ^ t'.
  This input computes the value of 7^7. If you then type

     t = 27 ; c2

  It changes the value of t to 27, then computes and computes 27^27,
  which is approximate (4.4342648824304 x 10 ^ 38)

  Results are also assigned to variables. The first part of the previous
  example causes Hypercalc to print 'r2 = 823543' indicating that the
  variable r2 holds the result 823543. Note that results have a fixed
  precision corresponding to the scale setting at the time the calculation
  was made, but after changing scale you can repeat a command with command
  history and get a more precise result. Thus:

    scale = 50 ; r4 ; c2

  will re-display the last result as '443426488243042000000000000000000000000'
  exposing the limited precision of the original calculation, but the 'c2'
  command then repeats the calculation of t^t to 50 digits of precision,
  giving the precise answer 443426488243037769948249630619149892803.

  There are also a few special history variables, that get redefined with each
  input:

    %   The last result (like in Maxima, but same as '.').
    .   The last result (like in bc, but same as '%').
    !!  The last input line (which may be more than one command).
";
      $default_command = "help format";

    } elsif ($cmd =~ m/^ *help +for/i) {
      print "
  Values of the 'format' special variable:

  1   human-readable ASCII (the default at startup)
  2   RHTF, the RILYBOT HyperText Format
  3   HTML
  4   Old-style numbers.rhtf label
  5   Current numbers.rhtf label and link
  6   Internal PT-VAL-UNC representation
  7   Base 60 (HH:MM:SS.FRAC)
";
      $default_command = "help unc";

    } elsif ($cmd =~ m/^ *help +unc/i) {
      print "
  Uncertainty Calculations:

  Hypercalc can calculate with values that include an uncertainty or
  'error' quantity. To specify the amount of uncertainty, add digits
  within parentheses, for example:

         123(5)          123 +- 5
         12.3(11)        12.3 +- 1.1
         1.231(143)e10   1.231e10 +- 1.43e9

  When values with uncertainty are used in a calculation, the result
  of the calculation includes the correct uncertainty amount.
  Examples:

         10.0(1) + 10.0         = 20.0(10)
         10.0(1) * 2.0          = 20.0(20)
         10.0(1) * 10.0(1)      = 100.0(20)
";
      $default_command = "help basic";

    } elsif ($cmd =~ m/^ *help +basic/i) {
      print qq@
  BASIC programming commands:

  10   Any input line starting with a number and a word, with no intervening
       symbol, is taken to be a BASIC input line and is added to the current
       program. A line can be any valid expression or variable assignment
       command, and the result will be printed.
         To make a variable assignment without printing the value, start the
       line with 'let' or end it with ';'.
         To insert a BASIC line that evaluates and prints an expression
       starting with a number or symbol, make it a PRINT statement.

  let  Assign a value to a variable, without printing the result

  print
       Give one or more expressions and/or literal strings separated by
       ',' or ';'.

  for..next loops may be nested in a program. Put a ';' at the end of the
       for statement to prevent it from printing its value each time through.

  if x+2>3 then 70
       Go to line 70 if x+2 is greater than 3.  This is currently the only
       type of IF..THEN that is supported.

  data 1, 2, -3, 7
       Provide values for use by READ statements

  read a1, a2
       Take the next two numbers in DATA statements and assign them to a1
       and a2. Put a ';' at the end of the READ statement to prevent it from
       printing "R1 = a1: 1", etc. for each item assigned.

  rem  Comment (must be on a line by itself)
  '    Comment (must be on a line by itself)

  end  Stop program execution

  Here is an example:

  5  ' Calculate Hugo Steinhaus' number "Mega"
  10  let mega=256;
  20  for n=1 to 256;
  40    let mega = mega ^ mega;
  80  next n
  160  print "Mega = "; mega
  320  end

  There are currently no subroutines or user-defined functions.

  list List the current program (will automatically indent loop bodies)
  cat  List saved files
  new  Erase the current program
  run  Run the program
  save Save the current file
  old  Load a saved program
@;
      $default_command = "help debug";

    } elsif ($cmd =~ m/^ *help +debug/i) {
      print "
  Debug bitmask fields:

    1   function calls; eval\_1; expand; docmd
    2   I and R history; eval\_2
    4   I/O to child #bc# process
    8   expression parsing
    16  High-level flow control and history substitution
    32  Infinity and NAN handling

  Add the values to choose multiple options; for example 'debug 5'
  enables options 1 and 4.
";
     # This is the last page of help
     # If adding another, should set $default_command here.

    } elsif ($cmd =~ m|^help|) {
      # This test must be after all the specific help pages above
      print "
  Example          Description
  ---------------  -----------------------------------------------
  3 * 4 + 2        Multiply and add (answer 14)
  2+3x4            Same answer, spaces are optional, x = *
  % + 2            Add 2 to previous answer
  4-3-2            Gives -1 (left-to-right)
  2^2^3            Gives 256 (right-to-left)
  27!              Factorial of 27
  27!!!            Same as ((27!)!)!
  1.2 x 10 ^ 3456  Entering a large number
  1.2e3456         Same number in scientific notation
  2P100            Googolplex (P = 'powers of 10', '2P' -> 10^10^)
  6.022(1)e23      6.022x10^23 with an uncertainty of 1 in the 4th digit
  c5               Repeat command C5 (as if you retyped it)
  c6;c7;c8         Repeat three typed commands in a row
  !!               Repeat last typed line
  q                quit
  debug 17         set debug bitmask

  For more help:

  help syn     Detailed description of command syntax
  help num     Number formats in Hypercalc
  help ops     Complete list of operators (symbols)
  help fun     Complete list of named functions
  help var     Complete list of special variables
  help hist    History variables
  help format  Output formats available through the format=N command
  help unc     Computing with values that have a known uncertainty
  help basic   Hypercalc's built-in BASIC interpreter
  help debug   Available debugging options

  You can see all of these help pages by just hitting <return> a few times...
";
      $default_command = "help syntax";
    } else {
      # If they didn't give a help command, we clear the default command.
      $not_yet_handled = 1;
      $default_command = '';
    }

    if ($not_yet_handled == 0) {
    } elsif ($cmd =~ m|^debug ([0-9]+)|) {
      $dbg1flag = $1;
      print "Debug flag set to $dbg1flag.\n";
    } elsif ($cmd =~ m|^format *\= *([0-9]+)|) {
      print "Setting format.\n";
      &format1($1);
      print "\n";
    } elsif ($cmd =~ m/^ *([0-9]+) +(x *\=.*)$/) {
      # A number followed by "x =..." : This is a BASIC program line
      $ln = $1; $text = $2; $BASIC{$ln} = $text; $g_BASIC_unsaved++;
    } elsif ($cmd =~ m/^ *([0-9]+) +x[^a-z]/) {
      # A number followed by 'x': This is a calculation
      &docmd6($cmd);
    } elsif ($cmd =~ m/^ *([0-9]+) +([a-z].*)$/i) {
      # A number followed by a word: This is a BASIC program line
      $ln = $1; $text = $2; $BASIC{$ln} = $text; $g_BASIC_unsaved++;
    } elsif ($cmd =~ m/^ *([0-9]+) +('.*)$/i) {
      # A number followed by ': This is a BASIC program line containing
      # a comment
      $ln = $1; $text = $2; $BASIC{$ln} = $text; $g_BASIC_unsaved++;
    } elsif ($cmd =~ m/^ *([0-9]+) $/) {
      # A number only followed by a single space: Remove a line from
      # the BASIC program
      $ln = $1;
      delete $BASIC{$ln}; $g_BASIC_unsaved++;
    } elsif ($cmd =~ m/^ *[.0-9]+/) {
      # Anything else starting with a number is a calculation
      &docmd6($cmd);
    } elsif ($cmd =~ m/^ *([0-9]+) +(.*)$/) {
      # Input (or modify) a line for a BASIC program
      $ln = $1; $text = $2;
      $BASIC{$ln} = $text; $g_BASIC_unsaved++;
    } elsif ($cmd =~ m/^ *list *$/i) {
      # List the BASIC program
      $err = &BASIC_parse();
      foreach $ln (sort {$a <=> $b} (keys %BASIC)) {
        print ( (($ln == $err) ? ">> " : "")
             .  sprintf("%4d ", $ln) . ("  " x $BASIC_indent{$ln})
                                                          . " $BASIC{$ln}\n");
      }
    } elsif ($cmd =~ m/^ *cat *$/i) {
      # Catalog
      &BASIC_cat();

    } elsif ($cmd =~ m/^ *troff *$/i) {
      # TRace OFF
      &cmd_pragma("notrace");

    } elsif ($cmd =~ m/^ *tron *$/i) {
      # TRace ON
      &cmd_pragma("trace");

    } elsif ($cmd =~ m/^ *new *$/i) {
      # NEW without name
      if (($g_BASIC_unsaved == 0) ||
            &yorn("There are $g_BASIC_unsaved unsaved BASIC changes."
                . " Confirm NEW command: ") )
      {
        $PROGNAME = "";
        undef %BASIC;
        $g_BASIC_unsaved = 0;
      }
    } elsif ($cmd =~ m/^ *new +($p_var) *$/i) {
      # NEW with name
      if (($g_BASIC_unsaved == 0) ||
            &yorn("There are $g_BASIC_unsaved unsaved BASIC changes."
                . " Confirm NEW command: ") )
      {
        $PROGNAME = $1;
        undef %BASIC;
        $g_BASIC_unsaved = 0;
      }
    } elsif ($cmd =~ m/^ *new/i) {
      # NEW with illegal parameter
      print "*** NEW: Program name must be alphanumeric\n";
    } elsif ($cmd =~ m/^ *run *$/i) {
      # Run the BASIC program
      &BASIC_run();
    } elsif ($cmd =~ m/^ *save (.*)$/i) {
      &BASIC_save($1);
    } elsif ($cmd =~ m/^ *save *$/i) {
      &BASIC_save("");
    } elsif ($cmd =~ m/^ *(old|run) ([^ ]*)$/i) {
      $cmd = $1;
      $ln = $2;
      if (($g_BASIC_unsaved == 0) ||
        &yorn("There are $g_BASIC_unsaved unsaved BASIC changes."
                . " Confirm OLD command: ") )
      {
        &BASIC_old($ln);
        $g_BASIC_unsaved = 0;
      }
      if ((lc($cmd) eq 'run') && ($g_BASIC_unsaved == 0)) {
        &BASIC_run();
      }
    } elsif ($cmd =~ m/^ *old *$/i) {
      if (($g_BASIC_unsaved == 0) ||
        &yorn("There are $g_BASIC_unsaved unsaved BASIC changes."
                . " Confirm OLD command: ") )
      {
        &BASIC_old('');
        $g_BASIC_unsaved = 0;
      }
    } else {
      # assignment and/or expression
      &docmd6($cmd);
    }
  }
} # End of main.loop

$| = 1;
$0 = "Hypercalc";

$dbg1flag = 0;

# Special case for -h or --help argument
$a0 = $ARGV[0]; if ($a0 =~ m/^-[-]?h(elp)?$/) { print $HC_MANPAGE; exit(0); }

$cmdline = "@ARGV";

$inunix = (-d "/usr") + 0;
$inwindows = (exists $ENV{"WINDIR"}) ? 1 : 0;
$incygwin = (`uname` =~ m/CYGWIN/) + 0;
if ($incygwin) { $inwindows = 0; } # Cygwin is UNIX-y enough for our needs.
if ($inunix == $inwindows) {
  print (
"Warning: Cannot determine if this is Windows or UNIX-like (U=$inunix,W=$inwindows,C=$incygwin).\n"
. "Please email the author, 'mrob at mrob.com' and he'll try to fix this.\n\n"
  );
}

if ($inunix) {
  &seterase();
}

chdir;

# If the user has a ~/tmp directory we put our log there; otherwise no log.
if (-d "tmp") {
  open($g_logfile, ">", "tmp/hc_log.txt");
  $loghdr = qq@# Hypercalc log file    --   ~/tmp/hc_log.txt
# This file contains debugging information generated by Hypercalc. It can
# be used to find errors in Hypercalc's parsing or evaluation algorithms.
#
@;
  print $g_logfile $loghdr;
} else {
  open($g_logfile, ">", "/dev/null");
}

$bc_running = 0;

# We start with a scale of 14 and use native floating-point primitives.
$curscale = 14;
$doround = 1;
$curprim = "nat";
$g_inf = 1.0e300; $g_inf=$g_inf*$g_inf; $g_inf=$g_inf*$g_inf;
  $g_inf=$g_inf*$g_inf; $g_inf=$g_inf*$g_inf; $g_inf=$g_inf*$g_inf;
&f64_init();

&hi_init(2);

# Init the printing/formatting routines
&format1(1);

&mainloop();

if ($curprim eq "bc") {
  &fbc_close();
} else {
  &f64_close();
}

close $g_logfile;
