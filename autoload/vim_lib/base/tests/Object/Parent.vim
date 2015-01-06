" Date Create: 2015-01-06 13:22:19
" Last Change: 2015-01-06 14:34:15
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Object = g:vim_lib#base#Object#

let s:Parent = s:Object.expand()

function! s:Parent.new(x) " {{{1
  let s:obj = {'class': self, 'parent': self.parent.new()}
  let s:obj.x = a:x
  let s:obj.array = [[1, 2, 3], 2, 3]
  return s:obj
endfunction " 1}}}

let g:vim_lib#base#tests#Object#Parent# = s:Parent
