let g:aicliprg="aicli"
let g:ai_text_history="default"

function! CmdTextPrepare(prompt = "", context = "", files = [], inerte = 0)
    let l:cmd = g:aicliprg." text"

    if a:inerte == 1
        let l:cmd .= " -i"
    endif

    if exists("g:ai_text_sdk") && g:ai_text_sdk != ""
        let l:cmd .= " -S ".g:ai_text_sdk
    endif

    if exists("g:ai_text_history") && g:ai_text_history != ""
        let l:cmd .= " -H ".g:ai_text_history
    endif

    if exists("g:ai_text_model") && g:ai_text_model != ""
        let l:cmd .= " -m ".g:ai_text_model
    endif

    if exists("g:ai_text_temp") && g:ai_text_temp != ""
        let l:cmd .= " -t ".g:ai_text_temp
    endif

    if len(a:files) > 0
        let l:files = ""
        for l:file in a:files
            let l:files .= " -f ".shellescape(l:file)
        endfor

        let l:cmd .= l:files
    endif

    if a:context != ""
        let l:cmd .= " -s ".shellescape(a:context)
    endif

    if a:prompt != ""
        let l:cmd .= " ".shellescape(a:prompt)
    endif

    return l:cmd
endfunction

function! CmdText(prompt = "", context = "", files = [], inerte = 0)
    let l:cmd = CmdTextPrepare(a:prompt, a:context, a:files, a:inerte)
    let l:result = system(l:cmd)

    if v:shell_error != 0
        echohl ErrorMsg | echomsg l:result | echohl None
        return
    endif

    echo l:result
endfunction

function! CmdTranslatePrepare(prompt, target, source = "")
    let l:cmd = g:aicliprg." translate -t ".a:target

    if exists("g:ai_translate_sdk") && g:ai_translate_sdk != ""
        let l:cmd .= " -S ".g:ai_translate_sdk
    endif

    if a:source != ""
        let l:cmd .= " -s ".a:source
    endif

    let l:cmd = l:cmd." ".shellescape(a:prompt)

    return l:cmd
endfunction

function! CmdTranslate(prompt, target, source = "")
    let l:cmd = CmdTranslatePrepare(a:prompt, a:target, a:source)
    let l:result = system(l:cmd)

    if v:shell_error != 0
        echohl ErrorMsg | echomsg l:result | echohl None
        return
    endif

    return l:result
endfunction

function! AiTranslate(is_selection, ...) range
    if a:0 == 0
        echohl ErrorMsg | echomsg "No target language specified" | echohl None
        return
    endif

    let l:source = ""

    if a:0 == 2
        let l:source = a:2
    endif

    let l:content = a:is_selection
        \? join(getline(a:firstline, a:lastline), "\n")
        \: join(getline(1, "$"), "\n")

    echo l:content

    echo "Processing please wait ..."
    let l:output = CmdTranslate(l:content, a:1, l:source)
    redraw | echo ""

    if a:is_selection
        call setline(a:firstline, split(l:output, "\n"))
    else
        call setline(1, split(l:output, "\n"))
    endif
endfunction

function! AiText(bang, is_selection, ...) range
    let l:instruction = a:0 ? a:1 : ""
    let l:ctx = []

    if l:instruction == ""
        if a:is_selection
            let l:lines = join(getline(a:firstline, a:lastline), "\n")
            call CmdText("", l:lines, [], 1)
        endif

        let l:cmd = CmdTextPrepare()
        execute "vertical terminal ++close ".l:cmd
        return
    endif

    if a:is_selection
        let l:lines = join(getline(a:firstline, a:lastline), "\n")
        let l:cmd = CmdTextPrepare(l:instruction, l:lines)

        let l:exec = a:bang == 0
            \? "normal! ".a:firstline."GV".a:lastline."Gc"
            \: "normal! ".a:lastline."Go"

        execute l:exec
    else
        let l:cmd = CmdTextPrepare(l:instruction)
    endif

    echo "Processing please wait ..."
    let l:result = system(l:cmd)

    if v:shell_error != 0
        echohl ErrorMsg | echomsg l:result | echohl None
        return
    endif

    let l:insert = a:is_selection ? "i" : "o"
    execute "normal! ".l:insert.l:result
endfunction

function! AiAddFile(...)
    call CmdText("", "", a:000, 1)
    echo "Files added in history"
endfunction

function! AiAddContext(is_selection, ...) range
    let l:instruction = a:0 ? a:1 : ""

    let l:context = a:is_selection
        \? join(getline(a:firstline, a:lastline), "\n")
        \: l:instruction

    call CmdText("", l:context, [], 1)
    echo "Context added in history"
endfunction

function! AiHistoryClear()
    let l:cmd = g:aicliprg." text"

    if exists("g:ai_text_history") && g:ai_text_history != ""
        let l:cmd .= " -H ".g:ai_text_history
    endif

    let l:cmd .= " -c"

    call system(l:cmd)

    if v:shell_error != 0
        echohl ErrorMsg | echomsg l:result | echohl None
        return
    endif

    echo "History cleared"
endfunction

function! AiHistory(name = "")
    if a:name == ""
        echo "history : ".g:ai_text_history
        return
    endif

    let g:ai_text_history = a:name
    echo "History updated"
endfunction

function! AiHistoryList()
    let l:cmd = g:aicliprg." text -L"

    let l:result = system(l:cmd)

    if v:shell_error != 0
        echohl ErrorMsg | echomsg l:result | echohl None
        return
    endif

    echo l:result
endfunction

command! -bang -range -nargs=? AiText <line1>,<line2>call AiText(<bang>0, <range>, <f-args>)
command! -nargs=+ -complete=file AiAddFile call AiAddFile(<f-args>)
command! -range -nargs=? AiAddContext <line1>,<line2>call AiAddContext(<range>, <f-args>)
command! -nargs=* AiHistory call AiHistory(<f-args>)
command! -nargs=0 AiHistoryClear call AiHistoryClear()
command! AiHistoryList call AiHistoryList()
command! -range -nargs=* AiTranslate <line1>,<line2>call AiTranslate(<range>, <f-args>)
