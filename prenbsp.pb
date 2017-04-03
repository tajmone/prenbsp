; ··············································································
; ··············································································
; ·································· PRENBSP ···································
; ··············································································
; ····························· by Tristano Ajmone ·····························
; ··············································································
;{··············································································
; prenbsp v1.0 (2017-04-03) | PureBASIC 5.60 | Win OS | Console 32/64 bit
; (c) by Tristano Ajmone, 2017. MIT License.
; ------------------------------------------------------------------------------
; Project Git repository:
; -- https://github.com/tajmone/prenbsp
; ------------------------------------------------------------------------------
; Uses PCRE library, by Philip Hazel, (c) 1997-2007 University of Cambridge,
; Cambridge, England. Released under BSD License.
;}------------------------------------------------------------------------------

#prenbspVer = "1.0" ; Current PRENBSP release version number.

; ******************************************************************************
; *                                                                            *
; *                           BUILDING INSTRUCTIONS                            *
; *                                                                            *
;{******************************************************************************
; Building PRENBSP is a two steps process:
; (1) Run "build-text-msgs.pb" from PureBASIC IDE (no need to compile it). You
;     may use 32 or 64 bit version of PureBASIC, indifferently.
; (2) Compile "prenbsp.pb" (this file) to "prenbsp.exe" using the "Console"
;     Executable format option.
;
; -  Step 1 will dynamically create two files required for inclusion by this
; source file (they contain the text shown by "--help" and "--about" options).
; -  When further compiling PRENBSP, you won't need to redo Step 1 unless you
; changed the contents of Help or About messages (inside "build-text-msgs.pb").
; ------------------------------------------------------------------------------
; -  This application was intended for Windows OS because it addresses a problem
; specific to Windows users. It should also compile and work on Linux and Mac,
; but it wasn't tested and might need some tweaking.
; -  You can compile it as 32 or 64 bit alike. For portability sake, 32 bit is
; a better choice for distribution because it will run on any Windows OS. But
; if you are building it yourself, stick to your OS bitness. The compiled binary
; will display its bitness in the "--help" output, along with the release info.
;}------------------------------------------------------------------------------
CompilerIf #PB_Compiler_ExecutableFormat <> #PB_Compiler_Console
  CompilerError "This program must be compiled into Console executable format!"
CompilerEndIf

IncludeFile "prenbsp.pbhgen.pbi" ;- PBHGENX

; ==============================================================================
;                                   INITIALIZE                                  
; ==============================================================================
inBuff.s            ; Input buffer
outBuff.s           ; Output buffer
#BUFF_STEP = 10000  ; 10Kb -- Value of STDIN Buffer incremental steps.
preBlock.s          ; <pre>..</pre> block

CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
  #archBits = "32" ; This is needed for showing bitness in "--help" output.
CompilerElse
  #archBits = "64"
