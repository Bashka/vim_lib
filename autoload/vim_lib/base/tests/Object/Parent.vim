" Date Create: 2015-01-06 13:22:19
" Last Change: 2015-02-02 14:41:50
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Object = g:vim_lib#base#Object#
let s:Mix = g:vim_lib#base#tests#Object#Mix#

let s:Parent = s:Object.expand()
let s:Parent.properties = {'property': 1}
call s:Parent.mix(s:Mix)

function! s:Parent.new(x) " {{{
  let l:obj = self.bless()
  let l:obj.x = a:x
  let l:obj.array = [[1, 2, 3], 2, 3]
  return l:obj
endfunction " }}}

function s:Parent.modificArray(value) " {{{
  let self.array[0][0] = a:value
endfunction " }}}

function! s:Parent.__staticMethod() " {{{
endfunction " }}}

let g:vim_lib#base#tests#Object#Parent# = s:Parent
