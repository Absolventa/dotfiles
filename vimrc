" Ruby settings
set ts=2             " Tabs are 2 spaces
set bs=2             " Backspace over everything in insert mode
set shiftwidth=2     " Tabs under smart indent
set autoindent
set smarttab
set expandtab
set si               " smartindent (local to buffer)


" Javascript settings
autocmd FileType javascript setlocal shiftwidth=4 tabstop=4


" Strip trailing whitespaces upon each save
" http://vimcasts.org/episodes/tidying-whitespace/"
function! <SID>StripTrailingWhitespaces()
  " Preparation: save last search, and cursor position.
  let _s=@/
  let l = line(".")
  let c = col(".")
  " Do the business:
  %s/\s\+$//e
  " Clean up: restore previous search history, and cursor position
  let @/=_s
  call cursor(l, c)
endfunction
autocmd BufWritePre *.rb,*.erb,*.py,*.js,*.haml,*.coffee,*.rake,*.md :call <SID>StripTrailingWhitespaces()
