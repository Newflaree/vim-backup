"==================================================
" Neovim init.vim — Config ordenada
"==================================================

"--------------------------------------------------
" Núcleo / Activación de detección y plugins
"--------------------------------------------------
filetype plugin indent on
syntax enable

"--------------------------------------------------
" UI / Básicos
"--------------------------------------------------
set number
set relativenumber
set numberwidth=1
set cursorline
set showmatch
set showcmd
set ruler
set laststatus=2
set noshowmode
set bg=dark
set hidden
set wrap

"--------------------------------------------------
" Entrada / Portapapeles / Ratón / Codificación
"--------------------------------------------------
set mouse=a
set clipboard=unnamed
set encoding=utf-8
set autoread

"--------------------------------------------------
" Sangría / Tabs
"--------------------------------------------------
set autoindent
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
" (también tienes: set ts=2 sw=2 et)
set ts=2 sw=2 et
set sw=2

"--------------------------------------------------
" Reglas específicas por filetype (Python)
"--------------------------------------------------
augroup python_indent
  autocmd!
  autocmd FileType python setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
augroup END

"==================================================
" Plugins (vim-plug)
"==================================================
call plug#begin('~/.config/nvim/plugged')

" Temas / UI
Plug 'morhetz/gruvbox'
Plug 'itchyny/lightline.vim'
Plug 'maximbaz/lightline-ale'
Plug 'ryanoasis/vim-devicons'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'bryanmylee/vim-colorscheme-icons'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'tribela/vim-transparent'

" Exploración / Movimiento / Tmux
Plug 'scrooloose/nerdtree'
Plug 'easymotion/vim-easymotion'
Plug 'christoomey/vim-tmux-navigator'

" LSP / IntelliSense / Test / Git
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'tpope/vim-fugitive'
Plug 'janko/vim-test'
Plug 'tyewang/vimux-jest-test'

" Edición / Pares / Surround / CloseTags / Repeat
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-surround'
Plug 'alvan/vim-closetag'
Plug 'tpope/vim-repeat'

" JS/TS/React/Node/Colores
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'tasn/vim-tsx'
Plug 'moll/vim-node'
Plug 'ap/vim-css-color'

" Otros lenguajes / Snippets / CSV
Plug 'keith/swift.vim'
Plug 'udalov/kotlin-vim'
Plug 'uiiaoo/java-syntax.vim'
Plug 'SirVer/ultisnips'
Plug 'mechatroner/rainbow_csv'

" Telescope / Treesitter
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', {'do': ':UpdateRemotePlugins'}
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Git: signos/hunks en el margen (para comandos nuevos)
Plug 'lewis6991/gitsigns.nvim'

call plug#end()

"==================================================
" Configuración de Plugins
"==================================================

" NERDTree
let NERDTreeShowHidden=1
let NERDTreeQuitOnOpen=1

" CloseTag (archivos donde se activa)
let g:closetag_filenames = '*.html, *.js, *.jsx, *.ts, *.tsx, *.java, *.py'

" Indent Guides
let g:indent_guides_enable_on_vim_startup = 1

"--------------------------------------------------
" Tema
"--------------------------------------------------
colorscheme gruvbox
let g:gruvbox_contrast_dark = "hard"

"--------------------------------------------------
" Treesitter (según tu config original: highlight desactivado)
"--------------------------------------------------
lua <<EOF
require('nvim-treesitter.configs').setup {
  ensure_installed = {"typescript", "tsx", "python"},
  highlight = { enable = false },
}
EOF

"==================================================
" Atajos / Leader / Navegación
"==================================================
let mapleader=" "

" Easymotion
nmap <Leader>s <Plug>(easymotion-s2)

" NERDTree
nmap <Leader>nt :NERDTreeFind<CR>
nmap <Leader>nr :NERDTreeToggle<CR>

" Guardar / Salir
nmap <Leader>w :w<CR>
nmap <Leader>q :q<CR>
nmap <Leader>Q :q!<CR>

" coc.nvim — definiciones / refs / etc.
nmap <silent>gd <Plug>(coc-definition)
nmap <silent>gy <Plug>(coc-type-definition)
nmap <silent>gi <Plug>(coc-implementation)
nmap <silent>gr <Plug>(coc-references)

" Tabs
nmap <Leader>h :tabprevious<cr>
nmap <Leader>l :tabnext<cr>

" Mover líneas
nnoremap <Leader>k :m .-2<CR>==
nnoremap <Leader>j :m .+1<CR>==

" Git (fugitive)
nnoremap <Leader>G :G<CR>
nnoremap <Leader>gp :Gpush<CR>
nnoremap <Leader>gl :Gpull<CR>

