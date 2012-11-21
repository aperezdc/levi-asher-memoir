=================================
 Levin Asher memoir EPUB creator
=================================

This is a Makefile and supporting tools and files to assemble an EPUB from
the online articles that conform Levin Asher's memoirs. The original texts
can be found at http://www.litkicks.com/AMemoirInProgress

Note that **this is not the book itself**: the HTML files will be downloaded
from the above address, and used to assemble a document that can be used
with e-book readers.

To build the output ``memoir.epub`` file, run::

  make download && make


Requirements
============

If you are running a decent Unix-like system, most likely you will already
have those (or easilt available in your package manager):

* GNU Make.
* ``wget``
* Python 2.x
* Command line ``zip`` tool from Info-Zip.

