; ··············································································
; ··············································································
; ··························· BUILD HELP/ABOUT TEXT ····························
; ··············································································
;{··············································································
; "build-text-msgs.pb" | PureBASIC 5.60 | Last edited: 2017-04-03
; (c) by Tristano Ajmone, 2017. MIT License.
; This file is part of the PRENBSP project v1.0 (2017-04-03):
; -- https://github.com/tajmone/prenbsp
; ------------------------------------------------------------------------------
; This file creates the text to be shown with prenbsp's "--help" and "--about"
; options. It must be run before compiling "prenbsp.pb" (and whenever changes
; to this file are made). Its execution will create two files in this folder:
;
;  -- "prenbsp-msg-about.ascii.inc"
;  -- "prenbsp-msg-help.ascii.inc"
;
; these two files are then included by "prenbsp.pb" at compilation time.
; ------------------------------------------------------------------------------
; -- You don't need to compile this file, just run it.
; -- It doesn't matter which PureBASIC architecture version you use to run it
;    (32 or 64 bit): it doesn't have to match the version used to actually
;    compile "prenbsp.pb".
; ------------------------------------------------------------------------------
; This file reuses a module I create for the NTC (Name That Color) project:
;  -- https://github.com/tajmone/name-that-color
;
; It provides some functions for nicely formatting the text to be show on the
; console (wrapping, columns, lists, etc.).
; The module was originally named "ntc.text-funcs.pbi", and is here renamed as:
;  -- "build-text-msgs.text-funcs-mod.pbi"
; ------------------------------------------------------------------------------
; NOTE: Use only Ascii chars (1-128) in the text contents!
; ------------------------------------------------------------------------------
; 1) The help/about text doesn't employ any Unicode chars
; 2) It halfs the text bytes-size in both the executable file and in memory.
;}------------------------------------------------------------------------------

IncludeFile "build-text-msgs.pbhgen.pbi" ;- PBHGENX

IncludeFile "build-text-msgs.text-funcs-mod.pbi" ; <= module with text-formatting
UseModule TextFuncs                              ;    functions (taken from NTC).

#WRAP = 80 ; wrap at column 80 (included)

; ==============================================================================
;                                      HELP                                     
; ==============================================================================
; Build the text to show when PRENBSP si invoked with "--help"
; ------------------------------------------------------------------------------
WRAPME$ = "Fix whitespaces and blank lines inside <pre> blocks through non-breaking spaces " +
          "substitions, without affecting tags. Needed for preserving indentation and " +
          "spacing in old versions of IE, the WebBrowser Control and CHM files."
HELP$ + TextWrap(WRAPME$) + #PAR_SEP

HELP$ + "Usage: prebnsp [options] [<file> [<file> ...]]" + #BLOCK_SEP 

HELP$ + Heading("OPTIONS:") + #PAR_SEP

LT$ + "-h, --help" + #BLOCK_SEP
RT$ + "Show this help guide." + #BLOCK_SEP

LT$ + "-a, --about" + #BLOCK_SEP
RT$ + "Detailed info about prenbsp, its license and purpose." + #BLOCK_SEP

LT$ + "-t <num>, --tabs <num>" + #BLOCK_SEP
RT$ + ~"Replace each tab by <num> spaces [default: 4].\nUse \"-t 0\" to strip all tabs." + #BLOCK_SEP

LT$ + "-f, --fragment" + #BLOCK_SEP
RT$ + "Input (STDIN or files) consists of preformatted contents only, there are no <pre> tags enclosing it. " + 
      "Prenbsp will sanitize all white spaces found outside tags." + #BLOCK_SEP

