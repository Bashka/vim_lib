" Date Create: 2015-01-06 22:20:12
" Last Change: 2015-01-07 11:19:01
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:List = vim_lib#base#List#

let s:TestList = deepcopy(vim_lib#base#Test#)

"" {{{1
" Должен создавать пустой список.
" @covers vim_lib#base#List#.new
"" 1}}}
function! s:TestList.testNew_createEmptyList() " {{{1
  let l:obj = s:List.new()
  call self.assertEquals(l:obj.length(), 0)
endfunction " 1}}}

"" {{{1
" Должен использовать массив в качестве начальных данных.
" @covers vim_lib#base#List#.new
"" 1}}}
function! s:TestList.testNew_wrapArray() " {{{1
  let l:obj = s:List.new([1, 2, 3])
  call self.assertEquals(l:obj.length(), 3)
  call self.assertEquals(l:obj.item(1), 2)
endfunction " 1}}}

"" {{{1
" Должен возвращать значение элемента списка по индексу.
" @covers vim_lib#base#List#.item
"" 1}}}
function! s:TestList.testItem_getValue() " {{{1
  let l:obj = s:List.new()
  call l:obj.item(0, 1)
  call l:obj.item(1, 2)
  call self.assertEquals(l:obj.item(0), 1)
  call self.assertEquals(l:obj.item(1), 2)
endfunction " 1}}}

"" {{{1
" Должен выбрасывать исключение, если элемент с заданым индексом отсутствует.
" @covers vim_lib#base#List#.item
"" 1}}}
function! s:TestList.testItem_throwExceptionGet() " {{{1
  let l:obj = s:List.new()
  try
    call l:obj.item(0)
    call self.fail('testItem_throwException', 'Expected exception <IndexOutOfRangeException> is not thrown.')
  catch /IndexOutOfRangeException:.*/
  endtry
endfunction " 1}}}

"" {{{1
" Должен устанавливать значение элементу списка.
" @covers vim_lib#base#List#.item
"" 1}}}
function! s:TestList.testItem_setValue() " {{{1
  let l:obj = s:List.new()
  call l:obj.item(0, 1)
  call self.assertEquals(l:obj.item(0), 1)
endfunction " 1}}}

"" {{{1
" Должен выбрасывать исключение, если произошел выход за границы списка.
" @covers vim_lib#base#List#.item
"" 1}}}
function! s:TestList.testItem_throwExceptionSet() " {{{1
  let l:obj = s:List.new()
  try
    call l:obj.item(1, 1)
    call self.fail('testItem_throwException', 'Expected exception <IndexOutOfRangeException> is not thrown.')
  catch /IndexOutOfRangeException:.*/
  endtry
endfunction " 1}}}

"" {{{1
" Должен формировать рекурсивную копию списка и возвращать ее в виде массива.
" @covers vim_lib#base#List#.list
"" 1}}}
function! s:TestList.testList_returnArray() " {{{1
  let l:obj = s:List.new()
  call l:obj.item(0, 1)
  call l:obj.item(1, 2)
  call l:obj.item(2, 3)
  let l:list = l:obj.list()
  call l:obj.item(0, 0)
  call self.assertEquals(l:list, [1, 2, 3])
endfunction " 1}}}

let g:vim_lib#base#tests#TestList# = s:TestList
call s:TestList.run()
