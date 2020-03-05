function! coc_fzf#common#remap_enter() abort
  let l:enter_map = maparg('<CR>', 't')
  if l:enter_map != ""
    let s:enter_map = l:enter_map
    tunmap <CR>
  endif
  tnoremap <silent> <CR> <C-\><C-n>:call coc_fzf#common#fzf_selector_save()<CR>i<CR>
endfunction

function! coc_fzf#common#unmap_enter() abort
  tunmap <CR>
  if exists('s:enter_map')
    exe 'tnoremap <silent><expr> <CR> ' . s:enter_map
  endif
endfunction

function! coc_fzf#common#fzf_selector_save() abort
  let l:cmd = 'g/^>/#'
  let t:fzf_selector_line_nb = split(s:redir_exec(l:cmd))[0]
endfunction

function! coc_fzf#common#fzf_selector_restore() abort
  " TODO: normal gg
  if exists('t:fzf_selector_line_nb')
    let l:c = 1
    while c < t:fzf_selector_line_nb
      call feedkeys("\<Down>")
      let l:c += 1
    endwhile
  endif
endfunction

" [function_name, args_string]
let s:last_func_call = []

function! coc_fzf#common#log_function_call(sfile, args) abort
  let l:func_name = substitute(a:sfile, '.*\(\.\.\|\s\)', '', '')
  let l:args_string = join(a:args, ',')
  let s:last_func_call = [l:func_name, l:args_string]
endfunction

function! coc_fzf#common#call_last_logged_function() abort
  if !empty(s:last_func_call)
    execute 'call ' . s:last_func_call[0] . '(' . s:last_func_call[1] . ')'
  endif
endfunction

function! s:redir_exec(command) abort
    redir =>output
    silent exec a:command
    redir END
    return output
endfunction

function coc_fzf#common#list_options(ArgLead, CmdLine, CursorPos) abort
  echom a:ArgLead
  let l:sources_list = systemlist(g:coc_fzf_plugin_dir . '/script/get_lists.sh --no-description')
  let l:diagnostics_opts = ['--current-buf']
  let l:symbols_opts = ['--kind']
  let l:kinds = ['File', 'Module', 'Namespace', 'Package', 'Class', 'Method',
        \ 'Property', 'Field', 'Constructor', 'Enum', 'Interface', 'Function',
        \ 'Variable', 'Constant', 'String', 'Number', 'Boolean', 'Array',
        \ 'Object', 'Key', 'Null', 'EnumMember', 'Struct', 'Event', 'Operator',
        \ 'TypeParameter']
  let l:CmdLineList = split(a:CmdLine)
  let l:source = len(l:CmdLineList) >= 2 ? l:CmdLineList[1] : ''
  if l:source == 'diagnostics'
    return join(l:diagnostics_opts, "\n")
  elseif l:source == 'symbols'
    if index(l:CmdLineList[-2:-1], '--kind') >= 0
      return join(l:kinds, "\n")
    endif
    return join(l:symbols_opts, "\n")
  endif
  if index(l:sources_list, l:source) < 0
    return join(l:sources_list, "\n")
  endif
endfunction
