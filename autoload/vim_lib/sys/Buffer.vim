" Date Create: 2015-01-07 16:18:33
" Last Change: 2015-02-03 09:10:38
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Object = g:vim_lib#base#Object#
let s:EventHandle = g:vim_lib#base#EventHandle#

"" {{{
" Класс представляет буфер редактора.
"" }}}
let s:Class = s:Object.expand()
"" {{{
" @var hash Объектный пул, хранящий все экземпляры данного класса. Используется для исключения возможности создания двух объектов с одним номером буфера.
"" }}}
let s:Class.buffers = {}
call s:Class.mix(s:EventHandle)

"" {{{
" Конструктор создает объектное представление буфера.
" @param integer number Номер целевого буфера. Если параметр не задан, создается новый буфер.
" @throws IndexOutOfRangeException Выбрасывается при обращении к отсутствующему буферу.
" @return vim_lib#sys#Buffer# Целевой буфер.
"" }}}
function! s:Class.new(...) " {{{
  " Получение объекта из пула. {{{
  if exists('a:1') && has_key(self.buffers, a:1)
    return self.buffers[a:1]
  endif
  " }}}
  let l:obj = self.bless()
  "" {{{
  " @var integer Номер буфера.
  "" }}}
  let l:obj.number = 0
  if exists('a:1')
    if type(a:1) == 0
      " Обращение к существующему буферу. {{{
      if !bufexists(a:1)
        throw 'IndexOutOfRangeException: Buffer <' . a:1 . '> not found.'
      endif
      let l:obj.number = a:1
      " }}}
    else
      " Создание нового, именованного буфера. {{{
      let l:obj.number = bufnr('#' . a:1 . '#', 1)
      " }}}
    endif
  else
    " Создание нового, анонимного буфера. {{{
    let l:obj.number = bufnr(bufnr('$') + 1, 1)
    " }}}
  endif
  "" {{{
  " @var hash Словарь опций, применяемых к буферу при его активации. Словарь имеет следующую структуру: [опция: значение, ...].
  "" }}}
  let l:obj.options = {}
  "" {{{
  " @var hash Словарь команд, применяемых к буферу при его активации, генерирующих события привязок. Словарь имеет следующую структуру: {режимКомбинация: командаГенерацииСобытия, ...}.
  "" }}}
  let l:obj.listenerComm = {}
  let self.buffers[l:obj.getNum()] = l:obj
  return l:obj
endfunction " }}}

"" {{{
" Конструктор создает объектное представление текущего буфера.
" @throws IndexOutOfRangeException Выбрасывается при обращении к отсутствующему буферу.
" @return vim_lib#sys#Buffer# Целевой буфер.
"" }}}
function! s:Class.current() " {{{
  return self.new(bufnr('%'))
endfunction " }}}

"" {{{
" Метод возвращает номер вызываемого буфера.
" @return integer Номер буфера.
"" }}}
function! s:Class.getNum() " {{{
  return self.number
endfunction " }}}

"" {{{
" Метод возвращает номер окна, в котором активирован буфер.
" Если буфер активен в более чем одном окне, метод возвращает номер верхнего левого окна.
" @return integer Номер окна, в котором активирован буфер или -1, если буфер не активен.
"" }}}
function! s:Class.getWinNum() " {{{
  return bufwinnr(self.getNum())
endfunction " }}}

"" {{{
" Метод закрывает все окна, в котором данный буфер является активным, а так же выгружает его из памяти.
" При вызове метода, все несохраненные в буфере данные будут потеряны.
"" }}}
function! s:Class.unload() " {{{
  exe 'bunload! ' . self.getNum()
endfunction " }}}

"" {{{
" Метод удаляет вызываемый буфер.
" При вызове метода, все несохраненные в буфере данные будут потеряны.
"" }}}
function! s:Class.delete() " {{{
  exe 'bw! ' . self.getNum()
  call remove(self.class.buffers, self.getNum())
endfunction " }}}

"" {{{
" Данный метод отвечает за рендеринг содержимого буфера, установку опций и обработчиков событий при активации буфера.
"" }}}
function! s:Class._setOptions() " {{{
  " render {{{
  if has_key(self, 'render')
    normal ggVGd
    if type(self.render) == 2
      silent put = self.render()
    else
      exe 'silent put = ' . self.render
    endif
    keepjumps 0d
  endif
  " }}}
  " Слушатели. {{{
  for l:listenerComm in values(self.listenerComm)
    exe l:listenerComm
  endfor
  " }}}
  " Опции. {{{
  for [l:option, l:value] in items(self.options)
    exe 'let &l:' . l:option . ' = "' . l:value . '"'
  endfor
  " }}}
endfunction " }}}

"" {{{
" Метод делает окно буфера текущим.
" Если буфер активен в более чем одном окне, метод делает текущим верхнее левое окно.
" @throws RuntimeException Выбрасывается в случае, если на момент вызова метода, буфер не был активен.
"" }}}
function! s:Class.select() " {{{
  let l:winNum = bufwinnr(self.getNum())
  if l:winNum == -1
    throw 'RuntimeException: Buffer <' . self.getNum() . '> not active.'
  endif
  exe l:winNum . 'wincmd w'
