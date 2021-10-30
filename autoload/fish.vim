function! fish#Fold()
    let l:line = getline(v:lnum)
    if l:line =~# '\v^\s*%(begin|if|while|for|function|switch)>'
        return 'a1'
    elseif l:line =~# '\v^\s*end>'
        return 's1'
    else
        return '='
    end
endfunction

function! fish#Complete(findstart, base) abort
    if a:findstart
        return getline('.') =~# '\v^\s*$' ? -1 : 0
    else
        if empty(a:base)
            return []
        endif
        let l:results = []
        let l:completions =
                    \ system('fish -c "complete -C'.shellescape(a:base).'"')
        let l:sufpos = match(a:base, '\v\S+$')
        if l:sufpos >= 0
            let l:cmd = a:base[:l:sufpos-1]
            let l:arg = a:base[l:sufpos:]
        else
            let l:cmd = a:base
            let l:arg = ''
        endif
        for l:line in filter(split(l:completions, '\n'), '!empty(v:val)')
            let l:tokens = split(l:line, '\t')
            let l:term = l:tokens[0]
            if l:term =~? '^\V'.l:arg
                call add(l:results, {
                            \ 'word': l:cmd.l:term,
                            \ 'abbr': l:term,
                            \ 'menu': get(l:tokens, 1, ''),
                            \ 'dup': 1
                            \ })
            endif
        endfor
        return l:results
    endif
endfunction

function! fish#Indent()
    let l:shiftwidth = shiftwidth()
    let l:prevlnum = prevnonblank(v:lnum - 1)
    if l:prevlnum ==# 0
        return 0
    endif
    let l:indent = 0
    let l:prevline = getline(l:prevlnum)
    if l:prevline =~# '\v^\s*switch>'
        let l:indent = l:shiftwidth * 2
    elseif l:prevline =~# '\v^\s*%(begin|if|else|while|for|function|case)>'
        let l:indent = l:shiftwidth
    endif
    let l:line = getline(v:lnum)
    if l:line =~# '\v^\s*end>'
        return indent(v:lnum) - (l:indent ==# 0 ? l:shiftwidth : l:indent)
    elseif l:line =~# '\v^\s*%(case|else)>'
        return indent(v:lnum) - l:shiftwidth
    endif
    return indent(l:prevlnum) + l:indent
endfunction