CompilerEndIf
; ------------------------------------------------------------------------------
;                              Regular Expressions                              
; ------------------------------------------------------------------------------
; RegExWS :: split <pre> contents in two groups: (1) code outside tags; (2) tags.
; Since <pre> blocks don't always end with a tag, the tag group is optional.
RegExWS  = CreateRegularExpression(#PB_Any, "([^<]*)((<[^>]+>)+)?",
                                   #PB_RegularExpression_DotAll |
                                   #PB_RegularExpression_AnyNewLine)
; RegExEOL :: catch consecutive EOL chars of the same type (no mix-mode).
RegExEOL = CreateRegularExpression(#PB_Any, "(\r\n|\n|\r)\1")

Enumeration ; ---------------------- Read / Write Options ----------------------
  #STDIN
  #STDOUT
  #FILE
EndEnumeration

Structure FilesList ; ---------------- list of files to process ----------------
  name.s
  size.i
EndStructure
NewList inFiles.FilesList()

; ==============================================================================
;                                DEFAULT SETTINGS                               
; ==============================================================================

optReadFrom = #STDIN  ; -------------------- Default Options --------------------
optWriteTo  = #STDOUT
tabSpaces = 4         ; Subst. each Tab with 4 spaces.

; \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ MAIN START \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
OpenConsole()
; ==============================================================================
;                                CHECK PARAMETERS                               
; ==============================================================================
params = CountProgramParameters()
If params
  For i=0 To params-1       ; program was invoked with parameters, parse them...
    
    currParam.s = ProgramParameter() 
    Select currParam
      Case "-h", "--help"
        Goto SHOW_HELP
      Case "-a", "--about"
        Goto SHOW_ABOUT
      Case "-f", "--fragment"
        optFrag = #True
      Case "-t", "--tabs"
        tabSpacesArg.s = ProgramParameter()
        i + 1 ; adjust index of For/Next loop
        tabSpaces = Val(tabSpacesArg)
        If Not tabSpaces And tabSpacesArg <> "0"
          ; Unless argument is a literal "0" there was an error...
          Abort(~"Invalid argument for tabs replacement: \""+ tabSpacesArg +~"\"")
        EndIf
      Default ; --------------- Then param must be a filename... ---------------
        optReadFrom = #FILE                      ; set all IO operations to File
        optWriteTo  = #FILE
        ; ----------------------------------------------------------------------
        ;                Check Input Files and Create Files List                    
        ; ----------------------------------------------------------------------
        probe = FileSize(currParam)
        If probe < 1                     ; ~~~ Something wrong with filename ~~~
          Select probe
            Case -1
              Abort(~"File not found: \""+ currParam +~"\"")
            Case -2
              Abort(~"Argument is a directory: \""+ currParam +~"\"")
            Case 0
              Abort(~"Zero-length file: \""+ currParam +~"\"")
            Default
              ; We shouldn't be here: all known error were covered above.
              ; But you never know ...
              Abort(~"Unknown problem with file: \""+ currParam +~"\"")
          EndSelect
        Else                                        ; --- File is good to go ---
          AddElement(inFiles())
          inFiles()\name = currParam
          inFiles()\size = probe
        EndIf 
    EndSelect
    
  Next ; [ iterate through next param ]
EndIf

; ============================= GET INPUT STREAMS ==============================
If optReadFrom = #STDIN
  inBuff = ReadFromSTDIN()
  Gosub PROCESS_INPUT
  WriteToSTDOUT(outBuff)
Else
  ResetList(inFiles())
  While NextElement(inFiles())                     ; Process all queued files...
    inBuff = ReadFromFile(inFiles()\name, inFiles()\size)
    Gosub PROCESS_INPUT
    WriteToFile(outBuff, inFiles()\name)
  Wend
EndIf

; ==============================================================================
;-                               WRAP-UP AND QUIT                               
; ==============================================================================
WRAP_UP:

CloseConsole()
End 0 ; set Exit Code to Success/No Error
; \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ MAIN END \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

; ******************************************************************************
; *                                SUBROUTINES                                 *
; ******************************************************************************
; The good old skool subs (Gosub / Return) ... for spaghetti-code nostalgics!
; It's BASIC man... and we all love pasta!
; ==============================================================================
;                                 PROCESS INPUT                                 
; ==============================================================================
PROCESS_INPUT:

; ==============================================================================
;                             PROCESS CODE FRAGMENT                             
; ==============================================================================
If optFrag
  outBuff = CleanCodeBlock(inBuff) ; there are no <pre> tags in a fragment!
  Return
EndIf

; ==============================================================================
;                        FIND AND PROCESS ALL PRE BLOCKS                        
; ==============================================================================
outBuff = #Null$
Repeat
  PreStart = FindPreStart(inBuff)
  If PreStart
    PreEnd   = FindPreEnd(inBuff, PreStart)
    outBuff + Left(inBuff, PreStart-1)
    preBlock = CleanCodeBlock(Mid(inBuff, PreStart, PreEnd-PreStart))
    outBuff + preBlock
    inBuff = Mid(inBuff, PreEnd)
  Else                               ; No more occurences of <pre> tag found ...
    outBuff + inBuff                 ; append rest of unprocessed stream
  EndIf
Until PreStart = 0

Return
; ******************************************************************************
; *                               "GOTO" LABELS                                *
; ******************************************************************************
; Old skool jumping up and down and all over the place ... just like a yo-yo.
; ==============================================================================
;-                                  SHOW HELP                                   
; ==============================================================================
SHOW_HELP:

; This first line needs to be generated outside the IncludeBinary DataSection
; because of the two locally defined constants.
*PRENBSP_INFO = Ascii(~"\nprebnsp v"+ #prenbspVer +" ("+ #archBits +"bit) " + 
                      ~"by Tristano Ajmone, 2017.\n\n")
WriteConsoleData(*PRENBSP_INFO, MemorySize(*PRENBSP_INFO)-1)
FreeMemory(*PRENBSP_INFO)                                       ; Release memory

; The rest of the Help msg will be taken from memory via a pointer pointing at
; the data label of a binary-included external file (Ascii).
*HELP_MSG = ?IMPORTED_HELP_MSG

; Because it's Ascii -- and because Print() causes problems with pipes -- we'll
; print the text as raw data via WriteConsoleData().
WriteConsoleData(*HELP_MSG, ?IMPORTED_HELP_MSG_END - ?IMPORTED_HELP_MSG)

; +--------------------------------------------------------------------+
; | SPECIAL THANKS to @Demivec, @DontTalkToMe and @djes for helping me |
; | understand and optimize this approach of binary including strings: |
; | -- http://www.purebasic.fr/english/viewtopic.php?f=13&t=68212      |
; +--------------------------------------------------------------------+
DataSection
  IMPORTED_HELP_MSG:
  IncludeBinary "prenbsp-msg-help.ascii.inc"      ; <-- Ascii characters (1-128)
  IMPORTED_HELP_MSG_END:
EndDataSection

Goto WRAP_UP
; ==============================================================================
;-                                  SHOW ABOUT                                  
; ==============================================================================
SHOW_ABOUT:

; Just like with *HELP_MSG before, all text is stored in an Ascii binary-included 
; DataSection and retrieved via labels pointers.

*ABOUT_MSG = ?IMPORTED_ABOUT_MSG
WriteConsoleData(*ABOUT_MSG, ?IMPORTED_ABOUT_MSG_END - ?IMPORTED_ABOUT_MSG)

DataSection
  IMPORTED_ABOUT_MSG:
  IncludeBinary "prenbsp-msg-about.ascii.inc"     ; <-- Ascii characters (1-128)
  IMPORTED_ABOUT_MSG_END:
EndDataSection

Goto WRAP_UP
; ******************************************************************************
; *                                 PROCEDURES                                 *
; ******************************************************************************

; ==============================================================================
;                                READ FROM STDIN                                
; ==============================================================================
Procedure.s ReadFromSTDIN()
  
  szTot  = 0
  szFree = #BUFF_STEP
  *inBuff = AllocateMemory(szFree)
  
  Repeat
    szRead = ReadConsoleData(*inBuff + szTot, szFree) ; read a chunck of data
    szTot  + szRead
    szFree - szRead
    If szFree < 100  ; Buffer needs resizing...
      szFree = #BUFF_STEP
      *inBuff = ReAllocateMemory(*inBuff, szTot + #BUFF_STEP)
    EndIf
  Until szRead = 0 ; Nothing left to read
  
  ; ------------------ convert input buffer to Unicode string ------------------
  inBuff.s = PeekS(*inBuff, -1, #PB_UTF8)
  FreeMemory(*inBuff)                                           ; Release memory
  ProcedureReturn inBuff
  
EndProcedure
; ==============================================================================
;                                 READ FROM FILE                                
; ==============================================================================
Procedure.s ReadFromFile(fileName.s, fileSize.i)
  
  If Not ReadFile(0, fileName, #PB_File_SharedRead | #PB_Unicode)
    Abort(~"Unable to open file: \""+ fileName +~"\"")
  EndIf
  *inBuff = AllocateMemory(fileSize)
  If Not ReadData(0, *inBuff, fileSize)
    Abort(~"Unable to read file: \""+ fileName +~"\"")
  EndIf
  CloseFile(0)
  ; ------------------ convert input buffer to unicode string ------------------
  inBuff.s = PeekS(*inBuff, -1, #PB_UTF8)
  FreeMemory(*inBuff)                                           ; Release memory
  ProcedureReturn inBuff
  
EndProcedure
; ==============================================================================
;                                WRITE TO SDTDOUT                               
; ==============================================================================
Procedure WriteToSTDOUT(outBuff.s)
  
  *outBuff = UTF8(outBuff) ; Convert output string to UTF8 buffer
  WriteConsoleData(*outBuff, MemorySize(*outBuff))
  FreeMemory(*outBuff)                                          ; Release memory

EndProcedure
; ==============================================================================
;                                 WRITE TO FILE                                 
; ==============================================================================
Procedure WriteToFile(outBuff.s, fileName.s)
  
  ; Since we are overwriting the original input file, we are sure it exists...
  If Not OpenFile(0, fileName, #PB_File_SharedRead | #PB_UTF8)
    Abort(~"Unable to open file: \""+ fileName +~"\"")
  EndIf
  
  *outBuff = UTF8(outBuff) ; Convert output string to UTF8 buffer
  If Not WriteData(0, *outBuff, MemorySize(*outBuff)-1) ; -1 excludes ZT char
    Abort(~"Unable to write file: \""+ fileName +~"\"")
  EndIf
  CloseFile(0)
  FreeMemory(*outBuff)                                          ; Release memory
 
EndProcedure
; ==============================================================================
;                            FIND START OF PRE BLOCK                            
; ==============================================================================

Procedure.i FindPreStart(tmpBuff.s)
  
  TagBegin = FindString(tmpBuff, "<pre", 1, #PB_String_NoCase)
  If TagBegin                                         ;       ________
    Pos = FindString(tmpBuff, ">", TagBegin + 4)      ;      /         \
    If Not Pos                                        ;      |  MOOOO  |
      ProcedureReturn 0                               ;      \______  /
    EndIf                                             ;             \| (__)
    ProcedureReturn Pos + 1                           ;        `\------(oo)
  Else                                                ;          || ## (__)
    ProcedureReturn 0                                 ;          ||w--||     \|/
  EndIf                                               ;      \|/
  
EndProcedure
; ==============================================================================
;                             FIND END OF PRE BLOCK                             
; ==============================================================================
Procedure.i FindPreEnd(tmpBuff.s, startPos)
  
  Pos = FindString(tmpBuff, "</pre>", startPos, #PB_String_NoCase)
  ProcedureReturn Pos
  
EndProcedure

; ==============================================================================
;                              CLEAN UP CODE BLOCK                              
; ==============================================================================
; Clean up HTML code block: subst whitespaces (outside tags) with "&nbsp;".
; ------------------------------------------------------------------------------
Procedure.s CleanCodeBlock(block.s)
  Shared RegExWS, RegExEOL, tabSpaces
  Define.s code, tags, Clean
  
  ExamineRegularExpression(RegExWS, block)      ;         _._     _,-'""`-._
  While NextRegularExpressionMatch(RegExWS)     ;        (,-.`._,'(       |\`-/|
    code = RegularExpressionGroup(RegExWS, 1)   ;            `-.-' \ )-`( , o o)
    tags = RegularExpressionGroup(RegExWS, 2)   ;                  `-    \`_`"'-
    code = ReplaceString(code, Chr(9), Space(tabSpaces))
    Clean + ReplaceString(code, " ", "&nbsp;") + tags
  Wend  
  
  ; ------------------ Insert a "&nbsp;" in every blank line! ------------------
  While MatchRegularExpression(RegExEOL, Clean)
    Clean = ReplaceString(Clean, #CRLF$+#CRLF$, #CRLF$ +"&nbsp;"+ #CRLF$) ; Win  style
    Clean = ReplaceString(Clean, #LF$+#LF$, #LF$ +"&nbsp;"+ #LF$)         ; Unix style
    Clean = ReplaceString(Clean, #CR$+#CR$, #CR$ +"&nbsp;"+ #CR$)         ; Mac  style
  Wend
  
  ProcedureReturn Clean
EndProcedure
; ==============================================================================
;                             PRINT ERROR AND ABORT                             
; ==============================================================================
Procedure Abort(ErrMsg.s)
  
  ConsoleError("ERROR -- "+ ErrMsg + #LF$ +"Aborting all oprations...")
  End 1 ; set Exit Code to Error (generic)
  
EndProcedure

; \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;                                   CHANGELOG                                   
; //////////////////////////////////////////////////////////////////////////////
;
; v1.0 (2017-04-03) -- First release.