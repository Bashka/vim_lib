" Date Create: <+datetime+>
" Last Change: <+datetime+>
" Author: <+author+> (<+email+>)
" License: <+license+>

let s:Test = vim_lib#base#Test#.expand()

"" {{{
" 
" @covers 
"" }}}
function! s:Test.test() " {{{
  
endfunction " }}}

let g:`substitute(strpart(g:vim_template#keywords.dir, stridx(g:vim_template#keywords.dir, '/') + 1), '/', '#', 'g') . '#' . g:vim_template#keywords.fname . '#'` = s:Test
call s:Test.run()
