" Date Create: 2015-01-06 22:23:22
" Last Change: 2015-01-08 23:06:56
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Object = g:vim_lib#base#Object#

"" {{{
" Класс представляет упорядоченный список с доступом к элементам по индексу.
"" }}}
let s:Class = s:Object.expand()

"" {{{
" Конструктор, формирующий список на основании заданного массива данных.
" @param array data [optional] Исходный массив данных. Если параметр не задан, создается пустой список.
" @return vim_lib#base#List# Целевой список.
"" }}}
function! s:Class.new(...) " {{{
  let l:obj = self.bless()
  "" {{{
  " @var array Массив значений списка.
  "" }}}
  let l:obj.values = (exists('a:1') && type(a:1) == 3)? a:1 : []
  return l:obj
endfunction " }}}

"" {{{
" Метод вычисляет длину списка.
" @return integer Длина списка.
"" }}}
function! s:Class.length() " {{{
  return len(self.values)
endfunction " }}}

"" {{{
" Метод устанавливает или возвращает значение заданного элемента списка.
" @param integer index Индекс целевого элемента.
" @param mixed value [optional] Устанавливаемое значение.
" @throws IndexOutOfRangeException Выбрасывается при обращении к отсутствующему элементу списка (чтение) или попытке выхода за границы списка (запись).
" @return mixed Запрашиваемое значение элемента.
"" }}}
function! s:Class.item(index, ...) " {{{
  let s:len = self.length()
  if !exists('a:1')
    " Возврат значения. {{{ 
    if s:len - 1 < a:index
      throw 'IndexOutOfRangeException: Index <' . a:index . '> not found.'
    endif
    return self.values[a:index]
    " }}}
  else
    " Установка значения {{{
    if s:len < a:index
      throw 'IndexOutOfRangeException: Index <' . a:index . '> out of range.'
    endif
    call insert(self.values, a:1, a:index)
    " }}}
  endif
endfunction " }}}

"" {{{
" Метод преобразует список в массив VimScript.
" @return array Массив элементов списка.
"" }}}
function! s:Class.list() " {{{
  return deepcopy(self.values)
endfunction " }}}

"" {{{
" Метод формирует и возвращает срез списка в виде нового списка.
" @param integer start Индекс элемента начала диапазона. Использование отрицательного значения эквивалентно: len() - значение.
" @param integer end [optional] Индекс элемента конца диапазона включительно. Если параметр не задан, выполняется выборка всех элементов до конца списка. Использование отрицательного значения эквивалентно: len() - значение.
" @return vim_lib#base#List# Результирующий список, содержащий срез исходного списка.
"" }}}
function! s:Class.sec(start, ...) " {{{
  if !exists('a:1')
    return self.class.new(self.values[a:start :])
  else
    return self.class.new(self.values[a:start : a:1])
  endif
endfunction " }}}

let g:vim_lib#base#List# = s:Class
