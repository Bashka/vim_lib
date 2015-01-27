" Date Create: 2015-01-22 19:07:10
" Last Change: 2015-01-26 09:31:53
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Object = g:vim_lib#base#Object#
let s:Stack = g:vim_lib#base#Stack#
let s:Buffer = g:vim_lib#sys#Buffer#

"" {{{
" Класс представляет стек буферов, накладываемых друг на друга так, чтобы закрытие одного автоматически активировала следующий.
"" }}}
let s:Class = s:Object.expand()

"" {{{
" Конструктор создает пустой стек буферов.
"" }}}
function! s:Class.new() " {{{
  let l:obj = self.bless()
  let l:obj.stack = s:Stack.new()
  return l:obj
endfunction " }}}

"" {{{
" Метод добавляет буфер в стек, но не активирует его.
" Метод добавляет привязку к клавише q для добавляемого буфера так, чтобы по нажатии этой клавиши, текущий буфер закрывался и автоматически активировался предыдущий.
" @param vim_lib#sys#Buffer# buffer Добавляемый буфер.
"" }}}
function! s:Class.push(buffer) " {{{
  let a:buffer.stack = self
  call a:buffer.listen('n', 'q', 'stack.delete')
  call self.stack.push(a:buffer)
endfunction " }}}

"" {{{
" Метод возвращает текущий буфер стека.
" @return vim_lib#sys#Buffer# Текущий буфер стека.
"" }}}
function! s:Class.current() " {{{
  return self.stack.current()
endfunction " }}}

"" {{{
" Метод удаляет текущий буфер, заменяя его следующим. Если стек буферов содержит только один буфер, окно, содержащее его, закрывается.
"" }}}
function! s:Class.delete() " {{{
  let s:currBuffer = self.stack.pop()
  if self.stack.length() > 0
    call self.active()
  endif
  call s:currBuffer.delete()
endfunction " }}}

"" {{{
" Метод делает текущий буфер стека (буфер на вершине стека) текущим.
"" }}}
function! s:Class.active() " {{{
  call self.stack.current().active()
endfunction " }}}

"" {{{
" Метод открывает новое окно, разделяя текущее по горизонтали, и делает в нем текущий буфер активным.
" @param string pos Позиция нового окна (t - выше текущего окна, b - ниже текущего окна).
" @param integer gsize [optional] Высота нового окна.
" @see vim_lib#sys#Buffer#.active
"" }}}
function! s:Class.gactive(pos, ...) " {{{
  if exists('a:1')
    call self.stack.current().gactive(a:pos, a:1)
  else
    call self.stack.current().gactive(a:pos)
  endif
endfunction " }}}

"" {{{
" Метод открывает новое окно, разделяя текущее по вертикали, и делает в нем текущий буфер активным.
" @param string pos Позиция нового окна (l - слева от текущего окна, r - справа от текущего окна).
" @param integer vsize [optional] Ширина нового окна.
" @see vim_lib#sys#Buffer#.active
"" }}}
function! s:Class.vactive(pos, ...) " {{{
  if exists('a:1')
    call self.stack.current().vactive(a:pos, a:1)
  else
    call self.stack.current().vactive(a:pos)
  endif
endfunction " }}}

let g:vim_lib#view#BufferStack# = s:Class
