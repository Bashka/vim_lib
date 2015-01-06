" Date Create: 2015-01-06 13:34:25
" Last Change: 2015-01-06 14:47:48
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Test = vim_lib#base#Test#

let s:Object = vim_lib#base#Object#
let s:Parent = vim_lib#base#tests#Object#Parent#
let s:Child = vim_lib#base#tests#Object#Child#

let s:TestObject = deepcopy(s:Test)

"" {{{1
" Должен создавать новый объект сохраняя ссылку на родителя в свойстве parent.
"" 1}}}
function! s:TestObject.testExpand_saveParentLink() " {{{1
  call self.assertEquals(s:Parent.parent, s:Object)
  call self.assertEquals(s:Child.parent, s:Parent)
  call self.assertEquals(s:Child.parent.parent, s:Object)
endfunction " 1}}}

"" {{{1
" Должен создавать новый объект копируя в него ссылки на все методы родителя.
"" 1}}}
function! s:TestObject.testExpand_copyMethods() " {{{1
  call self.assertEquals(s:Parent.expand, s:Object.expand)
  call self.assertEquals(s:Child.expand, s:Object.expand)
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

let g:vim_lib#base#tests#TestObject# = s:Object
call s:TestObject.run()
