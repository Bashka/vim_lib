" Date Create: 2015-01-06 13:24:32
" Last Change: 2015-01-07 11:45:23
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Parent = g:vim_lib#base#tests#Object#Parent#

let s:Child = s:Parent.expand()

function! s:Child.new(x, y) " {{{
  let l:obj = self.bless(self.parent.new(a:x))
  let l:obj.y = a:y
  return l:obj
endfunction " }}}

let g:vim_lib#base#tests#Object#Child# = s:Child
