;; abctab-mode.el - An Emacs major-mode for editing abc source

;; Filename: abctab-mode.el
;; Author:   Christoph Dalitz
;; Version:  1.6.2
;; License:  GNU General Public License

;; Installation:
;;
;;  1) Optionally, byte-compile this file
;;  2) Put this file in a directory Emacs can find
;;  3) Tell Emacs when to load this file
;;  4) Customize some variables for your system
;;
;; ad 1)
;;  Byte-compilation speeds up the load time for this mode
;;  and is therefore recommended. Just load this file into
;;  Emacs and select "Byte-compile This File" from the
;;  "Emacs-Lisp" main menu. This will create the compiled
;;  file with the extension "elc".
;;  On Unix, you will get warnings during compilation,
;;  which can safely be ignored.
;;
;; ad 2)
;;  The directories that Emacs searches are given by the 
;;  load-path variable, which you can query within Emacs with
;;     ESC-x describe-variable RET load-path Ret
;;  To add a directory (eg. ~/elisp) to load-path, add 
;;  the following code to your $HOME/.emacs file:
;;     (add-to-list 'load-path "~/elisp")
;;
;; ad 3)
;;  Add the following lines to your $HOME/.emacs file:
;;     (autoload 'abctab-mode "abctab-mode" "ABC mode." t)
;;     (add-to-list 'auto-mode-alist '("\\.abc$" . abctab-mode))
;;  The first line tells Emacs to load abctab-mode.elc or
;;  abctab-mode.el when the command 'abctab-mode' is called.
;;  The second line tells emacs to invoke the command 'abctab-mode'
;;  when a file with a name ending on ".abc" is opened.
;;
;; ad 4)
;;  Some variables might need adjustment to your local system
;;  environment. You can do it in your $HOME/.emacs file with 
;;  commands like
;;     (setq abctab-program  "abctab2ps")
;;     (setq abctab-psviewer "ghostview")
;;     (setq abctab-psfile   "/tmp/abc.ps")
;;     (setq abctab-psfile   "/tmp/tune.abc")
;;  You can also set this Variables interactively from the
;;  entry "Options" in the "ABC" main menu that is created
;;  when abctab-mode is entered.
;;
;;  Notes to Win32-Users:
;;   a) You will probably need to specify the full path name
;;      for abctab2ps and ghostview (for some obscure reason
;;      the use of the search path is unusual on Win32)
;;   b) Use slash (/) instead of backslash (\) in path names
;;   c) You might need to adjust the variables
;;        shell-file-name
;;        w32-quote-process-args
;;        shell-command-switch
;;      depending on whether you only have the crappy DOS-shell
;;      (ie. "command.com" on Win9x and "cmd.exe" on WinNT) 
;;      or a proper shell like bash or ksh. Beware that this
;;      mode has only been tested with bash; it may not work
;;      with the DOS-shell at all!
;;      See the Win32-Emacs distribution for details.

