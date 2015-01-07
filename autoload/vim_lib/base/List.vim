" Date Create: 2015-01-06 22:23:22
" Last Change: 2015-01-07 11:20:28
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Object = g:vim_lib#base#Object#

"" {{{1
" Класс представляет упорядоченный список с доступом к элементам по индексу.
"" 1}}}
let s:List = s:Object.expand()

"" {{{1
" Конструктор, формирующий список на основании заданного массива данных.
" @param array data [optional] Исходный массив данных. Если параметр не задан, создается пустой список.
" @return vim_lib#base#List# Целевой список.
"" 1}}}
function! s:List.new(...) " {{{1
  let l:obj = self.bless()
  let l:obj.values = (exists('a:1') && type(a:1) == 3)? a:1 : []
  return l:obj
endfunction " 1}}}

"" {{{1
" Метод вычисляет длину списка.
" @return integer Длина списка.
"" 1}}}
function! s:List.length() " {{{1
  return len(self.values)
endfunction " 1}}}

"" {{{1
" Метод устанавливает или возвращает значение заданного элемента списка.
" @param integer index Индекс целевого элемента.
" @param mixed value [optional] Устанавливаемое значение.
" @throws IndexOutOfRangeException Выбрасывается при обращении к отсутствующему элементу списка (чтение) или попытке выхода за границы списка (запись).
" @return mixed Запрашиваемое значение элемента.
"" 1}}}
function! s:List.item(index, ...) " {{{1
  let s:len = self.length()
  if !exists('a:1')
    " Возврат значения. {{{2 
    if s:len - 1 < a:index
      throw 'IndexOutOfRangeException: Index <' . a:index . '> not found.'
    endif
    return self.values[a:index]
    " 2}}}
  else
    " Установка значения {{{2
    if s:len < a:index
      throw 'IndexOutOfRangeException: Index <' . a:index . '> out of range.'
    endif
    call insert(self.values, a:1, a:index)
    " 2}}}
  endif
endfunction " 1}}}

"" {{{1
" Метод преобразует список в массив VimScript.
" @return array Массив элементов списка.
"" 1}}}
function! s:List.list() " {{{1
  return deepcopy(self.values)
endfunction " 1}}}

let g:vim_lib#base#List# = s:List
