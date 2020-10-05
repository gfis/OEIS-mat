#! /usr/bin/env python

# Cf. https://web.archive.org/web/20130925003421/http://mathforum.org/kb/thread.jspa?forumID=253&threadID=1602206&messageID=5836094
# 
# This Python program computes the coefficients of the Moonshine
# functions (McKay-Thompson series) by using the action of the
# generalized Hecke operators (or "replicability").

# David A. Madore <david.madore@ens.fr> - 2007-07-31 - Public Domain

# The coefficients of the Moonshine functions are the values of the
# characters of certain "head modules" ("Hauptmoduln") on the various
# conjugacy classes (of cyclic subgroups) of the Monster group.  For
# the identity class ("1A"), we get the ordinary j function.

# To explain the principle of computation, first describe the
# situation for the ordinary j function: if
#   j(q) = 1/q + c1 q + c2 q^2 + c3 q^3 + ...
# (we use the normalization 0 for the constant term), there exists a
# unique, easily computed, monic polynomial of degree n (the n-th
# Faber polynomial for j), F_n, such that F_n(j) starts like 1/q^n +
# terms of order at least 1 in q.  Now modular theory tells us that
# F_n(j) actually gives (n times) the n-th Hecke operator T_n acting
# on j, i.e., something like
#   2 T_2(j) = 1/q^2 + 2 c2 q + (2c4+c1) q^2 + 2 c6 q^3 + (2c8+c2) q^4 + ...
#   3 T_3(j) = 1/q^3 + 3 c3 q + 3 c6 q^2 + (3c9+c1) q^3 + 3c12 q^4 + ...
#   4 T_4(j) = 1/q^4 + 4 c4 q + (4c8+2c2) q^2 + 4c12 q^3 + (4c16+2c4+c1) q^4 + ...
# etc.  This relation F_n(j) = n T_n(j) can be used both ways:
# computing F_n(j) allows us to compute higher (divisible)
# coefficients from lower ones, but in the other direction, computing
# F_2(j) with the highest unknown coefficient as an indeterminate
# allows us to compute the latter from others.
#
# In the case of replicable functions, the same thing is almost true,
# except that the Hecke operators are "twisted": the coefficients come
# from the "replicas" of the function, e.g.,
#   2 T*_2(f) = 1/q^2 + 2 c2 q + (2c4+c'1) q^2 + 2 c6 q^3 + (2c8+c'2) q^4 + ...
# where c' are the coefficients of the second replica of f; for
# Moonshine functions, the replicas are the Moonshine functions of the
# corresponding powers of the conjugacy class.

# Set this to True to print coefficients as soon as they are computed,
# False to print them in ordered fashion (all coefficients of q then
# all of q^2, etc.).
import sys
earlyprint = False

# This is the list of the 172 conjugacy classes of cyclic subgroups of
# the Monster, in ATLAS notation:
classes = ["1A", "2A", "2B", "3A", "3B", "3C",
           "4A", "4B", "4C", "4D", "5A", "5B",
           "6A", "6B", "6C", "6D", "6E", "6F", "7A", "7B",
           "8A", "8B", "8C", "8D", "8E", "8F", "9A", "9B",
           "10A", "10B", "10C", "10D", "10E", "11A",
           "12A", "12B", "12C", "12D", "12E", "12F", "12G", "12H", "12I", "12J",
           "13A", "13B", "14A", "14B", "14C", "15A", "15B", "15C", "15D",
           "16A", "16B", "16C", "17A", "18A", "18B", "18C", "18D", "18E", "19A",
           "20A", "20B", "20C", "20D", "20E", "20F", "21A", "21B", "21C", "21D",
           "22A", "22B", "23AB",
           "24A", "24B", "24C", "24D", "24E", "24F", "24G", "24H", "24I", "24J",
           "25A", "26A", "26B", "27A", "27B", "28A", "28B", "28C", "28D", "29A",
           "30A", "30B", "30C", "30D", "30E", "30F", "30G", "31AB",
           "32A", "32B", "33A", "33B", "34A", "35A", "35B",
           "36A", "36B", "36C", "36D", "38A", "39A", "39B", "39CD",
           "40A", "40B", "40CD", "41A", "42A", "42B", "42C", "42D",
           "44AB", "45A", "46AB", "46CD", "47AB",
           "48A", "50A", "51A", "52A", "52B", "54A", "55A",
           "56A", "56BC", "57A", "59AB",
           "60A", "60B", "60C", "60D", "60E", "60F", "62AB", "66A", "66B",
           "68A", "69AB", "70A", "70B", "71AB", "78A", "78BC",
           "84A", "84B", "84C", "87AB", "88AB",
           "92AB", "93AB", "94AB", "95AB",
           "104AB", "105A", "110A", "119AB"]

