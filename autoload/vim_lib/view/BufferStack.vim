" Date Create: 2015-01-22 19:07:10
" Last Change: 2015-01-22 19:28:01
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Object = g:vim_lib#base#Object#
let s:Stack = g:vim_lib#base#Stack#
let s:Buffer = g:vim_lib#sys#Buffer#

let s:Class = s:Object.expand()

function! s:Class.new() " {{{
  let l:obj = self.bless()
  let l:obj.stack = s:Stack.new()
  return l:obj
endfunction " }}}

function! s:Class.push(buffer) " {{{
  let a:buffer.stack = self
  call a:buffer.listen('n', 'q', 'stack.delete')
  call self.stack.push(a:buffer)
endfunction " }}}

function! s:Class.delete() " {{{
  let s:currBuffer = self.stack.pop()
  if self.stack.length() > 0
    call self.active()
  endif
  call s:currBuffer.delete()
endfunction " }}}

function! s:Class.active() " {{{
  call self.stack.current().active()
endfunction " }}}

function! s:Class.gactive() " {{{
  call self.stack.current().gactive()
endfunction " }}}

function! s:Class.vactive() " {{{
  call self.stack.current().vactive()
endfunction " }}}

let g:vim_lib#view#BufferStack# = s:Class
