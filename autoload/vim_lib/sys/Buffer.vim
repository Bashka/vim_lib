" Date Create: 2015-01-07 16:18:33
" Last Change: 2015-06-28 17:25:54
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Object = g:vim_lib#base#Object#
let s:EventHandle = g:vim_lib#base#EventHandle#
let s:Content = g:vim_lib#sys#Content#.new()

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
" @param integer|string name Номер целевого буфера или имя файла, используемого для редактирования в буфере. Если параметр не задан, создается новый буфер.
" @throws IndexOutOfRangeException Выбрасывается при обращении к отсутствующему буферу.
" @return vim_lib#sys#Buffer# Целевой буфер.
"" }}}
function! s:Class.new(...) " {{{
  " Получение объекта из пула. {{{
  if exists('a:1')
    let l:bufnr = (type(a:1) == 1)? bufnr(a:1) : a:1
    if has_key(self.buffers, l:bufnr)
      return self.buffers[l:bufnr]
    endif
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
      let l:obj.number = bufnr(a:1, 1)
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
  let l:obj.listenerMap = {}
  "" {{{
  " @var hash Словарь событий, применяемых к буферу при его активации, генерирующих события привязок. Словарь имеет следующую структуру: {событие: командаГенерацииСобытия, ...}.
  "" }}}
  let l:obj.listenerAu = {}
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
  for l:listenerMap in values(self.listenerMap)
    exe l:listenerMap
  endfor
  for l:listenerAu in values(self.listenerAu)
    exe l:listenerAu
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
" Метод перерисовывает вызываемый буфер.
"" }}}
function! s:Class.redraw() " {{{
  let l:pos = s:Content.pos()
  call self.active()
  call s:Content.pos(l:pos)
endfunction " }}}

"" {{{
" Метод открывает новое окно по горизонтали и делает вызываемый буфер активным в нем.
" @param string pos Позиция нового окна (t - выше текущего окна, b - ниже текущего окна, T - выше всех окон, B - ниже всех окон).
" @param integer gsize [optional] Высота нового окна. Возможно указать процентное значение (n%) относительно текущего окна.
" @see vim_lib#sys#Buffer#.active
"" }}}
function! s:Class.gactive(pos, ...) " {{{
  let l:winheight = winheight(winnr())
  " Определение позиции нового окна. {{{
  if a:pos == 't'
    let l:pos = 'leftabove'
  elseif a:pos == 'T'
    let l:pos = 'topleft'
  elseif a:pos == 'b'
    let l:pos = 'rightbelow'
  elseif a:pos == 'B'
    let l:pos = 'botright'
  else
    let l:pos = ''
  endif
  " }}}
  exe 'silent! ' . l:pos . ' new'
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
" @param string pos Позиция нового окна (l - слева от текущего окна, r - справа от текущего окна, L - левее всех окон, R - правее всех окон).
" @param integer vsize [optional] Ширина нового окна. Возможно указать процентное значение (n%) относительно текущего окна.
" @see vim_lib#sys#Buffer#.active
"" }}}
function! s:Class.vactive(pos, ...) " {{{
  let l:winwidth = winwidth(winnr())
  " Определение позиции нового окна. {{{
  if a:pos == 'l'
    let l:pos = 'leftabove'
  elseif a:pos == 'L'
    let l:pos = 'topleft'
  elseif a:pos == 'r'
    let l:pos = 'rightbelow'
  elseif a:pos == 'R'
    let l:pos = 'botright'
  else
    let l:pos = ''
  endif
  " }}}
  exe 'silent! ' . l:pos . ' vnew'
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
  call self.option('swapfile', '0')
endfunction " }}}

