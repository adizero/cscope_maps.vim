if &compatible || exists('g:loaded_cscope_maps')
  finish
endif
let g:loaded_cscope_maps = 1

" This tests to see if vim was configured with the '--enable-cscope' option
" when it was compiled.  If it wasn't, time to recompile vim...
if !has('cscope')
    finish
endif

" use both cscope and ctag for 'ctrl-]', ':ta', and 'vim -t'
set cscopetag

" check cscope for definition of a symbol before checking ctags: set to 1
" if you want the reverse search order.
set cscopetagorder=1

set cscopepathcomp=0

set nocscopeverbose

" add any cscope database in current directory
if filereadable('cscope.out')
    " is already added by default in VIM 7 /etc/vimrc on some Linux machines ?,
    "  so we need try/catch to sort it out
    try
        cs add cscope.out
    catch /:E568:/
        " E568: database already added, just ignore
    endtry
endif
" add the database pointed to by environment variable
if $CSCOPE_DB !=# ''
    cs add $CSCOPE_DB
endif
if $CSCOPEDB_PREFIX !=# ''
    let s:prefix = $CSCOPEDB_PREFIX
    let s:bre=0
    for s:i in range(10)
        for s:j in range(10)
            let s:prefixnr = s:prefix.s:i.s:j
            if filereadable(s:prefixnr)
                " should never be -1, because that would mean file is not
                " found (-2 however means file size is too big to fit into
                " an integer)
                if (getfsize(s:prefixnr) != 0)
                    execute 'cs add ' . s:prefixnr
                endif
            else
                let s:bre=1
                break
            endif
        endfor
        if s:bre == 1
            break
        endif
    endfor
endif

" show msg after any other cscope db is added
set cscopeverbose


command! -nargs=1 CscopeSearch call cscope#CscopeSearch(<f-args>)
command! -nargs=1 CscopeInNewTab call cscope#CscopeInNewTab(<f-args>)

command! -nargs=1 -complete=tag CtagsSearch call cscope#CtagsSearch('tag', <f-args>)
command! -nargs=1 -complete=tag CtagsInNewTab call cscope#CtagsInNewTab('tjump', <f-args>)
command! -nargs=1 -complete=tag PreviewTjumpSearch call cscope#PreviewTjumpSearch(<f-args>)
" command mode abbreviation of tt as tabnew % | tag <args>
command! -nargs=1 -complete=tag TT call cscope#CtagsInNewTab('tag', <f-args>)
cabbrev tt <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'TT' : 'tt')<CR>

command! CscopeSwitchcase call cscope#SwitchCscopeCaseSensitivity()


" open results in the current window
nmap <C-\>s :CscopeSearch cs s <cword><CR>
nmap <C-\>g :CscopeSearch cs g <cword><CR>
nmap <C-\>c :CscopeSearch cs c <cword><CR>
nmap <C-\>t :CscopeSearch cs t <cword><CR>
nmap <C-\>e :CscopeSearch cs e <cword><CR>
nmap <C-\>f :CscopeSearch cs f <cfile><CR>
nmap <C-\>i :CscopeSearch cs i <cfile><CR>
nmap <C-\>d :CscopeSearch cs d <cword><CR>
nmap <C-\>a :CscopeSearch cs a <cword><CR>
nmap <C-\>m :CscopeSearch cs m <cword><CR>

"vmap <C-\>s <Esc>:call cscope#CscopeSearch("cs", "s", g:GetVisualSelection())<Enter>gv
vmap <C-\>s <Esc>:execute 'CscopeSearch cs s ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-\>g <Esc>:execute 'CscopeSearch cs g ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-\>c <Esc>:execute 'CscopeSearch cs c ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-\>t <Esc>:execute 'CscopeSearch cs t ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-\>e <Esc>:execute 'CscopeSearch cs e ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-\>f <Esc>:execute 'CscopeSearch cs f ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-\>i <Esc>:execute 'CscopeSearch cs i ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-\>d <Esc>:execute 'CscopeSearch cs d ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-\>a <Esc>:execute 'CscopeSearch cs a ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-\>m <Esc>:execute 'CscopeSearch cs m ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>

