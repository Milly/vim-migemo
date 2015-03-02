" vim:set ts=8 sts=2 sw=2 tw=0:
"
" migemo.vim
"   Direct search for Japanese with Romaji --- Migemo support script.
"
" Maintainer:   haya14busa <hayabusa1419@gmail.com>
" Original:     MURAOKA Taro <koron.kaoriya@gmail.com>
" Contributors: Yasuhiro Matsumoto <mattn_jp@hotmail.com>
" Last Change: 03 Mar 2015

" Japanese Description:

if exists('plugin_migemo_disable')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=* Migemo call migemo#search_word(<q-args>, '')

nnoremap <Plug>(migemo-searchchar) :call migemo#search_char('')<CR>
nnoremap <Plug>(migemo-searchchar-reverse) :call migemo#search_char('b')<CR>

if has('migemo')
  nnoremap <Plug>(migemo-migemosearch) :call migemo#init() \| call feedkeys('g/', 'n')<CR>
  nnoremap <Plug>(migemo-migemosearch-reverse) :call migemo#init() \| call feedkeys('g?', 'n')<CR>
else
  nnoremap <Plug>(migemo-migemosearch) :call migemo#search_word('', '')<CR>
  nnoremap <Plug>(migemo-migemosearch-reverse) :call migemo#search_word('', 'b')<CR>
endi

if !hasmapto('<Plug>(migemo-searchchar)') && empty(maparg('<Leader>f', 'n'))
  nmap <Leader>f <Plug>(migemo-searchchar)
endif
if !hasmapto('<Plug>(migemo-searchchar-reverse)') && empty(maparg('<Leader>F', 'n'))
  nmap <Leader>F <Plug>(migemo-searchchar-reverse)
endif

if !hasmapto('<Plug>(migemo-migemosearch)') && maparg('g/', 'n') == ""
  nmap g/ <Plug>(migemo-migemosearch)
endif
if !hasmapto('<Plug>(migemo-migemosearch-reverse)') && maparg('g?', 'n') == ""
  nmap g? <Plug>(migemo-migemosearch-reverse)
endif

let &cpo = s:save_cpo
unlet s:save_cpo
