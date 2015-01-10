" Date Create: 2015-01-09 15:13:39
" Last Change: 2015-01-09 20:13:41
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Plugin = vim_lib#sys#Plugin#
let s:NullPlugin = vim_lib#sys#NullPlugin#

let s:Test = deepcopy(vim_lib#base#Test#)

" new {{{
"" {{{
" Должен создавать объект плагина.
" @covers vim_lib#base#Plugin#.new
"" }}}
function! s:Test.testNew_createPlugin() " {{{
  let l:obj = s:Plugin.new('vim_lib_testPlugin')
  call self.assertTrue(l:obj.class.typeof(s:Plugin))
endfunction " }}}

"" {{{
" Должен возвращать объект класса vim_lib#sys#NullPlugin#, если плагин отключен.
" @covers vim_lib#base#Plugin#.new
"" }}}
function! s:Test.testNew_offPlugin() " {{{
  let g:vim_lib_testPlugin# = 0
  let l:obj = s:Plugin.new('vim_lib_testPlugin')
  call self.assertTrue(l:obj.class.typeof(s:NullPlugin))
  unlet g:vim_lib_testPlugin#
endfunction " }}}

"" {{{
" Должен сохранять имя плагина.
" @covers vim_lib#base#Plugin#.new
"" }}}
function! s:Test.testNew_saveName() " {{{
  let l:obj = s:Plugin.new('vim_lib_testPlugin')
  call self.assertEquals(l:obj.getName(), 'vim_lib_testPlugin')
endfunction " }}}
" }}}
" getName {{{
"" {{{
" Должен возвращать имя плагина.
" @covers vim_lib#base#Plugin#.getName
"" }}}
function! s:Test.testGetName() " {{{
  let l:obj = s:Plugin.new('vim_lib_testPlugin')
  call self.assertEquals(l:obj.getName(), 'vim_lib_testPlugin')
endfunction " }}}
" }}}
" def {{{
"" {{{
" Должен устанавливать опции по умолчанию.
" @covers vim_lib#base#Plugin#.def
"" }}}
function! s:Test.testDef_setOption() " {{{
  let l:obj = s:Plugin.new('vim_lib_testPlugin')
  call l:obj.def('a', 1)
  call l:obj.reg()
  call self.assertEquals(l:obj.a, 1)
  unlet g:vim_lib_testPlugin#
endfunction " }}}

"" {{{
" Не должен переопределять опцию, если она уже определена.
" @covers vim_lib#base#Plugin#.def
"" }}}
function! s:Test.testDef_defaulValue() " {{{
  let g:vim_lib_testPlugin# = {'a': 0}
  let l:obj = s:Plugin.new('vim_lib_testPlugin')
  call l:obj.def('a', 1)
  call l:obj.reg()
  call self.assertEquals(l:obj.a, 0)
  unlet g:vim_lib_testPlugin#
endfunction " }}}
" }}}
" reg {{{
"" {{{
" Должен инициализировать предопределенные опции.
" @covers vim_lib#base#Plugin#.reg
"" }}}
function! s:Test.testReg() " {{{
  let g:vim_lib_testPlugin# = {'a': 0}
  let l:obj = s:Plugin.new('vim_lib_testPlugin')
  call l:obj.def('a', 1)
  call l:obj.reg()
  call self.assertEquals(l:obj.a, 0)
  unlet g:vim_lib_testPlugin#
endfunction " }}}
" }}}

let g:vim_lib#base#tests#TestPlugin# = s:Test
call s:Test.run()
