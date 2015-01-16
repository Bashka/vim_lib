" Date Create: 2015-01-16 19:34:14
" Last Change: 2015-01-16 20:47:17
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Publisher = vim_lib#sys#Publisher#

let s:Test = vim_lib#base#Test#.expand()

function! s:Test.beforeTest() " {{{
  let self.var = 0
endfunction " }}}

function! s:Test.afterTest() " {{{
  call s:Publisher.new().ignore('TestEvent')
endfunction " }}}

" listeners {{{
function! g:ListenerInc(event) " {{{
  let g:vim_lib#base#tests#TestPublisher#.var += 1
endfunction " }}}
function! g:ListenerDec(event) " {{{
  let g:vim_lib#base#tests#TestPublisher#.var -= 1
endfunction " }}}
function! g:ListenerPlus(event) " {{{
  let g:vim_lib#base#tests#TestPublisher#.var += a:event.var
endfunction " }}}
" }}}

" listen {{{
"" {{{
" Должен добавлять слушателя.
" @covers vim_lib#base#Publisher#.listen
"" }}}
function! s:Test.testListen_addListener() " {{{
  let s:obj = s:Publisher.new()
  call s:obj.listen('TestEvent', function('g:ListenerInc'))
  call s:obj.listen('TestEvent', function('g:ListenerDec'))
  call self.assertEquals(s:obj.listeners, {'TestEvent': [function('g:ListenerInc'), function('g:ListenerDec')]})
endfunction " }}}

"" {{{
" Разрешено дублирование.
" @covers vim_lib#base#Publisher#.listen
"" }}}
function! s:Test.testListen_repeat() " {{{
  let s:obj = s:Publisher.new()
  call s:obj.listen('TestEvent', function('g:ListenerInc'))
  call s:obj.listen('TestEvent', function('g:ListenerInc'))
  call self.assertEquals(s:obj.listeners, {'TestEvent': [function('g:ListenerInc'), function('g:ListenerInc')]})
endfunction " }}}
" }}}
" ignore {{{
"" {{{
" Должен удалять данного слушателя.
" @covers vim_lib#base#Publisher#.ignore
"" }}}
function! s:Test.testIgnore_deleteListener() " {{{
  let s:obj = s:Publisher.new()
  call s:obj.listen('TestEvent', function('g:ListenerInc'))
  call s:obj.listen('TestEvent', function('g:ListenerDec'))
  call s:obj.ignore('TestEvent', function('g:ListenerInc'))
  call self.assertEquals(s:obj.listeners, {'TestEvent': [function('g:ListenerDec')]})
endfunction " }}}

"" {{{
" Должен удалять всех слушателей данного события.
" @covers vim_lib#base#Publisher#.ignore
"" }}}
function! s:Test.testIgnore_deleteEvent() " {{{
  let s:obj = s:Publisher.new()
  call s:obj.listen('TestEvent', function('g:ListenerInc'))
  call s:obj.listen('TestEvent', function('g:ListenerDec'))
  call s:obj.ignore('TestEvent')
  call self.assertEquals(s:obj.listeners, {})
endfunction " }}}
" }}}
" fire {{{
"" {{{
" Должен информировать слушателей о наступлении события.
" @covers vim_lib#base#Publisher#.fire
"" }}}
function! s:Test.testFire_callListeners() " {{{
  let s:obj = s:Publisher.new()
  call s:obj.listen('TestEvent', function('g:ListenerInc'))
  call s:obj.fire('TestEvent')
  call self.assertEquals(self.var, 1)
  call s:obj.listen('TestEvent', function('g:ListenerDec'))
  call s:obj.listen('TestEvent', function('g:ListenerDec'))
  call s:obj.listen('TestEvent', function('g:ListenerDec'))
  call s:obj.fire('TestEvent')
  call self.assertEquals(self.var, -1)
endfunction " }}}

"" {{{
" Должен передавать слушателю объект события.
" @covers vim_lib#base#Publisher#.fire
"" }}}
function! s:Test.testFire_giveEvent() " {{{
  let s:obj = s:Publisher.new()
  call s:obj.listen('TestEvent', function('g:ListenerPlus'))
  call s:obj.fire('TestEvent', {'var': 5})
  call self.assertEquals(self.var, 5)
endfunction " }}}
" }}}

let g:vim_lib#base#tests#TestPublisher# = s:Test
call s:Test.run()
