" Date Create: 2015-01-16 19:26:08
" Last Change: 2015-01-22 11:15:28
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Object = g:vim_lib#base#Object#

"" {{{
" Данный класс представляет модель событий редактора. Класс позволяет компонентам редактора и плагинам подписываться на определенные события с целью последующего реагирования на их возникновение.
"" }}}
let s:Class = s:Object.expand()

"" {{{
" Конструктор всегда возвращает единственный экземпляр данного класса.
" @return vim_lib#sys#Publisher# Модель событий.
"" }}}
function! s:Class.new() " {{{
  return self.singleton
endfunction " }}}

"" {{{
" Метод вызывает все обработчики данного события.
" @param string eventName Имя целевого события.
" @param hash event [optional] Объект события, передаваемый обработчику в качестве единственного параметра. Данный объект дополняется свойством name, хранящим имя события.
"" }}}
function! s:Class.fire(eventName, ...) " {{{
  let l:event = (exists('a:1'))? a:1 : {}
  let l:event.name = a:eventName
  if has_key(self.listeners, a:eventName)
    for l:Listener in self.listeners[a:eventName]
      call call(l:Listener, [l:event])
    endfor
  endif
endfunction " }}}

"" {{{
" Метод добавляет слушателя события.
" @param string eventName Имя целевого события.
" @param function listener Функция-обработчик события.
"" }}}
function! s:Class.listen(eventName, listener) " {{{
  if !has_key(self.listeners, a:eventName)
    let self.listeners[a:eventName] = []
  endif
  call add(self.listeners[a:eventName], a:listener)
endfunction " }}}

"" {{{
" Метод удаляет слушателя события.
" @param string eventName Имя целевого события.
" @param function listener [optional] Удаляемая функция-обработчик. Если параметр не передан, удаляются все обработчики целевого события.
"" }}}
function! s:Class.ignore(eventName, ...) " {{{
  if exists('a:1')
    if has_key(self.listeners, a:eventName)
      let l:i = index(self.listeners[a:eventName], a:1)
      if l:i != -1
        call remove(self.listeners[a:eventName], l:i)
      endif
    endif
  else
    if has_key(self.listeners, a:eventName)
      call remove(self.listeners, a:eventName)
    endif
  endif
endfunction " }}}

"" {{{
" @var vim_lib#sys#Publisher# Единственный экземпляр класса.
"" }}}
let s:Class.singleton = s:Class.bless()
"" {{{
" @var hash Словарь слушателей, имеющий следующую структуру: {имяСобытия: [слушатель, ...], ...}
"" }}}
let s:Class.singleton.listeners = {}

let g:vim_lib#sys#Publisher# = s:Class