HELP$ + TwoColumnsWrap(LT$, RT$, -1, #WRAP, "  ")

WRAPME$ = "If no <file> arguments are provided, prebnsp will process from STDIN to STDOUT. " +
          "Each <file> will be processed and overwritten in place, no backups are made."
HELP$ + TextWrap(WRAPME$) + #PAR_SEP

HELP$ + Heading("ERRORS HANDLING:") + #PAR_SEP

WRAPME$ = "Before starting to process the input files, prebnsp will check that: (1) they exist, " +
          "(2) they are not directories, and (3) they are not zero-sized. " +
          "If any input file doesn't meet all these conditions, prebnsp will print " +
          "an error and abort without processing anything."
HELP$ + TextWrap(WRAPME$) + #PAR_SEP

WRAPME$ = "In all other cases, at the first error encountered prebnsp will print an error and abort, " +
          "even if there are still some input files left to process."
HELP$ + TextWrap(WRAPME$) + #PAR_SEP

WRAPME$ = "All errors will produce the same Exit Code (%ERRORLEVEL% = 1)."
HELP$ + TextWrap(WRAPME$)

Debug HELP$

Conv2BinaryFile("prenbsp-msg-help", HELP$)     ; <= filename without extensions!

Debug LSet("", #WRAP, "=")
; ==============================================================================
;                                     ABOUT                                     
; ==============================================================================
; Build the text to show when PRENBSP si invoked with "--about"
; ------------------------------------------------------------------------------
ABOUT$ = ~"\n"+ Heading("ABOUT PRENBSP") + #PAR_SEP

WRAPME$ = "Prenbsp was created to ensure proper rendering of source code examples in " +
          "<pre> and <pre><code> blocks within CHM documents and compiled (executable) HTML eBooks. " +
          "Since in Windows OS these technologies rely on the WebBrowser Control, " +
          "which by default runs in backward compatibility mode and does not support " +
          "word-wrap and whitespace CSS properties, indentation and white spacing is " +
          "collapsed, breaking the readibility of source code examples. "
ABOUT$ + TextWrap(WRAPME$) + #PAR_SEP

WRAPME$ = "Prenbsp solves the issue by substituting with non-breaking space entities " +
          ~"(\"&nbsp;\") every space cahracter (0x20) found in contents within a <pre> block " +
          "and by adding a single non-breaking space in every blank line, without " +
          "affecting any tags in the <pre> block. " + 
          "Any attributes of the <pre> tags will be preserved unchanged."
ABOUT$ + TextWrap(WRAPME$) + #PAR_SEP

WRAPME$ = "This is a simple yet bullet-proof solution, granting proper rendering of source " +
          "code snippets in applications using the WebBrowser Control, CHM documents, old " +
          "versions of IE, and any third party browser or HTML rendering engine not " +
          "supporting whitespace preservation CSS properties. "
ABOUT$ + TextWrap(WRAPME$) + #PAR_SEP

WRAPME$ = ~"Furthermore, since \"&nbsp;\" entities are the proper way to represent " +
          "non-breaking spaces in HTML, their presence won't have any negative effect in " +
          "modern browsers that are fully HTML/HTML5 compliant. " 
ABOUT$ + TextWrap(WRAPME$) + #PAR_SEP

WRAPME$ = "While prenbsp was coinceived to be used with syntax-higlighted code in mind " +
          "(and, particularly, to work in conjunction with Andre Simon's Highlight tool), " +
          "it can be used with any kind of preformatted block (eg: Ascii Art) and will work " +
          "with any syntax highlighter -- either through piping, or by processing the final " +
          "html files. "
ABOUT$ + TextWrap(WRAPME$) + #PAR_SEP

; ------------------------------------------------------------------------------
;                                     USAGE                                     
; ------------------------------------------------------------------------------
ABOUT$ + Heading("USAGE") + #PAR_SEP

WRAPME$ = "You should invoke prenbsp after you've syntax-highlighted your code snippets in the " +
          "HTML document. Prenbsp was designed with Andre Simon's Highlight tool in mind, " +
          "but it should work with any highlighter. You can either pipe the output of the " +
          "highlighter to prenbsp and then redirect prenbsp's output to file, or you can pass " +
          "to prenbsp the filenames of the highlighted html documents as its arguments."
ABOUT$ + TextWrap(WRAPME$) + #PAR_SEP

WRAPME$ = "Prenbsp will parse its input for all occurences of <pre> blocks. If you are " +
          "feeding to prenbsp just the highlighted code (without any surrounding <pre> tags) " +
          ~"you must use the \"--fragment\" option so that prenbsp will substitute " +
          "all whitespace found outside tags. (this option is the counterpart of the " +
          ~"\"-f\"/\"--fragment\" option found in Highlight tool). If you omit " +
          "this option, prenbsp will look for <pre> tags and, failing to find any, will "+
          "end up leaving the input unchanged."
ABOUT$ + TextWrap(WRAPME$) + #PAR_SEP

; ------------------------------------------------------------------------------
;                                    LICENSE                                    
; ------------------------------------------------------------------------------
ABOUT$ + Heading("LICENSE") + #PAR_SEP

WRAPME$ = "Prenbsp is copyright by Tristano Ajmone, 2007, released under the MIT License."
ABOUT$ + TextWrap(WRAPME$)

WRAPME$ = "It was written in PureBASIC. The full source code and binary releases can be found at:"
ABOUT$ + TextWrap(WRAPME$) + #PAR_SEP

ABOUT$ + "  https://github.com/tajmone/prenbsp" + #BLOCK_SEP

ABOUT$ + Heading("THIRD PARTY COMPONENTS", 2) + #PAR_SEP

WRAPME$ = "Prenbsp uses the PCRE library, written by Philip Hazel, " +
          "(c) 1997-2007 University of Cambridge, Cambridge, England, " +
          "released under the BSD license."
ABOUT$ + TextWrap(WRAPME$) + #PAR_SEP

ABOUT$ + "  http://www.pcre.org"+ #BLOCK_SEP

WRAPME$ = ~"The full license of PCRE library can be viewed in the \"LICENSE_PCRE\" file that " +
          "ships with prenbsp."
ABOUT$ + TextWrap(WRAPME$) + #PAR_SEP

; ------------------------------------------------------------------------------
;                                    CREDITS                                    
; ------------------------------------------------------------------------------
ABOUT$ + Heading("ACKNOWLEDGMENTS") + #PAR_SEP

WRAPME$ = "Special thanks to Andre Simon, author of Highlight, to John MacFarlane, " +
          "author of pandoc, and to Christophe Delord, author of PP, for their " +
          "unceasing support to all my questions and feature requests -- without " + 
          "their help and precious tools I wouldn't have managed to setup the workflow " +
          "for automated documentation conversion that I am enjoying today."
ABOUT$ + TextWrap(WRAPME$) + #PAR_SEP

List$ + ~"Highlight ** Source code to formatted text converter, by Andre Simon:" + #PAR_SEP +
        "-- http://www.andre-simon.de" + #PAR_SEP +
        "-- https://github.com/andre-simon/highlight" + #BLOCK_SEP

List$ + ~"Pandoc ** Universal markup converter, by John MacFarlane:" + #PAR_SEP +
        "-- http://pandoc.org" + #PAR_SEP +
        "-- https://github.com/jgm/pandoc" + #BLOCK_SEP

List$ + ~"PP ** Generic preprocessor with pandoc in mind, by Christophe Delord:" + #PAR_SEP +
        "-- http://cdsoft.fr/pp" + #PAR_SEP +
        "-- https://github.com/CDSoft/pp"

ABOUT$ + BulletList(List$, "** ", #WRAP) + #PAR_SEP 

WRAPME$ = "My gratitude goes also the PureBASIC forum users -- one of the " +
          "most supportive and welcoming online communities I've ever met -- " +
          "for having helped me out whenever I was stuck with coding problems."
ABOUT$ + TextWrap(WRAPME$) + #PAR_SEP

ABOUT$ + "  http://www.purebasic.fr/english/"

ABOUT$  + #PAR_SEP

Debug ABOUT$

Conv2BinaryFile("prenbsp-msg-about", ABOUT$)   ; <= filename without extensions!

; ******************************************************************************
; *                       CONVERT STRING TO BINARY FILE                        *
; ******************************************************************************
Procedure Conv2BinaryFile(FileName.s, Contents.s, Format.i = #PB_Ascii)
  ;{ Convert <Contents> string to a file named "<FileName>.(ascii|utf8|ucs2).inc"
  ;  using <Format> as the output format (defaults to #PB_Ascii but accepts also
  ;  #PB_UTF8 and #PB_Unicode).
  ;  The created file is intended for inclusion in the main source, via a labeled
  ;  IncludeBinary instruction inside a DataSection block, so that the text can be
  ;  converted into a Mem Buffer or a String (Unicode only!) via direct pointers
  ;  to labels -- thus avoiding the duplication of contents that would occur
  ;  using the Read.s approach. For more info on this topic, see:
  ;
  ;      http://www.purebasic.fr/english/viewtopic.php?f=13&t=68212
  ;
  ;  NOTE1: All strings in PureBASIC must be in #PB_Unicode and null-terminated.
  ;         Ascii and UTF8 text operations need to go through memory buffers and
  ;         raw data output functions.
  ;  NOTE2: #PB_Unicode is UCS2-LE (Little Endian).
  ;  NOTE3: The BOM is never added (not even with Unicode) because it would
  ;         interfere with the final text in memory.
  ;}----------------------------------------------------------------------------
  Select Format
    Case #PB_UTF8
      FileName + ".utf8.inc"
    Case #PB_Unicode
      FileName + ".ucs2.inc"
    Default ; #PB_Ascii
      FileName + ".ascii.inc"      
  EndSelect
  
  If Not CreateFile(0, FileName)
    MessageRequester("ERROR!", ~"Unable to create file: \""+ FileName +~"\"")
    End 1 ; Exit with Error
  EndIf
  
  WriteString(0, Contents, Format)
  CloseFile(0)
  
EndProcedure
; \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;                                   CHANGELOG                                   
; //////////////////////////////////////////////////////////////////////////////
;
; v1.0 (2017-04-03) -- First release.