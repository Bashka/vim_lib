" Date Create: 2015-01-07 15:58:24
" Last Change: 2015-02-09 14:55:07
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Buffer = vim_lib#sys#Buffer#

let s:Test = vim_lib#base#Test#.expand()

" new, current {{{
"" {{{
" Должен запоминать заданный номер буфера.
" @covers vim_lib#sys#Buffer#.new
"" }}}
function s:Test.testNew_saveNum() " {{{
  let l:obj = s:Buffer.new(bufnr('%'))
  call self.assertEquals(l:obj.getNum(), bufnr('%'))
endfunction " }}}

"" {{{
" Должен выбрасывать исключение в случае, если требуемого буфера не сущесвует.
" @covers vim_lib#sys#Buffer#.new
"" }}}
function s:Test.testNew_throwOutOfRange() " {{{
  try
    let l:obj = s:Buffer.new(bufnr('$') + 1)
    call self.fail('testNew_throwOutOfRange', 'Expected exception <IndexOutOfRangeException> is not thrown.')
  catch /IndexOutOfRangeException:.*/
  endtry
endfunction " }}}

"" {{{
" Если параметр не указан, должен создавать новый, анонимный буфер.
" @covers vim_lib#sys#Buffer#.new
"" }}}
function s:Test.testNew_createBuffer() " {{{
  let l:bufCount = bufnr('$')
  let l:obj = s:Buffer.new()
  call self.assertTrue(bufnr('$') > l:bufCount)
  exe 'bw! ' . l:obj.getNum()
endfunction " }}}

"" {{{
" Если параметр текстовый, должен создавать новый, именованный буфер.
" @covers vim_lib#sys#Buffer#.new
"" }}}
function! s:Test.testNew_createBufferOnName() " {{{
  let l:bufCount = bufnr('$')
  let l:obj = s:Buffer.new('#TestBuffer#')
  call self.assertTrue(bufnr('$') > l:bufCount)
  exe 'bw! ' . l:obj.getNum()
endfunction " }}}

"" {{{
" Если параметр текстовый и буфер с таким именем уже существует, должен возвращать его.
" @covers vim_lib#sys#Buffer#.new
"" }}}
function! s:Test.testNew_returtNamedBuffer() " {{{
  let l:objA = s:Buffer.new('#TestBuffer#')
  let l:objB = s:Buffer.new('#TestBuffer#')
  call self.assertEquals(l:objA.getNum(), l:objB.getNum())
  exe 'bw! ' . l:objA.getNum()
endfunction " }}}

"" {{{
" Должен сохранять и восстанавливать объекты из пула.
" @covers vim_lib#sys#Buffer#.new
"" }}}
function s:Test.testNew_usePool() " {{{
  let l:obj = s:Buffer.new()
  let l:obj.test = 1
  let l:obj2 = s:Buffer.new(l:obj.getNum())
  call self.assertEquals(l:obj.test, l:obj2.test)
  exe 'bw! ' . l:obj.getNum()
endfunction " }}}

"" {{{
" Должен создавать объект текущего буфера.
" @covers vim_lib#sys#Buffer#.current
"" }}}
function! s:Test.testCurrent() " {{{
  let l:obj = s:Buffer.current()
  call self.assertEquals(l:obj.getNum(), bufnr('%'))
endfunction " }}}
" }}}
" getNum {{{
"" {{{
" Должен возвращать номер буфера.
" @covers vim_lib#sys#Buffer#.getNum
"" }}}
function s:Test.testGetNum() " {{{
  let l:obj = s:Buffer.new(bufnr('%'))
  call self.assertEquals(l:obj.getNum(), bufnr('%'))
endfunction " }}}
" }}}
" delete {{{
"" {{{
" Должен удалять буфер.
" @covers vim_lib#sys#Buffer#.delete
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
" @covers vim_lib#sys#Buffer#.active
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
" @covers vim_lib#sys#Buffer#.gactive
"" }}}
function s:Test.testGactive_openNewHorizontalWin() " {{{
  let l:winCount = winnr('$')
  let l:obj = s:Buffer.new()
  call l:obj.gactive('t')
  call self.assertTrue(winnr('$') > l:winCount)
  exe 'q'
