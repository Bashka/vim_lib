" Date Create: 2015-01-08 23:04:18
" Last Change: 2015-01-08 23:25:42
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Object = g:vim_lib#base#Object#

"" {{{
" Класс представляет список с доступом типа "стек".
"" }}}
let s:Class = s:Object.expand()

"" {{{
" Конструктор, формирующий пустой стек.
" @return vim_lib#base#Stack# Целевой стек.
"" }}}
function! s:Class.new() " {{{
  let l:obj = self.bless()
  "" {{{
  " @var array Массив значений стека.
  "" }}}
  let l:obj.values = []
  return l:obj
endfunction " }}}

"" {{{
" Метод добавляет значение на вершину стека.
" @param mixed value Добавляемое значение.
"" }}}
function! s:Class.push(value) " {{{
  call add(self.values, a:value)
endfunction " }}}

"" {{{
" Метод изымает и возвращает значение с вершины стека.
" @return mixed Значение с вершины стека.
"" }}}
function! s:Class.pop() " {{{
  let l:len = self.length()
  if l:len == 0
    throw 'IndexOutOfRangeException: Stack is empty.'
  endif
  return remove(self.values, self.length() - 1)
endfunction " }}}

"" {{{
" Метод возвращает значение с вершины стека не изымая его.
" @return mixed Значение с вершины стека.
"" }}}
function! s:Class.current() " {{{
  let l:len = self.length()
  if l:len == 0
    throw 'IndexOutOfRangeException: Stack is empty.'
  endif
  return self.values[l:len - 1]
endfunction " }}}

"" {{{
" Метод вычисляет длину стека.
" @return integer Длина стека.
"" }}}
function! s:Class.length() " {{{
  return len(self.values)
endfunction " }}}

let g:vim_lib#base#Stack# = s:Class
