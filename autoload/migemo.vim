" vim:set ts=8 sts=2 sw=2 tw=0:
"
" migemo.vim
"   Direct search for Japanese with Romaji --- Migemo support script.
"
" Maintainer:   haya14busa <hayabusa1419@gmail.com>
" Original:     MURAOKA Taro <koron.kaoriya@gmail.com>
" Contributors: Yasuhiro Matsumoto <mattn_jp@hotmail.com>
" Last Change: 03 Mar 2015

let s:save_cpo = &cpo
set cpo&vim

function! s:has_vimproc()
  if !exists('s:exists_vimproc')
    try
      silent call vimproc#version()
      let s:exists_vimproc = 1
    catch
      let s:exists_vimproc = 0
    endtry
  endif

  return s:exists_vimproc
endfunction

function! migemo#system(...)
    return call(s:has_vimproc() ? 'vimproc#system' : 'system', a:000)
endfunction

function! s:SearchDict2(name)
  let path = $VIM . ',' . &runtimepath
  let dict = globpath(path, "dict/".a:name)
  if dict == ''
    let dict = globpath(path, a:name)
  endif
  if dict == ''
    for path in [
          \ '/usr/local/share/migemo/',
          \ '/usr/local/share/cmigemo/',
          \ '/usr/local/share/',
          \ '/usr/share/cmigemo/',
          \ '/usr/share/',
          \ ]
      let path = path . a:name
      if filereadable(path)
        let dict = path
        break
      endif
    endfor
  endif
  let dict = matchstr(dict, "^[^\<NL>]*")
  return dict
endfunction

function! s:SearchDict()
  for path in [
        \ 'migemo/'.&encoding.'/migemo-dict',
        \ &encoding.'/migemo-dict',
        \ 'migemo-dict',
        \ ]
    let dict = s:SearchDict2(path)
    if dict != ''
      return dict
    endif
  endfor
  echoerr 'a dictionary for migemo is not found'
  echoerr 'your encoding is '.&encoding
endfunction

if has('migemo')
  function! migemo#init()
    if &migemodict == '' || !filereadable(&migemodict)
      let &migemodict = s:SearchDict()
    endif
    nnoremap <Plug>(migemo-migemosearch) g/
    nnoremap <Plug>(migemo-migemosearch-reverse) g?
  endfunction

  function! migemo#get_vim_pattern(pattern)
    call migemo#init()
    return migemo(a:pattern)
  endfunction
else
  " non-builtin version
  function! migemo#init()
    if ! executable('cmigemo')
      echoerr 'cmigemo is not installed'
    endif
    if get(g:, 'migemodict', '') ==# ''
      let g:migemodict = s:SearchDict()
    endif
  endfunction

  function! migemo#get_vim_pattern(pattern)
    call migemo#init()
    return migemo#system('cmigemo -v -w '.shellescape(a:pattern).' -d '.shellescape(g:migemodict))
  endfunction
endif

function! migemo#search_char(flags)
  let input = nr2char(getchar())
  let pat = migemo#get_vim_pattern(input)
  call search(pat, a:flags, line('.'))
  noh
endfunction

function! migemo#search_word(word, flags)
  let pattern = a:word != '' ? a:word : input('MIGEMO:')
  if pattern == ''
    return
  endif
  let pattern = migemo#get_vim_pattern(pattern)
  if pattern == ''
    return
  endif

  let @/ = pattern
  if string(a:flags) !~? 'b'
    call feedkeys("/\<CR>", 'n')
  else
    call feedkeys("?\<CR>", 'n')
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
