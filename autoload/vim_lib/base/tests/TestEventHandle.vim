" Date Create: 2015-02-02 17:06:46
" Last Change: 2015-02-02 17:37:52
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Test = vim_lib#base#Test#.expand()
let s:Mock = vim_lib#base#tests#EventHandle#Mock#

" listen {{{
"" {{{
" Должен сохранять слушателя в словарь обработчиков событий.
" @covers vim_lib#base#EventHandle#.listen
"" }}}
function! s:Test.testListen_saveListener() " {{{
  let l:obj = s:Mock.new()
  call l:obj.listen('event', 'listener')
  call self.assertEquals(l:obj.listeners['event'][0], 'listener')
endfunction " }}}

"" {{{
" Должен сохранять множество слушателей одного события.
" @covers vim_lib#base#EventHandle#.listen
"" }}}
function! s:Test.testListen_saveListeners() " {{{
  let l:obj = s:Mock.new()
  call l:obj.listen('event', 'listener1')
  call l:obj.listen('event', 'listener2')
  call l:obj.listen('event', 'listener3')
  call self.assertEquals(l:obj.listeners['event'][0], 'listener1')
  call self.assertEquals(l:obj.listeners['event'][1], 'listener2')
  call self.assertEquals(l:obj.listeners['event'][2], 'listener3')
endfunction " }}}
" }}}
" fire {{{
"" {{{
" Должен запускать функции-обработчики событий.
" @covers vim_lib#base#EventHandle#.fire
"" }}}
function! s:Test.testFire_runListeners() " {{{
  let l:obj = s:Mock.new()
  let l:obj.x = 0
  function! l:obj.listener(...) " {{{
    let self.x += 1
  endfunction " }}}
  call l:obj.listen('event', 'listener')
  call l:obj.listen('event', 'listener')
  call l:obj.fire('event')
  call self.assertEquals(l:obj.x, 2)
endfunction " }}}
" }}}
" ignore {{{
"" {{{
" Должен удалять все обработчики данного события.
" @covers vim_lib#base#EventHandle#.ignore
"" }}}
function! s:Test.testIgnore_ignoreEvent() " {{{
  let l:obj = s:Mock.new()
  call l:obj.listen('event', 'listener')
  call l:obj.listen('event', 'listener')
  call l:obj.listen('otherEvent', 'listener')
  call l:obj.ignore('event')
  call self.assertEquals(l:obj.listeners.event, [])
  call self.assertEquals(l:obj.listeners.otherEvent, ['listener'])
endfunction " }}}

"" {{{
" Должен удалять обработчики с заданым именем.
" @covers vim_lib#base#EventHandle#.ignore
"" }}}
function! s:Test.testIgnore_ignoreListener() " {{{
  let l:obj = s:Mock.new()
  call l:obj.listen('event', 'listenerA')
  call l:obj.listen('event', 'listenerA')
  call l:obj.listen('event', 'listenerB')
  call l:obj.listen('event', 'listenerB')
  call l:obj.ignore('event', 'listenerA')
  call self.assertEquals(l:obj.listeners.event, ['listenerB', 'listenerB'])
endfunction " }}}
" }}}

let g:vim_lib#base#tests#TestEventHandle# = s:Test
call s:Test.run()