" Метод listen примеси EventHandle выносится в закрытую область класса.
let s:Class._listen = s:Class.listen
unlet s:Class.listen
"" {{{
" Метод определяет функцию-обработчик (слушатель) для события клавиатуры.
" Слушатель должен быть методом данного буфера или ссылкой на глобальную функцию.
" @param string mode Режим привязки. Возможно одно из следующих значений: n, v, o, i, l, c.
" @param string sequence Комбинация клавишь, для которой создается привязка.
" @param string listener Имя метода вызываемого буфера или ссылка на глобальную функцию, используемую в качестве функции-обработчика.
"" }}}
function! s:Class.map(mode, sequence, listener) " {{{
  " Исключаем автоматический перевод комбинаций вида <C-...> в ^... при вызове noremap.
  let l:modSeq = substitute(a:sequence, '<', '\\<', '')
  let l:modSeq = substitute(l:modSeq, '>', '\\>', '')
  call self._listen('keyPress_' . a:mode . a:sequence, a:listener)
  let self.listenerMap[a:mode . a:sequence] = a:mode . 'noremap <silent> <buffer> ' . a:sequence . ' :call vim_lib#sys#Buffer#.current().fire("' . a:mode . '", "' . l:modSeq . '")<CR>'
endfunction " }}}

"" {{{
" Метод определяет функцию-обработчик (слушатель) для события редактора.
" Слушатель должен быть методом данного буфера или ссылкой на глобальную функцию.
" @param string events Имена событий, перечисленных через запятую, к которым выполняется привязка. Доступно одной из приведенных в разделе |autocommand-events| значений.
" @param string listener Имя метода вызываемого буфера или ссылка на глобальную функцию, используемую в качестве функции-обработчика.
"" }}}
function! s:Class.au(events, listener) " {{{
  call self._listen('autocmd_' . a:events, a:listener)
  let self.listenerAu[a:events] = 'au ' . a:events . ' ' . bufname(self.getNum()) . ' :call vim_lib#sys#Buffer#.current().doau("' . a:events . '")'
endfunction " }}}

" Метод ignore примеси EventHandle выносится в закрытую область класса.
let s:Class._ignore = s:Class.ignore
"" {{{
" Метод удаляет функции-обработчики (слушатели) для события клавиатуры.
" @param string mode Режим привязки. Возможно одно из следующих значений: n, v, o, i, l, c.
" @param string sequence Комбинация клавишь, для которой удаляется привязка.
" @param string listener [optional] Имя удаляемой функции-слушателя. Если параметр не задан, удаляются все слушатели данной комбинации клавишь.
"" }}}
function! s:Class.ignoreMap(mode, sequence, ...) " {{{
  if exists('a:1')
    call self._ignore('keyPress_' . a:mode . a:sequence, a:1)
  else
    call self._ignore('keyPress_' . a:mode . a:sequence)
    if has_key(self.listenerMap, a:mode . a:sequence)
      unlet self.listenerMap[a:mode . a:sequence]
    endif
  endif
endfunction " }}}

"" {{{
" Метод удаляет функции-обработчики (слушатели) для события редактора.
" @param string events Имена событий, перечисленных через запятую, для которым отменяется привязка. Доступно одной из приведенных в разделе |autocommand-events| значений.
" @param string listener [optional] Имя удаляемой функции-слушателя. Если параметр не задан, удаляются все слушатели данного события редактора.
"" }}}
function! s:Class.ignoreAu(events, ...) " {{{
  if exists('a:1')
    call self._ignore('autocmd_' . a:events, a:1)
  else
    call self._ignore('autocmd_' . a:events)
    if has_key(self.listenerAu, a:events)
      unlet self.listenerAu[a:events]
    endif
  endif
  if len(self.listeners['autocmd_' . a:events]) == 0
    exe 'au! ' . a:events . ' ' . bufname(self.getNum())
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

"" {{{
" Метод генерирует событие редактора для данного буфера.
" @param string events Имена событий, перечисленных через запятую, для которых выполняется генерация. Доступно одной из приведенных в разделе |autocommand-events| значений.
"" }}}
function! s:Class.doau(events) " {{{
  call self._fire('autocmd_' . a:events)
endfunction " }}}

let g:vim_lib#sys#Buffer# = s:Class