endfunction " }}}

"" {{{
" Должен автоматически удалять временный буфер, создаваемый при открытии нового окна.
" @covers vim_lib#sys#Buffer#.gactive
"" }}}
function s:Test.testGactive_delTmpBuffer() " {{{
  let l:bufCount = bufnr('$')
  let l:obj = s:Buffer.new(bufnr('%'))
  call l:obj.gactive('t')
  call self.assertTrue(bufnr('$') == l:bufCount)
  exe 'q'
endfunction " }}}

"" {{{
" Должен устанавливать высоту нового окна.
" @covers vim_lib#sys#Buffer#.gactive
"" }}}
function! s:Test.testGactive_resize() " {{{
  let l:winCount = winnr('$')
  let l:obj = s:Buffer.new(bufnr('%'))
  call l:obj.gactive('t', 20)
  call self.assertEquals(winheight(0), 20)
  exe 'q'
endfunction " }}}

"" {{{
" Должен делать вызываемый буфер активным в новом, вертикальном окне.
" @covers vim_lib#sys#Buffer#.vactive
"" }}}
function s:Test.testVactive_openNewVerticalWin() " {{{
  let l:winCount = winnr('$')
  let l:obj = s:Buffer.new()
  call l:obj.vactive('l')
  call self.assertTrue(winnr('$') > l:winCount)
  exe 'q'
endfunction " }}}

"" {{{
" Должен автоматически удалять временный буфер, создаваемый при открытии нового окна.
" @covers vim_lib#sys#Buffer#.vactive
"" }}}
function s:Test.testVactive_delTmpBuffer() " {{{
  let l:bufCount = bufnr('$')
  let l:obj = s:Buffer.new(bufnr('%'))
  call l:obj.vactive('l')
  call self.assertTrue(bufnr('$') == l:bufCount)
  exe 'q'
endfunction " }}}

"" {{{
" Должен устанавливать ширину нового окна.
" @covers vim_lib#sys#Buffer#.vactive
"" }}}
function! s:Test.testVactive_resize() " {{{
  let l:winCount = winnr('$')
  let l:obj = s:Buffer.new(bufnr('%'))
  call l:obj.vactive('l', 20)
  call self.assertEquals(winwidth(0), 20)
  exe 'q'
endfunction " }}}
" }}}
" option, temp {{{
"" {{{
" Должен делать вызываемый буфер активным в текущем окне.
" @covers vim_lib#sys#Buffer#.option
"" }}}
function s:Test.testOption() " {{{
  let l:currentBuf = s:Buffer.new(bufnr('%'))
  let l:obj = s:Buffer.new()
  call l:obj.option('filetype', 'test')
  call l:obj.gactive('t')
  call self.assertEquals(&l:filetype, 'test') " Опции устанавливаются после активации в новом окне.
  call l:currentBuf.active()
  call l:obj.active()
  call self.assertEquals(&l:filetype, 'test') " Опции устанавливаются после активации в текущем окне.
  call l:obj.delete()
endfunction " }}}

"" {{{
" Должен устанавливать опцию buftype в значение nofile.
" @covers vim_lib#sys#Buffer#.temp
"" }}}
function! s:Test.testTemp() " {{{
  let l:currentBuf = s:Buffer.new(bufnr('%'))
  let l:obj = s:Buffer.new()
  call l:obj.temp()
  call l:obj.gactive('t')
  call self.assertEquals(&l:buftype, 'nofile')
  call l:obj.delete()
endfunction " }}}
" }}}
" map, ignoreMap, fire {{{
"" {{{
" Должен устанавливать привязку при активации буфера.
" @covers vim_lib#sys#Buffer#.map
"" }}}
function s:Test.testMap_setListener() " {{{
  let l:obj = s:Buffer.new()
  call l:obj.map('n', 'q', 'testA')
  call l:obj.map('n', 'q', 'testB')
  call self.assertEquals(l:obj.listenerMap, {'nq': 'nnoremap <silent> <buffer> q :call vim_lib#sys#Buffer#.current().fire("n", "q")<CR>'})
  call self.assertEquals(l:obj.listeners, {'keyPress_nq': ['testA', 'testB']})
  call l:obj.gactive('t')
  call self.assertExec('nnoremap <silent> <buffer> q', "\n\n" . 'n  q           *@:call vim_lib#sys#Buffer#.current().fire("n", "q")<CR>')
  call l:obj.delete()
