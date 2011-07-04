" brep.vim -- Scan certain buffers for a regexp and save as quickfix
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @GIT:         http://github.com/tomtom/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2011-07-04.
" @Last Change: 2011-07-04.
" @Revision:    10
" GetLatestVimScripts: 0 0 :AutoInstall: brep.vim
" 

if &cp || exists("loaded_brep")
    finish
endif
let loaded_brep = 1

let s:save_cpo = &cpo
set cpo&vim


" :display: Brep[!] REGEXP
" Scan buffers for REGEXP by means of |brep#Grep()|.
"
" With the optional bang '!', scan unlisted buffers too.
command! -nargs=1 -bang Brep call brep#Grep(<q-args>, [], !empty('<bang>'))


let &cpo = s:save_cpo
unlet s:save_cpo
