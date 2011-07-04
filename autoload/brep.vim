" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2011-07-04.
" @Last Change: 2011-07-04.
" @Revision:    39


" Command used to display the |quickfixlist|.
TLet g:brep#view_qfl = exists('g:loaded_trag') ? 'Tragcw' : 'cwindow'


" :display: brep#Grep(regexp, ?buffers=[], ?show_hidden=0)
" Scan buffers vor a |regexp|.
function! brep#Grep(regexp, ...) "{{{3
    TVarArg ['buffers', []], ['show_hidden', 0]
    if empty(buffers)
        redir => bufferss
        if show_hidden
            silent ls!
        else
            silent ls
        endif
        redir END
        let buffers = split(bufferss, '\n')
        let buffers = map(buffers, '0 + matchstr(v:val, ''^\s*\zs\d\+'')')
    endif
    let qfl = []
    for bufnr in buffers
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
    endfor
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

