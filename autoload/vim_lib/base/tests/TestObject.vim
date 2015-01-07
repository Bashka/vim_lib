" Date Create: 2015-01-06 13:34:25
" Last Change: 2015-01-07 12:05:32
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Object = vim_lib#base#Object#
let s:Subclass = vim_lib#base#tests#Object#Subclass#
let s:Parent = vim_lib#base#tests#Object#Parent#
let s:Child = vim_lib#base#tests#Object#Child#

let s:Test = deepcopy(vim_lib#base#Test#)

" expand {{{
"" {{{
" Должен создавать новый класс сохраняя ссылку на родителя в свойстве parent.
" @covers vim_lib#base#Object#.expand
"" }}}
function! s:Test.testExpand_saveParentLink() " {{{
  call self.assertEquals(s:Parent.parent, s:Object)
  call self.assertEquals(s:Child.parent, s:Parent)
  call self.assertEquals(s:Child.parent.parent, s:Object)
endfunction " }}}

"" {{{
" Должен создавать новый класс копируя в него ссылки на все методы родителя.
" @covers vim_lib#base#Object#.expand
"" }}}
function! s:Test.testExpand_copyMethods() " {{{
  call self.assertEquals(s:Parent.expand, s:Object.expand)
  call self.assertEquals(s:Child.expand, s:Object.expand)
endfunction " }}}

"" {{{
" Может использоваться подклассом без переопределения.
" @covers vim_lib#base#Object#.expand
"" }}}
function! s:Test.testExpand_definedSubclass() " {{{
  let s:Subsubclass = s:Subclass.expand()
  call self.assertEquals(s:Subsubclass.parent, s:Subclass)
  call self.assertEquals(s:Subsubclass.new, s:Subclass.new)
  call self.assertEquals(s:Subsubclass.expand, s:Subclass.expand)
  call self.assertEquals(s:Subsubclass.bless, s:Subclass.bless)
endfunction " }}}
" }}}
" bless {{{
"" {{{
" Должен создавать неинициализированный экземпляр класса со свойствами parent и class.
" @covers vim_lib#base#Object#.bless
"" }}}
function! s:Test.testBless_createObject() " {{{
  let s:par = s:Parent.bless()
  call self.assertEquals(s:par.parent, s:obj)
  call self.assertEquals(s:par.class, s:Parent)
endfunction " }}}

"" {{{
" Должен позволять задать объекту родителя.
" @covers vim_lib#base#Object#.bless
"" }}}
function! s:Test.testBless_setParentObject() " {{{
  let s:obj = s:Object.new()
  let s:par = s:Parent.bless(s:obj)
  call self.assertEquals(s:par.parent, s:obj)
  call self.assertEquals(s:par.class, s:Parent)
endfunction " }}}

"" {{{
" Должен копировать частные методы класса в объект.
" @covers vim_lib#base#Object#.bless
"" }}}
function! s:Test.testBless_copyMethods() " {{{
  let s:par = s:Parent.bless()
  call self.assertDictHasKey(s:par, 'modificArray')
endfunction " }}}
" }}}
" new {{{
"" {{{
" Должен создавать новый объект на основании данного класса сохраняя ссылку на класс в свойстве class объекта.
" @covers vim_lib#base#Object#.new
"" }}}
function! s:Test.testNew_saveClassLink() " {{{
  let l:obj = s:Object.new()
  call self.assertEquals(l:obj.class, s:Object)
  let l:obj = s:Parent.new(1)
  call self.assertEquals(l:obj.class, s:Parent)
  let l:obj = s:Child.new(1, 2)
  call self.assertEquals(l:obj.class, s:Child)
endfunction " }}}

"" {{{
" Для подкласса должен сохранять ссылку на объект родительского класса в свойстве parent объекта дочернего класса.
" @covers vim_lib#base#Object#.new
"" }}}
function! s:Test.testNew_saveParentObject() " {{{
  let l:p = s:Parent.new(1)
  call self.assertEquals(l:p.parent, s:Object.new())
  let l:c = s:Child.new(1, 2)
  call self.assertEquals(l:c.parent, l:p)
endfunction " }}}

"" {{{
" Должен правильно инициализировать объекты для подклассов.
" @covers vim_lib#base#Object#.new
"" }}}
function! s:Test.testNew_initialization() " {{{
  let l:obj = s:Child.new(1, 2)
  call self.assertEquals(1, l:obj.parent.x)
  call self.assertEquals(2, l:obj.y)
endfunction " }}}

"" {{{
" Для подкласса должен создавать новый объект не копируя все свойства родителя в объект.
" @covers vim_lib#base#Object#.new
"" }}}
function! s:Test.testNew_createObject() " {{{
  let l:obj = s:Child.new(1, 2)
  call self.assertDictNotHasKey(l:obj, 'x')
  call self.assertDictHasKey(l:obj, 'y')
endfunction " }}}

"" {{{
" Для подклассов должен правильно инициализировать (рекурсивно копировать) сложные структуры.
" @covers vim_lib#base#Object#.new
"" }}}
function! s:Test.testNew_initializationComplexStructure() " {{{
  let l:a = s:Child.new(1, 2)
  let l:b = s:Child.new(1, 2)
  let l:a.parent.array[0][0] = 0
  call self.assertEquals(l:a.parent.array[0][0], 0)
  call self.assertEquals(l:b.parent.array[0][0], 1)
endfunction " }}}

"" {{{
" Должен копировать ссылки на конкретные методы класса в экземпляр этого класса.
" @covers vim_lib#base#Object#.new
"" }}}
function! s:Test.testNew_copyMethodLinks() " {{{
  let l:obj = s:Parent.new(1)
  call l:obj.modificArray(0)
  call self.assertEquals(l:obj.array[0][0], 0)
endfunction " }}}

"" {{{
" Для подклассов интерфейс родительского класса сохраняется в экземпляря родительского класса.
" @covers vim_lib#base#Object#.new
"" }}}
function! s:Test.testNew_noSaveMethodsLink() " {{{
  let l:a = s:Child.new(1, 2)
  call l:a.parent.modificArray(0)
  call self.assertEquals(l:a.parent.array[0][0], 0)
endfunction " }}}

"" {{{
" Может использоваться подклассом без переопределения.
" @covers vim_lib#base#Object#.new
"" }}}
function! s:Test.testNew_definedSubclass() " {{{
  let l:obj = s:Subclass.new()
  call self.assertEquals(l:obj.parent, s:Object.new())
  call self.assertEquals(l:obj.class, s:Subclass)
endfunction " }}}
" }}}
" typeof {{{
"" {{{
" Должен определять, является ли вызываемый класс почерним по отношению к заданному.
" @covers vim_lib#base#Object#.typeof
"" }}}
function! s:Test.testTypeof() " {{{
  let l:obj = s:Child.new(1, 2)
  call self.assertTrue(l:obj.class.typeof(s:Child))
  call self.assertTrue(l:obj.class.typeof(s:Parent))
  call self.assertTrue(l:obj.class.typeof(s:Object))
  call self.assertFalse(l:obj.class.typeof(s:Subclass))
endfunction " }}}
" }}}

let g:vim_lib#base#tests#TestObject# = s:Test
call s:Test.run()
