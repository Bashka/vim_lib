" Date Create: 2015-01-07 15:58:24
" Last Change: 2015-01-08 23:08:22
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Buffer = vim_lib#base#Buffer#

let s:Test = deepcopy(vim_lib#base#Test#)

" new {{{
"" {{{
" Должен запоминать заданный номер буфера.
" @covers vim_lib#base#Buffer#.new
"" }}}
function s:Test.testNew_saveNum() " {{{
  let l:obj = s:Buffer.new(bufnr('%'))
  call self.assertEquals(l:obj.getNum(), bufnr('%'))
endfunction " }}}

"" {{{
" Должен выбрасывать исключение в случае, если требуемого буфера не сущесвует.
" @covers vim_lib#base#Buffer#.new
"" }}}
function s:Test.testNew_throwOutOfRange() " {{{
  try
    let l:obj = s:Buffer.new(bufnr('$') + 1)
    call self.fail('testNew_throwOutOfRange', 'Expected exception <IndexOutOfRangeException> is not thrown.')
  catch /IndexOutOfRangeException:.*/
  endtry
endfunction " }}}

"" {{{
" Должен создавать новый пустой буфер.
" @covers vim_lib#base#Buffer#.new
"" }}}
function s:Test.testNew_createBuffer() " {{{
  let l:bufCount = bufnr('$')
  let l:obj = s:Buffer.new()
  call self.assertTrue(bufnr('$') > l:bufCount)
  exe 'bw! ' . l:obj.getNum()
endfunction " }}}

"" {{{
" Должен сохранять и восстанавливать объекты из пула.
" @covers vim_lib#base#Buffer#.new
"" }}}
function s:Test.testNew_usePool() " {{{
  let l:bufCount = bufnr('$')
  let l:obj = s:Buffer.new()
  let l:obj.test = 1
  let l:obj2 = s:Buffer.new(l:obj.getNum())
  call self.assertEquals(l:obj.test, l:obj2.test)
  exe 'bw! ' . l:obj.getNum()
endfunction " }}}
" }}}
" getNum {{{
"" {{{
" Должен возвращать номер буфера.
" @covers vim_lib#base#Buffer#.getNum
"" }}}
function s:Test.testGetNum() " {{{
  let l:obj = s:Buffer.new(bufnr('%'))
  call self.assertEquals(l:obj.getNum(), bufnr('%'))
endfunction " }}}
" }}}
" delete {{{
"" {{{
" Должен удалять буфер.
" @covers vim_lib#base#Buffer#.delete
"" }}}
function s:Test.testDelete() " {{{
  let l:bufCount = bufnr('$')
  let l:obj = s:Buffer.new()
  call l:obj.delete()
  call self.assertTrue(bufnr('$') == l:bufCount)
endfunction " }}}
" }}}
" active, gactive, vactive {{{
"" {{{
" Должен делать вызываемый буфер активным в текущем окне.
" @covers vim_lib#base#Buffer#.active
"" }}}
function s:Test.testActive() " {{{
  let l:obj = s:Buffer.new(bufnr('%'))
  new
  let l:newBuff = bufnr('%')
  call l:obj.active()
  call self.assertEquals(l:obj.getNum(), bufnr('%'))
  exe 'q'
  exe 'bw! ' . l:newBuff
endfunction " }}}

"" {{{
" Должен делать вызываемый буфер активным в новом, горизонтальном окне.
" @covers vim_lib#base#Buffer#.gactive
"" }}}
function s:Test.testGactive_openNewHorizontalWin() " {{{
  let l:winCount = winnr('$')
  let l:obj = s:Buffer.new(bufnr('%'))
  call l:obj.gactive()
  call self.assertTrue(winnr('$') > l:winCount)
  exe 'q'
endfunction " }}}

"" {{{
" Должен автоматически удалять временный буфер, создаваемый при открытии нового окна.
" @covers vim_lib#base#Buffer#.gactive
"" }}}
function s:Test.testGactive_delTmpBuffer() " {{{
  let l:bufCount = bufnr('$')
  let l:obj = s:Buffer.new(bufnr('%'))
  call l:obj.gactive()
  call self.assertTrue(bufnr('$') == l:bufCount)
  exe 'q'
endfunction " }}}

"" {{{
" Должен делать вызываемый буфер активным в новом, вертикальном окне.
" @covers vim_lib#base#Buffer#.vactive
"" }}}
function s:Test.testVactive_openNewVerticalWin() " {{{
  let l:winCount = winnr('$')
  let l:obj = s:Buffer.new(bufnr('%'))
  call l:obj.vactive()
  call self.assertTrue(winnr('$') > l:winCount)
  exe 'q'
endfunction " }}}

"" {{{
" Должен автоматически удалять временный буфер, создаваемый при открытии нового окна.
" @covers vim_lib#base#Buffer#.vactive
"" }}}
function s:Test.testVactive_delTmpBuffer() " {{{
  let l:bufCount = bufnr('$')
  let l:obj = s:Buffer.new(bufnr('%'))
  call l:obj.vactive()
  call self.assertTrue(bufnr('$') == l:bufCount)
  exe 'q'
endfunction " }}}
" }}}
" option {{{
"" {{{
" Должен делать вызываемый буфер активным в текущем окне.
" @covers vim_lib#base#Buffer#.option
"" }}}
function s:Test.testOption() " {{{
  let l:currentBuf = s:Buffer.new(bufnr('%'))
  let l:obj = s:Buffer.new()
  call l:obj.option('filetype', 'test')
  call l:obj.gactive()
  call self.assertEquals(&l:filetype, 'test') " Опции устанавливаются после активации в новом окне.
  call l:currentBuf.active()
  call l:obj.active()
  call self.assertEquals(&l:filetype, 'test') " Опции устанавливаются после активации в текущем окне.
  call l:obj.delete()
endfunction " }}}
" }}}
" listen, ignore {{{
"" {{{
" Должен устанавливать привязку при активации буфера.
" @covers vim_lib#base#Buffer#.listen
"" }}}
function s:Test.testListen() " {{{
  let l:obj = s:Buffer.new()
  call l:obj.listen('n', 'q', 'test')
  call self.assertEquals(l:obj.listeners, {'n': {'q': 'test'}})
  call l:obj.gactive()
  call self.assertExec('nnoremap q', "\n\n" . 'n  q           *@:call vim_lib#base#Buffer#.new(bufnr("%")).test()<CR>:echo ""<CR>')
  call l:obj.delete()
endfunction " }}}

"" {{{
" Должен удалять ранее созданную привязку.
" @covers vim_lib#base#Buffer#.ignore
"" }}}
function s:Test.testIgnore() " {{{
  let l:obj = s:Buffer.new()
  call l:obj.listen('n', 'q', 'test')
  call l:obj.ignore('n', 'q')
  call self.assertDictNotHasKey(l:obj.listeners['n'], 'q')
  call l:obj.gactive()
  call self.assertExec('nnoremap q', "\n\n" . 'Привязки не найдены')
  call l:obj.delete()
endfunction " }}}
" }}}
" render {{{
function! s:Test.testRender_setStr() " {{{
  let l:obj = s:Buffer.new()
  call l:obj.option('buftype', 'nofile')
  let l:obj.render = "'test'"
  call l:obj.gactive()
  call self.assertEquals('test', join(getline(0, '$'), ''))
  call l:obj.delete()
endfunction " }}}

function! s:Test.testRender_setMethod() " {{{
  let l:obj = s:Buffer.new()
  call l:obj.option('buftype', 'nofile')
  function! l:obj.render() " {{{
    return 'test'
  endfunction " }}}
  call l:obj.gactive()
  call self.assertEquals('test', join(getline(0, '$'), ''))
  call l:obj.delete()
endfunction " }}}
" }}}

let g:vim_lib#base#tests#TestBuffer# = s:Test
call s:Test.run()
