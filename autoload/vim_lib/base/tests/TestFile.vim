" Date Create: 2015-01-13 09:00:17
" Last Change: 2015-01-13 15:23:16
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:File = vim_lib#base#File#

let s:Test = vim_lib#base#Test#.expand()

" relative, absolute {{{
"" {{{
" Должен сохранять адрес файла относительно файла текущего буфера.
" @covers vim_lib#base#File#.relative
"" }}}
function! s:Test.testRelative_saveAddress() " {{{
  let l:obj = s:File.relative('File/file.txt')
  call self.assertEquals(l:obj.getAddress(), fnamemodify(expand('%'), ':p:h') . '/' . 'File/file.txt')
endfunction " }}}

"" {{{
" Должен сохранять абсолютный адрес файла.
" @covers vim_lib#base#File#.absolute
"" }}}
function! s:Test.testAbsolute_saveAddress() " {{{
  let l:obj = s:File.absolute('/vim_lib/base/tests/File/file.txt')
  call self.assertEquals(l:obj.getAddress(), '/vim_lib/base/tests/File/file.txt')
endfunction " }}}
" }}}
" getAddress, getName, getDir {{{
"" {{{
" Должен возвращать адрес файла.
" @covers vim_lib#base#File#.getAddress
"" }}}
function! s:Test.testGetAddress() " {{{
  let l:obj = s:File.relative('File/file.txt')
  call self.assertEquals(l:obj.getAddress(), fnamemodify(expand('%'), ':p:h') . '/' . 'File/file.txt')
endfunction " }}}

"" {{{
" Должен возвращать имя файла.
" @covers vim_lib#base#File#.name
"" }}}
function! s:Test.testName_returnFileName() " {{{
  let l:obj = s:File.relative('File/dir')
  call self.assertEquals(l:obj.getName(), 'dir')
  let l:obj = s:File.relative('File/dir/dir/file.txt')
  call self.assertEquals(l:obj.getName(), 'file.txt')
endfunction " }}}

"" {{{
" Должен возвращать родительский каталог.
" @covers vim_lib#base#File#.dir
"" }}}
function! s:Test.testGetDir_returnParentDir() " {{{
  let l:obj = s:File.relative('File/dir')
  call self.assertEquals(l:obj.getDir().getAddress(), fnamemodify(expand('%'), ':p:h') . '/' . 'File')
  call self.assertTrue(l:obj.getDir().class.typeof(s:File))
  let l:obj = s:File.relative('File/dir/dir/file.txt')
  call self.assertEquals(l:obj.getDir().getAddress(), fnamemodify(expand('%'), ':p:h') . '/' . 'File/dir/dir')
endfunction " }}}
" }}}
" isExists, isFile, isDir {{{
"" {{{
" Должен определять, существует ли файл вызываемого объекта.
" @covers vim_lib#base#File#.isExists
"" }}}
function! s:Test.testIsExists_currentFileExists() " {{{
  let l:obj = s:File.relative('File/file.txt')
  call self.assertTrue(l:obj.isExists())
  let l:obj = s:File.relative('File/dir')
  call self.assertTrue(l:obj.isExists())
  let l:obj = s:File.relative('File/void')
  call self.assertFalse(l:obj.isExists())
endfunction " }}}

"" {{{
" Должен определять, существует ли заданный файл.
" @covers vim_lib#base#File#.isExists
"" }}}
function! s:Test.testIsExists_thisFileExists() " {{{
  let l:obj = s:File.relative('File/dir')
  call self.assertTrue(l:obj.isExists('file.txt'))
  call self.assertTrue(l:obj.isExists('dir'))
  call self.assertFalse(l:obj.isExists('void'))
endfunction " }}}

"" {{{
" Должен определять, является ли данный компонент файлом.
" @covers vim_lib#base#File#.isFile
"" }}}
function! s:Test.testIsFile() " {{{
  let l:obj = s:File.relative('File/file.txt')
  call self.assertTrue(l:obj.isFile())
  let l:obj = s:File.relative('File/dir')
  call self.assertFalse(l:obj.isFile())
endfunction " }}}

"" {{{
" Должен определять, является ли данный компонент каталогом.
" @covers vim_lib#base#File#.isDir
"" }}}
function! s:Test.testIsDir() " {{{
  let l:obj = s:File.relative('File/dir')
  call self.assertTrue(l:obj.isDir())
  let l:obj = s:File.relative('File/file.txt')
  call self.assertFalse(l:obj.isDir())
endfunction " }}}
" }}}
" createDir, createFile, deleteFile {{{
"" {{{
" Должен создавать новый каталог.
" @covers vim_lib#base#File#.createDir
"" }}}
function! s:Test.testCreateDir() " {{{
  let l:obj = s:File.relative('File/newDir')
  call self.assertFalse(l:obj.isExists())
  call l:obj.createDir()
  call self.assertTrue(l:obj.isExists())
  call self.assertTrue(l:obj.isDir())
  call system('rmdir ' . l:obj.getAddress())
endfunction " }}}

"" {{{
" Должен создавать новый файл.
" @covers vim_lib#base#File#.createFile
"" }}}
function! s:Test.testCreateFile() " {{{
  let l:obj = s:File.relative('File/newFile.txt')
  call self.assertFalse(l:obj.isExists())
  call l:obj.createFile()
  call self.assertTrue(l:obj.isExists())
  call self.assertTrue(l:obj.isFile())
  call delete(l:obj.getAddress())
endfunction " }}}

"" {{{
" Должен удалять файл.
" @covers vim_lib#base#File#.deleteFile
"" }}}
function! s:Test.testDeleteFile() " {{{
  call writefile([''], fnamemodify(expand('%'), ':p:h') . '/File/newfile.txt')
  let l:obj = s:File.relative('File/newfile.txt')
  call self.assertTrue(l:obj.isExists())
  call l:obj.deleteFile()
  call self.assertFalse(l:obj.isExists())
endfunction " }}}
" }}}
" read, write, rewrite {{{
"" {{{
" Должен считывает содержимое строки в массив.
" @covers vim_lib#base#File#.read
"" }}}
function! s:Test.testRead() " {{{
  let l:obj = s:File.relative('File/file.txt')
  call self.assertEquals(l:obj.read(), ['Hello world', 'Test'])
endfunction " }}}

"" {{{
" Должен перезаписывать файл.
" @covers vim_lib#base#File#.rewrite
"" }}}
function! s:Test.testRewrite() " {{{
  let l:obj = s:File.relative('File/file.txt')
  let l:content = l:obj.read()
  let l:content[1] = 'Rewrite'
  call l:obj.rewrite(l:content)
  call self.assertEquals(l:obj.read(), ['Hello world', 'Rewrite'])
  call l:obj.rewrite(['Hello world', 'Test'])
endfunction " }}}

"" {{{
" Должен добавлять запись в конец файла.
" @covers vim_lib#base#File#.write
"" }}}
function! s:Test.testWrite() " {{{
  let l:obj = s:File.relative('File/file.txt')
  call l:obj.write('New string')
  call self.assertEquals(l:obj.read(), ['Hello world', 'Test', 'New string'])
  call l:obj.rewrite(['Hello world', 'Test'])
endfunction " }}}
" }}}

let g:vim_lib#base#tests#TestDict# = s:Test
call s:Test.run()
