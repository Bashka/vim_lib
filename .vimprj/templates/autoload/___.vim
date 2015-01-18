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

let g:vim_lib#base#<+fname+># = s:Class
