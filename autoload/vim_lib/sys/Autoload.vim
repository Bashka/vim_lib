" Date Create: 2015-03-04 11:34:58
" Last Change: 2015-03-15 16:07:49
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:File = vim_lib#base#File#

"" {{{
" @var string Текущий уровень загрузки.
"" }}}
let vim_lib#sys#Autoload#currentLevel = ''
"" {{{
" @var hash Словарь используемых уровней загрузки. Словарь имеет следующую структуру: {уровень: {plugdir: каталогПлагинов, plugins: [плагин, ...]}, ...}.
"" }}}
let vim_lib#sys#Autoload#levels = {}

" Установка rtp. {{{
set nocompatible
set exrc
let s:rtp = [$VIMRUNTIME, $VIM . s:File.slash . 'vimfiles']
if has('win16') || has('win32') || has('win64') || has('win95')
  call add(s:rtp, $HOME . '\vimfiles')
else
  call add(s:rtp, $HOME . '/.vim')
endif
call add(s:rtp, '.vim')
exe 'set rtp=' . join(s:rtp, ',')
" }}}

"" {{{
" Команда подключает указанный плагин для текущего уровня загрузки.
"" }}}
com! -nargs=+ Plugin call vim_lib#sys#Autoload#plugin(<args>)

"" {{{
" Метод инициализирует очередь загрузки для данного уровня.
" @param string level Адрес каталога, содержадего загружаемые файлы (на уровне системы это $VIMRUNTIME, на уровне пользователя ~/.vim или ~/vimfiles, а на уровне проекта это .vim).
" @param string plugindir Имя каталога, содержащего плагины редактора (обычно это bundle). Данный каталог должен располагаться в каталоге, определенном аргументом level.
"" }}}
function! vim_lib#sys#Autoload#init(level, plugindir) " {{{
  let g:vim_lib#sys#Autoload#levels[a:level] = {'plugdir': a:plugindir, 'plugins': []}
  let g:vim_lib#sys#Autoload#currentLevel = a:level
endfunction " }}}

"" {{{
" Метод добавляет указанный плагин в очередь загрузки.
" @param string name Имя целевого плагина.
" @param hash options Словарь глобальных опций, которые будут установлены перед загрузкой плагина. Опции устанавливаются в виде переменной: g:имяПлагина#ключ = значение.
"" }}}
function! vim_lib#sys#Autoload#plugin(name, ...) " {{{
  let l:level = g:vim_lib#sys#Autoload#currentLevel
  let l:plugdir = g:vim_lib#sys#Autoload#levels[l:level]['plugdir']
  let l:plug = s:File.absolute(l:level . s:File.slash . l:plugdir . s:File.slash . a:name)
  if l:plug.isDir()
    call add(g:vim_lib#sys#Autoload#levels[l:level]['plugins'], a:name)
    exe 'set rtp+=' . l:plug.getAddress()
    if exists('a:1')                                                                                                                                
      for l:prop in keys(a:1)
        let g:[a:name. '#' . l:prop] = a:1[l:prop]
      endfor
    endif
  endif
endfunction " }}}

"" {{{
" Метод возвращает информацию об используемых уровнях загрузки.
" @return hash Свойство vim_lib#sys#Autoload#levels.
"" }}}
function! vim_lib#sys#Autoload#getLevels() " {{{
  return g:vim_lib#sys#Autoload#levels
endfunction " }}}

"" {{{
" Метод определяет, используется ли заданный плагин.
" Метод вернет true даже в том случае, если плагин физически не установлен, но подключен командой Plugin.
" @param string name Имя целевого плагина.
" @return bool true - если плагин используется, иначе - false.
"" }}}
function! vim_lib#sys#Autoload#isPlug(name) " {{{
  for l:body in values(g:vim_lib#sys#Autoload#levels)
    if index(l:body.plugins, a:name) != -1
      return 1
    endif
  endfor
  return 0
endfunction " }}}
