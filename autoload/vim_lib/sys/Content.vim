" Date Create: 2015-01-11 21:01:41
" Last Change: 2015-01-12 20:13:18
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Object = g:vim_lib#base#Object#

"" {{{
" Класс представляет содержимое текущего буфера.
"" }}}
let s:Class = s:Object.expand()

"" {{{
" Метод возвращает информацию о текущем положении курсора, или устанавливает его.
" @param hash pos [optional] Информация о положении курсора. Словарь имеет следующую структуру: {'l': номерСтроки, 'c': номерСимвола}. Любой элемент словаря является необязательным.
" @return hash Информация о положении курсора. Структура соответствует аргументу pos.
"" }}}
function! s:Class.pos(...) " {{{
  if exists('a:1')
   let l:pos = [bufnr('%'), (has_key(a:1, 'l'))? a:1['l'] : line('.'), (has_key(a:1, 'c'))? a:1['c'] : col('.'), 0] 
   call setpos('.', l:pos)
  else
    return {'l': line('.'), 'c': col('.')}
  endif
endfunction " }}}

"" {{{
" Метод добавляет строку в указанную позицию, сдвигая остальные строки вниз.
" @param integer num Номер целевой строки.
" @param string str Вставляемая строка.
"" }}}
function! s:Class.add(num, str) " {{{
  call append(a:num - 1, a:str)
endfunction " }}}

"" {{{
" Метод возвращает заданную строку или заменяет ее на указанную.
" @param integer num Номер целевой строки.
" @param string str [optional] Заменяющая строка. Если параметр не задан, метод возвращает целевую строку.
"" }}}
function! s:Class.line(num, ...) " {{{
  if exists('a:1')
    call setline(a:num, a:1)
  else
    return getline(a:num)
  endif
endfunction " }}}

"" {{{
" Метод возвращает строку, выделенную в режиме Visual, или заменяет ее на указанную.
" @param string str [optional] Заменяющая строка. Если параметр не задан, метод возвращает строку, выделенную пользователем в режиме Visual.
" @return string Строка, выделенная пользователем в режиме Visual или пустая строка, если пользователь ничего не выделил.
"" }}}
function! s:Class.select(...) " {{{
  
endfunction " }}}

"" {{{
" Метод возвращает слово, расположенное под курсором, или заменяет его на указанное.
" @param string str [optional] Заменяющее слово. Если параметр не задан, метод возвращает текущее слово.
" @return string Слово, расположенное под курсором.
"" }}}
function! s:Class.word(...) " {{{
  if exists('a:1')
    let l:col = col('.')
    if l:col == 1 " Курсор в начале строки
      exe 'normal de'
    elseif getline('.')[l:col - 2] !~ '\w' " Курсор в начале слова
      exe 'normal de'
    else " Курсор в середине слова
      exe 'normal bde'
    endif
    exe 'normal i' . a:1
  else
    return expand('<cword>')
  endif
endfunction " }}}

"" {{{
" Метод возвращает слово (от пробела, до пробела), расположенное под курсором, или заменяет его на указанное.
" @param string str [optional] Заменяющее слово. Если параметр не задан, метод возвращает текущее слово.
" @return string Слово, расположенное под курсором.
"" }}}
function! s:Class.WORD(...) " {{{
  if exists('a:1')
    let l:col = col('.')
    if l:col == 1 " Курсор в начале строки
      exe 'normal dE'
    elseif getline('.')[l:col - 2] =~ ' ' " Курсор в начале слова
      exe 'normal dE'
    else " Курсор в середине слова
      exe 'normal bdE'
    endif
    exe 'normal i' . a:1
  else
    return expand('<cWORD>')
  endif
endfunction " }}}

let g:vim_lib#sys#Content# = s:Class