endfunction " }}}

"" {{{
" Должен удалять конкретный обработчик.
" @covers vim_lib#sys#Buffer#.ignoreMap
"" }}}
function s:Test.testIgnoreMap_deleteListener() " {{{
  let l:obj = s:Buffer.new()
  call l:obj.map('n', 'q', 'testA')
  call l:obj.map('n', 'q', 'testA')
  call l:obj.map('n', 'q', 'testB')
  call l:obj.map('n', 'q', 'testB')
  call l:obj.ignoreMap('n', 'q', 'testA')
  call self.assertDictHasKey(l:obj.listenerMap, 'nq')
  call self.assertEquals(l:obj.listeners, {'keyPress_nq': ['testB', 'testB']})
endfunction " }}}

"" {{{
" Должен удалять все привязки.
" @covers vim_lib#sys#Buffer#.ignoreMap
"" }}}
function s:Test.testIgnoreMap_deleteAllListeners() " {{{
  let l:obj = s:Buffer.new()
  call l:obj.map('n', 'q', 'test')
  call l:obj.ignoreMap('n', 'q')
  call self.assertDictNotHasKey(l:obj.listenerMap, 'nq')
  call l:obj.gactive('t')
  call self.assertExec('nnoremap <buffer> nq', "\n\n" . 'Привязки не найдены')
  call l:obj.delete()
endfunction " }}}

"" {{{
" Должен генерировать события.
" @covers vim_lib#sys#Buffer#.fire
"" }}}
function! s:Test.testFire() " {{{
  let l:obj = s:Buffer.new()
  let l:obj.x = 0
  function! l:obj.inc(...) " {{{
    let self.x += 1
  endfunction " }}}
  call l:obj.map('n', 'q', 'inc')
  call l:obj.map('n', 'q', 'inc')
  call l:obj.gactive('t')
  call l:obj.fire('n', 'q')
  call self.assertEquals(l:obj.x, 2)
  call l:obj.delete()
endfunction " }}}
" }}}
" au, ignoreAu, doau {{{
"" {{{
" Должен устанавливать привязку при активации буфера.
" @covers vim_lib#sys#Buffer#.au
"" }}}
function s:Test.testAu_setListener() " {{{
  let l:obj = s:Buffer.new()
  call l:obj.au('BufEnter', 'testA')
  call l:obj.au('BufEnter', 'testB')
  call self.assertEquals(l:obj.listenerAu, {'BufEnter': 'au BufEnter ' . bufname(l:obj.getNum()) . ' :call vim_lib#sys#Buffer#.current().doau("BufEnter")'})
  call self.assertEquals(l:obj.listeners, {'autocmd_BufEnter': ['testA', 'testB']})
  call l:obj.gactive('t')
  call self.assertExec('autocmd BufEnter ' . bufname(l:obj.getNum()), "\n" . '--- Автокоманды ---' . "\n" . 'BufEnter' . "\n" . '    ' . bufname(l:obj.getNum()) . '        :call vim_lib#sys#Buffer#.current().doau("BufEnter")')
  call l:obj.delete()
endfunction " }}}

"" {{{
" Должен удалять конкретный обработчик.
" @covers vim_lib#sys#Buffer#.ignoreAu
"" }}}
function s:Test.testIgnoreAu_deleteListener() " {{{
  let l:obj = s:Buffer.new()
  call l:obj.au('BufEnter', 'testA')
  call l:obj.au('BufEnter', 'testA')
  call l:obj.au('BufEnter', 'testB')
  call l:obj.au('BufEnter', 'testB')
  call l:obj.ignoreAu('BufEnter', 'testA')
  call self.assertDictHasKey(l:obj.listenerAu, 'BufEnter')
  call self.assertEquals(l:obj.listeners, {'autocmd_BufEnter': ['testB', 'testB']})
endfunction " }}}

