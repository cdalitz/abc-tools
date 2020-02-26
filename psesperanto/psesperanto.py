#!/usr/bin/python
#
# convert abctab2ps output to esperanto latin3 postscript
# cx etc. is converted to the proper chars in latin3 encoding
#
# Author:  Christoph Dalitz
# Version: 1.0 from 2017-10-02
# License: GNU GPL version 2
#

import sys
import os
import re

usagemsg = "Usage: psesperanto.py <in.ps>\n"
infile = None
outfile = sys.stdout

# parse command line
i = 1
while i < len(sys.argv):
    infile = sys.argv[i]
    i = i + 1
if not infile or not os.path.isfile(infile):
    sys.stderr.write(usagemsg)
    sys.exit(1)

# latin3 encoding
ps_encodingvector = """%%BeginResource: procset Character-Encoding-ISO-8859-3
/ISOLatin3Encoding [
/.notdef      	/.notdef      	/.notdef      	/.notdef      	
/.notdef      	/.notdef      	/.notdef      	/.notdef      	
/.notdef      	/.notdef      	/.notdef      	/.notdef      	
/.notdef      	/.notdef      	/.notdef      	/.notdef      	
/.notdef      	/.notdef      	/.notdef      	/.notdef      	
/.notdef      	/.notdef      	/.notdef      	/.notdef      	
/.notdef      	/.notdef      	/.notdef      	/.notdef      	
/.notdef      	/.notdef      	/.notdef      	/.notdef      	
/space        	/exclam       	/quotedbl     	/numbersign   	
/dollar       	/percent      	/ampersand    	/quoteright   	
/parenleft    	/parenright   	/asterisk     	/plus         	
/comma        	/hyphen       	/period       	/slash        	
/zero         	/one          	/two          	/three        	
/four         	/five         	/six          	/seven        	
/eight        	/nine         	/colon        	/semicolon    	
/less         	/equal        	/greater      	/question     	
/at           	/A            	/B            	/C            	
/D            	/E            	/F            	/G            	
/H            	/I            	/J            	/K            	
/L            	/M            	/N            	/O            	
/P            	/Q            	/R            	/S            	
/T            	/U            	/V            	/W            	
/X            	/Y            	/Z            	/bracketleft  	
/backslash    	/bracketright 	/asciicircum  	/underscore   	
/quoteleft    	/a            	/b            	/c            	
/d            	/e            	/f            	/g            	
/h            	/i            	/j            	/k            	
/l            	/m            	/n            	/o            	
/p            	/q            	/r            	/s            	
/t            	/u            	/v            	/w            	
/x            	/y            	/z            	/braceleft    	
/bar          	/braceright   	/tilde        	/.notdef      	
/.notdef      	/.notdef      	/.notdef      	/.notdef      	
/.notdef      	/.notdef      	/.notdef      	/.notdef      	
/.notdef      	/.notdef      	/.notdef      	/.notdef      	
/.notdef      	/.notdef      	/.notdef      	/.notdef      	
/.notdef      	/.notdef      	/.notdef      	/.notdef      	
/.notdef      	/.notdef      	/.notdef      	/.notdef      	
/.notdef      	/.notdef      	/.notdef      	/.notdef      	
/.notdef      	/.notdef      	/.notdef      	/.notdef      	
/space        	/Hbar         	/breve        	/sterling     	
/currency     	/yen          	/Hcircumflex  	/section      	
/dieresis     	/Idotaccent   	/Scedilla     	/Gbreve       	
/Jcircumflex  	/hyphen       	/registered   	/Zdotaccent   	
/degree       	/hbar         	/twosuperior  	/threesuperior	
/acute        	/mu           	/hcircumflex  	/bullet       	
/cedilla      	/dotlessi     	/scedilla     	/gbreve       	
/jcircumflex  	/onehalf      	/threequarters	/zdotaccent   	
/Agrave       	/Aacute       	/Acircumflex  	/Atilde       	
/Adieresis    	/Cdotaccent   	/Ccircumflex  	/Ccedilla     	
/Egrave       	/Eacute       	/Ecircumflex  	/Edieresis    	
/Igrave       	/Iacute       	/Icircumflex  	/Idieresis    	
/Eth          	/Ntilde       	/Ograve       	/Oacute       	
/Ocircumflex  	/Gdotaccent   	/Odieresis    	/multiply     	
/Gcircumflex  	/Ugrave       	/Uacute       	/Ucircumflex  	
/Udieresis    	/Ubreve       	/Scircumflex  	/germandbls   	
/agrave       	/aacute       	/acircumflex  	/atilde       	
/adieresis    	/cdotaccent   	/ccircumflex  	/ccedilla     	
/egrave       	/eacute       	/ecircumflex  	/edieresis    	
/igrave       	/iacute       	/icircumflex  	/idieresis    	
/eth          	/ntilde       	/ograve       	/oacute       	
/ocircumflex  	/gdotaccent   	/odieresis    	/divide       	
/gcircumflex  	/ugrave       	/uacute       	/ucircumflex  	
/udieresis    	/ubreve       	/scircumflex  	/dotaccent    	
] def
%%EndResource
"""

# function that does the character translation
def translate_one_str(sin):
    sout = sin.replace("HX","\\246 ")
    sout = sout.replace("Hx","\\246 ")
    sout = sout.replace("hx","\\266 ")
    sout = sout.replace("CX","\\306 ")
    sout = sout.replace("Cx","\\306 ")
    sout = sout.replace("cx","\\346 ")
    sout = sout.replace("SX","\\336 ")
    sout = sout.replace("Sx","\\336 ")
    sout = sout.replace("sx","\\376 ")
    sout = sout.replace("JX","\\254 ")
    sout = sout.replace("Jx","\\254 ")
    sout = sout.replace("jx","\\274 ")
    sout = sout.replace("GX","\\330 ")
    sout = sout.replace("Gx","\\330 ")
    sout = sout.replace("gx","\\370 ")
    sout = sout.replace("UX","\\335 ")
    sout = sout.replace("Ux","\\335 ")
    sout = sout.replace("ux","\\375 ")
    return sout
def translate_all_str(sin):
    sout = ""
    s2replace = ""
    pos = 0
    inparen = 0
    while (pos < len(sin)):
        if sin[pos] == "(":
            inparen += 1
        if inparen == 0:
            sout += sin[pos]
        else:
            s2replace += sin[pos]
        if sin[pos] == ")":
            inparen -= 1
            if inparen == 0:
                sout += translate_one_str(s2replace)
                s2replace = ""
        pos += 1
    if (inparen != 0):
        sys.stderr("Warning: mismatched parenthesis\n")
    return sout

# read infile and add/replace stuff
rexpr = re.compile(".*\(.*[cghjsu]x.*\).*", re.IGNORECASE)
f = open(infile)
for line in f:
    if line.startswith("%%BeginSetup"):
        outfile.write("%%BeginProlog\n" + ps_encodingvector + "%%EndProlog\n\n")
        sys.stdout.write(line)
    elif "ISOLatin1Encoding" in line:
        sys.stdout.write(line.replace("ISOLatin1Encoding", "ISOLatin3Encoding"))
    elif rexpr.match(line):
        sys.stdout.write(translate_all_str(line))
    else:
        sys.stdout.write(line)
