" Date Create: 2015-02-02 10:05:45
" Last Change: 2015-02-04 11:23:03
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Object = g:vim_lib#base#Object#
let s:EventHandle = g:vim_lib#base#EventHandle#

"" {{{
" Класс представляет интерфейс для взаимодействия с операционной системой и редактором Vim.
"" }}}
let s:Class = s:Object.expand()
call s:Class.mix(s:EventHandle)

"" {{{
" Конструктор всегда возвращает единственный экземпляр данного класса.
" @return vim_lib#sys#System# Интерфейс системы.
"" }}}
function! s:Class.new() " {{{
  return self.singleton
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

" Метод listen примеси EventHandle выносится в закрытую область класса.
let s:Class._listen = s:Class.listen
"" {{{
" Метод определяет функцию-обработчик (слушатель) для глобального события клавиатуры.
" Слушатель должен быть методом вызываемого класса или ссылкой на глобальную функцию.
" @param string mode Режим привязки. Возможно одно из следующих значений: n, v, o, i, l, c.
" @param string sequence Комбинация клавишь, для которой создается привязка.
" @param string listener Имя метода класса или ссылка на глобальную функцию, используемую в качестве функции-обработчика.
"" }}}
function! s:Class.map(mode, sequence, listen) " {{{
  call self._listen('keyPress_' . a:mode . ':' . a:sequence, a:listen)
  exe a:mode . 'noremap ' . a:sequence . ' :call vim_lib#sys#System#.new().fire("' . a:mode . '", "' . a:sequence . '")<CR>:echo ""<CR>'
endfunction " }}}

" Метод ignore примеси EventHandle выносится в закрытую область класса.
let s:Class._ignore = s:Class.ignore
"" {{{
" Метод удаляет функции-обработчики (слушатели) для глобального события клавиатуры.
" @param string mode Режим привязки. Возможно одно из следующих значений: n, v, o, i, l, c.
" @param string sequence Комбинация клавишь, для которой удаляется привязка.
" @param string listener [optional] Имя удаляемой функции-слушателя или ссылка на глобальную функцию. Если параметр не задан, удаляются все слушатели данной комбинации клавишь.
"" }}}
function! s:Class.ignore(mode, sequence, ...) " {{{
  if exists('a:1')
    call self._ignore('keyPress_' . a:mode . ':' . a:sequence, a:1)
  else
    call self._ignore('keyPress_' . a:mode . ':' . a:sequence)
  endif
  if len(self.listeners['keyPress_' . a:mode . ':' . a:sequence]) == 0
    exe a:mode . 'unmap ' . a:sequence
  endif
endfunction " }}}

" Метод fire примеси EventHandle выносится в закрытую область класса.
let s:Class._fire = s:Class.fire
"" {{{
" Метод генерирует глобальное событие клавиатуры.
" @param string mode Режим привязки. Возможно одно из следующих значений: n, v, o, i, l, c.
" @param string sequence Комбинация клавишь, для которой генерируется событие нажатия.
"" }}}
function! s:Class.fire(mode, event) " {{{
  call self._fire('keyPress_' . a:mode . ':' . a:event)
endfunction " }}}

"" {{{
" @var vim_lib#sys#System# Единственный экземпляр класса.
"" }}}
let s:Class.singleton = s:Class.bless()

let g:vim_lib#sys#System# = s:Class
