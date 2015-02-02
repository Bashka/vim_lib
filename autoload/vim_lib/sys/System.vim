" Date Create: 2015-02-02 10:05:45
" Last Change: 2015-02-02 11:24:21
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Object = g:vim_lib#base#Object#

"" {{{
" Класс представляет интерфейс для взаимодействия с операционной системой и редактором Vim.
"" }}}
let s:Class = s:Object.expand()

function! s:Class.new() " {{{
  let l:obj = self.bless()
  return l:obj
endfunction " }}}

"" {{{
" Метод выполняет команду в командной оболочке и возвращает результат.
" @param string command Выполняемая команда.
" @throws ShellException Выбрасывается в случае ошибки при выполнении команды командной оболочке.
" @return string Результат работы команды.
"" }}}
function! s:Class.run(command) " {{{
  " Вызов для MacVim, которые не наследуют переменные окружения
  let l:response = system(((has('mac') && &shell =~ 'sh$')? 'EDITOR="" ' : '') . a:command)
  if v:shell_error
    echohl Error | echo l:response | echohl None
    throw 'ShellException: command fails.'
  else
    return l:response
  endif
endfunction " }}}

"" {{{
" Метод выполняет команду в командной оболочке. В отличии от метода run, данный метод исполняет команду с переходом в командную оболочку.
" @param string command Выполняемая команда.
"" }}}
function! s:Class.exe(command) " {{{
  " Вызов для MacVim, которые не наследуют переменные окружения
  exe '!' . ((has('mac') && &shell =~ 'sh$')? 'EDITOR="" ' : '') . a:command
endfunction " }}}

"" {{{
" Метод печатает сообщение в консоли редактора.
" @param string msg Сообщение.
" @param string color [optional] Цвет сообщения.
"" }}}
function! s:Class.echo(msg, ...) " {{{
  let l:color = (exists('a:1'))? a:1 : 'None'
  exe 'echohl ' . l:color
  exe 'echo "' . a:msg . '"'
  echohl None
endfunction " }}}

"" {{{
" Метод печатает устойчивое сообщение в консоли редактора.
" @param string msg Сообщение.
" @param string color [optional] Цвет сообщения.
"" }}}
function! s:Class.echom(msg, ...) " {{{
  let l:color = (exists('a:1'))? a:1 : 'None'
  exe 'echohl ' . l:color
  exe 'echom "' . a:msg . '"'
  echohl None
endfunction " }}}

"" {{{
" Метод печатает сообщение в консоли редактора, ожидая реакции пользователя.
" @param string msg Сообщение.
" @param string color [optional] Цвет сообщения.
"" }}}
function! s:Class.print(msg, ...) " {{{
  let l:color = (exists('a:1'))? a:1 : 'None'
  call inputsave()
  exe 'echohl ' . l:color
  call input(a:msg)
  echohl None
  call inputrestore()
endfunction " }}}

"" {{{
" Метод запрашивает строку у пользователя.
" @param string msg Заголовок запроса.
" @param string color [optional] Цвет заголовка.
" @return string Строка, введеная пользователем.
"" }}}
function! s:Class.read(msg, ...) " {{{
  let l:color = (exists('a:1'))? a:1 : 'None'
  call inputsave()
  exe 'echohl ' . l:color
  let l:result = input(a:msg)
  echohl None
  call inputrestore()
  return l:result
endfunction " }}}

let g:vim_lib#sys#System# = s:Class
