" Date Create: 2015-01-06 18:56:11
" Last Change: 2015-01-06 20:26:45
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Object = g:vim_lib#base#Object#

let s:Subclass = s:Object.expand()

let g:vim_lib#base#tests#Object#Subclass# = s:Subclass
