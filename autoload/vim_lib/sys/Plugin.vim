" Date Create: 2015-01-09 13:58:18
" Last Change: 2015-02-03 10:51:46
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Object = g:vim_lib#base#Object#
let s:NullPlugin = g:vim_lib#sys#NullPlugin#

"" {{{
" Объекты данного класса представляют каждый конкретный, подключаемый редактором плагин.
" Такой плагин можно отключить, определив переменную: let имяПлагина# = 0 - в файле .vimrc или скриптах каталога 'plugin'. При этом все опции, команды и привязки плагина, определенные в нем по умолчанию, не будут применены.
" Плагин, использующий данный класс, инициализируется в каталоге 'plugin' редактора и может выглядить следующим образом:
"   let s:Plugin = vim_lib#sys#Plugin#
"   let s:p = s:Plugin.new('myPlugin', '1.0')
"   ... " Значения свойств, а так же команды и привязки, используемые по умолчанию для данного плагина.
"   let s:p.reg()
" Интерфейс плагина описывается в каталоге 'autoload' редактора и может выглядить следующим образом:
"   function! myPlugin#method()
"     echo g:myPlugin#optionA
"   endfunction
"" }}}
let s:Class = s:Object.expand()
let s:Class.plugins = {}

function! s:Class.__verifyDep(dep) " {{{
  if has_key(a:dep, 'version') && !self.__verifyVersion(a:dep['version'])
    return 0
  endif
  if has_key(a:dep, 'has') && !self.__verifyEnv(a:dep['has'])
    return 0
  endif
  if has_key(a:dep, 'plugins') && !self.__verifyPlugs(a:dep['plugins'])
    return 0
  endif
  return 1
endfunction " }}}

function! s:Class.__verifyVersion(assertVersion) " {{{
  if v:version < a:assertVersion
    echohl Error | echo 'Module ' . self.currentModule . ': You need Vim v' . a:assertVersion . ' or higher.' | echohl None
    return 0
  endif
  return 1
endfunction " }}}

function! s:Class.__verifyEnv(assertEnv) " {{{
  for l:module in a:assertEnv
    if !has(l:module)
      echohl Error | echo 'Module ' . self.currentModule . ': You need module "' . l:module . '".' | echohl None
      return 0
    endif
  endfor
  return 1
endfunction " }}}

function! s:Class.__verifyPlugs(assertPlugins) " {{{
  for l:plugin in a:assertPlugins
    if !has_key(self.plugins, l:plugin)
      echohl Error | echo 'Module ' . self.currentModule . ': You need plugin "' . l:plugin . '".' | echohl None
      return 0
    endif
  endfor
  return 1
endfunction " }}}

"" {{{
" Конструктор, формирующий объектное представление плагина.
" После инициализации плагина необходимо вызвать метод reg.
" Если плагин с заданным именем уже зарегистрирован, метод возвращает его объектное представление, созданное ранее. При этом версия, задаваемая вторым параметром, не применяется.
" @param string name Имя плагина.
" @param string version Версия плагина.
" @param hash dependency [optional] Зависимости плагина. Словарь может иметь следующую структуру: {'version': версияРедактора, 'has': [модулиОкружения], 'plugins': [плагины]}
" @return vim_lib#sys#Plugin# Целевой плагин.
"" }}}
function! s:Class.new(name, version, ...) " {{{
  " Получение объекта из пула. {{{
  if has_key(self.plugins, a:name)
    return self.plugins[a:name]
  endif
  " }}}
  let self.currentModule = a:name " Свойство используется методом __verifyDep для определения имени верифицируемого плагина до его создания
  if exists('g:' . a:name . '#') && g:[a:name . '#'] == 0
    return s:NullPlugin.new(a:name)
  endif
  if exists('a:1') && !self.__verifyDep(a:1)
    return s:NullPlugin.new(a:name)
  endif
  let l:obj = self.bless()
  let l:obj.name = a:name
  let l:obj.version = a:version
  let l:obj.commands = {}
  let l:obj.keyListeners = {}
  let l:obj.savecpo = &l:cpo
  let self.plugins[a:name] = l:obj
  set cpo&vim
  return l:obj
endfunction " }}}

"" {{{
" Метод возвращает имя плагина.
" @return string Имя плагина.
"" }}}
function! s:Class.getName() " {{{
  return self.name
endfunction " }}}

"" {{{
" Метод возвращает адрес каталога плагина.
" @return string Адрес каталога плагина.
"" }}}
function! s:Class.getPath() " {{{
  return self.path
endfunction " }}}

"" {{{
" Метод возвращает версию модуля.
" @return string Версия модуля.
"" }}}
function! s:Class.getVersion() " {{{
  return self.version