" open results in a new tab
nmap <C-\><C-\>s :CscopeInNewTab s <cword><CR>
nmap <C-\><C-\>g :CscopeInNewTab g <cword><CR>
nmap <C-\><C-\>c :CscopeInNewTab c <cword><CR>
nmap <C-\><C-\>t :CscopeInNewTab t <cword><CR>
nmap <C-\><C-\>e :CscopeInNewTab e <cword><CR>
nmap <C-\><C-\>f :CscopeInNewTab f <cfile><CR>
nmap <C-\><C-\>i :CscopeInNewTab i <cfile><CR>
nmap <C-\><C-\>d :CscopeInNewTab d <cword><CR>
nmap <C-\><C-\>a :CscopeInNewTab a <cword><CR>
nmap <C-\><C-\>m :CscopeInNewTab m <cword><CR>

vmap <C-\><C-\>s <Esc>:execute 'CscopeInNewTab s ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-\><C-\>g <Esc>:execute 'CscopeInNewTab g ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-\><C-\>c <Esc>:execute 'CscopeInNewTab c ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-\><C-\>t <Esc>:execute 'CscopeInNewTab t ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-\><C-\>e <Esc>:execute 'CscopeInNewTab e ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-\><C-\>f <Esc>:execute 'CscopeInNewTab f ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-\><C-\>i <Esc>:execute 'CscopeInNewTab i ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-\><C-\>d <Esc>:execute 'CscopeInNewTab d ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-\><C-\>a <Esc>:execute 'CscopeInNewTab a ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-\><C-\>m <Esc>:execute 'CscopeInNewTab m ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>

" horizontal splits
nmap <C-@>s :CscopeSearch scs s <cword><CR>
nmap <C-@>g :CscopeSearch scs g <cword><CR>
nmap <C-@>c :CscopeSearch scs c <cword><CR>
nmap <C-@>t :CscopeSearch scs t <cword><CR>
nmap <C-@>e :CscopeSearch scs e <cword><CR>
nmap <C-@>f :CscopeSearch scs f <cfile><CR>
nmap <C-@>i :CscopeSearch scs i <cfile><CR>
nmap <C-@>d :CscopeSearch scs d <cword><CR>
nmap <C-@>a :CscopeSearch scs a <cword><CR>
nmap <C-@>m :CscopeSearch scs m <cword><CR>

vmap <C-@>s <Esc>:execute 'CscopeSearch scs s ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-@>g <Esc>:execute 'CscopeSearch scs g ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-@>c <Esc>:execute 'CscopeSearch scs c ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-@>t <Esc>:execute 'CscopeSearch scs t ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-@>e <Esc>:execute 'CscopeSearch scs e ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-@>f <Esc>:execute 'CscopeSearch scs f ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-@>i <Esc>:execute 'CscopeSearch scs i ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-@>d <Esc>:execute 'CscopeSearch scs d ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-@>a <Esc>:execute 'CscopeSearch scs a ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-@>m <Esc>:execute 'CscopeSearch scs m ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>

" vertical splits
nmap <C-@><C-@>s :CscopeSearch vert\ scs s <cword><CR>
nmap <C-@><C-@>g :CscopeSearch vert\ scs g <cword><CR>
nmap <C-@><C-@>c :CscopeSearch vert\ scs c <cword><CR>
nmap <C-@><C-@>t :CscopeSearch vert\ scs t <cword><CR>
nmap <C-@><C-@>e :CscopeSearch vert\ scs e <cword><CR>
nmap <C-@><C-@>f :CscopeSearch vert\ scs f <cfile><CR>
nmap <C-@><C-@>i :CscopeSearch vert\ scs i <cfile><CR>
nmap <C-@><C-@>d :CscopeSearch vert\ scs d <cword><CR>
nmap <C-@><C-@>a :CscopeSearch vert\ scs a <cword><CR>
nmap <C-@><C-@>m :CscopeSearch vert\ scs m <cword><CR>

