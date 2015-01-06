" Date Create: 2015-01-06 13:34:25
" Last Change: 2015-01-06 20:26:57
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Object = vim_lib#base#Object#
let s:Subclass = vim_lib#base#tests#Object#Subclass#
let s:Parent = vim_lib#base#tests#Object#Parent#
let s:Child = vim_lib#base#tests#Object#Child#

let s:TestObject = deepcopy(vim_lib#base#Test#)

"" {{{1
" Должен создавать новый класс сохраняя ссылку на родителя в свойстве parent.
" @covers vim_lib#base#Object#.expand
"" 1}}}
function! s:TestObject.testExpand_saveParentLink() " {{{1
  call self.assertEquals(s:Parent.parent, s:Object)
  call self.assertEquals(s:Child.parent, s:Parent)
  call self.assertEquals(s:Child.parent.parent, s:Object)
endfunction " 1}}}

"" {{{1
" Должен создавать новый класс копируя в него ссылки на все методы родителя.
" @covers vim_lib#base#Object#.expand
"" 1}}}
function! s:TestObject.testExpand_copyMethods() " {{{1
  call self.assertEquals(s:Parent.expand, s:Object.expand)
  call self.assertEquals(s:Child.expand, s:Object.expand)
endfunction " 1}}}

"" {{{1
" Может использоваться подклассом без переопределения.
" @covers vim_lib#base#Object#.expand
"" 1}}}
function! s:TestObject.testExpand_definedSubclass() " {{{1
  let s:Subsubclass = s:Subclass.expand()
  call self.assertEquals(s:Subsubclass.parent, s:Subclass)
  call self.assertEquals(s:Subsubclass.new, s:Subclass.new)
  call self.assertEquals(s:Subsubclass.expand, s:Subclass.expand)
  call self.assertEquals(s:Subsubclass.bless, s:Subclass.bless)
endfunction " 1}}}

"" {{{1
" Должен создавать неинициализированный экземпляр класса со свойствами parent и class.
" @covers vim_lib#base#Object#.bless
"" 1}}}
function! s:TestObject.testBless_createObject() " {{{1
  let s:par = s:Parent.bless()
  call self.assertEquals(s:par.parent, s:obj)
  call self.assertEquals(s:par.class, s:Parent)
endfunction " 1}}}

"" {{{1
" Должен позволять задать объекту родителя.
" @covers vim_lib#base#Object#.bless
"" 1}}}
function! s:TestObject.testBless_setParentObject() " {{{1
  let s:obj = s:Object.new()
  let s:par = s:Parent.bless(s:obj)
  call self.assertEquals(s:par.parent, s:obj)
  call self.assertEquals(s:par.class, s:Parent)
endfunction " 1}}}

"" {{{1
" Должен копировать частные методы класса в объект.
" @covers vim_lib#base#Object#.bless
"" 1}}}
function! s:TestObject.testBless_copyMethods() " {{{1
  let s:par = s:Parent.bless()
  call self.assertDictHasKey(s:par, 'modificArray')
endfunction " 1}}}

"" {{{1
" Должен создавать новый объект на основании данного класса сохраняя ссылку на класс в свойстве class объекта.
" @covers vim_lib#base#Object#.new
"" 1}}}
function! s:TestObject.testNew_saveClassLink() " {{{1
  let l:obj = s:Object.new()
  call self.assertEquals(l:obj.class, s:Object)
  let l:obj = s:Parent.new(1)
  call self.assertEquals(l:obj.class, s:Parent)
  let l:obj = s:Child.new(1, 2)
  call self.assertEquals(l:obj.class, s:Child)
endfunction " 1}}}

"" {{{1
" Для подкласса должен сохранять ссылку на объект родительского класса в свойстве parent объекта дочернего класса.
" @covers vim_lib#base#Object#.new
"" 1}}}
function! s:TestObject.testNew_saveParentObject() " {{{1
  let l:p = s:Parent.new(1)
  call self.assertEquals(l:p.parent, s:Object.new())
  let l:c = s:Child.new(1, 2)
  call self.assertEquals(l:c.parent, l:p)
endfunction " 1}}}

"" {{{1
" Должен правильно инициализировать объекты для подклассов.
" @covers vim_lib#base#Object#.new
"" 1}}}
function! s:TestObject.testNew_initialization() " {{{1
  let l:obj = s:Child.new(1, 2)
  call self.assertEquals(1, l:obj.parent.x)
  call self.assertEquals(2, l:obj.y)
endfunction " 1}}}

"" {{{1
" Для подкласса должен создавать новый объект не копируя все свойства родителя в объект.
" @covers vim_lib#base#Object#.new
"" 1}}}
function! s:TestObject.testNew_createObject() " {{{1
  let l:obj = s:Child.new(1, 2)
  call self.assertDictNotHasKey(l:obj, 'x')
  call self.assertDictHasKey(l:obj, 'y')
endfunction " 1}}}

"" {{{1
" Для подклассов должен правильно инициализировать (рекурсивно копировать) сложные структуры.
" @covers vim_lib#base#Object#.new
"" 1}}}
function! s:TestObject.testNew_initializationComplexStructure() " {{{1
  let l:a = s:Child.new(1, 2)
  let l:b = s:Child.new(1, 2)
  let l:a.parent.array[0][0] = 0
  call self.assertEquals(l:a.parent.array[0][0], 0)
  call self.assertEquals(l:b.parent.array[0][0], 1)
endfunction " 1}}}

"" {{{1
" Для подклассов интерфейс родительского класса сохраняется в экземпляря родительского класса.
" @covers vim_lib#base#Object#.new
"" 1}}}
function! s:TestObject.testNew_saveMethodsLink() " {{{1
  let l:a = s:Child.new(1, 2)
  call l:a.parent.modificArray(0)
  call self.assertEquals(l:a.parent.array[0][0], 0)
endfunction " 1}}}

"" {{{1
" Может использоваться подклассом без переопределения.
" @covers vim_lib#base#Object#.new
"" 1}}}
function! s:TestObject.testNew_definedSubclass() " {{{1
  let l:obj = s:Subclass.new()
  call self.assertEquals(l:obj.parent, s:Object.new())
  call self.assertEquals(l:obj.class, s:Subclass)
endfunction " 1}}}

"" {{{1
" Должен определять, является ли вызываемый класс почерним по отношению к заданному.
" @covers vim_lib#base#Object#.typeof
"" 1}}}
function! s:TestObject.testTypeof() " {{{1
  let l:obj = s:Child.new(1, 2)
  call self.assertTrue(l:obj.class.typeof(s:Child))
  call self.assertTrue(l:obj.class.typeof(s:Parent))
  call self.assertTrue(l:obj.class.typeof(s:Object))
  call self.assertFalse(l:obj.class.typeof(s:Subclass))
endfunction " 1}}}

let g:vim_lib#base#tests#TestObject# = s:Object
call s:TestObject.run()
