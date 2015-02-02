" Date Create: 2015-02-02 17:09:15
" Last Change: 2015-02-02 17:11:02
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Object = g:vim_lib#base#Object#
let s:EventHandle = g:vim_lib#base#EventHandle#

let s:Class = s:Object.expand()
call s:Class.mix(s:EventHandle)

function! s:Class.new() " {{{
  let l:obj = self.bless()
  return l:obj
endfunction " }}}

let g:vim_lib#base#tests#EventHandle#Mock# = s:Class
