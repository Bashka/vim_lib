" Date Create: 2015-01-11 21:34:18
" Last Change: 2015-01-16 23:59:46
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Content = vim_lib#sys#Content#

let s:Test = vim_lib#base#Test#.expand()

function! s:Test.beforeRun() " {{{
  new
endfunction " }}}

function! s:Test.beforeTest() " {{{
  call setline(1, 'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod')
  call setline(2, 'tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.')
endfunction " }}}

function! s:Test.afterTest() " {{{
  call setpos('.', [bufnr('%'), 1, 1, 0])
endfunction " }}}

function! s:Test.afterRun() " {{{
  q!
endfunction " }}}

" new {{{
"" {{{
" Класс является Singleton.
" @covers vim_lib#sys#Content#.new
"" }}}
function! s:Test.testNew() " {{{
  let l:obj = s:Content.new()
  call self.assertEquals(l:obj, s:Content.new())
endfunction " }}}
" }}}
" pos {{{
"" {{{
" Должен устанавливать позицию курсора.
" @covers vim_lib#sys#Content#.pos
"" }}}
function! s:Test.testPos_setAll() " {{{
  let l:obj = s:Content.new()
  call l:obj.pos({'l': 2, 'c': 5})
  call self.assertEquals([line('.'), col('.')], [2, 5])
endfunction " }}}

"" {{{
" Должен устанавливать текущую строку.
" @covers vim_lib#sys#Content#.pos
"" }}}
function! s:Test.testPos_setLine() " {{{
  let l:obj = s:Content.new()
  call l:obj.pos({'l': 2})
  call self.assertEquals([line('.'), col('.')], [2, 1])
endfunction " }}}

"" {{{
" Должен устанавливать текущую столбец.
" @covers vim_lib#sys#Content#.pos
"" }}}
function! s:Test.testPos_setCol() " {{{
  let l:obj = s:Content.new()
  call l:obj.pos({'c': 5})
  call self.assertEquals([line('.'), col('.')], [1, 5])
endfunction " }}}

"" {{{
" Должен возвращать позицию курсора.
" @covers vim_lib#sys#Content#.pos
"" }}}
function! s:Test.testPos_getPos() " {{{
  let l:obj = s:Content.new()
  call self.assertEquals(l:obj.pos(), {'l': 1, 'c': 1})
endfunction " }}}
" }}}
" add, line {{{
"" {{{
" Должен добавлять строку в указанную позицию, сдвигая остальные строки вниз.
" @covers vim_lib#sys#Content#.add
"" }}}
function! s:Test.testAdd() " {{{
  let l:obj = s:Content.new()
  call l:obj.add(2, 'Test')
  call self.assertEquals(getline(2), 'Test')
  call self.assertEquals(getline(3), 'tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.')
endfunction " }}}

"" {{{
" Должен возвращать заданную строку.
" @covers vim_lib#sys#Content#.line
"" }}}
function! s:Test.testLine_getLine() " {{{
  let l:obj = s:Content.new()
  call self.assertEquals(l:obj.line(2), 'tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.')
endfunction " }}}

"" {{{
" Должен задавать строку.
" @covers vim_lib#sys#Content#.line
"" }}}
function! s:Test.testLine_setLine() " {{{
  let l:obj = s:Content.new()
  call l:obj.line(2, 'Test')
  call self.assertEquals(getline(2), 'Test')
endfunction " }}}
" }}}
" word, WORD {{{
"" {{{
" Должен возвращать текущее слово.
" @covers vim_lib#sys#Content#.word
"" }}}
function! s:Test.testWord_getWord() " {{{
  let l:obj = s:Content.new()
  call self.assertEquals(l:obj.word(), 'Lorem')
  call setpos('.', [bufnr('%'), 1, 2, 0])
  call self.assertEquals(l:obj.word(), 'Lorem')
  call setpos('.', [bufnr('%'), 1, 5, 0])
  call self.assertEquals(l:obj.word(), 'Lorem')
endfunction " }}}

"" {{{
" Должен устанавливать текущее слово.
" @covers vim_lib#sys#Content#.word
"" }}}
function! s:Test.testWord_setWord() " {{{
  let l:obj = s:Content.new()
  call l:obj.word('Test') " Курсор на начале слова
  call setpos('.', [bufnr('%'), 1, 1, 0])
  call self.assertEquals(expand('<cword>'), 'Test')
  call setpos('.', [bufnr('%'), 1, 2, 0])
  call l:obj.word('Lorem') " Курсор в слове
  call self.assertEquals(expand('<cword>'), 'Lorem')
  call setpos('.', [bufnr('%'), 1, 5, 0])
  call l:obj.word('Test') " Курсор в конце слова
  call self.assertEquals(expand('<cword>'), 'Test')
endfunction " }}}

"" {{{
" Должен возвращать текущее СЛОВО.
" @covers vim_lib#sys#Content#.WORD
"" }}}
function! s:Test.testWORD_getWord() " {{{
  let l:obj = s:Content.new()
  call self.assertEquals(l:obj.WORD(), 'Lorem')
  call setpos('.', [bufnr('%'), 1, 2, 0])
  call self.assertEquals(l:obj.WORD(), 'Lorem')
  call setpos('.', [bufnr('%'), 1, 5, 0])
  call self.assertEquals(l:obj.WORD(), 'Lorem')
endfunction " }}}

"" {{{
" Должен устанавливать текущее СЛОВО.
" @covers vim_lib#sys#Content#.WORD
"" }}}
function! s:Test.testWORD_setWord() " {{{
  let l:obj = s:Content.new()
  call l:obj.WORD('Test') " Курсор на начале слова
  call self.assertEquals(expand('<cWORD>'), 'Test')
  call setpos('.', [bufnr('%'), 1, 2, 0])
  call l:obj.WORD('Lorem') " Курсор в слове
  call self.assertEquals(expand('<cWORD>'), 'Lorem')
  call setpos('.', [bufnr('%'), 1, 5, 0])
  call l:obj.WORD('Test') " Курсор в конце слова
  call self.assertEquals(expand('<cWORD>'), 'Test')
endfunction " }}}
" }}}
" rewrite {{{
"" {{{
" Должен перезаписывать содержимое буфера.
" @covers vim_lib#sys#Content#.rewrite
"" }}}
function! s:Test.testRewrite() " {{{
  let l:obj = s:Content.new()
  call l:obj.rewrite('Hello')
  call self.assertEquals(l:obj.line(1), 'Hello')
endfunction " }}}
" }}}
" isEmpty {{{
"" {{{
" Должен возвращать 1, когда буфер пуст, иначе - 0.
" @covers vim_lib#sys#Content#.isEmpty
"" }}}
function! s:Test.testIsEmpty() " {{{
  let l:obj = s:Content.new()
  call self.assertFalse(l:obj.isEmpty())
  call l:obj.rewrite('')
  call self.assertTrue(l:obj.isEmpty())
endfunction " }}}
" }}}
" countLine {{{
"" {{{
" Должен определять число строк в текущем буфере.
" @covers vim_lib#sys#Content#.countLine
"" }}}
function! s:Test.testCountLine() " {{{
  let l:obj = s:Content.new()
  call self.assertEquals(l:obj.countLine(), 2)
endfunction " }}}
" }}}

let g:vim_lib#base#tests#TestContent# = s:Test
call s:Test.run()