endfunction " }}}

"" {{{
" Метод деталет вызываемый буфер активным в текущем окне.
" При активации буфера используется свойство или метод render, который отвечает за создание содержимого этого буфера. В качестве этого свойства можно указать вызов любой функции редактора, которая возвращает строку:
"   let buffer.render = 'myModule#run()'
" конкретное значение в виде строки, которое будет установлено в буфер:
"   let buffer.render = "'Hello world'"
" либо определить метод, который будет возвращать строку:
"   function! buffer.render()
"     return self.myData
"   endfunction
" в этом случае метод будет вызываться от имени объекта, представляющего буфер.
"" }}}
function! s:Class.active() " {{{
  exe 'buffer ' . self.number
  cal self._setOptions()
endfunction " }}}

"" {{{
" Метод открывает новое окно по горизонтали и делает вызываемый буфер активным в нем.
" @param string pos Позиция нового окна (t - выше текущего окна, b - ниже текущего окна).
" @param integer gsize [optional] Высота нового окна.
" @see vim_lib#sys#Buffer#.active
"" }}}
function! s:Class.gactive(pos, ...) " {{{
  let l:winheight = winheight(winnr())
  exe 'silent! ' . ((a:pos == 'b')? 'rightbelow' : 'leftabove') . ' new'
  if exists('a:1')
    if a:1[-1 : ] == '%'
      exe 'resize ' . (l:winheight * a:1[0 : -2] / 100)
    else
      exe 'resize ' . a:1
    endif
  endif
  let l:newBufNum = bufnr('%')
  call self.active()
  exe 'bw! ' . l:newBufNum
endfunction " }}}

"" {{{
" Метод открывает новое окно по вертикали и делает вызываемый буфер активным в нем.
" @param string pos Позиция нового окна (l - слева от текущего окна, r - справа от текущего окна).
" @param integer vsize [optional] Ширина нового окна.
" @see vim_lib#sys#Buffer#.active
"" }}}
function! s:Class.vactive(pos, ...) " {{{
  let l:winwidth = winwidth(winnr())
  exe 'silent! ' . ((a:pos == 'r')? 'rightb' : 'lefta') . ' vnew'
  if exists('a:1')
    if a:1[-1 : ] == '%'
      exe 'vertical resize ' . (l:winwidth * a:1[0 : -2] / 100)
    else
      exe 'vertical resize ' . a:1
    endif
  endif
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
function! s:Class.option(name, value) " {{{
  let self.options[a:name] = a:value
endfunction " }}}

"" {{{
" Метод делает буфер временным устанавливая опцию buftype в значение nofile.
"" }}}
function! s:Class.temp() " {{{
  call self.option('buftype', 'nofile')
endfunction " }}}

" Метод listen примеси EventHandle выносится в закрытую область класса.
let s:Class._listen = s:Class.listen
"" {{{
" Метод определяет функцию-обработчик (слушатель) для события клавиатуры.
" Слушатель должен быть методом данного буфера.
" @param string mode Режим привязки. Возможно одно из следующих значений: n, v, o, i, l, c.
" @param string sequence Комбинация клавишь, для которой создается привязка.
" @param string listener Имя метода вызываемого буфера, используемого в качестве функции-обработчика.
"" }}}
function! s:Class.listen(mode, sequence, listener) " {{{
  call self._listen('keyPress_' . a:mode . a:sequence, a:listener)
  let self.listenerComm[a:mode . a:sequence] = a:mode . 'noremap <buffer> ' . a:sequence . ' :call vim_lib#sys#Buffer#.current().fire("keyPress_' . a:mode . a:sequence . '")<CR>:echo ""<CR>'
endfunction " }}}

" Метод ignore примеси EventHandle выносится в закрытую область класса.
let s:Class._ignore = s:Class.ignore
"" {{{
" Метод удаляет функции-обработчики (слушатели) для события клавиатуры.
" @param string mode Режим привязки. Возможно одно из следующих значений: n, v, o, i, l, c.
" @param string sequence Комбинация клавишь, для которой удаляется привязка.
" @param string listener [optional] Имя удаляемой функции-слушателя. Если параметр не задан, удаляются все слушатели данной комбинации клавишь.
"" }}}
function! s:Class.ignore(mode, sequence, ...) " {{{
  if exists('a:1')
    call self._ignore('keyPress_' . a:mode . a:sequence, a:1)
  else
    call self._ignore('keyPress_' . a:mode . a:sequence)
    if has_key(self.listenerComm, a:mode . a:sequence)
      unlet self.listenerComm[a:mode . a:sequence]
    endif
  endif
endfunction " }}}

" Метод fire примеси EventHandle выносится в закрытую область класса.
let s:Class._fire = s:Class.fire
"" {{{
" Метод генерирует событие клавиатуры для данного буфера.
" @param string mode Режим привязки. Возможно одно из следующих значений: n, v, o, i, l, c.
" @param string sequence Комбинация клавишь, для которой генерируется событие нажатия.
"" }}}
function! s:Class.fire(mode, sequence) " {{{
  call self._fire('keyPress_' . a:mode . a:sequence)
endfunction " }}}

let g:vim_lib#sys#Buffer# = s:Class
