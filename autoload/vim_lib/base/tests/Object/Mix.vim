" Date Create: 2015-02-02 14:29:45
" Last Change: 2015-02-02 14:32:15
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Object = g:vim_lib#base#Object#

let s:Class = s:Object.expand()
let s:Class.properties = {'mixProperty': 1}

function! s:Class.mixMethod() " {{{
  return self.mixProperty
endfunction " }}}

let g:vim_lib#base#tests#Object#Mix# = s:Class
