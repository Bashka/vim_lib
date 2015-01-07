" Date Create: 2015-01-07 16:18:33
" Last Change: 2015-01-07 18:23:25
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Object = g:vim_lib#base#Object#

let s:Buffer = s:Object.expand()

"" {{{
" Конструктор создает объектное представление буфера.
" @param integer number Номер целевого буфера. Если параметр не задан, создается новый буфер.
" @throws IndexOutOfRangeException Выбрасывается при обращении к отсутствующему буферу.
" @return vim_lib#base#Buffer# Целевой буфер.
"" }}}
function! s:Buffer.new(...) " {{{
  let l:obj = self.bless()
  if exists('a:1')
    " Обращение к существующему буферу. {{{
    if !bufexists(a:1)
      throw 'IndexOutOfRangeException: Buffer <' . a:1 . '> not found.'
    endif
    let l:obj.number = a:1
    " }}}
  else
    " Создание нового буфера. {{{
    let l:obj.number = bufnr(bufnr('$') + 1, 1)
    " }}}
  endif
  return l:obj
endfunction " }}}

"" {{{
" Метод возвращает номер вызываемого буфера.
" @return integer Номер буфера.
"" }}}
function! s:Buffer.getNum() " {{{
  return self.number
endfunction " }}}

"" {{{
" Метод удаляет вызываемый буфер.
"" }}}
function! s:Buffer.delete() " {{{
  exe 'bw! ' . self.getNum()
endfunction " }}}

"" {{{
" Метод деталет вызываемый буфер активным в текущем окне.
"" }}}
function! s:Buffer.active() " {{{
  exe 'buffer ' . self.number
endfunction " }}}

"" {{{
" Метод открывает новое окно по горизонтали и делает вызываемый буфер активным в нем.
"" }}}
function! s:Buffer.gactive() " {{{
  new
  let l:newBufNum = bufnr('%')
  call self.active()
  exe 'bw! ' . l:newBufNum
endfunction " }}}

"" {{{
" Метод открывает новое окно по вертикали и делает вызываемый буфер активным в нем.
"" }}}
function! s:Buffer.vactive() " {{{
  vnew
  let l:newBufNum = bufnr('%')
  call self.active()
  exe 'bw! ' . l:newBufNum
endfunction " }}}

let g:vim_lib#base#Buffer# = s:Buffer
