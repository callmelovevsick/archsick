# ============================================================
# ArchSick .zshrc
# Developer: lovevsick
# ============================================================

# ── Performance: skip compinit on cached dump ─────────────────
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# ── Oh-My-Zsh ────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    colored-man-pages
    command-not-found
    extract
    z
)

[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# ── Powerlevel10k instant prompt ─────────────────────────────
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ── Environment ──────────────────────────────────────────────
export EDITOR=nano
export VISUAL=codium
export BROWSER=firefox
export PAGER=less
export MANPAGER="sh -c 'col -bx | bat -l man -p'" 2>/dev/null || export MANPAGER=less
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# ── C++ development ──────────────────────────────────────────
export CC=/usr/bin/gcc
export CXX=/usr/bin/g++
export CPP_STD="-std=c++17"

# Competitive programming shortcut
alias cpp='g++ -std=c++17 -O2 -Wall -Wextra'
alias cppdebug='g++ -std=c++17 -O0 -g -fsanitize=address,undefined -Wall'
alias run='./a.out'

# ── Git aliases ───────────────────────────────────────────────
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias glog='git log --oneline --graph --decorate'

# ── System aliases ────────────────────────────────────────────
alias ls='ls --color=auto -F'
alias ll='ls -la'
alias la='ls -A'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ps='ps auxf'
alias top='btop'
alias vim='nano'

# ── pacman / yay aliases ──────────────────────────────────────
alias pac='sudo pacman'
alias pacS='sudo pacman -S'
alias pacSyu='sudo pacman -Syu'
alias pacRns='sudo pacman -Rns'
alias pacSs='pacman -Ss'
alias pacQ='pacman -Q | grep'
alias y='yay'
alias ys='yay -S'
alias yu='yay -Syu'

# ── Navigation ───────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias dev='cd ~/Dev'
alias cfg='cd ~/.config'

# ── ArchSick utils ───────────────────────────────────────────
alias sick-update='sudo pacman -Syu && yay -Syu'
alias sick-clean='sudo pacman -Sc --noconfirm && sudo pacman -Rns $(pacman -Qtdq) 2>/dev/null; sudo journalctl --vacuum-size=50M'
alias sick-stats='echo "=== Memory ===" && free -h && echo "=== CPU ===" && grep "cpu MHz" /proc/cpuinfo | head -4 && echo "=== Disk ===" && df -h /'
alias sick-bench='stress-ng --cpu 0 --timeout 10s 2>/dev/null || echo "Install stress-ng"'

# ── CMake helpers ─────────────────────────────────────────────
alias cmake-release='cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release && cmake --build build -j$(nproc)'
alias cmake-debug='cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug && cmake --build build -j$(nproc)'

# ── Gaming ────────────────────────────────────────────────────
alias osu='gamemoderun osu'
alias mc='gamemoderun prismlauncher'

# ── Functions ────────────────────────────────────────────────
# Quick C++ compile and run
cr() {
    local src="${1:-main.cpp}"
    local bin="${src%.cpp}"
    g++ -std=c++17 -O2 -Wall "$src" -o "$bin" && ./"$bin"
}

# Make dir and cd into it
mcd() { mkdir -p "$1" && cd "$1"; }

# Extract any archive
extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz)  tar xzf "$1" ;;
            *.tar.xz)  tar xJf "$1" ;;
            *.tar.zst) tar --use-compress-program=unzstd -xf "$1" ;;
            *.bz2)     bunzip2 "$1" ;;
            *.gz)      gunzip  "$1" ;;
            *.tar)     tar xf  "$1" ;;
            *.tbz2)    tar xjf "$1" ;;
            *.tgz)     tar xzf "$1" ;;
            *.zip)     unzip   "$1" ;;
            *.7z)      7z x    "$1" ;;
            *.rar)     unrar x "$1" ;;
            *)         echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick HTTP server
serve() {
    local port="${1:-8080}"
    echo "Serving $(pwd) at http://localhost:$port"
    python -m http.server "$port"
}

# ── Zsh options ───────────────────────────────────────────────
setopt AUTO_CD
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt COMPLETE_ALIASES
setopt CORRECT
setopt CORRECT_ALL 2>/dev/null || true
setopt NO_BEEP

HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history

# ── Completion ───────────────────────────────────────────────
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

# ── Fastfetch on new terminal (once per session) ──────────────
if [[ -z "$ARCHSICK_FETCHED" ]] && [[ -o interactive ]] && command -v fastfetch &>/dev/null; then
    export ARCHSICK_FETCHED=1
    fastfetch --config ~/.config/fastfetch/config.jsonc 2>/dev/null || fastfetch
fi
