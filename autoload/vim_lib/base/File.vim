" Date Create: 2015-01-12 23:45:01
" Last Change: 2015-02-22 14:03:32
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Object = g:vim_lib#base#Object#

let s:Class = s:Object.expand()

"" {{{
" @var string Переменная хранит слеш, используемый в данной операционной системе.
"" }}}
let s:Class.slash = (has('win16') || has('win32') || has('win64') || has('win95'))? '\' : '/'

"" {{{
" Конструктор создает объектное представление файла.
" @param string address Относительный адрес файла. Основой адреса является текущий файл редактора.
" @return vim_lib#base#File# Целевой файл.
"" }}}
function! s:Class.relative(address) " {{{
  let l:obj = self.bless()
  let l:obj.address = fnamemodify(expand('%'), ':p:h') . '/' . a:address
  return l:obj
endfunction " }}}

"" {{{
" Конструктор создает объектное представление файла.
" @param string Абсолютный адрес файла.
" @return vim_lib#base#File# Целевой файл.
"" }}}
function! s:Class.absolute(address) " {{{
  let l:obj = self.bless()
  let l:obj.address = a:address
  return l:obj
endfunction " }}}

"" {{{
" Метод возвращает адрес файла. Адрес каталогов не завершается слешем.
" @return string Адрес файла.
"" }}}
function! s:Class.getAddress() " {{{
  return self.address
endfunction " }}}

"" {{{
" Метод возвращает имя файла.
" @return string Имя файла.
"" }}}
function! s:Class.getName() " {{{
  return fnamemodify(self.getAddress(), ':t')
endfunction " }}}

"" {{{
" Метод возвращает каталог, в котором расположен файл.
" @return vim_lib#base#File# Родительский каталог файла.
"" }}}
function! s:Class.getDir() " {{{
  return self.class.absolute(fnamemodify(self.getAddress(), ':h'))
endfunction " }}}

"" {{{
" Метод возвращает файл, предположительно содержащийся в данном каталоге.
" @param string name Имя целевого файла.
" @return vim_lib#base#File# Целевой файл.
"" }}}
function! s:Class.getChild(name) " {{{
  return self.class.absolute(self.getAddress() . self.class.slash . a:name)
endfunction " }}}

"" {{{
" Метод возвращает массив имен файлов, содержащихся в данном каталоге, за исключением файлов . и ..
" @return array Массив имен файлов, содержащихся в данном каталоге.
"" }}}
function! s:Class.getChildren() " {{{
  let l:address = self.getAddress()
  let l:childAddress = split(globpath(l:address, '*') . "\n" . globpath(l:address, '.*'), "\n")
  let l:childNames = []
  for l:file in l:childAddress
    if l:file !~# '\/\.\.\/\?$' && l:file !~# '\/\.\/\?$'
      call add(l:childNames, fnamemodify(l:file, ':t'))
    endif
  endfor
  return l:childNames
endfunction " }}}

"" {{{
" Метод создает файл, если он еще не был создан.
"" }}}
function! s:Class.createFile() " {{{
  call writefile([''], self.getAddress())
endfunction " }}}

"" {{{
" Метод создает каталог, если он еще не был создан.
"" }}}
function! s:Class.createDir() " {{{
  if !self.isExists()
    call mkdir(self.getAddress(), '')
  endif
endfunction " }}}

"" {{{
" Метод удаляет файл.
"" }}}
function! s:Class.deleteFile() " {{{
  call delete(self.getAddress())
endfunction " }}}

"" {{{
" Метод удаляет каталог.
"" }}}
function! s:Class.deleteDir() " {{{
  if has("win16") || has("win32") || has("win64")
    call system('rmdir /s /q ' . self.getAddress())
  else
    call system('rm -rf ' . self.getAddress())
  endif
endfunction " }}}

"" {{{
" Метод считывает содержимое файла в массив.
" @return array Массив строк, содержащихся в файле.
"" }}}
function! s:Class.read() " {{{
  return readfile(self.getAddress())
endfunction " }}}

"" {{{
" Метод записывает строку в конец файла.
" @param string str Записываемая строка.
"" }}}
function! s:Class.write(str) " {{{
  call self.rewrite(add(self.read(), a:str))
endfunction " }}}

"" {{{
" Метод перезаписывает содержимое файла.
" @param array strs Массив строк, записываемых в файл.
"" }}}
function! s:Class.rewrite(strs) " {{{
  call writefile(a:strs, self.getAddress())
endfunction " }}}

"" {{{
" Метод определяет, является ли данный компонент файловой системы файлом.
" @return bool true - если это файл, иначе - false.
"" }}}
function! s:Class.isFile() " {{{
  return !isdirectory(self.getAddress())
endfunction " }}}

"" {{{
" Метод определяет, является ли данный компонент файловой системы каталогом.
" @return bool true - если это каталог, иначе - false.
"" }}}
function! s:Class.isDir() " {{{
  return isdirectory(self.getAddress())
endfunction " }}}

"" {{{
" Метод определяет, существует ли данный файл, или файл с данным именем в каталоге.
" @param string name [optional] Искомый в данном каталоге файл. Если параметр не задан, метод оценивает существование файла вызываемого объекта.
" @return bool true - если файл существует, иначе - false.
"" }}}
function! s:Class.isExists(...) " {{{
  if exists('a:1')
    return empty(glob(self.getAddress() . '/' . a:1))? 0 : 1
  else
    return empty(glob(self.getAddress()))? 0 : 1
  endif
endfunction " }}}

let g:vim_lib#base#File# = s:Class