# Now the power maps, also from the ATLAS (via the GAP character table
# library):
clpowers = {"1A": ["1A","1A","1A","1A","1A","1A","1A","1A","1A","1A"],
            "2A": ["1A","2A","1A","2A","1A","2A","1A","2A","1A","2A"],
            "2B": ["1A","2B","1A","2B","1A","2B","1A","2B","1A","2B"],
            "3A": ["1A","3A","3A","1A","3A","3A","1A","3A","3A","1A"],
            "3B": ["1A","3B","3B","1A","3B","3B","1A","3B","3B","1A"],
            "3C": ["1A","3C","3C","1A","3C","3C","1A","3C","3C","1A"],
            "4A": ["1A","4A","2B","4A","1A","4A","2B","4A","1A","4A"],
            "4B": ["1A","4B","2A","4B","1A","4B","2A","4B","1A","4B"],
            "4C": ["1A","4C","2B","4C","1A","4C","2B","4C","1A","4C"],
            "4D": ["1A","4D","2B","4D","1A","4D","2B","4D","1A","4D"],
            "5A": ["1A","5A","5A","5A","5A","1A","5A","5A","5A","5A"],
            "5B": ["1A","5B","5B","5B","5B","1A","5B","5B","5B","5B"],
            "6A": ["1A","6A","3A","2A","3A","6A","1A","6A","3A","2A"],
            "6B": ["1A","6B","3B","2B","3B","6B","1A","6B","3B","2B"],
            "6C": ["1A","6C","3A","2B","3A","6C","1A","6C","3A","2B"],
            "6D": ["1A","6D","3B","2A","3B","6D","1A","6D","3B","2A"],
            "6E": ["1A","6E","3B","2B","3B","6E","1A","6E","3B","2B"],
            "6F": ["1A","6F","3C","2B","3C","6F","1A","6F","3C","2B"],
            "7A": ["1A","7A","7A","7A","7A","7A","7A","1A","7A","7A"],
            "7B": ["1A","7B","7B","7B","7B","7B","7B","1A","7B","7B"],
            "8A": ["1A","8A","4C","8A","2B","8A","4C","8A","1A","8A"],
            "8B": ["1A","8B","4A","8B","2B","8B","4A","8B","1A","8B"],
            "8C": ["1A","8C","4B","8C","2A","8C","4B","8C","1A","8C"],
            "8D": ["1A","8D","4C","8D","2B","8D","4C","8D","1A","8D"],
            "8E": ["1A","8E","4C","8E","2B","8E","4C","8E","1A","8E"],
            "8F": ["1A","8F","4D","8F","2B","8F","4D","8F","1A","8F"],
            "9A": ["1A","9A","9A","3B","9A","9A","3B","9A","9A","1A"],
            "9B": ["1A","9B","9B","3B","9B","9B","3B","9B","9B","1A"],
            "10A": ["1A","10A","5A","10A","5A","2A","5A","10A","5A","10A"],
            "10B": ["1A","10B","5A","10B","5A","2B","5A","10B","5A","10B"],
            "10C": ["1A","10C","5B","10C","5B","2A","5B","10C","5B","10C"],
            "10D": ["1A","10D","5B","10D","5B","2B","5B","10D","5B","10D"],
            "10E": ["1A","10E","5B","10E","5B","2B","5B","10E","5B","10E"],
            "11A": ["1A","11A","11A","11A","11A","11A","11A","11A","11A","11A"],
            "12A": ["1A","12A","6C","4A","3A","12A","2B","12A","3A","4A"],
            "12B": ["1A","12B","6E","4A","3B","12B","2B","12B","3B","4A"],
            "12C": ["1A","12C","6A","4B","3A","12C","2A","12C","3A","4B"],
            "12D": ["1A","12D","6F","4A","3C","12D","2B","12D","3C","4A"],
            "12E": ["1A","12E","6C","4C","3A","12E","2B","12E","3A","4C"],
            "12F": ["1A","12F","6B","4D","3B","12F","2B","12F","3B","4D"],
            "12G": ["1A","12G","6D","4B","3B","12G","2A","12G","3B","4B"],
            "12H": ["1A","12H","6E","4C","3B","12H","2B","12H","3B","4C"],
            "12I": ["1A","12I","6E","4C","3B","12I","2B","12I","3B","4C"],
            "12J": ["1A","12J","6F","4D","3C","12J","2B","12J","3C","4D"],
            "13A": ["1A","13A","13A","13A","13A","13A","13A","13A","13A","13A"],
            "13B": ["1A","13B","13B","13B","13B","13B","13B","13B","13B","13B"],
            "14A": ["1A","14A","7A","14A","7A","14A","7A","2A","7A","14A"],
            "14B": ["1A","14B","7A","14B","7A","14B","7A","2B","7A","14B"],
            "14C": ["1A","14C","7B","14C","7B","14C","7B","2B","7B","14C"],
            "15A": ["1A","15A","15A","5A","15A","3A","5A","15A","15A","5A"],
            "15B": ["1A","15B","15B","5A","15B","3B","5A","15B","15B","5A"],
            "15C": ["1A","15C","15C","5B","15C","3B","5B","15C","15C","5B"],
            "15D": ["1A","15D","15D","5B","15D","3C","5B","15D","15D","5B"],
            "16A": ["1A","16A","8A","16A","4C","16A","8A","16A","2B","16A"],
            "16B": ["1A","16B","8E","16B","4C","16B","8E","16B","2B","16B"],
            "16C": ["1A","16C","8E","16C","4C","16C","8E","16C","2B","16C"],
            "17A": ["1A","17A","17A","17A","17A","17A","17A","17A","17A","17A"],
            "18A": ["1A","18A","9B","6D","9B","18A","3B","18A","9B","2A"],
            "18B": ["1A","18B","9A","6D","9A","18B","3B","18B","9A","2A"],
            "18C": ["1A","18C","9A","6E","9A","18C","3B","18C","9A","2B"],
            "18D": ["1A","18D","9B","6E","9B","18D","3B","18D","9B","2B"],
            "18E": ["1A","18E","9B","6E","9B","18E","3B","18E","9B","2B"],
            "19A": ["1A","19A","19A","19A","19A","19A","19A","19A","19A","19A"],
            "20A": ["1A","20A","10B","20A","5A","4A","10B","20A","5A","20A"],
            "20B": ["1A","20B","10A","20B","5A","4B","10A","20B","5A","20B"],
            "20C": ["1A","20C","10E","20C","5B","4A","10E","20C","5B","20C"],
            "20D": ["1A","20D","10B","20D","5A","4D","10B","20D","5A","20D"],
            "20E": ["1A","20E","10D","20E","5B","4D","10D","20E","5B","20E"],
            "20F": ["1A","20F","10E","20F","5B","4C","10E","20F","5B","20F"],
            "21A": ["1A","21A","21A","7A","21A","21A","7A","3A","21A","7A"],
            "21B": ["1A","21B","21B","7B","21B","21B","7B","3A","21B","7B"],
            "21C": ["1A","21C","21C","7A","21C","21C","7A","3C","21C","7A"],
            "21D": ["1A","21D","21D","7B","21D","21D","7B","3B","21D","7B"],
            "22A": ["1A","22A","11A","22A","11A","22A","11A","22A","11A","22A"],
            "22B": ["1A","22B","11A","22B","11A","22B","11A","22B","11A","22B"],
            "23AB": ["1A","23AB","23AB","23AB","23AB","23AB","23AB","23AB","23AB","23AB"],
            "24A": ["1A","24A","12A","8B","6C","24A","4A","24A","3A","8B"],
            "24B": ["1A","24B","12E","8A","6C","24B","4C","24B","3A","8A"],
            "24C": ["1A","24C","12I","8A","6E","24C","4C","24C","3B","8A"],
            "24D": ["1A","24D","12E","8D","6C","24D","4C","24D","3A","8D"],
            "24E": ["1A","24E","12D","8B","6F","24E","4A","24E","3C","8B"],
            "24F": ["1A","24F","12F","8F","6B","24F","4D","24F","3B","8F"],
            "24G": ["1A","24G","12G","8C","6D","24G","4B","24G","3B","8C"],
            "24H": ["1A","24H","12H","8D","6E","24H","4C","24H","3B","8D"],
            "24I": ["1A","24I","12I","8E","6E","24I","4C","24I","3B","8E"],
            "24J": ["1A","24J","12J","8F","6F","24J","4D","24J","3C","8F"],
            "25A": ["1A","25A","25A","25A","25A","5B","25A","25A","25A","25A"],
            "26A": ["1A","26A","13A","26A","13A","26A","13A","26A","13A","26A"],
            "26B": ["1A","26B","13B","26B","13B","26B","13B","26B","13B","26B"],
            "27A": ["1A","27A","27A","9B","27A","27A","9B","27A","27A","3B"],
            "27B": ["1A","27B","27B","9B","27B","27B","9B","27B","27B","3B"],
            "28A": ["1A","28A","14A","28A","7A","28A","14A","4B","7A","28A"],
            "28B": ["1A","28B","14B","28B","7A","28B","14B","4A","7A","28B"],
            "28C": ["1A","28C","14B","28C","7A","28C","14B","4C","7A","28C"],
            "28D": ["1A","28D","14C","28D","7B","28D","14C","4D","7B","28D"],
            "29A": ["1A","29A","29A","29A","29A","29A","29A","29A","29A","29A"],
            "30A": ["1A","30A","15C","10D","15C","6B","5B","30A","15C","10D"],
            "30B": ["1A","30B","15A","10A","15A","6A","5A","30B","15A","10A"],
            "30C": ["1A","30C","15A","10B","15A","6C","5A","30C","15A","10B"],
            "30D": ["1A","30D","15B","10B","15B","6B","5A","30D","15B","10B"],
            "30E": ["1A","30E","15D","10D","15D","6F","5B","30E","15D","10D"],
            "30F": ["1A","30F","15C","10C","15C","6D","5B","30F","15C","10C"],
            "30G": ["1A","30G","15C","10E","15C","6E","5B","30G","15C","10E"],
            "31AB": ["1A","31AB","31AB","31AB","31AB","31AB","31AB","31AB","31AB","31AB"],
            "32A": ["1A","32A","16B","32A","8E","32A","16B","32A","4C","32A"],
            "32B": ["1A","32B","16C","32B","8E","32B","16C","32B","4C","32B"],
            "33A": ["1A","33A","33A","11A","33A","33A","11A","33A","33A","11A"],
            "33B": ["1A","33B","33B","11A","33B","33B","11A","33B","33B","11A"],
            "34A": ["1A","34A","17A","34A","17A","34A","17A","34A","17A","34A"],
            "35A": ["1A","35A","35A","35A","35A","7A","35A","5A","35A","35A"],
            "35B": ["1A","35B","35B","35B","35B","7B","35B","5B","35B","35B"],
            "36A": ["1A","36A","18C","12B","9A","36A","6E","36A","9A","4A"],
            "36B": ["1A","36B","18D","12B","9B","36B","6E","36B","9B","4A"],
            "36C": ["1A","36C","18B","12G","9A","36C","6D","36C","9A","4B"],
            "36D": ["1A","36D","18D","12I","9B","36D","6E","36D","9B","4C"],
            "38A": ["1A","38A","19A","38A","19A","38A","19A","38A","19A","38A"],
            "39A": ["1A","39A","39A","13A","39A","39A","13A","39A","39A","13A"],
            "39B": ["1A","39B","39B","13A","39B","39B","13A","39B","39B","13A"],
            "39CD": ["1A","39CD","39CD","13B","39CD","39CD","13B","39CD","39CD","13B"],
            "40A": ["1A","40A","20B","40A","10A","8C","20B","40A","5A","40A"],
            "40B": ["1A","40B","20A","40B","10B","8B","20A","40B","5A","40B"],
            "40CD": ["1A","40CD","20F","40CD","10E","8D","20F","40CD","5B","40CD"],
            "41A": ["1A","41A","41A","41A","41A","41A","41A","41A","41A","41A"],
            "42A": ["1A","42A","21A","14A","21A","42A","7A","6A","21A","14A"],
            "42B": ["1A","42B","21D","14C","21D","42B","7B","6B","21D","14C"],
            "42C": ["1A","42C","21C","14B","21C","42C","7A","6F","21C","14B"],
            "42D": ["1A","42D","21B","14C","21B","42D","7B","6C","21B","14C"],
            "44AB": ["1A","44AB","22B","44AB","11A","44AB","22B","44AB","11A","44AB"],
            "45A": ["1A","45A","45A","15B","45A","9A","15B","45A","45A","5A"],
            "46AB": ["1A","46AB","23AB","46AB","23AB","46AB","23AB","46AB","23AB","46AB"],
            "46CD": ["1A","46CD","23AB","46CD","23AB","46CD","23AB","46CD","23AB","46CD"],
            "47AB": ["1A","47AB","47AB","47AB","47AB","47AB","47AB","47AB","47AB","47AB"],
            "48A": ["1A","48A","24B","16A","12E","48A","8A","48A","6C","16A"],
            "50A": ["1A","50A","25A","50A","25A","10C","25A","50A","25A","50A"],
            "51A": ["1A","51A","51A","17A","51A","51A","17A","51A","51A","17A"],
            "52A": ["1A","52A","26A","52A","13A","52A","26A","52A","13A","52A"],
            "52B": ["1A","52B","26B","52B","13B","52B","26B","52B","13B","52B"],
            "54A": ["1A","54A","27A","18A","27A","54A","9B","54A","27A","6D"],
            "55A": ["1A","55A","55A","55A","55A","11A","55A","55A","55A","55A"],
            "56A": ["1A","56A","28C","56A","14B","56A","28C","8A","7A","56A"],
            "56BC": ["1A","56BC","28D","56BC","14C","56BC","28D","8F","7B","56BC"],
            "57A": ["1A","57A","57A","19A","57A","57A","19A","57A","57A","19A"],
            "59AB": ["1A","59AB","59AB","59AB","59AB","59AB","59AB","59AB","59AB","59AB"],
            "60A": ["1A","60A","30B","20B","15A","12C","10A","60A","15A","20B"],
            "60B": ["1A","60B","30C","20A","15A","12A","10B","60B","15A","20A"],
            "60C": ["1A","60C","30G","20C","15C","12B","10E","60C","15C","20C"],
            "60D": ["1A","60D","30G","20F","15C","12H","10E","60D","15C","20F"],
            "60E": ["1A","60E","30D","20D","15B","12F","10B","60E","15B","20D"],
            "60F": ["1A","60F","30E","20E","15D","12J","10D","60F","15D","20E"],
            "62AB": ["1A","62AB","31AB","62AB","31AB","62AB","31AB","62AB","31AB","62AB"],
            "66A": ["1A","66A","33B","22A","33B","66A","11A","66A","33B","22A"],
            "66B": ["1A","66B","33A","22B","33A","66B","11A","66B","33A","22B"],
            "68A": ["1A","68A","34A","68A","17A","68A","34A","68A","17A","68A"],
            "69AB": ["1A","69AB","69AB","23AB","69AB","69AB","23AB","69AB","69AB","23AB"],
            "70A": ["1A","70A","35A","70A","35A","14A","35A","10A","35A","70A"],
            "70B": ["1A","70B","35B","70B","35B","14C","35B","10D","35B","70B"],
            "71AB": ["1A","71AB","71AB","71AB","71AB","71AB","71AB","71AB","71AB","71AB"],
            "78A": ["1A","78A","39A","26A","39A","78A","13A","78A","39A","26A"],
            "78BC": ["1A","78BC","39CD","26B","39CD","78BC","13B","78BC","39CD","26B"],
            "84A": ["1A","84A","42A","28A","21A","84A","14A","12C","21A","28A"],
            "84B": ["1A","84B","42B","28D","21D","84B","14C","12F","21D","28D"],
            "84C": ["1A","84C","42C","28B","21C","84C","14B","12D","21C","28B"],
            "87AB": ["1A","87AB","87AB","29A","87AB","87AB","29A","87AB","87AB","29A"],
            "88AB": ["1A","88AB","44AB","88AB","22B","88AB","44AB","88AB","11A","88AB"],
            "92AB": ["1A","92AB","46AB","92AB","23AB","92AB","46AB","92AB","23AB","92AB"],
            "93AB": ["1A","93AB","93AB","31AB","93AB","93AB","31AB","93AB","93AB","31AB"],
            "94AB": ["1A","94AB","47AB","94AB","47AB","94AB","47AB","94AB","47AB","94AB"],
            "95AB": ["1A","95AB","95AB","95AB","95AB","19A","95AB","95AB","95AB","95AB"],
            "104AB": ["1A","104AB","52A","104AB","26A","104AB","52A","104AB","13A","104AB"],
            "105A": ["1A","105A","105A","35A","105A","21A","35A","15A","105A","35A"],
            "110A": ["1A","110A","55A","110A","55A","22A","55A","110A","55A","110A"],
            "119AB": ["1A","119AB","119AB","119AB","119AB","119AB","119AB","17A","119AB","119AB"]}

