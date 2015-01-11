" Date Create: 2015-01-08 23:10:42
" Last Change: 2015-01-11 15:55:04
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Stack = vim_lib#base#Stack#

let s:Test = vim_lib#base#Test#.expand()

" new {{{
"" {{{
" Должен создавать пустой стек.
" @covers vim_lib#base#Stack#.new
"" }}}
function! s:Test.testNew() " {{{
  let l:obj = s:Stack.new()
  call self.assertEquals(l:obj.length(), 0)
endfunction " }}}
" }}}
" length {{{
"" {{{
" Должен возвращать размер стека.
" @covers vim_lib#base#Stack#.length
"" }}}
function! s:Test.testLength() " {{{
  let l:obj = s:Stack.new()
  call self.assertEquals(l:obj.length(), 0)
  call l:obj.push(1)
  call l:obj.push(2)
  call self.assertEquals(l:obj.length(), 2)
endfunction " }}}
" }}}
" push, pop, current {{{
"" {{{
" Должен добавлять элемент в вершину стека.
" @covers vim_lib#base#Stack#.push
"" }}}
function! s:Test.testPush() " {{{
  let l:obj = s:Stack.new()
  call l:obj.push(1)
  call self.assertEquals(l:obj.values, [1])
  call l:obj.push(2)
  call self.assertEquals(l:obj.values, [1, 2])
  call self.assertEquals(l:obj.length(), 2)
endfunction " }}}

"" {{{
" Должен изымать и возвращать элемент из вершины стека.
" @covers vim_lib#base#Stack#.pop
"" }}}
function! s:Test.testPop() " {{{
  let l:obj = s:Stack.new()
  call l:obj.push(1)
  call l:obj.push(2)
  call self.assertEquals(l:obj.pop(), 2)
  call self.assertEquals(l:obj.pop(), 1)
  call self.assertEquals(l:obj.length(), 0)
endfunction " }}}

"" {{{
" Должен выбрасывать исключение, если стек пуст.
" @covers vim_lib#base#Stack#.pop
"" }}}
function! s:Test.testPop_throwExceptionIfEmpty() " {{{
  let l:obj = s:Stack.new()
  try
    call l:obj.pop()
    call self.fail('testPop_throwExceptionIfEmpty', 'Expected exception <IndexOutOfRangeException> is not thrown.')
  catch /IndexOutOfRangeException:.*/
  endtry
endfunction " }}}

"" {{{
" Должен возвращать элемент из вершины стека не изымая его.
" @covers vim_lib#base#Stack#.current
"" }}}
function! s:Test.testCurrent() " {{{
  let l:obj = s:Stack.new()
  call l:obj.push(1)
  call l:obj.push(2)
  call self.assertEquals(l:obj.current(), 2)
  call self.assertEquals(l:obj.current(), 2)
  call self.assertEquals(l:obj.length(), 2)
endfunction " }}}

"" {{{
" Должен выбрасывать исключение, если стек пуст.
" @covers vim_lib#base#Stack#.current
"" }}}
function! s:Test.testCurrent_throwExceptionIfEmpty() " {{{
  let l:obj = s:Stack.new()
  try
    call l:obj.current()
    call self.fail('testPop_throwExceptionIfEmpty', 'Expected exception <IndexOutOfRangeException> is not thrown.')
  catch /IndexOutOfRangeException:.*/
  endtry
endfunction " }}}
" }}}

let g:vim_lib#base#tests#TestStack# = s:Test
call s:Test.run()