"" {{{
" Должен удалять все привязки.
" @covers vim_lib#sys#Buffer#.ignoreAu
"" }}}
function s:Test.testIgnoreAu_deleteAllListeners() " {{{
  let l:obj = s:Buffer.new()
  call l:obj.au('BufEnter', 'test')
  call l:obj.ignoreAu('BufEnter')
  call self.assertDictNotHasKey(l:obj.listenerAu, 'BufEnter')
  call l:obj.gactive('t')
  call self.assertExec('autocmd BufEnter ' . bufname(l:obj.getNum()), "\n" . '--- Автокоманды ---')
  call l:obj.delete()
endfunction " }}}

"" {{{
" Должен генерировать события.
" @covers vim_lib#sys#Buffer#.doau
"" }}}
function! s:Test.testDoau() " {{{
  let l:obj = s:Buffer.new()
  let l:obj.x = 0
  function! l:obj.inc(...) " {{{
    let self.x += 1
  endfunction " }}}
  call l:obj.au('BufEnter', 'inc')
  call l:obj.au('BufEnter', 'inc')
  call l:obj.gactive('t')
  call l:obj.doau('BufEnter')
  call self.assertEquals(l:obj.x, 2)
  call l:obj.delete()
endfunction " }}}
" }}}
" render {{{
"" {{{
" Должен добавлять содержимое буфера из строки.
" @covers vim_lib#sys#Buffer#.render
"" }}}
function! s:Test.testRender_setStr() " {{{
  let l:obj = s:Buffer.new()
  call l:obj.option('buftype', 'nofile')
  let l:obj.render = "'test'"
  call l:obj.gactive('t')
  call self.assertEquals('test', join(getline(0, '$'), ''))
  call l:obj.delete()
endfunction " }}}

"" {{{
" Должен добавлять содержимое буфера из метода.
" @covers vim_lib#sys#Buffer#.render
"" }}}
function! s:Test.testRender_setMethod() " {{{
  let l:obj = s:Buffer.new()
  call l:obj.option('buftype', 'nofile')
  function! l:obj.render() " {{{
    return 'test'
  endfunction " }}}
  call l:obj.gactive('t')
  call self.assertEquals('test', join(getline(0, '$'), ''))
  call l:obj.delete()
endfunction " }}}
" }}}
" select {{{
"" {{{
" Должен делать окно буфера активным.
" @covers vim_lib#sys#Buffer#.select
"" }}}
function! s:Test.testSelect() " {{{
  let l:obj = s:Buffer.new()
  call l:obj.gactive('t')
  exe winnr('#') . 'wincmd w'
  call l:obj.select()
  call self.assertEquals(bufwinnr(l:obj.getNum()), winnr())
  call l:obj.delete()
endfunction " }}}

"" {{{
" Должен выбрасывать исключение, если буфер не активен.
" @covers vim_lib#sys#Buffer#.select
"" }}}
function! s:Test.testSelect_throwException() " {{{
  let l:obj = s:Buffer.new()
  try
    call l:obj.select()
    call self.fail('testSelect_throwException', 'Expected exception <RuntimeException> is not thrown.')
  catch /RuntimeException:.*/
  endtry
endfunction " }}}
" }}}
" getWinNum {{{
"" {{{
" Должен возвращать номер окна, в котором активен буфер.
" @covers vim_lib#sys#Buffer#.getWinNum
"" }}}
function! s:Test.testGetWinNum() " {{{
  let l:obj = s:Buffer.new()
  call l:obj.gactive('t')
  call self.assertEquals(l:obj.getWinNum(), bufwinnr(l:obj.getNum()))
  call l:obj.delete()
endfunction " }}}

"" {{{
" Должен возвращать -1, если буфер не активен.
" @covers vim_lib#sys#Buffer#.getWinNum
"" }}}
function! s:Test.testGetWinNum_returnNegative() " {{{
  let l:obj = s:Buffer.new()
  call self.assertEquals(l:obj.getWinNum(), -1)
  call l:obj.delete()
endfunction " }}}
" }}}

let g:vim_lib#base#tests#TestBuffer# = s:Test
call s:Test.run()