# We bootstrap with a few known coefficients:
bootcoefs = {"1A": [0, 196884, 21493760, 864299970, 20245856256, 333202640600],
             "2A": [0, 4372, 96256, 1240002, 10698752, 74428120],
             "2B": [0, 276, -2048, 11202, -49152, 184024],
             "3A": [0, 783, 8672, 65367, 371520, 1741655],
             "3B": [0, 54, -76, -243, 1188, -1384],
             "3C": [0, 0, 248, 0, 0, 4124],
             "4A": [0, 276, 2048, 11202, 49152, 184024],
             "4B": [0, 52, 0, 834, 0, 4760],
             "4C": [0, 20, 0, -62, 0, 216], "4D": [0, -12, 0, 66, 0, -232],
             "5A": [0, 134, 760, 3345, 12256, 39350],
             "5B": [0, 9, 10, -30, 6, -25],
             "6A": [0, 79, 352, 1431, 4160, 13015],
             "6B": [0, 78, 364, 1365, 4380, 12520],
             "6C": [0, 15, -32, 87, -192, 343],
             "6D": [0, -2, 28, -27, -52, 136],
             "6E": [0, 6, 4, -3, -12, -8], "6F": [0, 0, -8, 0, 0, 28],
             "7A": [0, 51, 204, 681, 1956, 5135],
             "7B": [0, 2, 8, -5, -4, -10],
             "8A": [0, 36, 128, 386, 1024, 2488],
             "8B": [0, 12, 0, 66, 0, 232], "8C": [0, 0, 0, 26, 0, 0],
             "8D": [0, -4, 0, 2, 0, 8], "8E": [0, 4, 0, 2, 0, -8],
             "8F": [0, 0, 0, -6, 0, 0],
             "9A": [0, 27, 86, 243, 594, 1370], "9B": [0, 0, 5, 0, 0, -7],
             "10A": [0, 22, 56, 177, 352, 870], "10B": [0, 6, -8, 17, -32, 54],
             "10C": [0, -3, 6, 2, 2, -5], "10D": [0, 21, 62, 162, 378, 819],
             "10E": [0, 1, 2, 2, -2, -1], "11A": [0, 17, 46, 116, 252, 533],
             "12A": [0, 15, 32, 87, 192, 343], "12B": [0, 6, -4, -3, 12, -8],
             "12C": [0, 7, 0, 15, 0, 71], "12D": [0, 0, 8, 0, 0, 28],
             "12E": [0, -1, 0, 7, 0, -9], "12F": [0, 6, 0, 21, 0, 56],
             "12G": [0, -2, 0, -3, 0, 8], "12H": [0, 14, 36, 85, 180, 360],
             "12I": [0, 2, 0, 1, 0, 0], "12J": [0, 0, 0, 0, 0, -4],
             "13A": [0, 12, 28, 66, 132, 258], "13B": [0, -1, 2, 1, 2, -2],
             "14A": [0, 11, 20, 57, 92, 207], "14B": [0, 3, -4, 9, -12, 15],
             "14C": [0, 10, 24, 51, 100, 190],
             "15A": [0, 8, 22, 42, 70, 155], "15B": [0, -1, 4, -3, -2, 11],
             "15C": [0, 9, 19, 42, 78, 146], "15D": [0, 0, -2, 0, 0, -1],
             "16A": [0, 4, 0, 10, 0, 24], "16B": [0, 0, 0, 2, 0, 0],
             "16C": [0, 8, 16, 34, 64, 112], "17A": [0, 7, 14, 29, 50, 92],
             "18A": [0, -2, 1, 0, 2, 1], "18B": [0, 7, 10, 27, 38, 82],
             "18C": [0, 3, -2, 3, -6, 10], "18D": [0, 0, 1, 0, 0, 1],
             "18E": [0, 6, 13, 24, 42, 73], "19A": [0, 6, 10, 21, 36, 61],
             "20A": [0, 6, 8, 17, 32, 54], "20B": [0, 2, 0, 9, 0, 10],
             "20C": [0, 1, -2, 2, 2, -1], "20D": [0, -2, 0, 1, 0, -2],
             "20E": [0, 3, 0, 6, 0, 13], "20F": [0, 5, 10, 18, 30, 51],
             "21A": [0, 6, 6, 15, 30, 41], "21B": [0, -1, -1, 1, 2, -1],
             "21C": [0, 0, 3, 0, 0, 8], "21D": [0, 5, 8, 16, 26, 44],
             "22A": [0, 5, 6, 16, 20, 41], "22B": [0, 1, -2, 4, -4, 5],
             "23AB": [0, 4, 7, 13, 19, 33],
             "24A": [0, 3, 0, 3, 0, 7], "24B": [0, 3, 8, 11, 16, 31],
             "24C": [0, 0, 2, -1, -2, 4], "24D": [0, -1, 0, -1, 0, -1],
             "24E": [0, 0, 0, 0, 0, 4], "24F": [0, 0, 0, 3, 0, 0],
             "24G": [0, 0, 0, -1, 0, 0], "24H": [0, 2, 0, 5, 0, 8],
             "24I": [0, 4, 6, 11, 18, 28], "24J": [0, 0, 0, 0, 0, 0],
             "25A": [0, 4, 5, 10, 16, 25],
             "26A": [0, 4, 4, 10, 12, 26], "26B": [0, 3, 6, 9, 14, 22],
             "27A": [0, 3, 5, 9, 12, 20], "27B": [0, 3, 5, 9, 12, 20],
             "28A": [0, 3, 0, 1, 0, 7], "28B": [0, 3, 4, 9, 12, 15],
             "28C": [0, -1, 0, 1, 0, -1], "28D": [0, 2, 0, 3, 0, 6],
             "29A": [0, 3, 4, 7, 10, 17],
             "30A": [0, 3, -1, 0, 0, 0], "30B": [0, 4, 2, 6, 10, 15],
             "30C": [0, 0, -2, 2, -2, 3], "30D": [0, 3, 4, 5, 10, 15],
             "30E": [0, 0, 2, 0, 0, 3], "30F": [0, 3, 3, 8, 8, 16],
             "30G": [0, 1, -1, 2, -2, 2], "31AB": [0, 3, 3, 6, 9, 13],
             "32A": [0, 2, 4, 6, 8, 12], "32B": [0, 2, 0, 2, 0, 4],
             "33A": [0, -1, 1, -1, 0, 2], "33B": [0, 2, 4, 5, 6, 14],
             "34A": [0, 3, 2, 5, 6, 12],
             "35A": [0, 1, 4, 6, 6, 10], "35B": [0, 2, 3, 5, 6, 10],
             "36A": [0, 3, 2, 3, 6, 10], "36B": [0, 0, -1, 0, 0, 1],
             "36C": [0, 1, 0, 3, 0, 2], "36D": [0, 2, 3, 4, 6, 9],
             "38A": [0, 2, 2, 5, 4, 9],
             "39A": [0, 3, 1, 3, 6, 6], "39B": [0, 0, 1, 0, 0, 3],
             "39CD": [0, 2, 2, 4, 5, 7],
             "40A": [0, 0, 0, 1, 0, 0], "40B": [0, 2, 0, 1, 0, 2],
             "40CD": [0, 1, 0, 2, 0, 3], "41A": [0, 2, 2, 3, 4, 7],
             "42A": [0, 2, 2, 3, 2, 9], "42B": [0, 1, 0, 0, -2, 4],
             "42C": [0, 0, -1, 0, 0, 0], "42D": [0, 1, 3, 3, 4, 7],
             "44AB": [0, 1, 2, 4, 4, 5],
             "45A": [0, 2, 1, 3, 4, 5],
             "46AB": [0, 0, -1, 1, -1, 1], "46CD": [0, 2, 1, 3, 3, 5],
             "47AB": [0, 1, 2, 3, 3, 5],
             "48A": [0, 1, 0, 1, 0, 3],
             "50A": [0, 2, 1, 2, 2, 5], "51A": [0, 1, 2, 2, 2, 5],
             "52A": [0, 0, 0, 2, 0, 2], "52B": [0, 1, 0, 1, 0, 2],
             "54A": [0, 1, 1, 3, 2, 4], "55A": [0, 2, 1, 1, 2, 3],
             "56A": [0, 1, 2, 1, 2, 3], "56BC": [0, 0, 0, 1, 0, 0],
             "57A": [0, 0, 1, 0, 0, 1], "59AB": [0, 1, 1, 2, 2, 3],
             "60A": [0, 2, 0, 0, 0, 1], "60B": [0, 0, 2, 2, 2, 3],
             "60C": [0, 1, 1, 2, 2, 2], "60D": [0, -1, 1, 0, 0, 0],
             "60E": [0, 1, 0, 1, 0, 1], "60F": [0, 0, 0, 0, 0, 1],
             "62AB": [0, 1, 1, 2, 1, 3],
             "66A": [0, 2, 0, 1, 2, 2], "66B": [0, 1, 1, 1, 2, 2],
             "68A": [0, 1, 0, 1, 0, 0], "69AB": [0, 1, 1, 1, 1, 3],
             "70A": [0, 1, 0, 2, 2, 2], "70B": [0, 0, -1, 1, 0, 0],
             "71AB": [0, 1, 1, 1, 1, 2],
             "78A": [0, 1, 1, 1, 0, 2], "78BC": [0, 0, 0, 0, -1, 1],
             "84A": [0, 0, 0, 1, 0, 1], "84B": [0, -1, 0, 0, 0, 0],
             "84C": [0, 0, 1, 0, 0, 0], "87AB": [0, 0, 1, 1, 1, 2],
             "88AB": [0, 1, 0, 0, 0, 1],
             "92AB": [0, 0, 1, 1, 1, 1], "93AB": [0, 0, 0, 0, 0, 1],
             "94AB": [0, 1, 0, 1, 1, 1], "95AB": [0, 1, 0, 1, 1, 1],
             "104AB": [0, 0, 0, 0, 0, 0],
             "105A": [0, 1, 1, 0, 0, 1], "110A": [0, 0, 1, 1, 0, 1],
             "119AB": [0, 0, 0, 1, 1, 1]}

