" Date Create: 2015-01-09 14:35:46
" Last Change: 2015-02-16 13:59:56
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Object = g:vim_lib#base#Object#

let s:Class = s:Object.expand()

function! s:Class.new(name) " {{{
  let l:obj = self.bless()
  let l:obj.name = a:name
  return l:obj
endfunction " }}}

function! s:Class.getName() " {{{
  return self.name
endfunction " }}}

function! s:Class.comm(command, method) " {{{
endfunction " }}}

function! s:Class.map(sequence, method) " {{{
endfunction " }}}

function! s:Class.au(event, template, method) " {{{
endfunction " }}}

function! s:Class.menu(point, method) " {{{
endfunction " }}}

function! s:Class.reg() " {{{
  let g:[self.name . '#'] = self
endfunction " }}}

function! s:Class.run() " {{{
endfunction " }}}

let g:vim_lib#sys#NullPlugin# = s:Class
