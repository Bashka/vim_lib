" Date Create: 2015-01-06 22:20:12
" Last Change: 2015-01-08 11:52:04
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:List = vim_lib#base#List#

let s:Test = deepcopy(vim_lib#base#Test#)

" new {{{
"" {{{
" Должен создавать пустой список.
" @covers vim_lib#base#List#.new
"" }}}
function s:Test.testNew_createEmptyList() " {{{
  let l:obj = s:List.new()
  call self.assertEquals(l:obj.length(), 0)
endfunction " }}}

"" {{{
" Должен использовать массив в качестве начальных данных.
" @covers vim_lib#base#List#.new
"" }}}
function s:Test.testNew_wrapArray() " {{{
  let l:obj = s:List.new([1, 2, 3])
  call self.assertEquals(l:obj.length(), 3)
  call self.assertEquals(l:obj.item(1), 2)
endfunction " }}}
" }}}
" item {{{
"" {{{
" Должен возвращать значение элемента списка по индексу.
" @covers vim_lib#base#List#.item
"" }}}
function s:Test.testItem_getValue() " {{{
  let l:obj = s:List.new()
  call l:obj.item(0, 1)
  call l:obj.item(1, 2)
  call self.assertEquals(l:obj.item(0), 1)
  call self.assertEquals(l:obj.item(1), 2)
endfunction " }}}

"" {{{
" Должен выбрасывать исключение, если элемент с заданым индексом отсутствует.
" @covers vim_lib#base#List#.item
"" }}}
function s:Test.testItem_throwExceptionGet() " {{{
  let l:obj = s:List.new()
  try
    call l:obj.item(0)
    call self.fail('testItem_throwException', 'Expected exception <IndexOutOfRangeException> is not thrown.')
  catch /IndexOutOfRangeException:.*/
  endtry
endfunction " }}}

"" {{{
" Должен устанавливать значение элементу списка.
" @covers vim_lib#base#List#.item
"" }}}
function s:Test.testItem_setValue() " {{{
  let l:obj = s:List.new()
  call l:obj.item(0, 1)
  call self.assertEquals(l:obj.item(0), 1)
endfunction " }}}

"" {{{
" Должен выбрасывать исключение, если произошел выход за границы списка.
" @covers vim_lib#base#List#.item
"" }}}
function s:Test.testItem_throwExceptionSet() " {{{
  let l:obj = s:List.new()
  try
    call l:obj.item(1, 1)
    call self.fail('testItem_throwException', 'Expected exception <IndexOutOfRangeException> is not thrown.')
  catch /IndexOutOfRangeException:.*/
  endtry
endfunction " }}}
" }}}
" list {{{
"" {{{
" Должен формировать рекурсивную копию списка и возвращать ее в виде массива.
" @covers vim_lib#base#List#.list
"" }}}
function s:Test.testList_returnArray() " {{{
  let l:obj = s:List.new()
  call l:obj.item(0, 1)
  call l:obj.item(1, 2)
  call l:obj.item(2, 3)
  let l:list = l:obj.list()
  call l:obj.item(0, 0)
  call self.assertEquals(l:list, [1, 2, 3])
endfunction " }}}
" }}}
" sec {{{
"" {{{
" Должен позволять выдилить хвост списка.
" @covers vim_lib#base#List#.sec
"" }}}
function s:Test.testSec_getTail() " {{{
  let l:obj = s:List.new([1, 2, 3, 4, 5])
  call self.assertEquals(l:obj.sec(2).list(), [3, 4, 5])
endfunction " }}}

"" {{{
" Должен позволять выдилить голову списка.
" @covers vim_lib#base#List#.sec
"" }}}
function s:Test.testSec_getHead() " {{{
  let l:obj = s:List.new([1, 2, 3, 4, 5])
  call self.assertEquals(l:obj.sec(0, 3).list(), [1, 2, 3, 4])
endfunction " }}}

"" {{{
" Должен позволять выдилить тело списка.
" @covers vim_lib#base#List#.sec
"" }}}
function s:Test.testSec_getBody() " {{{
  let l:obj = s:List.new([1, 2, 3, 4, 5])
  call self.assertEquals(l:obj.sec(1, 3).list(), [2, 3, 4])
endfunction " }}}

"" {{{
" Можно использовать отрицательные значения параметров.
" @covers vim_lib#base#List#.sec
"" }}}
function s:Test.testSec_negativeParams() " {{{
  let l:obj = s:List.new([1, 2, 3, 4, 5])
  call self.assertEquals(l:obj.sec(0, -1).list(), [1, 2, 3, 4, 5])
  call self.assertEquals(l:obj.sec(0, -2).list(), [1, 2, 3, 4])
  call self.assertEquals(l:obj.sec(-2).list(), [4, 5])
  call self.assertEquals(l:obj.sec(-3, -2).list(), [3, 4])
endfunction " }}}
" }}}

let g:vim_lib#base#tests#TestList# = s:Test
call s:Test.run()
