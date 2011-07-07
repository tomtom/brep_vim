" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2011-07-04.
" @Last Change: 2011-07-07.
" @Revision:    73


if !exists('g:brep#view_qfl')
    " Command used to display the |quickfixlist|.
    let g:brep#view_qfl = exists('g:loaded_trag') ? 'Tragcw' : 'cwindow'   "{{{2
endif

if !exists('g:brep#ignore_buftypes')
    " Ignore buffer types (see 'buftype').
    let g:brep#ignore_buftypes = ['quickfix']   "{{{2
endif

if !exists('g:brep#ignore_bufnames_rx')
    " Ignore buffers matchings this |regexp|.
    let g:brep#ignore_bufnames_rx = ''   "{{{2
endif

if !exists('g:brep#ignore_filetype')
    " Ignore these filetypes.
    let g:brep#ignore_filetype = []   "{{{2
endif

if !exists('g:brep#use_bufdo')
    " By default brep does single line scans on the buffer contents. If 
    " you want to search for multi-line patterns, you have to use |:bufdo| 
    " instead. You won't be able to scan unlisted buffers this way. 
    " Using bufdo is slightly slower.
    " If the pattern contains '\n', |:Brep| always uses :bufdo anyway.
    let g:brep#use_bufdo = 0   "{{{2
endif


" :display: brep#Grep(regexp, ?buffers=[], ?show_hidden=0)
" Scan buffers vor a |regexp|.
function! brep#Grep(regexp, ...) "{{{3
    let buffers = a:0 >= 1 ? a:1 : []
    let show_hidden = a:0 >= 2 ? a:2 : 0
    if empty(buffers)
        redir => bufferss
        if show_hidden
            silent ls!
        else
            silent ls
        endif
        redir END
        let buffers = split(bufferss, '\n')
        let buffers = map(buffers, 'str2nr(matchstr(v:val, ''^\s*\zs\d\+''))')
    endif
    let qfl = []
    if g:brep#use_bufdo || match(a:regexp, '\(^\|[^\\]\|\(^\|[^\\]\)\(\\\\\)\+\)\\n') != -1
        let cbufnr = bufnr('%')
        let lazyredraw = &lazyredraw
        let eventignore = &eventignore
        set lazyredraw
        set eventignore=all
        try
            exec 'silent keepalt bufdo! g/'. escape(a:regexp, '/') .'/call add(qfl, {"bufnr": bufnr("%"), "lnum": line("."), "text": getline("."), "type": "G"})'
        finally
            exec 'keepalt buffer' cbufnr
            let &lazyredraw = lazyredraw
            let &eventignore = eventignore
        endtry
    else
        for bufnr in buffers
            if index(g:brep#ignore_buftypes, getbufvar(bufnr, '&buftype')) == -1
                        \ && index(g:brep#ignore_filetype, getbufvar(bufnr, '&filetype')) == -1
                        \ && (empty(g:brep#ignore_bufnames_rx) || bufname(bufnr) !~ g:brep#ignore_bufnames_rx)
                let buffer_text = getbufline(bufnr, 1, '$')
                let s:lnum = 0
                let buffer_text = map(buffer_text, 's:LineDef(bufnr, v:val)')
                unlet s:lnum
                if &smartcase && a:regexp =~ '\u'
                    let ic = &ignorecase
                    let &l:ic = 0
                endif
                let buffer_text = filter(buffer_text, 'v:val.text =~ a:regexp')
                if &smartcase && a:regexp =~ '\u'
                    let &l:ic = ic
                endif
                if !empty(buffer_text)
                    let qfl = extend(qfl, buffer_text)
                endif
            endif
        endfor
    endif
    if !empty(qfl)
        call setqflist(qfl)
        if !empty(g:brep#view_qfl)
            exec g:brep#view_qfl
        endif
    endif
endf


function! s:LineDef(bufnr, text) "{{{3
    let s:lnum += 1
    return {'bufnr': a:bufnr, 'lnum': s:lnum, 'text': a:text, 'type': 'G'}
endf

