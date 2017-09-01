""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CSCOPE settings for vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" This file contains some boilerplate settings for vim's cscope interface,
" plus some keyboard mappings that I've found useful.
"
" USAGE:
" -- vim 6:     Stick this file in your ~/.vim/plugin directory (or in a
"               'plugin' directory in some other directory that is in your
"               'runtimepath'.
"
" -- vim 5:     Stick this file somewhere and 'source cscope.vim' it from
"               your ~/.vimrc file (or cut and paste it into your .vimrc).
"
" NOTE:
" These key maps use multiple keystrokes (2 or 3 keys).  If you find that vim
" keeps timing you out before you can complete them, try changing your timeout
" settings, as explained below.
"
" Happy cscoping,
"
" Jason Duell       jduell@alumni.princeton.edu     2002/3/7
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    " TODO SR project specific search for tMci structure - move to different file (.vimrc ?)
    function! s:camelcase(word)
        let word = substitute(a:word, '-', '_', 'g')
        if word !~# '_' && word =~# '\l'
            return substitute(word,'^.','\l&','')
        else
            return substitute(word,'\C\(_\)\=\(.\)','\=submatch(1)==""?tolower(submatch(2)) : toupper(submatch(2))','g')
        endif
    endfunction

    function! s:mixedcase(word)
        return substitute(s:camelcase(a:word),'^.','\u&','')
    endfunction

    function! s:tMciStructFromDashYangList(word)
        return "tMci" . s:mixedcase(a:word)
    endfunction

    function! s:MciSetFromDashYangList(word)
        return "mci_set_" . s:camelcase(a:word)
    endfunction

    function! s:FromDbFromDashYangList(word)
        return s:mixedcase(a:word) . "FromDb"
    endfunction

    function! s:ToDbFromDashYangList(word)
        return s:mixedcase(a:word) . "ToDb"
    endfunction

    function! s:RequestOrErrorTranslatorFromDashYangList(word)
        return s:mixedcase(a:word)
    endfunction

    function! s:CscopeSearchInternal(command_prefix, type, keyword)
        let l:cword = expand(a:keyword)
        let l:type = a:type

        let l:ctagslist = [ ]
        let l:wordlist = [ l:cword ]

        if l:type == "m"
            if expand("%:t") =~ "translator\.yang" "type translator files (no request/error translators are searched)
                let l:wordlist = [ s:ToDbFromDashYangList(l:cword), s:FromDbFromDashYangList(l:cword), s:MciSetFromDashYangList(l:cword), s:tMciStructFromDashYangList(l:cword) ]
            elseif expand("%:t") =~ "snmp-translator-.*\.yang" "request translator files (no type translator are searched)
                let l:ctagword = s:RequestOrErrorTranslatorFromDashYangList(l:cword)
                if l:ctagword =~ ".*ErrorTranslator"
                    let l:ctagslist = [ "/:" . l:ctagword . "::raiseError" ]
                elseif l:ctagword =~ ".*Observer"
                    let l:ctagslist = [ "/:" . l:ctagword . "::onModify" ]
                elseif l:ctagword =~ ".*Translator"
                    let l:ctagslist = [ "/:" . l:ctagword . "::createMo" ]
                endif
                let l:wordlist = [ s:RequestOrErrorTranslatorFromDashYangList(l:cword), s:MciSetFromDashYangList(l:cword), s:tMciStructFromDashYangList(l:cword) ]
            else "rest of yang files (everything is searched)
                let l:ctagword = s:RequestOrErrorTranslatorFromDashYangList(l:cword)
                if l:ctagword =~ ".*ErrorTranslator"
                    let l:ctagslist = [ "/:" . l:ctagword . "::raiseError" ]
                elseif l:ctagword =~ ".*Observer"
                    let l:ctagslist = [ "/:" . l:ctagword . "::onModify" ]
                elseif l:ctagword =~ ".*Translator"
                    let l:ctagslist = [ "/:" . l:ctagword . "::createMo" ]
                endif
                let l:wordlist = [ s:MciSetFromDashYangList(l:cword), s:tMciStructFromDashYangList(l:cword), s:ToDbFromDashYangList(l:cword), s:FromDbFromDashYangList(l:cword), s:RequestOrErrorTranslatorFromDashYangList(l:cword) ]
            endif
            let l:type = "g"
        endif

        let l:found = 0

        if len(l:ctagslist) > 0
            echohl ModeMsg
                echo "Searching for ::raiseError/::onModify/::createMo function definition"
            echohl None
            let l:index = 0
            while 1
                try
                    exe "tag " . l:ctagslist[l:index]
                    call g:Move_to_column_with_match(l:ctagslist[l:index][2:])
                    "redraw!
                    let l:found = 1
                    break
                catch /:E325:/
                    " ATTENTION when opening file
                    call g:Move_to_column_with_match(l:ctagslist[l:index][2:])
                    "redraw!
                    let l:found = 1
                    break
                catch /:E562:\|:E567:\|:E257:\|:E259:\|:E499:\|:E560:\|:E426:\|:E433:/
                    let l:index = l:index + 1
                    if l:index == len(l:ctagslist)
                        let l:index = 0  "ctags did not found anything, proceed with cscope itself
                        break
                    endif
                endtry
            endwhile
        endif

        if l:found == 0 && len(l:wordlist) > 0
            let l:index = 0
            "if l:type ==# 'f' || l:type ==# 'g'
            "    let l:ale_previous_state = PauseALE()
            "endif
            while 1
                try
                    exe a:command_prefix . " " . l:type . " " . l:wordlist[l:index]
                    call g:Move_to_column_with_match(l:wordlist[l:index])
                    let l:found = 1
                    break
                catch /:E325:/
                    " ATTENTION when opening file
                    call g:Move_to_column_with_match(l:wordlist[l:index])
                    let l:found = 1
                    break
                catch /:E562:\|:E567:\|:E257:\|:E259:\|:E499:\|:E560:\|:E426:\|:E433:/
                    let l:index = l:index + 1
                    if l:index == len(l:wordlist)
                        break
                    endif
                endtry
            endwhile
            "if l:type ==# 'f' || l:type ==# 'g'
            "    call ResumeALE(l:ale_previous_state)
            "endif
        endif

        if l:found == 0
            if len(l:ctagslist) > 0
                echohl WarningMsg
                    echo "Sorry, no result found for ctags find " . join(l:ctagslist, " OR ")
                echohl None
            endif
            if len(l:wordlist) > 0
                echohl WarningMsg
                echo "Sorry, no result found for cscope find " . a:type . " " . join(l:wordlist, " OR ")
                echohl None
            endif
        endif
    endfunction

    function! cscope#CscopeSearch(command, type, keyword)
        call s:CscopeSearchInternal(a:command . " find ", a:type, a:keyword)
    endfunction
    
    function! cscope#CtagsSearch(type, ident)
        let l:saved_cst = &cst
        set nocscopetag
        if a:type ==# 'tag'
            let l:search_cmd = 'tag '
        elseif a:type ==# 'tjump'
            let l:search_cmd = 'tjump '
        elseif a:type ==# 'ptjump'
            let l:search_cmd = 'ptjump '
        else
            echohl WarningMsg
            echo 'Wrong ctags search type chosen: ' . a:type
            echohl None
        endif

        try
            execute l:search_cmd . a:ident
            call g:Move_to_column_with_match(a:ident)
        catch /:E325:/
            " ATTENTION when opening file
            call g:Move_to_column_with_match(a:ident)
        catch /:E562:\|:E567:\|:E257:\|:E259:\|:E499:\|:E560:\|:E426:\|:E433:/
            echohl WarningMsg
            echo 'Sorry, no tag generated for ' . a:ident
            echohl None
        endtry
        let &cst = l:saved_cst
    endfunction

    function! cscope#CscopeInNewTab(type, keyword)
        exe 'tab split'
        call s:CscopeSearch('cs', a:type, a:keyword)
    endfunction

    function! cscope#CtagsInNewTab(type, ident)
        exe 'tab split'
        call s:CtagsSearch(a:type, a:ident)
    endfunction

    function! cscope#PreviewTjumpSearch(ident)
        ""let l:ale_previous_state = PauseALE()
        "exe "ptjump " . a:ident
        ""call ResumeALE(l:ale_previous_state)
        call s:CtagsSearch('ptjump', a:ident)
    endfunction

    "use :csswitchcase command to switch case sensitivity of cscope searches
    function! cscope#SwitchCscopeCaseSensitivity()
        if &cscopeprg =~ "cscope -C"
            let &cscopeprg="cscope"
        else
            let &cscopeprg="cscope -C"
        endif
        silent cscope reset
        echohl ModeMsg
        if &cscopeprg =~ "cscope -C"
            echo "case insensitive cscope mode"
        else
            echo "case sensitive cscope mode"
        endif
        echohl None
    endfunction

    """"""""""""" My cscope/vim key mappings
    "
    " The following maps all invoke one of the following cscope search types:
    "
    "   's'   symbol: find all references to the token under cursor
    "   'g'   global: find global definition(s) of the token under cursor
    "   'c'   calls:  find all calls to the function name under cursor
    "   't'   text:   find all instances of the text under cursor
    "   'e'   egrep:  egrep search for the word under cursor
    "   'f'   file:   open the filename under cursor
    "   'i'   includes: find files that include the filename under cursor
    "   'd'   called: find functions that function under cursor calls
    "   'a'   assignments: find assignments to the token under cursor
    "
    " Below are three sets of the maps: one set that just jumps to your
    " search result, one that splits the existing vim window horizontally and
    " diplays your search result in the new window, and one that does the same
    " thing, but does a vertical split instead (vim 6 only).
    "
    " I've used CTRL-\ and CTRL-@ as the starting keys for these maps, as it's
    " unlikely that you need their default mappings (CTRL-\'s default use is
    " as part of CTRL-\ CTRL-N typemap, which basically just does the same
    " thing as hitting 'escape': CTRL-@ doesn't seem to have any default use).
    " If you don't like using 'CTRL-@' or CTRL-\, , you can change some or all
    " of these maps to use other keys.  One likely candidate is 'CTRL-_'
    " (which also maps to CTRL-/, which is easier to type).  By default it is
    " used to switch between Hebrew and English keyboard mode.
    "
    " All of the maps involving the <cfile> macro use '^<cfile>$': this is so
    " that searches over '#include <time.h>" return only references to
    " 'time.h', and not 'sys/time.h', etc. (by default cscope will return all
    " files that contain 'time.h' as part of their name).


    " To do the first type of search, hit 'CTRL-\', followed by one of the
    " cscope search types above (s,g,c,t,e,f,i,d).  The result of your cscope
    " search will be displayed in the current window.  You can use CTRL-T to
    " go back to where you were before the search.

    """"""""""""" key map timeouts
    "
    " By default Vim will only wait 1 second for each keystroke in a mapping.
    " You may find that too short with the above typemaps.  If so, you should
    " either turn off mapping timeouts via 'notimeout'.
    "
    "set notimeout
    "
    " Or, you can keep timeouts, by uncommenting the timeoutlen line below,
    " with your own personal favorite value (in milliseconds):
    "
    "set timeoutlen=4000
    "
    " Either way, since mapping timeout settings by default also set the
    " timeouts for multicharacter 'keys codes' (like <F1>), you should also
    " set ttimeout and ttimeoutlen: otherwise, you will experience strange
    " delays as vim waits for a keystroke after you hit ESC (it will be
    " waiting to see if the ESC is actually part of a key code like <F1>).
    "
    "set ttimeout
    "
    " personally, I find a tenth of a second to work well for key code
    " timeouts. If you experience problems and have a slow terminal or network
    " connection, set it higher.  If you don't set ttimeoutlen, the value for
    " timeoutlent (default: 1000 = 1 second, which is sluggish) is used.
    "
    "set ttimeoutlen=100

