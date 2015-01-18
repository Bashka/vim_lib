" Date Create: <+datetime+>
" Last Change: <+datetime+>
" Author: <+author+> (<+email+>)
" License: <+license+>

let s:Object = g:vim_lib#base#Object#

let s:Class = s:Object.expand()

function! s:Class.new() " {{{
  let l:obj = self.bless()
  <++>
  return l:obj
endfunction " }}}

let g:`substitute(strpart(g:vim_template#keywords.dir, stridx(g:vim_template#keywords.dir, '/') + 1), '/', '#', 'g') . '#' . g:vim_template#keywords.fname . '#'` = s:Test
