" Date Create: 2015-01-07 16:18:33
" Last Change: 2015-01-08 12:15:17
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Object = g:vim_lib#base#Object#

"" {{{
" Класс представляет буфер редактора.
"" }}}
let s:Buffer = s:Object.expand()
"" {{{
" @var hash Объектный пул, хранящий все экземпляры данного класса. Используется для исключения возможности создания двух объектов с одним номером буфера.
"" }}}
let s:Buffer.objectPool = {}

"" {{{
" Конструктор создает объектное представление буфера.
" @param integer number Номер целевого буфера. Если параметр не задан, создается новый буфер.
" @throws IndexOutOfRangeException Выбрасывается при обращении к отсутствующему буферу.
" @return vim_lib#base#Buffer# Целевой буфер.
"" }}}
function! s:Buffer.new(...) " {{{
  " Получение объекта из пула. {{{
  if exists('a:1') && has_key(g:vim_lib#base#Buffer#.objectPool, a:1)
    return g:vim_lib#base#Buffer#.objectPool[a:1]
  endif
  " }}}
  let l:obj = self.bless()
  "" {{{
  " @var integer Номер буфера.
  "" }}}
  let l:obj.number = 0
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
  "" {{{
  " @var hash Словарь опций, применяемых к буферу при его активации. Словарь имеет следующую структуру: [опция: значение, ...].
  "" }}}
  let l:obj.options = {}
  "" {{{
  " @var hash Словарь привязок, применяемых к буферу при его активации. Словарь имеет следующую структуру: [режим: [комбинация: метод], ...].
  "" }}}
  let l:obj.listeners = {}
  let l:obj.class.objectPool[l:obj.getNum()] = l:obj
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
  call remove(self.class.objectPool, self.getNum())
endfunction " }}}

"" {{{
" Данный метод отвечает за установку опций и обработчиков событий при активации буфера.
"" }}}
function! s:Buffer._setOptions() " {{{
  " Слушатели. {{{
  for l:mode in keys(self.listeners)
    for [l:sequence, l:listener] in items(self.listeners[l:mode])
      " Завершающий команду вывод пустой строки позволяет отчистить статусбар.
      exe l:mode . 'noremap <buffer> ' . l:sequence . ' :call vim_lib#base#Buffer#.new(bufnr("%")).' . l:listener . '()<CR>:echo ""<CR>'
    endfor
  endfor
  " }}}
  " Опции. {{{
  for [l:option, l:value] in items(self.options)
    exe 'let &l:' . l:option . ' = "' . l:value . '"'
  endfor
  " }}}
endfunction " }}}

"" {{{
" Метод деталет вызываемый буфер активным в текущем окне.
"" }}}
function! s:Buffer.active() " {{{
  exe 'buffer ' . self.number
  cal self._setOptions()
endfunction " }}}

"" {{{
" Метод открывает новое окно по горизонтали и делает вызываемый буфер активным в нем.
"" }}}
function! s:Buffer.gactive() " {{{
  silent! new
  let l:newBufNum = bufnr('%')
  call self.active()
  exe 'bw! ' . l:newBufNum
endfunction " }}}

"" {{{
" Метод открывает новое окно по вертикали и делает вызываемый буфер активным в нем.
"" }}}
function! s:Buffer.vactive() " {{{
  silent! vnew
  let l:newBufNum = bufnr('%')
  call self.active()
  exe 'bw! ' . l:newBufNum
endfunction " }}}

"" {{{
" Метод определяет локальную опцию буферу.
" Данное значение будет установлено для опции при каждой активации буфера методом active, gactive или vactive.
" @param string name Имя целевой опции.
" @param string value Устанавливаемое значение.
"" }}}
function! s:Buffer.option(name, value) " {{{
  let self.options[a:name] = a:value
endfunction " }}}

"" {{{
" Метод определяет функцию-обработчик (слушатель) для события клавиатуры.
" Слушатель должен быть методом данного буфера.
" @param string mode Режим привязки. Возможно одно из следующих значений: n, v, o, i, l, c.
" @param string sequence Комбинация клавишь, для которой создается привязка.
" @param string listener Имя метода вызываемого буфера, используемого в качестве функции-обработчика.
"" }}}
function! s:Buffer.listen(mode, sequence, listener) " {{{
  if !has_key(self.listeners, a:mode)                                                                                                                  
    let self.listeners[a:mode] = {}
  endif
  let self.listeners[a:mode][a:sequence] = a:listener
endfunction " }}}

"" {{{
" Метод удаляет функции-обработчики (слушатели) для события клавиатуры.
" @param string mode Режим привязки. Возможно одно из следующих значений: n, v, o, i, l, c.
" @param string sequence Комбинация клавишь, для которой удаляется привязка.
"" }}}
function! s:Buffer.ignore(mode, sequence) " {{{
  if has_key(self.listeners, a:mode)
    if has_key(self.listeners[a:mode], a:sequence) 
      call remove(self.listeners[a:mode], a:sequence)
    endif
  endif
endfunction " }}}

let g:vim_lib#base#Buffer# = s:Buffer
