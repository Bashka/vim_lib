" Date Create: 2015-02-02 17:00:19
" Last Change: 2015-02-06 23:36:03
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Object = g:vim_lib#base#Object#

"" {{{
" Данная примесь добавляет классу механизм обработки событий.
"" }}}
let s:Class = s:Object.expand()

let s:Class.properties = {}
"" {{{
" @var hash Словарь обработчиков событий, имеющий следующую структуру: {событие: [обработчик, ...], ...}.
"" }}}
let s:Class.properties.listeners = {}

"" {{{
" Метод добавляет обработчик события.
" В качестве обработчика события должен выступать метод вызываемого объекта или ссылка на глобальную функцию.
" Позволяется устанавливать несколько обработчиков одного события. В случае наступления события, они будут вызваны в порядке их добавления.
" @param string event Событие.
" @param string|function listener Имя метода-обработчика события или ссылка на функцию-обработчик события.
"" }}}
function! s:Class.listen(event, listener) " {{{
  if !has_key(self.listeners, a:event)
    let self.listeners[a:event] = []
  endif
  call add(self.listeners[a:event], a:listener)
endfunction " }}}

"" {{{
" Метод исполняет обработчики данного события.
" @param string event Имя эмулируемого события.
"" }}}
function! s:Class.fire(event) " {{{
  if has_key(self.listeners, a:event)
    for l:Listener in self.listeners[a:event]
      if type(l:Listener) == 2
        call call(l:Listener, [])
      else
        call call(self[l:Listener], [], self)
      endif
    endfor
  endif
endfunction " }}}

"" {{{
" Метод удаляет обработчик события.
" @param string event Имя целевого события.
" @param string|function listener [optional] Имя метода-обработчика события или ссылка на функцию-обработчик. Если параметр не задан, удаляются все обработчики данного события.
"" }}}
function! s:Class.ignore(event, ...) " {{{
  if !exists('a:1')
    let self.listeners[a:event] = []
  else
    let l:pos = index(self.listeners[a:event], a:1)
    while l:pos != -1
      call remove(self.listeners[a:event], l:pos)
      let l:pos = index(self.listeners[a:event], a:1)
    endwhile
  endif
endfunction " }}}

let g:vim_lib#base#EventHandle# = s:Class
