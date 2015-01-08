" Date Create: 2015-01-07 11:55:51
" Last Change: 2015-01-08 23:07:25
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Object = g:vim_lib#base#Object#

"" {{{
" Класс представляет словарь с доступом к элементам по ключу.
"" }}}
let s:Class = s:Object.expand()

"" {{{
" Конструктор, формирующий словарь на основании заданного массива или хэша данных.
" @param hash|array data [optional] Исходный массив данных, имеющий следующую структуру: [[key, value], ...] или хэш. Если параметр не задан, создается пустой словарь.
" @return vim_lib#base#Dict# Целевой словарь.
"" }}}
function! s:Class.new(...) " {{{
  let l:obj = self.bless()
  if exists('a:1')
    if type(a:1) == 3
      " Обработка массива. {{{
      let l:obj.values = {}
      for [l:k, l:v] in a:1
        let l:obj.values[l:k] = l:v
      endfor
      " }}}
    elseif type(a:1) == 4
      " Обработка хэша.
      let l:obj.values = a:1
    else
      let l:obj.values = {}
    endif
  else
    let l:obj.values = {}
  endif
  return l:obj
endfunction " }}}

"" {{{
" Метод вычисляет длину словаря.
" @return integer Длина словаря.
"" }}}
function! s:Class.length() " {{{
  return len(self.values)
endfunction " }}}

"" {{{
" Метод устанавливает или возвращает значение заданного элемента словаря.
" @param string|integer key Ключ целевого элемента.
" @param mixed value [optional] Устанавливаемое значение.
" @throws IndexOutOfRangeException Выбрасывается при обращении к отсутствующему элементу словаря.
" @return mixed Запрашиваемое значение элемента.
"" }}}
function! s:Class.item(key, ...) " {{{
  if !exists('a:1')
    " Возврат значения. {{{ 
    if !has_key(self.values, a:key)
      throw 'IndexOutOfRangeException: Key <' . a:key . '> not found.'
    endif
    return self.values[a:key]
    " }}}
  else
    " Установка значения {{{
    let self.values[a:key] = a:1
    " }}}
  endif
endfunction " }}}

"" {{{
" Метод возвращает массив ключей, используемый в словаре.
" @return array Массив ключей в словаре.
"" }}}
function! s:Class.keys() " {{{
  return keys(self.values)
endfunction " }}}

"" {{{
" Метод возвращает массив значений элементов словаря.
" @return array Массив значений элементов словаря.
"" }}}
function! s:Class.vals() " {{{
  return values(self.values)
endfunction " }}}

"" {{{
" Метод возвращает двумерный массив ключей и значений элементов словаря.
" @return array Двумерный массив следующей структуры: [[key, val], ...].
"" }}}
function! s:Class.items() " {{{
  return items(self.values)
endfunction " }}}

let g:vim_lib#base#Dict# = s:Class