# Now we need an object class for doing simple operations on power
# series (actually Laurent series: index is the valuation):
class PowerSeries:
    def __init__(self, index, coefs):
        self.index = index
        self.coefs = coefs
    def precis(self): # Return the (big-O) precision we have
        return self.index + len(self.coefs)
    def multiply(s1, s2): # Return a _new_ series by multiplying s1 and s2
        index = s1.index + s2.index
        length = min(len(s1.coefs),len(s2.coefs))
        coefs = []
        for i in range(length):
            x = 0
            for j in range(i+1):
                x += s1.coefs[j]*s2.coefs[i-j]
            coefs.append(x)
        return PowerSeries(index, coefs)
    def addMonomial(self, c, k): # _Change_ a series by adding a monomial
        if k < self.index:
            self.coefs[:0] = (self.index - k) * [0]
            self.index = k
        self.coefs[k-self.index] += c
    def addMonomialTimes(self, c, k, f): # Add a monomial times f
        if k + f.precis() < self.index:
            raise Exception("PowerSeries defined nowhere")
        elif k + f.precis() < self.precis():
            del self.coefs[(f.precis() - self.index):]
        if k + f.index < self.index:
            self.coefs[:0] = (self.index - k - f.index) * [0]
            self.index = k + f.index
        for i in range(len(self.coefs)):
            if self.index + i >= k + f.index:
                self.coefs[i] += c*f.coefs[i+self.index-k-f.index]
    def coef(self, k): # Return a given coefficient
        if k < self.index:
            return 0
        elif k < self.precis():
            return self.coefs[k-self.index]
        else:
            raise Exception("PowerSeries insufficiently precise")
    def toString(self): # Return a string representation of the power series
        result = ""
        sep = "["
        for i in range(len(self.coefs)):
            result += sep + str(self.coefs[i])
            sep = ","
        return result + "]:" + str(self.index)

