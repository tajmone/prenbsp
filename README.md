PRENBSP
=======

-   <https://github.com/tajmone/prenbsp>

Convert spaces inside `<pre>` blocks to non-breaking space entities (`&nbsp;`).

    prenbsp v1.0 (2017-04-03) | PureBASIC 5.60 | Win OS | Console 32/64 bit

Windows command line tool to optimize html documents containing source code snippets so that they show properly in CHM documents, compiled HTML eBooks and in the WebBrowser Control.

Standalone executable (c. 200 Kb). Created with André Simon’s [Highlight](http://www.andre-simon.de/doku/highlight/en/highlight.php) tool in mind — but works with any syntax highlighter and on any html document.

Pre-compiled binary available for download:

-   [PRENBSP v1.0 (32 bit)](https://github.com/tajmone/prenbsp/releases/download/v1.0/prenbsp_v1.0_Win_x86_binary.zip)
-   [PRENBSP v1.0 (64 bit)](https://github.com/tajmone/prenbsp/releases/download/v1.0/prenbsp_v1.0_Win_x86-64_binary.zip)

------------------------------------------------------------------------

<!-- #toc -->
-   [Introduction](#introduction)
-   [Installation](#installation)
-   [Usage](#usage)
-   [Building](#building)
-   [License](#license)
-   [Acknowledgments](#acknowledgments)

<!-- /toc -->

------------------------------------------------------------------------

Introduction
============

Prenbsp was created to ensure proper rendering of source code examples in `<pre>` and `<pre><code>` blocks within CHM documents and compiled (executable) HTML eBooks. Since in Windows OS these technologies rely on the WebBrowser Control, which by default runs in backward compatibility mode and does not support word-wrap and whitespace CSS properties, indentation and white spacing is collapsed, breaking the readibility of source code examples.

Prenbsp solves the issue by substituting with non-breaking space entities (“`&nbsp;`”) every space cahracter (0x20) found in contents within a `<pre>` block and by adding a single non-breaking space in every blank line, without affecting any tags in the `<pre>` block. Any attributes of the `<pre>` tags will be preserved unchanged.

This is a simple yet bullet-proof solution, granting proper rendering of source code snippets in applications using the WebBrowser Control, CHM documents, old versions of IE, and any third party browser or HTML rendering engine not supporting whitespace preservation CSS properties.

Furthermore, since “`&nbsp;`” entities are the proper way to represent non-breaking spaces in HTML, their presence won’t have any negative effect in modern browsers that are fully HTML/HTML5 compliant.

While prenbsp was coinceived to be used with syntax-higlighted code in mind (and, particularly, to work in conjunction with André Simon’s [Highlight](http://www.andre-simon.de/doku/highlight/en/highlight.php) tool), it can be used with any kind of preformatted block (eg: Ascii Art) and will work with any syntax highlighter – either through piping, or by processing the final html files.

Installation
============

No installation required: just download archive and extract binary (or compile source code) and copy it to working folder (or put in a folder that is on system `%PATH%`).

Usage
=====

    >prenbsp --help

    prebnsp v1.0 (64bit) by Tristano Ajmone, 2017.

    Fix whitespaces and blank lines inside <pre> blocks through non-breaking spaces 
    substitions, without affecting tags. Needed for preserving indentation and      
    spacing in old versions of IE, the WebBrowser Control and CHM files.

    Usage: prebnsp [options] [<file> [<file> ...]]

    OPTIONS:
    ========

    -h, --help              Show this help guide.                                   
    -a, --about             Detailed info about prenbsp, its license and purpose.   
    -t <num>, --tabs <num>  Replace each tab by <num> spaces [default: 4].          
                            Use "-t 0" to strip all tabs.                           
    -f, --fragment          Input (STDIN or files) consists of preformatted         
                            contents only, there are no <pre> tags enclosing it.    
                            Prenbsp will sanitize all white spaces found outside    
                            tags.                                                   
                                                                                    
    If no <file> arguments are provided, prebnsp will process from STDIN to STDOUT. 
    Each <file> will be processed and overwritten in place, no backups are made.

    ERRORS HANDLING:
    ================

    Before starting to process the input files, prebnsp will check that: (1) they   
    exist, (2) they are not directories, and (3) they are not zero-sized. If any    
    input file doesn't meet all these conditions, prebnsp will print an error and   
    abort without processing anything.

    In all other cases, at the first error encountered prebnsp will print an error  
    and abort, even if there are still some input files left to process.

    All errors will produce the same Exit Code (%ERRORLEVEL% = 1).

Building
========

To compile PRENBSP you’ll need [PureBASIC](http://www.purebasic.com/) for Windows. Detailed compilation instructions are found in the source code comments.

> **NOTE**: This application was intended for Windows OS because it addresses a problem specific to Windows users. It should also compile and work on Linux and Mac, but it wasn’t tested and might need some tweaking.

License
=======

Prenbsp is copyright by [Tristano Ajmone](https://github.com/tajmone), 2007, released under the [MIT License](./LICENSE). It was written in [PureBASIC](http://www.purebasic.com/). The full source code and binary releases can be found at:

-   <https://github.com/tajmone/prenbsp>

Prenbsp uses the **PCRE library**, written by Philip Hazel, (c) 1997-2007 University of Cambridge, Cambridge, England, released under the BSD license.

-   <http://www.pcre.org>

The full license of PCRE library can be viewed in the [LICENSE\_PCRE](LICENSE_PCRE) file.

Acknowledgments
===============

Special thanks to André Simon, author of Highlight, to John MacFarlane, author of pandoc, and to Christophe Delord, author of PP, for their unceasing support to all my questions and feature requests — without their help and precious  
tools I wouldn’t have managed to setup the workflow for automated documentation conversion that I am enjoying today.

-   **Highlight** — Source code to formatted text converter, by [André Simon](https://github.com/andre-simon):
    -   <http://www.andre-simon.de>
    -   <https://github.com/andre-simon/highlight>  
-   **Pandoc** — Universal markup converter, by [John MacFarlane](https://github.com/jgm):
    -   <http://pandoc.org>  
    -   <https://github.com/jgm/pandoc>  
-   **PP** — Generic preprocessor with pandoc in mind, by [Christophe Delord](https://github.com/CDSoft):
    -   <http://cdsoft.fr/pp>
    -   <https://github.com/CDSoft/pp>

My gratitude goes also the [PureBASIC forum](http://www.purebasic.fr/english/) users — one of the most supportive and welcoming online communities I’ve ever met — for having helped me out whenever I was stuck with coding problems. And in particulare to users **@Demivec**, **@DontTalkToMe** and **@djes** for having helped me understand and optimize the technique for binary inclusion of strings from external files used in PRENBSP:

-   <http://www.purebasic.fr/english/viewtopic.php?f=13&t=68212>