vmap <C-@><C-@>s <Esc>:execute 'CscopeSearch vert\ scs s ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-@><C-@>g <Esc>:execute 'CscopeSearch vert\ scs g ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-@><C-@>c <Esc>:execute 'CscopeSearch vert\ scs c ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-@><C-@>t <Esc>:execute 'CscopeSearch vert\ scs t ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-@><C-@>e <Esc>:execute 'CscopeSearch vert\ scs e ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-@><C-@>f <Esc>:execute 'CscopeSearch vert\ scs f ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-@><C-@>i <Esc>:execute 'CscopeSearch vert\ scs i ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-@><C-@>d <Esc>:execute 'CscopeSearch vert\ scs d ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-@><C-@>a <Esc>:execute 'CscopeSearch vert\ scs a ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap <C-@><C-@>m <Esc>:execute 'CscopeSearch vert\ scs m ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>

nmap <C-\><SPACE> :CscopeSearch cs<SPACE>
nmap <C-\><C-\><SPACE> :CscopeInNewTab<SPACE>
nmap <C-@><SPACE> :CscopeSearch scs<SPACE>
nmap <C-@><C-@><SPACE> :CscopeSearch vert\ scs<SPACE>

" added simplified mappings (<C+\> is kind of hard to reach on Macbooks with only left Ctrl)
nmap \s <C-\>s
nmap \g <C-\>g
nmap \c <C-\>c
nmap \t <C-\>t
nmap \e <C-\>e
nmap \f <C-\>f
nmap \i <C-\>i
nmap \d <C-\>d
nmap \a <C-\>a
nmap \m <C-\>m
nmap \<Space> <C-\><Space>
nmap \] :CtagsSearch <cword><CR>
nmap \} :PreviewTjumpSearch <cword><CR>
nmap \<Backspace> <C-T>

vmap \s <C-\>s
vmap \g <C-\>g
vmap \c <C-\>c
vmap \t <C-\>t
vmap \e <C-\>e
vmap \f <C-\>f
vmap \i <C-\>i
vmap \d <C-\>d
vmap \a <C-\>a
vmap \m <C-\>m
vmap \<Space> <C-\><Space>
vmap \] <Esc>:execute 'CtagsSearch ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>
vmap \} <Esc>:execute 'PreviewTjumpSearch ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>

nmap \\s <C-\><C-\>s
nmap \\g <C-\><C-\>g
nmap \\c <C-\><C-\>c
nmap \\t <C-\><C-\>t
nmap \\e <C-\><C-\>e
nmap \\f <C-\><C-\>f
nmap \\i <C-\><C-\>i
nmap \\d <C-\><C-\>d
nmap \\a <C-\><C-\>a
nmap \\m <C-\><C-\>m
nmap \\<Space> <C-\><C-\><Space>
nmap \\] :CtagsInNewTab <cword><CR>
nmap \\<Backspace> <C-O>
nmap \\\<Backspace> <C-I>

vmap \\s <C-\><C-\>s
vmap \\g <C-\><C-\>g
vmap \\c <C-\><C-\>c
vmap \\t <C-\><C-\>t
vmap \\e <C-\><C-\>e
vmap \\f <C-\><C-\>f
vmap \\i <C-\><C-\>i
vmap \\d <C-\><C-\>d
vmap \\a <C-\><C-\>a
vmap \\m <C-\><C-\>m
vmap \\<Space> <C-\><C-\><Space>
vmap \\] <Esc>:execute 'CtagsInNewTab ' . escape(g:GetVisualSelection(), '\ ') <Bar> normal! gv<CR>

nmap <silent>z<LeftMouse> <C-\>s
nmap <silent>z<RightMouse> <C-\>c
nmap <A-LeftMouse> z<LeftMouse>
nmap <A-RightMouse> z<RightMouse>

nmap <C-\>h :YcmCompleter GoToDeclaration<CR>
nmap <C-\><C-\>h :tab split<CR> :YcmCompleter GoToDeclaration<CR>
nmap <C-@>h :split<CR> :YcmCompleter GoToDeclaration<CR>
nmap <C-@><C-@>h :vsplit<CR> :YcmCompleter GoToDeclaration<CR>
nmap \h :YcmCompleter GoToDeclaration<CR>
nmap \\h :tab split<CR> :YcmCompleter GoToDeclaration<CR>