" Terminal / Tests
nnoremap <Leader>t :term<CR>
nnoremap <Leader>te :TestNearest<CR>
nnoremap <Leader>T :TestFile<CR>
nnoremap <Leader>TT :TestSuite<CR>

" Telescope
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

"==================================================
" Compleción unificada (<Tab>) — coc.nvim + UltiSnips
" Requiere: :CocInstall coc-ultisnips
"==================================================

" UX del popup de completion
set completeopt=menuone,noinsert,noselect
set shortmess+=c

function! s:check_backspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1] =~# '\s'
endfunction

" <Tab> prioriza:
" 1) navegar por el menú de Coc
" 2) expandir snippet (UltiSnips vía coc-ultisnips)
" 3) saltar dentro del snippet
" 4) tab literal si hay espacio atrás
" 5) refrescar sugerencias
inoremap <silent><expr> <Tab>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ coc#expandable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand',''])\<CR>" :
      \ coc#jumpable() ? "\<C-r>=coc#rpc#request('snippetNext', [])\<CR>" :
      \ <SID>check_backspace() ? "\<Tab>" :
      \ coc#refresh()

" Shift-Tab: atrás en menú o salto atrás en snippet
inoremap <silent><expr> <S-Tab>
      \ coc#pum#visible() ? coc#pum#prev(1) :
      \ coc#jumpable(-1) ? "\<C-r>=coc#rpc#request('snippetPrev', [])\<CR>" :
      \ "\<C-h>"

" Enter confirma selección cuando hay popup
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

" Disparo manual del menú
inoremap <silent><expr> <C-Space> coc#refresh()

"==================================================
" Git – Comandos productivos (Fugitive + Telescope + Gitsigns)
"==================================================

" Gitsigns: configuración (heredoc bien cerrado)
lua <<EOF_LUA_GITSIGNS
local ok, gitsigns = pcall(require, 'gitsigns')
if ok then
  gitsigns.setup({
    current_line_blame = true,
    current_line_blame_opts = { delay = 400 },
    signcolumn = true,
  })
end
EOF_LUA_GITSIGNS

" ---- Fugitive: Comandos de alto nivel ----
command! GStatus        execute 'G'                         " estado del repo
command! GStage         execute 'Gwrite'                    " add %
command! GStageAll      execute 'Git add -A'               " add -A
command! GUnstage       execute 'Git restore --staged %'   " unstage %
command! GDiscard       execute 'Gread | write'            " descartar cambios del buffer (HEAD)

command! GCommit        execute 'Gcommit'                  " buffer de mensaje
command! -nargs=+ GCommitm execute 'Git commit -m "<args>"'
command! GAmend         execute 'Git commit --amend --no-edit'

command! GPull          execute 'Git pull --rebase'
command! GPush          execute 'Git push'
command! GSync          execute 'Git pull --rebase | Git push'

command! -nargs=+ GSwitch execute 'Git checkout <args>'    " cambiar/crear rama
command! -nargs=+ GStart  execute 'Git checkout -b <args>' " crear rama

command! GLog           execute 'Gclog'                    " log repo → quickfix
command! GLogFile       execute 'Gclog -- %' | copen       " log archivo actual
command! GBlame         execute 'Git blame'                " blame del buffer

" Resolver conflictos con vista 3-way (ours/theirs):
"   :diffget //2  (OURS / local)
"   :diffget //3  (THEIRS / remoto)
command! GConflicts     execute 'Gvdiffsplit!'

command! GStash         execute 'Git stash -u'
command! GStashPop      execute 'Git stash pop'
command! -nargs=1 GFixup execute 'Git commit --fixup=<args>'
command! GAutosquash    execute 'Git rebase -i --autosquash origin/main'
command! GSetUpstream   execute 'Git push -u origin HEAD'  " 1er push de la rama

" ---- Telescope: pickers Git (si tienes Telescope) ----
command! GFiles         execute 'Telescope git_files'
command! GBranches      execute 'Telescope git_branches'
command! GCommits       execute 'Telescope git_commits'
command! GBufCommits    execute 'Telescope git_bcommits'
command! GChanged       execute 'Telescope git_status'

" ---- Gitsigns: comandos por hunk (1 línea, válidos para :command!) ----
command! HunkStage   lua local gs=package.loaded.gitsigns if gs then gs.stage_hunk() end
command! HunkReset   lua local gs=package.loaded.gitsigns if gs then gs.reset_hunk() end
command! HunkPreview lua local gs=package.loaded.gitsigns if gs then gs.preview_hunk() end
command! LineBlame   lua local gs=package.loaded.gitsigns if gs then gs.blame_line({full=true}) end
command! HunkNext    lua local gs=package.loaded.gitsigns if gs then gs.next_hunk() end
command! HunkPrev    lua local gs=package.loaded.gitsigns if gs then gs.prev_hunk() end

"==================================================
" FIN
"==================================================