;; History
;;
;;   27.11.2000  first creation
;;   08.01.2001  font-lock-keywords-only set for correct syntax 
;;               highlighting; require-final-newline set
;;   09.03.2001  additional bar line syntax; ps-preview improved
;;               (no resizing of buffer *Shell Command Output*);
;;               automatic cursor motion to errors;
;;               listing of format paramaters vie main menu
;;   04.07.2001  buffer with abctab2ps messages minimized;
;;               new ABC-menu function "Insert Tune Header";
;;               new entry "List Format/All Settings"
;;   08.10.2001  Bugfix syntax highlighting inline info fields
;;               Bugfix in listing of possible pseudocomments
;;               new function "abctab-fixup-xrefs"
;;               dependency on external grep program removed
;;   07.02.2002  forced display of abctab2ps output for Emacs 21.x
;;   31.07.2002  Buffer no longer piped in abc2ps program
;;               => now works with all abc2ps-derivates
;;               new ABC-menu function "Preview Tune" for processing
;;               only the tune wherein the curser currently is
;;   14.08.2002  syntax highlighting support for [| and [|]
;;   05.11.2004  midi creation and listening added (via abc2midi)
;;   09.11.2004  workaround for double display of shell command output
;;   08.09.2005  fixed error in preamble generation for "Preview Tune"

;; List of functions called when abctab-mode is entered
(defcustom abctab-mode-hook '()
  "*Hook for customising `abctab-mode'."
  :type 'hook
  :group 'Abctab)

;; custom variables
(defcustom abctab-program "abctab2ps"
  "Program for translating abc to postscript.
Must understand the option -O for the outputfile, which
should be fulfilled by all abc2ps derivates.
Here is how to set `abctab-program' for various abc2ps derivates:
  \"abc2ps -o\"   - Michael Methfessel's abc2ps
  \"abcm2ps\"     - Jef Moine's abcm2ps
  \"abctab2ps\"   - Christoph Dalitz' abctab2ps
Unlike previous versions of this mode, the abc source is no
longer piped into the program but written to a temporary file.
This means that you may no longer use the option \"-\" with abcm2ps."
  :group 'Abctab)
(defcustom abctab-psviewer "gv"
  "Postscript previewer program.
On Windows 95/98/ME you must specify the full path to ghostview;
make sure it does not contain spaces.
On Windows NT/200/XP you can set `abctab-psviewer' to \"cmd.exe /c\";
this will start the program that is registered with .ps files."
  :group 'Abctab)
(defcustom abctab-midiprogram "abc2midi"
  "Program for translating abc to midi.
Must understand the option -o for the outputfile."
  :group 'Abctab)
(defcustom abctab-midiplayer "open"
  "Midi player program.
On Windows NT/200/XP you can set `abctab-midiplayer' to \"cmd.exe /c\";
this will start the program that is registered with .mid files.
On MacOS X you can set `abctab-midiplayer' to \"open\""
  :group 'Abctab)
(defcustom abctab-psfile "/tmp/abc.ps"
  "Temporary file for postscript output.
Make sure the directory in the file name exists and is writable.
Good directories are /tmp on Unix and C:/Temp on Win32."
  :group 'Abctab)
(defcustom abctab-tmpfile "/tmp/tune.abc"
  "Temporary file for storing part of buffer.
Used by `abctab-postscript-tune'.
Make sure the directory in the file name exists and is writable.
Good directories are /tmp on Unix and C:/Temp on Win32."
  :group 'Abctab)
(defcustom abctab-midifile "/tmp/abc.mid"
  "Temporary file for midi output.
Used by `abctab-midi-tune'.
Make sure the directory in the file name exists and is writable.
Good directories are /tmp on Unix and C:/Temp on Win32."
  :group 'Abctab)

;; shortcut key bindings
(defvar abctab-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-p") 'abctab-postscript-buffer)
    (define-key map (kbd "C-c C-t") 'abctab-postscript-tune)
    (define-key map (kbd "C-c C-l") 'abctab-midi-tune)
    (define-key map (kbd "C-c C-c") 'abctab-comment-region)
    (define-key map (kbd "C-c C-u") 'abctab-uncomment-region)
    map)
  "Mode map used for `abctab-mode'.")

;; main menu entry
(easy-menu-define
 abctab-mode-menu abctab-mode-map
 "Menu for `abctab-mode'."
 '("ABC"
   ["Preview Buffer" abctab-postscript-buffer ]
   ["Preview Tune" abctab-postscript-tune ]
   ["Listen Tune" abctab-midi-tune ]
   ["Comment Region" abctab-comment-region (region-beginning) (region-end)]
   ["Uncomment Region" abctab-uncomment-region (region-beginning) (region-end)]
   ["Insert Tune Header" abctab-insert-tune-header ]
   ["Fixup Xrefs" abctab-fixup-xrefs ]
   ("List Format Params" 
    ["Font Settings" abctab-list-font-settings]
    ["Layout Settings" abctab-list-layout-settings]
    ["Tablature Settings" abctab-list-tab-settings]
    ["All Settings" abctab-list-all-settings])
   ["-" nil ]
   ["Options" abctab-customize-options ]
))

;; syntax table (not used in abctab-mode!)
(defvar abctab-mode-syntax-table 
  (let ((table (make-syntax-table)))
    ; comments start with % and end with newline
    (modify-syntax-entry ?\% "<" table)
    (modify-syntax-entry 10  ">" table)
    (modify-syntax-entry 12  ">" table)
    ; matching parenthesis
    (modify-syntax-entry ?\[  "(]" table)
    (modify-syntax-entry ?\]  ")[" table)
    (modify-syntax-entry ?\{  "(}" table)
    (modify-syntax-entry ?\}  "){" table)
    table)
  "Syntax table used in 'abctab-mode'.")

(defvar abctab-mode-font-lock-keywords nil
  "Abctab keywords used by font-lock.")
(if abctab-mode-font-lock-keywords ()
  (let ()
    (setq abctab-mode-font-lock-keywords
      (list 
       ; comments
       (cons "^%.*" 'font-lock-comment-face)
       ; voice definition/change
       (cons "^V:.*" 'font-lock-string-face)
       (cons "\\[V:[^\]]*\\]" 'font-lock-string-face)
       ; lyrics
       (cons "^w:.*" 'font-lock-constant-face)
       ; information field
       (cons "^[A-Z,a-z]:.*" 'font-lock-function-name-face)
       ; inline information field
       (cons "\\[[A-Z]:[^\]]*\\]" 'font-lock-function-name-face)
       ; bar line
       (cons (regexp-opt '("|" ":|" "|:" ":||:" "::" "[|]" "|]" "[|" "[1" "[2")) 'font-lock-warning-face)
      ))
))

;; function definitions
(defun abctab-comment-region (start end)
  "Comments out the current region with '% '."
  (interactive "r")
  (goto-char end) (beginning-of-line) (setq end (point))
  (goto-char start) (beginning-of-line) (setq start (point))
  (let ()
  (save-excursion
    (save-restriction
      (narrow-to-region start end)
      (while (not (eobp))
        (insert "% ")
        (forward-line 1)))))
)
(defun abctab-uncomment-region (start end)
  "Remove '% ' comments from current region."
  (interactive "r")
  (goto-char end) (beginning-of-line) (setq end (point))
  (goto-char start) (beginning-of-line) (setq start (point))
  (let ((prefix-len '2))
  (save-excursion
    (save-restriction
      (narrow-to-region start end)
      (while (not (eobp))
        (if (string= "% "
                     (buffer-substring
                      (point) (+ (point) prefix-len)))
            (delete-char prefix-len))
        (forward-line 1)))))
)
(defun abctab-mark-tune ()
  "Marks the current tune.
In abctab-mode, one tune is one paragraph. Unfortunately `mark-paragraph'
is notoriously buggy, so that `mark-paragraph' cannot be used for marking 
a tune."
  (interactive)
  (let ((tunebegin "^X:") (pos 0))
	(end-of-line)
	(if (re-search-forward tunebegin nil t)
		(beginning-of-line)
	  (goto-char (point-max)))
	(push-mark (point) t t)
	(unless (re-search-backward tunebegin nil t)
	  (goto-char (point-min)))
  )
)
(defun abctab-get-errorpos ()
  "Returns line and column of the first error reported by abc(tab)2ps.
The error messages are searched in the buffer \"*Shell Command Output*\"
and must be of the form \"^+++ .* in line \"."
  (interactive)
  ;; search output from abc(tab)2ps for error messages
  (let ((errline 0) (errcol 0))
    (save-excursion 
      (set-buffer "*Shell Command Output*")
      (beginning-of-buffer)
      (if (re-search-forward "^+++ .* in line " nil t)
		  ;; extract line and column from error message
		  (let ((start (point)) (dotfound nil))
			(setq dotfound (search-forward "." nil t))
			(setq errline (string-to-number (buffer-substring start (point))))
			(when dotfound
			  (setq start (point))
			  (end-of-line)
			  (setq errcol 
					(string-to-number (buffer-substring start (point)))))))
	  (list errline errcol)))
)
(defun abctab-postscript-file (abcfile)
  "Translates given file to postscript with `abctab-program'."
  (interactive)
  ;; on Win32 supress popping up DOS-box
  (when (boundp 'w32-start-process-share-console)
    (setq w32-start-process-share-console t))
  (shell-command 
   (format "%s -O %s %s" abctab-program abctab-psfile
		   (shell-quote-argument abcfile)))
  (display-buffer "*Shell Command Output*" t)
  (shrink-window-if-larger-than-buffer
   (get-buffer-window "*Shell Command Output*"))
)
(defun abctab-errorcheck-psview (&optional skipstart skipend)
  "Check for error messages and start postscript viewer on `abctab-psfile'.
When the last run of `abctab-program' reported errors, the user is asked
whether he wants to see the PS output; if not the cursor is moved to the
first reported error in the buffer.
The optional args `skipstart' and `skipend' are linenumbers for a region
in the buffer that has not been processed by `abctab-program'. This is
necessary when only a single tune is processed in `abctab-postscript-tune'."
  ;; otherwise psviewer is not displayed on win32
  (when (boundp 'w32-start-process-show-window)
    (setq w32-start-process-show-window t))
  ;; look for error messages from abc(tab)2ps
  (let ((errpos (abctab-get-errorpos)) (errcol 0) (errcol 0))
	(setq errline (nth 0 errpos))
	(setq errcol (nth 1 errpos))
	;; (message-box "errline:%d\nerrcol:%d" errline errcol)
	(if (not (> errline 0))
		(start-process-shell-command "view-abc" nil abctab-psviewer abctab-psfile)
	  (if (y-or-n-p "Preview despite errors? ")
		  (start-process-shell-command "view-abc" nil abctab-psviewer abctab-psfile)
		;; answer "no": goto first error position
		(when (and skipstart (> errline skipstart))
		  (setq errline (+ errline skipend (- skipstart))))
		(goto-line errline)
		(when (> errcol 0) (forward-char (1- errcol))))))
)
(defun abctab-postscript-buffer ()
  "Translates buffer to postscript with `abctab-program'."
  (interactive)
  (save-buffer)
  (abctab-postscript-file buffer-file-name)
  (abctab-errorcheck-psview)
)
(defun abctab-postscript-tune ()
  "Translates current tune to postscript with `abctab-program'.
The current tune is the tune wherein the cursor currently is."
  (interactive)
  (save-buffer)
  (let ((skipstart nil) (skipend nil))
    ;; empty tmpfile (delete-file throws an error, hence this ugly workaround)
    (write-region 1 1 abctab-tmpfile)
    ;; write preamble to tempfile when it existst
    (if (not (string= (buffer-substring 1 3) "X:"))
	(save-excursion
	  (goto-char (point-min))
	  (abctab-mark-tune)
	  (setq skipstart (count-lines (point-min) (region-end)))
	  (write-region (region-beginning) (region-end) abctab-tmpfile))
      (setq skipstart 0))
    ;; write current tune to tempfile
    (save-excursion
	  ;; move to first tune when cursor before first tune
	  (let ((pnum (string-to-number (how-many "^X:"))))
		(save-excursion
		  (goto-char (point-min))
		  (setq pnum (- (string-to-number (how-many "^X:")) pnum)))
		(when (< pnum 1) (re-search-forward "^X:" nil t)))
	  (abctab-mark-tune)
	  (setq skipend (count-lines (point-min) (region-beginning)))
	  (append-to-file (region-beginning) (region-end) abctab-tmpfile))
    ;; process temporary file and display output
    (abctab-postscript-file abctab-tmpfile)
    ;;(message-box "skipstart:%d\nskipend:%d" skipstart skipend)
    (abctab-errorcheck-psview skipstart skipend))
)
(defun abctab-midi-tune ()
  "Translates current tune to postscript with `abctab-midiprogram'.
The current tune is the tune wherein the cursor currently is."
  (interactive)
  (save-buffer)
  (let ((skipstart nil) (skipend nil))
    ;; empty tmpfile (delete-file throws an error, hence this ugly workaround)
    (write-region 1 1 abctab-tmpfile)
    ;; write preamble to tempfile when it existst
    (if (not (string= (buffer-substring 1 3) "X:"))
	(save-excursion
	  (goto-char (point-min))
	  (abctab-mark-tune)
	  (setq skipstart (count-lines (point-min) (region-end)))
	  (write-region (region-beginning) (region-end) abctab-tmpfile))
      (setq skipstart 0))
    ;; write current tune to tempfile
    (save-excursion
	  ;; move to first tune when cursor before first tune
	  (let ((pnum (string-to-number (how-many "^X:"))))
		(save-excursion
		  (goto-char (point-min))
		  (setq pnum (- (string-to-number (how-many "^X:")) pnum)))
		(when (< pnum 1) (re-search-forward "^X:" nil t)))
	  (abctab-mark-tune)
	  (setq skipend (count-lines (point-min) (region-beginning)))
	  (append-to-file (region-beginning) (region-end) abctab-tmpfile))
    ;; process temporary file and display output
    ;; on Win32 supress popping up DOS-box
    (when (boundp 'w32-start-process-share-console)
      (setq w32-start-process-share-console t))
    (shell-command 
     (format "%s %s -o %s" abctab-midiprogram
	     (shell-quote-argument abctab-tmpfile)
	     (shell-quote-argument abctab-midifile)))
    (display-buffer "*Shell Command Output*" t)
    (shrink-window-if-larger-than-buffer
     (get-buffer-window "*Shell Command Output*"))
    ;; Workaround for double display of command output:
    (message "Start Midi-Player")
    ;;(message-box "skipstart:%d\nskipend:%d" skipstart skipend)
    (start-process-shell-command "listen-abc" nil
				 abctab-midiplayer abctab-midifile))
)
(defun abctab-insert-tune-header ()
  "Inserts tune header at cursor position"
  (interactive)
  (beginning-of-line)
  (insert (format "X:1\n%%\nT:title\nC:composer\nL:1/4\nM:C\nK:C treble\n%%\n"))
)
(defun abctab-list-settings (regex)
  "Lists default settings of `abctab-program' that match `regex'.
`abctab-program' is called with the switch -H and in the
resulting output, lines not matching regex are removed."
  (interactive "sRegexp for setting:")
  ;; on Win32 supress popping up DOS-box
  (when (boundp 'w32-start-process-share-console)
    (setq w32-start-process-share-console t))
  (shell-command (format "%s -H" abctab-program))
  (display-buffer "*Shell Command Output*")
  ;; remove all lines not matching regex
  ;; and replace leading spaces with %%
  (save-excursion
    (set-buffer "*Shell Command Output*")
    (beginning-of-buffer)
	(deactivate-mark)
	(keep-lines regex)
    (replace-regexp "^ +" "%%"))
)
(defun abctab-list-font-settings ()
  "Lists default font settings of `abctab-program'.
See `abctab-list-settings' for more details."
  (interactive)
  (abctab-list-settings "font")
)
(defun abctab-list-layout-settings ()
  "Lists default layout settings of `abctab-program'.
See `abctab-list-settings' for more details."
  (interactive)
  (abctab-list-settings 
   (regexp-opt '("width" "height" "margin" "space" "sep")))
)
(defun abctab-list-tab-settings ()
  "Lists default tablature settings of `abctab-program'.
See `abctab-list-settings' for more details."
  (interactive)
  (abctab-list-settings "^ *tab")
)
(defun abctab-list-all-settings ()
  "Lists all default settings of `abctab-program'.
See `abctab-list-settings' for more details."
  (interactive)
  (abctab-list-settings "^ ")
)
(defun abctab-fixup-xrefs ()
  "Number X: info fields in the current buffer sequentially."
  (interactive)
  (save-excursion
    (let ((xnum 0))
      (goto-char (point-min))
      (while (re-search-forward "^X:.*$" nil t)
		(setq xnum (1+ xnum))
        (replace-match (format "X:%d" xnum)))))
)
(defun abctab-customize-options ()
  "Interactive customization for abctab-mode options."
  (interactive)
  (customize-group "Abctab")
)

;;;###autoload
(defun abctab-mode ()
  "Major mode for editing abctab2ps source.
Information fields, bar lines, lyrics etc. are highlighted with
font-lock. There are also a number of commands that make editing 
and working with ABC files more convenient. These commands begin
with the prefix `abctab-' and are available from the main menu `ABC'.
For the following commands shortcuts are predefined:

\\[abctab-postscript-buffer]  - Run `abctab-program' on the current buffer.
\\[abctab-postscript-tune]  - Run `abctab-program' on the current tune.
\\[abctab-comment-region]  - Comment out the current region.
\\[abctab-uncomment-region]  - Uncomment the current region.
"
  (interactive)
  (kill-all-local-variables)
  (setq major-mode 'abctab-mode)
  (setq mode-name "abctab")

  (use-local-map abctab-mode-map)

  (set-syntax-table abctab-mode-syntax-table)
  (make-local-variable 'font-lock-defaults)
  (setq font-lock-defaults '(abctab-mode-font-lock-keywords
                 t t ((?_ . "w") (?. . "w"))))
  ;             ^^^
  ; (otherwise syntax table wins and keywords are ignored!)

  ; abc requires a newline at the end of a tune
  (make-local-variable 'require-final-newline)
  (setq require-final-newline t)

  ;; paragraph == tune
  ;; It is impossible to make paragraphs start exactly with "^X:"
  ;; mark-paragraph always marks preceding blank lines too (emacs bug?)
  ;; thus setting paragraph-start/separate is of no use for abc
  (make-local-variable 'paragraph-start)
  (make-local-variable 'paragraph-separate)
  (setq paragraph-start "^X:\\|^[ \t]*$")
  (setq paragraph-separate "^[ \t]*$")

  ;; case insensitive pattern matching
  (setq font-lock-keywords-case-fold-search t)
  (put 'abctab-mode 'font-lock-keywords-case-fold-search t)

  (run-hooks 'abctab-mode-hook)
)