endfunction " }}}

"" {{{
" Метод определяет команды редактора, создаваемые плагином.
" При выполнении этих команд будут вызываться методы плагина, определенные в его интерфейсе. Так, команда вида:
"   call s:p.comm('MyPlugComm', 'method()')
" выполнит метод 'MyPlugin#method'.
" Важно помнить, что в качестве имени метода необходимо указывать имя целевого метода с завершающими круглыми скобками. Это позволяет указать параметры метода при его вызове.
" Для переопределения команд плагина можно использовать словарь: имяПлагина#commands, который имеет следующую структуру: {команда: метод, ...}.
" Команды не будут созданы, если плагин отключен.
" @param string command Команда.
" @param string method Имя метода, являющегося частью интерфейса плагина.
"" }}}
function! s:Class.comm(command, method) " {{{
  let self.commands[a:command] = a:method
endfunction " }}}

"" {{{
" Метод определяет горячие клавиши, создаваемые плагином.
" При использовании этих привязок будут вызываться методы плагина, определенные в его интерфейсе. Так, привязка вида:
"   call s:p.map('n', 'q', 'quit()')
" выполнит метод 'MyPlugin#quit()'.
" Важно помнить, что в качестве имени метода необходимо указывать имя целевого метода с завершающими круглыми скобками. Это позволяет указать параметры метода при его вызове.
" Для переопределения привязок плагина можно использовать словарь: имяПлагина#map, который имеет следующую структуру: {режим: {комбинация: метод}, ...}.
" Привязки не будут созданы, если плагин отключен.
" @param string mode Режим привязки. Возможно одно из следующих значений: n, v, o, i, l, c.
" @param string sequence Комбинация клавишь, для которой создается привязка.
" @param string method Имя метода, являющегося частью интерфейса плагина.
"" }}}
function! s:Class.map(mode, sequence, method) " {{{
  if !has_key(self.keyListeners, a:mode)
    let self.keyListeners[a:mode] = {}
  endif
  let self.keyListeners[a:mode][a:sequence] = a:method
endfunction " }}}

"" {{{
" Метод определяет обработчик события редактора.
" При возникновении этих событий будут вызываться методы плагина, определенные в его интерфейсе. Так, событие вида:
"   call s:p.au('VimEnter', '*', 'method')
" выполнит метод 'MyPlugin#method'.
" Обработчики не будут созданы, если плагин отключен.
" @param string event Событие редактора (|autocmd-events|).
" @param string template Шаблон, используемый для определения типа файла.
" @param string method Имя метода, являющегося частью интерфейса плагина.
"" }}}
function! s:Class.au(event, template, method) " {{{
  exe 'au ' . a:event . ' ' . a:template . ' call ' . self.getName() . '#' . a:method . '()'
endfunction " }}}

"" {{{
" Метод регистрирует плагин в системе и восстанавливает систему в начальное состояние.
" Данный метод необходимо вызвать в конце файла инициализации плагина.
"" }}}
function! s:Class.reg() " {{{
  " Переопределение свойств плагина. {{{
  let g:[self.name . '#'] = extend(self, (exists('g:' . self.name . '#options'))? g:[self.name . '#options'] : {})
  if exists('g:' . self.name . '#options')
    unlet g:[self.name . '#options']
  endif
  " }}}
  " Переопределение и установка команд плагина. {{{
  let self.commands = extend(self.commands, (exists('g:' . self.name . '#commands'))? g:[self.name . '#commands'] : {})
  for [l:comm, l:method] in items(self.commands)
    exe 'command! -nargs=? ' . l:comm . ' call ' . self.getName() . '#' . l:method
  endfor
  if exists('g:' . self.name . '#commands')
    unlet g:[self.name . '#commands']
  endif
  " }}}
  " Переопределение и установка привязок плагина. {{{
  let self.keyListeners = extend(self.keyListeners, (exists('g:' . self.name . '#map'))? g:[self.name . '#map'] : {})
  for [l:mode, l:map] in items(self.keyListeners)
    for [l:sequence, l:method] in items(l:map)
      exe l:mode . 'noremap ' . l:sequence . ' :call ' . self.getName() . '#' . l:method . '<CR>'
    endfor
  endfor
  if exists('g:' . self.name . '#map')
    unlet g:[self.name . '#map']
  endif
  " }}}
  call self.run()
  let &l:cpo = self.savecpo
endfunction " }}}

"" {{{
" Данный метод может быть переопределен конкретным плагином с целью реализации логики.
"" }}}
function! s:Class.run() " {{{
endfunction " }}}

let g:vim_lib#sys#Plugin# = s:Class
