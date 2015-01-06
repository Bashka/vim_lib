" Date Create: 2015-01-06 13:22:19
" Last Change: 2015-01-06 13:27:02
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Object = g:vim_lib#base#Object#

let s:Parent = s:Object.expand()

let s:Parent.x = 1

function! s:Parent.new(x) " {{{1
  let s:obj = self.parent.new()
  let s:obj.x = a:x
  return s:obj
endfunction " 1}}}

let g:vim_lib#base#tests#Object#Parent# = s:Parent
