COMS W4701 - Artificial Intelligence 
Jonathan Voris

Josh Lieberman
jal2238
Assignment 1 - Pattern Matcher

Programming Language Used: ANSI Common Lisp
Development Environment Used: LispWorks Personal Edition 6.1.1 (Intel)
Code tested on these environments: LispWorks Personal Edition 6.1.1 (Intel), GNU CLISP 2.49 (2010-07-07), Steel Bank Common Lisp (SBCL) 1.1.8.0-19cda10

Running the program:
CLISP and SBCL:
Load "jal2238.lisp" and use the entry function (match '(pattern) '(data)).

CLISP:
jal2238@vienna:~$ clisp
  i i i i i i i       ooooo    o        ooooooo   ooooo   ooooo
  I I I I I I I      8     8   8           8     8     o  8    8
  I  \ `+' /  I      8         8           8     8        8    8
   \  `-+-'  /       8         8           8      ooooo   8oooo
    `-__|__-'        8         8           8           8  8
        |            8     o   8           8     o     8  8
  ------+------       ooooo    8oooooo  ooo8ooo   ooooo   8

Welcome to GNU CLISP 2.49 (2010-07-07) <http://clisp.cons.org/>

Copyright (c) Bruno Haible, Michael Stoll 1992, 1993
Copyright (c) Bruno Haible, Marcus Daniels 1994-1997
Copyright (c) Bruno Haible, Pierpaolo Bernardi, Sam Steingold 1998
Copyright (c) Bruno Haible, Sam Steingold 1999-2000
Copyright (c) Sam Steingold, Bruno Haible 2001-2010

Type :h and hit Enter for context help.

[1]> (load "/home/jal2238/cs4701/jal2238.lisp")
;; Loading file /home/jal2238/cs4701/jal2238.lisp ...
;; Loaded file /home/jal2238/cs4701/jal2238.lisp
T
[2]> (match '(?x ?y ?z (& <x >y !z)) '(10 5 7 8))
((?Z . 7) (?Y . 5) (?X . 10))
[3]> (quit)
Bye.
jal2238@vienna:~$

SBCL:
Josh-Liebermans-MacBook-Pro:jal2238_Project_1_Common_Lisp joshlieberman$ sbcl
This is SBCL 1.1.8.0-19cda10, an implementation of ANSI Common Lisp.
More information about SBCL is available at <http://www.sbcl.org/>.

SBCL is free software, provided as is, with absolutely no warranty.
It is mostly in the public domain; some portions are provided under
BSD-style licenses.  See the CREDITS and COPYING files in the
distribution for more information.
* (load "/Users/joshlieberman/workspace/lisp/cs4701/jal2238_Project_1_Common_Lisp/jal2238.lisp")

; file: /Users/joshlieberman/workspace/lisp/cs4701/jal2238_Project_1_Common_Lisp/jal2238.lisp
; in: DEFUN MATCHER
;     (AMP (CDR A) B C)
;
; caught STYLE-WARNING:
;   undefined function: AMP
;
; compilation unit finished
;   Undefined function:
;     AMP
;   caught 1 STYLE-WARNING condition

T
* (match '(?x ?y ?z (& <x >y !z)) '(10 5 7 8))

((?Z . 7) (?Y . 5) (?X . 10))
* (quit)
Josh-Liebermans-MacBook-Pro:jal2238_Project_1_Common_Lisp joshlieberman$

LispWorks:
Open lispworks.  Navigate to File -> Open... and open "jal2238.lisp."  Then navigate to File -> Compile and Load...  The file should load without issue:

Output:
;;; Compiling file /Users/joshlieberman/workspace/lisp/cs4701/jal2238_Project_1_Common_Lisp/jal2238.lisp ...
;;; Safety = 3, Speed = 1, Space = 1, Float = 1, Interruptible = 1
;;; Compilation speed = 1, Debug = 2, Fixnum safety = 3
;;; Source level debugging is on
;;; Source file recording is  on
;;; Cross referencing is on
; (TOP-LEVEL-FORM 0)
; MATCHER
; MATCH
; AMP
;; Processing Cross Reference Information
; Loading fasl file /Users/joshlieberman/workspace/lisp/cs4701/jal2238_Project_1_Common_Lisp/jal2238.xfasl

---- Press Space to continue ----

Press space, and then use the (match '(pattern) '(data)) function in the Listener.

Example:
CL-USER 1 > (match '(?x ?y ?z (& <x >y !z)) '(10 5 7 8))
((?Z . 7) (?Y . 5) (?X . 10))

Function:
My Common Lisp program is heavily commented to describe the function of each section.  This pattern matcher takes two lists as an input, a pattern and a matcher.  The program will return T if the pattern and matcher match, nil if they don't, or a pair of variable bindings if they were assigned by the pattern.

My program uses three functions: match, matcher, and amp.
match: The entry function.  Takes in two lists from the user in the format (match '(pattern) '(matcher/data))
matcher: The main function.  Compares and element of the list pattern to one in the matcher list using recursive calls.
amp: Special function to handle ampersand (&) cases.

My program also uses three variables: list1, list2, and c.
list1: The input list for the pattern.
list2: The input list for the matcher/data.
c: The association list that returns variable pairs when necessary.

As seen in the "jal2238_test.txt" test cases file, my code works for all 25 examples used in the assignment_1.txt instruction file.  The only case that my program fails is the "Horrible Example" given in class.  Somewhere in my program my logic is flawed, but because it works for all test cases except for this one and I am pressed for time, I am handing the program in as-is.

My program has been tested and works with CLISP 2.49 on the CLIC Lab machines.