def strictDivisors(n): # Return the list of divisors of n between 1 and n-1
    l = []
    for i in range(1,n):
        if (n % i)==0:
            l.append(i)
    return l

# An exception thrown in various places to signify we can't compute
# something yet.
class MissingCoef(Exception):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr(self.value)
#----------------------------------------------------------------
# The main part!
selected = sys.argv[1]
sDebug = 0
if len(sys.argv) > 2:
    sDebug = int(sys.argv[2])
    if sDebug >= 1:
        earlyprint = True
else:
    earlyprint = False
if selected == "*":
    selected = classes;
else:
    selected = selected.split(",")

# lencomplete is the *first unknown* coefficient for each class.
lencomplete = dict()
for cl in selected:
    lencomplete[cl] = len(bootcoefs[cl])
# coefs is the main storage of coefficients; it is a (tuple-indexed)
# dictionary so we don't have to store things contiguously.
coefs = dict()
for cl in selected:
    for i in range(lencomplete[cl]):
        coefs[cl,i] = bootcoefs[cl][i]
        if earlyprint and (i>0):
            print ("early#1 %s\t%d\t%d"%(cl, i, coefs[cl,i]))
lenprinted = 1

while True:
    for cl in selected:
        # Start by forming a series with whatever contiguous
        # coefficients we have (i.e. j is the best approximation we
        # have so far on the Moonshine function for class cl).
        jcoefs = []
        for k in range(lencomplete[cl]):
            jcoefs.append(coefs[cl,k])
        j = PowerSeries(0, jcoefs)
        j.addMonomial(1, -1)
        # Now compute the first Faber polynomials of j:
        jFaber = [None, j]
        if sDebug >= 2:
            print ("# cl=" + cl + ", j=" + j.toString())
        for n in range(2, min(lencomplete[cl],7)):
            # ((Here 7 is a heuristic, meaning we compute the first 6 Faber
            # polynomials: any value at least equal to 5 should work, but
            # higher values are interesting only if you wish to earlyprint
            # high coefficients; besides, if you make this higher than 10
            # you need to extend the class power maps.))
            jn = PowerSeries.multiply(jFaber[n-1], j)
            if sDebug >= 2:
                print ("#1 n=" + str(n) + ", jn=" + jn.toString() + ", precis=" + str(jn.precis()))
            for k in range(n-2, 0, -1):
                jn.addMonomialTimes(-jn.coef(-k),0,jFaber[k])
            jn.addMonomial(-jn.coef(0),0)
            if sDebug >= 2:
                print ("#2 n=" + str(n) + ", jn=" + jn.toString() + ", precis=" + str(jn.precis()))
            jFaber.append(jn)
            # At this point, jn is the n-th Faber polynomial of j.
            ld = strictDivisors(n)
            for k in range(1, jn.precis()):
                if (cl,k*n) not in coefs:
                    # Compute a coefficient from the action of the n-th
                    # Hecke operator (with just n*coefs[k*n], the one we
                    # will deduce, missing from the sum):
                    if (sDebug >= 2):
                        print("# n-th Hecke, n=" + str(n) + ", k=" + str(k));
                    try:
                        v = 0
                        for d in ld:
                            a = n // d
                            cla = clpowers[cl][a]
                            if (sDebug >= 2):
                                print("# d=" + str(d) + ", k=" + str(k) + ", n=" + str(n) + ", a=" + str(a) + ", cla=" + cla)
                            if (k % a)==0:
                                kk = (k // a) * d
                                if (cla,kk) in coefs:
                                    v += (n // a)*coefs[cla,kk]
                                else:
                                    raise MissingCoef(kk)
                        w = jn.coef(k)-v
                        if (sDebug >= 2):
                            print("# w=" + str(w) + ", v=" + str(v))
                        if (w % n) != 0:
                            raise Exception("Divisibility check failed!")
                        w //= n
                        coefs[cl,k*n] = w
                        if earlyprint:
                            print ("early#2 %s\t%d\t%d"%(cl, k*n, w))
                    except MissingCoef as kk:
                        print ("MissingCoef#1 k=" + str(k) + ", n=" + str(n))
                        pass # (Actually never happens...)
    # Now try the other way around: deduce some lower coefficients
    # from the higher ones (known through the Hecke operators).  We
    # only use T_2 here, so we only deal with F_2(j), which is
    # essentially j^2 (up to a constant -2*c1 we don't care about
    # since we're interested only in one, higher, coefficient).
    for cl in selected:
        cl2 = clpowers[cl][2]
        try:
            while True:
                # See if lencomplete can be increased.
                while (cl,lencomplete[cl]) in coefs:
                    lencomplete[cl] += 1
                # Try to compute the first unknown coefficient
                # (lencomplete) by computing the previous coefficient in
                # 2 T_2(j) and equating.
                k = lencomplete[cl]-1
                if (cl,k*2) not in coefs:
                    raise MissingCoef(k*2)
                v = 2*coefs[cl,k*2]
                if (k % 2)==0:
                    if (cl2,k//2) not in coefs:
                        raise MissingCoef(k // 2)
                    v += coefs[cl2,k // 2]
                # At this point, v is coefficient k of j^2, computed from
                # the Hecke operators.  Now we can deduce coefficient k+1
                # of j from this:
                for i in range(1, k):
                    v -= coefs[cl,i] * coefs[cl,k-i]
                if (v % 2)!=0:
                    raise Exception("Evenness check failed!")
                v //= 2
                coefs[cl,k+1] = v
                if earlyprint:
                    print ("%s\t%d\t%d"%(cl, k+1, v))
        except MissingCoef as kk:
            print ("MissingCoef#2 " + "%d"%(k))
            pass
    # Print what we've computed so far, in orderly fashion:
    if not earlyprint:
        lastcomplete = lencomplete[selected[0]]
        for cl in selected:
            if lastcomplete < lencomplete[cl]:
                lastcomplete = lencomplete[cl]
        for k in range(lenprinted,lastcomplete):
            for cl in selected:
                print ("%s\t%d\t%d"%(cl, k, coefs[cl,k]))
        lenprinted = lastcomplete
