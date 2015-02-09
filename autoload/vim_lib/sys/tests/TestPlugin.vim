" Date Create: 2015-01-09 15:13:39
" Last Change: 2015-02-09 00:48:13
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Plugin = vim_lib#sys#Plugin#
let s:NullPlugin = vim_lib#sys#NullPlugin#

let s:Test = vim_lib#base#Test#.expand()

"" {{{
" Удаление всех зарегистрированных плагинов после выполнения теста.
"" }}}
function! s:Test.afterTest() " {{{
  let s:Plugin.plugins = {}
endfunction " }}}

" new {{{
"" {{{
" Должен создавать объект плагина.
" @covers vim_lib#base#Plugin#.new
"" }}}
function! s:Test.testNew_createPlugin() " {{{
  let l:obj = s:Plugin.new('vim_lib_testPlugin', '1')
  call self.assertTrue(l:obj.class.typeof(s:Plugin))
endfunction " }}}

"" {{{
" Должен возвращать объект класса vim_lib#sys#NullPlugin#, если плагин отключен.
" @covers vim_lib#base#Plugin#.new
"" }}}
function! s:Test.testNew_offPlugin() " {{{
  let g:vim_lib_testPlugin# = 0
  let l:obj = s:Plugin.new('vim_lib_testPlugin', '1')
  call self.assertTrue(l:obj.class.typeof(s:NullPlugin))
  unlet g:vim_lib_testPlugin#
endfunction " }}}

"" {{{
" Должен возвращать объект класса vim_lib#sys#NullPlugin#, если версия редактора отличается от требуемой.
" @covers vim_lib#base#Plugin#.new
"" }}}
function! s:Test.testNew_verifyVersion() " {{{
  let l:obj = s:Plugin.new('vim_lib_testPlugin', '1', {'version': v:version + 1})
  call self.assertTrue(l:obj.class.typeof(s:NullPlugin))
endfunction " }}}

"" {{{
" Должен возвращать объект класса vim_lib#sys#NullPlugin#, если отсутствует требуемый модуль окружения.
" @covers vim_lib#base#Plugin#.new
"" }}}
function! s:Test.testNew_verifyEnv() " {{{
  let l:obj = s:Plugin.new('vim_lib_testPlugin', '1', {'has': ['vim_lib-testModule']})
  call self.assertTrue(l:obj.class.typeof(s:NullPlugin))
endfunction " }}}

"" {{{
" Должен возвращать объект класса vim_lib#sys#NullPlugin#, если отсутствует требуемый плагин.
" @covers vim_lib#base#Plugin#.new
"" }}}
function! s:Test.testNew_verifyPlugins() " {{{
  let l:obj = s:Plugin.new('vim_lib_testPlugin', '1', {'plugins': ['vim_lib-testPlugin']})
  call self.assertTrue(l:obj.class.typeof(s:NullPlugin))
endfunction " }}}

"" {{{
" Должен сохранять имя плагина.
" @covers vim_lib#base#Plugin#.new
"" }}}
function! s:Test.testNew_saveName() " {{{
  let l:obj = s:Plugin.new('vim_lib_testPlugin', '1')
  call self.assertEquals(l:obj.getName(), 'vim_lib_testPlugin')
endfunction " }}}

"" {{{
" Должен сохранять версию плагина.
" @covers vim_lib#base#Plugin#.new
"" }}}
function! s:Test.testNew_saveVersion() " {{{
  let l:obj = s:Plugin.new('vim_lib_testPlugin', '1')
  call self.assertEquals(l:obj.getVersion(), '1')
endfunction " }}}

"" {{{
" Должен сохранять и восстанавливать объекты из пула.
" @covers vim_lib#sys#Plugin#.new
"" }}}
function s:Test.testNew_usePool() " {{{
  let l:obj = s:Plugin.new('vim_lib_testPlugin', '1')
  let l:obj.test = 1
  let l:obj2 = s:Plugin.new(l:obj.getName(), '2')
  call self.assertEquals(l:obj.test, l:obj2.test)
  call self.assertEquals(l:obj2.getVersion(), '1')
endfunction " }}}
" }}}
" getName, getVersion {{{
"" {{{
" Должен возвращать имя плагина.
" @covers vim_lib#base#Plugin#.getName
"" }}}
function! s:Test.testGetName() " {{{
  let l:obj = s:Plugin.new('vim_lib_testPlugin', '1')
  call self.assertEquals(l:obj.getName(), 'vim_lib_testPlugin')
endfunction " }}}

"" {{{
" Должен возвращать версию плагина.
" @covers vim_lib#base#Plugin#.getVersion
"" }}}
function! s:Test.testGetVersion() " {{{
  let l:obj = s:Plugin.new('vim_lib_testPlugin', '1')
  call self.assertEquals(l:obj.getVersion(), '1')
endfunction " }}}
" }}}
" comm, map {{{
"" {{{
" Должен устанавливать команду плагина.
" @covers vim_lib#base#Plugin#.comm
"" }}}
function! s:Test.testComm() " {{{
  let l:obj = s:Plugin.new('vim_lib_testPlugin', '1')
  call l:obj.comm('testComm', 'testMethod')
  call self.assertEquals(l:obj.commands, {'testComm': 'testMethod'})
endfunction " }}}

"" {{{
" Должен устанавливать привязку плагина.
" @covers vim_lib#base#Plugin#.map
"" }}}
function! s:Test.testMap() " {{{
  let l:obj = s:Plugin.new('vim_lib_testPlugin', '1')
  call l:obj.map('q', 'testMethod')
  call self.assertEquals(l:obj.keyListeners, {'testMethod': 'q'})
endfunction " }}}
" }}}
" reg {{{
"" {{{
" Должен переопределять опции плагина.
" @covers vim_lib#base#Plugin#.reg
"" }}}
function! s:Test.testReg_resetOptions() " {{{
  let g:vim_lib_testPlugin#options = {'a': 0}
  let l:obj = s:Plugin.new('vim_lib_testPlugin', '1')
  let l:obj.a = 1
  call l:obj.reg()
  call self.assertEquals(l:obj.a, 0)
  unlet g:vim_lib_testPlugin#
endfunction " }}}

"" {{{
" Должен переопределять привязки плагина.
" @covers vim_lib#base#Plugin#.reg
"" }}}
function! s:Test.testReg_resetKeyListeners() " {{{
  let g:vim_lib_testPlugin#map = {'testMethodA': 'a'}
  let l:obj = s:Plugin.new('vim_lib_testPlugin', '1')
  call l:obj.map('q', 'testMethodA')
  call l:obj.reg()
  call self.assertEquals(l:obj.keyListeners, {'testMethodA': 'a'})
  unlet g:vim_lib_testPlugin#
endfunction " }}}
" }}}

let g:vim_lib#base#tests#TestPlugin# = s:Test
call s:Test.run()
