" Date Create: 2015-01-09 13:58:18
" Last Change: 2015-02-16 15:54:06
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Object = g:vim_lib#base#Object#
let s:NullPlugin = g:vim_lib#sys#NullPlugin#
let s:System = g:vim_lib#sys#System#.new()

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
"" {{{
" @var hash Словарь инициализированных плагинов. Словарь имеет следующую структуру: {имя: объектПлагина, ...}
"" }}}
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
  if exists('g:' . a:name . '#') && type(g:[a:name . '#']) == 0
    return s:NullPlugin.new(a:name)
  endif
  if exists('a:1') && !self.__verifyDep(a:1)
    return s:NullPlugin.new(a:name)
  endif
  let l:obj = self.bless()
  "" {{{
  " @var stinrg Имя плагина.
  "" }}}
  let l:obj.name = a:name
  "" {{{
  " @var string Версия плагина.
  "" }}}
  let l:obj.version = a:version
  "" {{{
  " @var hash Словарь команд, определенных плагином. Словарь имеет следующую структуру: {команда: метод, ...}.
  "" }}}
  let l:obj.commands = {}
  "" {{{
  " @var hash Словарь привязок горячих клавишь, определенных плагином. Словарь имеет следующую структуру: {метод: комбинация, ...}.
  "" }}}
  let l:obj.keyListeners = {}
  "" {{{
  " @var hash Словарь пунктов меню, определенных плагином. Словарь имеет следующую структуру: {пункт: метод, ...}.
  "" }}}
  let l:obj.menuPoints = {}
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
"   call s:p.map('q', 'quit')
" выполнит метод 'MyPlugin#quit'.
" Для переопределения привязок плагина можно использовать словарь: имяПлагина#map, который имеет следующую структуру: {метод: комбинация, ...}.
" Привязки не будут созданы, если плагин отключен.
" @param string sequence Комбинация клавишь, для которой создается привязка.
" @param string method Имя метода, являющегося частью интерфейса плагина.
"" }}}
function! s:Class.map(sequence, method) " {{{
  let self.keyListeners[a:method] = a:sequence
endfunction " }}}

"" {{{
" Метод определяет пункт меню для данного плагина.
" Пункт добавляется по адресу Plugins.имяПлагина.point
" При выборе данного пункта меню, вызывается метод плагина, определенный в его интерфейсе. Так, событие вида:
"   call s:p.menu('test', 'mehod')
" выполнит метод 'myPlugin#method'.
" Пункты меню не будут созданы, если плагин отключен.
" @param string point Наименование создаваемого пункта меню.
" @param string method Имя метода, являющегося частью интерфейса плагина.
" @param integer priority [optional] Приоритет создаваемого пункта меню. Чем данное значение ниже, тем выше приоритет.
"" }}}
function! s:Class.menu(point, method, ...) " {{{
  if exists('a:1')
    let l:priority = '1.' . len(self.class.plugins) . '.' . a:1
  else
    let l:priority = ''
  endif
  let self.menuPoints[a:point] = [a:method, l:priority]
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
  " Установка команд плагина. {{{
  for [l:comm, l:method] in items(self.commands)
    exe 'command! -nargs=* ' . l:comm . ' call ' . self.name . '#' . l:method
  endfor
  " }}}
  " Установка пунктов меню. {{{
  for [l:point, l:menuListener] in items(self.menuPoints)
    call s:System.menu('n', 'Plugins.' . self.name . '.' . l:point, function(self.name . '#' . l:menuListener[0]), l:menuListener[1])
  endfor
  " }}}
  " Переопределение и установка привязок плагина. {{{
  let self.keyListeners = extend(self.keyListeners, (exists('g:' . self.name . '#map'))? g:[self.name . '#map'] : {})
  for [l:method, l:sequence] in items(self.keyListeners)
    if l:method != ''
      call s:System.map('n', l:sequence, function(self.name . '#' . l:method))
    endif
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
