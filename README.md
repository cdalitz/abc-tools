Some simple tools for the ABC music notation
============================================

The ABC music notation is an ASCII code for notating music. It was
originally developed by Chris Walshaw and there are meanwhile many
tools for processing this notation, e.g. [abctab2ps](http://www.lautengesellschaft.de/cdmm/)
or [abm2ps](http://moinejf.free.fr/) for converting it to Postscript,
[abc2midi](http://abc.sourceforge.net/abcMIDI/) for converting it to MIDI, or
[abc2svg](http://moinejf.free.fr/) for converting it to SVG.

Here are some tools that I occasionally find useful when working with
abc and abctab2ps.


Add page numbers to PS files
----------------------------

The Perl script *pspage* adds page numbers at choosable positions and fonts
to a given Postscript file. The call *pspage -?* prints a usage message.


Part extraction
---------------

The Perl script *abcselect* can extract voices, movements ("tunes" in
abc lingo) etc. from abc files. See the subdirectory *abcselect* for
details and a man page describing its usage.


Conversion from TAB to ABC
--------------------------

The Perl script *tab2abc* converts a file in Wayne Cripps' tab format to
abc as understood by *abctab2ps*. See the subdirectory *tab2abc* for
details and a man page describing its usage.


Esperanto character conversion
------------------------------

The Python script *psesperanto.py* is only useful in combination with
*abctab2ps*. It converts the combination 'cx', 'gx', etc. in the Postscript
output of *abctab2ps* to the respective Esperanto characters in ISO-8859-3
encoding. See the subdirectory *psesperanto* for details and an example.


Transpose ABC files
-------------------

The Perl script *transpose_abc.pl* transposes abc files. Calling it without
arguments prints a usage message.

Beware that *transpose_abc.pl* almost always transposes accidentals erroneously.
The results therefore require post-correction, but the tool is nevertheless
useful.


ABC mode for the text editor Emacs
----------------------------------------------

It is provided by the file *abctab-mode.el* and adds syntax highlighting
and menu entries and shortcuts for calling abctab2ps or abcm2ps directly
from within Emacs. See the comments at the beginning of the file for
installation instructions.

Note that there is an easier integrated abc editor available elsewhere,
see [flabc](http://www.lautengesellschaft.de/cdmm/), but if you are using
Emacs anyway, this mode will be useful.


ABC macros for the text editor Nedit
---------------------------------------------

Adds syntax highlighting menu entries for calling abctab2ps or abcm2ps
form within the editor Nedit. See the subdirectory *nedit-macro* for
details and installation instructions.


Author
------

All tools have been written by Christoph Dalitz with the exception of
*transpose_abc.pl*, which was written by Matthew J. Fisher.


License
-------

Almost all scripts are provided under the GPL license. See the file
LICENSE-GPL for details. The only exception is *transpose_abc.pl*, which
was licensed by Matthew J. Fisher under a BSD-style license (see the comments
in the file itself).
