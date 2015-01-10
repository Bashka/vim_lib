" Date Create: 2015-01-09 13:58:18
" Last Change: 2015-01-10 11:55:42
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Object = g:vim_lib#base#Object#
let s:NullPlugin = g:vim_lib#sys#NullPlugin#

"" {{{
" Объекты данного класса представляют каждый конкретный, подключаемый редактором плагин.
" Такой плагин можно отключить, определив переменную: let имяПлагина# = 0 - в файле .vimrc или скриптах каталога 'plugin'. При этом все опции, команды и привязки плагина, определенные в нем по умолчанию, не будут применены.
" Плагин, использующий данный класс, инициализируется в каталоге 'plugin' редактора и может выглядить следующим образом:
"   let s:Plugin = vim_lib#sys#Plugin#
"   let s:p = s:Plugin.new('myPlugin')
"   ... " Значения свойств, а так же команды и привязки, используемые по умолчанию для данного плагина.
"   let s:p.reg()
" Интерфейс плагина описывается в каталоге 'autoload' редактора и может выглядить следующим образом:
"   function! myPlugin#method()
"     echo g:myPlugin#optionA
"   endfunction
"" }}}
let s:Class = s:Object.expand()

"" {{{
" Конструктор, формирующий объектное представление плагина.
" После инициализации плагина необходимо вызвать метод reg.
" @param string name Имя плагина.
" @return vim_lib#sys#Plugin# Целевой плагин.
"" }}}
function! s:Class.new(name) " {{{
  if exists('g:' . a:name . '#') && type(g:[a:name . '#']) == 0
    return s:NullPlugin.new(a:name)
  else
    let l:obj = self.bless()
    let l:obj.name = a:name
    let l:obj.savecpo = &l:cpo
    set cpo&vim
    return l:obj
  endif
endfunction " }}}

"" {{{
" Метод возвращает имя плагина.
" @return string Имя плагина.
"" }}}
function! s:Class.getName() " {{{
  return self.name
endfunction " }}}

"" {{{
" Метод определяет начальное значение свойства плагина. Он может применяться для определения свойств плагина по умолчанию.
" Переопределить свойства плагина можно двумя способами:
" 1. Если плагин еще не был загружен (на пример для файла '.vimrc' или скриптов каталога 'plugin'), можно определить словарь 'имяПлагина#', элементы которого определят значения опций плагина. На пример так:
"   let myPlugin# = {'a': 1}
" 2. Если плагин уже был загружен (на пример для скриптов каталога 'ftplugin'), можно непосредственно переопределить свойства объекта плагина, на пример так:
"   let myPlugin#.a = 1
" @param string option Имя свойства.
" @param mixed value Значение по умолчанию для данного свойства.
"" }}}
function! s:Class.def(option, value) " {{{
  let self[a:option] = a:value
endfunction " }}}

"" {{{
" Метод определяет команды редактора, создаваемые плагином.
" При выполнении этих команд будут вызываться методы плагина, определенные в его интерфейсе. Так, команда вида:
"   call s:p.comm('MyPlugComm', 'methodA')
" выполнит метод 'MyPluginComm#methodA'.
" Команды не будут созданы, если плагин отключен.
" @param string command Команда.
" @param string method Имя метода, являющегося частью интерфейса плагина.
"" }}}
function! s:Class.comm(command, method) " {{{
  exe 'command! -nargs=? ' . a:command . ' call ' . self.getName() . '#' . a:method . '()'
endfunction " }}}

"" {{{
" Метод определяет горячие клавиши, создаваемые плагином.
" При использовании этих привязок будут вызываться методы плагина, определенные в его интерфейсе. Так, привязка вида:
"   call s:p.map('n', 'q', 'quit')
" выполнит метод 'MyPluginComm#quit'.
" Привязки не будут созданы, если плагин отключен.
" @param string mode Режим привязки. Возможно одно из следующих значений: n, v, o, i, l, c.
" @param string sequence Комбинация клавишь, для которой создается привязка.
" @param string method Имя метода, являющегося частью интерфейса плагина.
"" }}}
function! s:Class.map(mode, sequence, method) " {{{
  exe a:mode . 'noremap ' . a:sequence . ' :call ' . self.getName() . '#' . a:method . '()<CR>'
endfunction " }}}

"" {{{
" Метод регистрирует плагин в системе и восстанавливает систему в начальное состояние.
" Данный метод необходимо вызвать в конце файла инициализации плагина.
"" }}}
function! s:Class.reg() " {{{
  " Переопределение локальных опций плагина путем объединения словарей и запись его в глобальный объект имяПлагина#.
  let g:[self.name . '#'] = extend(self, (exists('g:' . self.name . '#'))? g:[self.name . '#'] : {})
  let &l:cpo = self.savecpo
endfunction " }}}

let g:vim_lib#sys#Plugin# = s:Class
