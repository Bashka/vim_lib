" Date Create: 2015-01-07 12:03:58
" Last Change: 2015-01-11 15:56:04
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Dict = vim_lib#base#Dict#

let s:Test = vim_lib#base#Test#.expand()

" new {{{
"" {{{
" Должен создавать пустой словарь.
" @covers vim_lib#base#Dict#.new
"" }}}
function s:Test.testNew_createEmptyDict() " {{{
  let l:obj = s:Dict.new()
  call self.assertEquals(l:obj.length(), 0)
endfunction " }}}

"" {{{
" Должен использовать хэш в качестве начальных данных.
" @covers vim_lib#base#Dict#.new
"" }}}
function s:Test.testNew_wrapHash() " {{{
  let l:obj = s:Dict.new({'a': 1, 'b': 2, 'c': 3})
  call self.assertEquals(l:obj.length(), 3)
  call self.assertEquals(l:obj.item('a'), 1)
endfunction " }}}

"" {{{
" Должен использовать массив в качестве начальных данных.
" @covers vim_lib#base#Dict#.new
"" }}}
function s:Test.testNew_wrapArray() " {{{
  let l:obj = s:Dict.new([['a', 1], ['b', 2], ['c', 3]])
  call self.assertEquals(l:obj.length(), 3)
  call self.assertEquals(l:obj.item('a'), 1)
endfunction " }}}
" }}}
" item {{{
"" {{{
" Должен возвращать значение элемента словаря по ключу.
" @covers vim_lib#base#Dict#.item
"" }}}
function s:Test.testItem_getValue() " {{{
  let l:obj = s:Dict.new()
  call l:obj.item('a', 1)
  call l:obj.item('b', 2)
  call self.assertEquals(l:obj.item('a'), 1)
  call self.assertEquals(l:obj.item('b'), 2)
endfunction " }}}

"" {{{
" Должен выбрасывать исключение, если элемент с заданым ключем отсутствует.
" @covers vim_lib#base#Dict#.item
"" }}}
function s:Test.testItem_throwExceptionGet() " {{{
  let l:obj = s:Dict.new()
  try
    call l:obj.item('a')
    call self.fail('testItem_throwException', 'Expected exception <IndexOutOfRangeException> is not thrown.')
  catch /IndexOutOfRangeException:.*/
  endtry
endfunction " }}}

"" {{{
" Должен устанавливать значение элементу словаря.
" @covers vim_lib#base#Dict#.item
"" }}}
function s:Test.testItem_setValue() " {{{
  let l:obj = s:Dict.new()
  call l:obj.item('a', 1)
  call self.assertEquals(l:obj.item('a'), 1)
endfunction " }}}
" }}}
" keys, vals, items {{{
"" {{{
" Должен возвращать массив ключей словаря.
" @covers vim_lib#base#Dict#.keys
"" }}}
function s:Test.testKeys() " {{{
  let l:obj = s:Dict.new({'a': 1, 'b': 2, 'c': 3})
  call self.assertEquals(l:obj.keys(), ['a', 'b', 'c'])
endfunction " }}}

"" {{{
" Должен возвращать массив значений словаря.
" @covers vim_lib#base#Dict#.vals
"" }}}
function s:Test.testValues() " {{{
  let l:obj = s:Dict.new({'a': 1, 'b': 2, 'c': 3})
  call self.assertEquals(l:obj.vals(), [1, 2, 3])
endfunction " }}}

"" {{{
" Должен возвращать массив элементов словаря.
" @covers vim_lib#base#Dict#.items
"" }}}
function s:Test.testItems() " {{{
  let l:obj = s:Dict.new({'a': 1, 'b': 2, 'c': 3})
  call self.assertEquals(l:obj.items(), [['a', 1], ['b', 2], ['c', 3]])
endfunction " }}}
" }}}

let g:vim_lib#base#tests#TestDict# = s:Test
call s:Test.run()
