# Standalone Zsh configuration.
#
# This file only relies on Zsh and, when present, the Git command-line tool.

# Keep the terminal pleasant without changing application-specific behavior.
setopt AUTO_CD                 # Type a directory name to enter it.
setopt AUTO_PUSHD              # Keep visited directories on the directory stack.
setopt PUSHD_IGNORE_DUPS       # Do not add duplicate stack entries.
setopt INTERACTIVE_COMMENTS    # Allow comments on an interactive command line.
setopt CORRECT                 # Offer corrections for mistyped commands.
setopt NO_BEEP                 # Do not beep for completion/correction feedback.
setopt PROMPT_SUBST            # Allow command/parameter substitution inside the prompt.

# History: one shared, de-duplicated file across terminal sessions.
HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY

# Completion is provided by Zsh itself. The cache makes large completion trees
# responsive while remaining safe to delete at any time.
autoload -Uz compinit
_dotfiles_compdump="${ZDOTDIR:-$HOME}/.zcompdump"
compinit -d "$_dotfiles_compdump"
unset _dotfiles_compdump

# Familiar, deliberately small aliases. Commands that can remove data retain
# their usual names and require their usual explicit flags.
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias c='clear'
alias l='ls -lah'
alias la='ls -A'
alias ll='ls -lh'

# Let a per-machine file add private settings such as PATH entries, work
# aliases, or secrets without putting them in version control.
[[ -r "${ZDOTDIR:-$HOME}/.zshrc.local" ]] && source "${ZDOTDIR:-$HOME}/.zshrc.local"

# ---------------------------------------------------------------------------
# Powerline-style prompt, reproducing a 5-segment oh-my-posh theme
# (session -> path -> git -> root -> status) in plain Zsh — no oh-my-zsh,
# no oh-my-posh binary.
#
# Requires a Powerline-patched / Nerd Font in the terminal to render the
# diamond caps, arrows, and icons correctly. Also requires a true-color
# terminal, since colors below are 24-bit hex (zsh supports %F{#rrggbb}
# and %K{#rrggbb} natively since 5.8).
# ---------------------------------------------------------------------------

autoload -Uz add-zsh-hook

# Separator / cap glyphs.
ARROW=$'\ue0b0'         #  powerline arrow, closes a segment
ROUND_LEFT=$'\ue0b6'    #  rounded left cap (start of the prompt)
ROUND_RIGHT=$'\ue0b4'   #  rounded right cap (end of the prompt)

# Icons. All require a Nerd Font (see README.md) — without one these render
# as boxes, question marks, or missing-glyph placeholders.
SSH_ICON=$'\ueba9'          # prefixes the username when connected over SSH
FOLDER_ICON=$'\uea83'       # directory segment
BRANCH_ICON=$'\ue0a0'       # git branch name prefix
UPSTREAM_GITHUB_ICON=$'\uf408'    # shown instead of the generic git icon
UPSTREAM_GITLAB_ICON=$'\uf296'    # when the tracked remote's URL matches
UPSTREAM_BITBUCKET_ICON=$'\uf171' # github.com / gitlab.com / bitbucket.org
UPSTREAM_GIT_ICON=$'\ue708'       # fallback for any other remote host
WORKING_ICON=$'\uf044'   # pencil — unstaged (working tree) changes
STAGING_ICON=$'\uf046'   # filled box — staged (index) changes
ROOT_ICON=$'\uf0e7'      # bolt — shown only when running as root
STATUS_OK_ICON=$'\uf00c' # check — last command exited 0
STATUS_ERR_ICON=$'\uf00d' # cross — last command exited non-zero

# Palette, straight from the theme's "palette" block.
P_BLACK='#262B44'
P_BLUE='#4B95E9'
P_GREEN='#59C9A5'
P_ORANGE='#F07623'
P_RED='#D81E5B'
P_WHITE='#E0DEF4'
P_YELLOW='#F3AE35'

CURRENT_BG='NONE'

# Draws one powerline block.
#
# On the transition into a new segment, this prints a "black diamond" gap
# instead of a single blended arrow: a right-pointing triangle colored as
# the PREVIOUS segment's background (sitting on black), immediately
# followed by a left-pointing triangle colored black (sitting on the NEW
# segment's background). The two triangles together form a solid black
# wedge between every pair of segments.
#
# prompt_segment <background> <foreground> [content] [no_leading_pad]
prompt_segment() {
    local bg fg lead_pad=' '
    [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
    [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
    [[ -n $4 ]] && lead_pad=''

    if [[ "$CURRENT_BG" != 'NONE' ]]; then
        print -n "%{%K{$P_BLACK}%F{$CURRENT_BG}%}${ARROW}%{$bg%F{$P_BLACK}%}${ARROW}%{$fg%}${lead_pad}"
    else
        print -n "%{$bg%}%{$fg%}${lead_pad}"
    fi
    CURRENT_BG=$1
    [[ -n $3 ]] && print -n "$3 "
}

# Closes the segment chain: caps the right edge of the last drawn segment
# with a rounded cap (ROUND_RIGHT) fading back to the terminal's own
# background, then resets colors so command output isn't tinted.
prompt_end() {
    if [[ "$CURRENT_BG" != 'NONE' ]]; then
        print -n "%{%k%F{$CURRENT_BG}%}${ROUND_RIGHT}"
    else
        print -n "%{%k%}"
    fi
    print -n "%{%f%}"
    CURRENT_BG='NONE'
}

# Session: username, yellow, opens the whole prompt with a rounded cap.
# Shows an SSH icon prefix when connected over SSH.
prompt_session() {
    local content="%n"
    [[ -n "$SSH_CONNECTION" ]] && content="${SSH_ICON} %n"
    print -n "%{%F{$P_YELLOW}%}${ROUND_LEFT}"
    prompt_segment "$P_YELLOW" "$P_BLACK" "$content" 1
}

# Path: current directory, orange.
prompt_path() {
    prompt_segment "$P_ORANGE" "$P_WHITE" "${FOLDER_ICON} %1~"
}

# Git: branch + status. Green by default; foreground/background react to
# state, with LATER templates overriding EARLIER ones when more than one
# condition is true (mirrors the theme's own template evaluation order).
prompt_git() {
    command -v git >/dev/null 2>&1 || return
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return

    local branch git_status line x y remote_url upstream_icon
    local ahead=0 behind=0 working=0 staging=0 bg fg

    branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) || \
        branch=$(git rev-parse --short HEAD 2>/dev/null) || return
    git_status=$(git status --porcelain=2 --branch 2>/dev/null) || return

    # Upstream icon: only shown when this branch tracks a remote.
    if git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' >/dev/null 2>&1; then
        remote_url=$(git remote get-url origin 2>/dev/null)
        case "$remote_url" in
            *github.com*)    upstream_icon=$UPSTREAM_GITHUB_ICON ;;
            *gitlab.com*)    upstream_icon=$UPSTREAM_GITLAB_ICON ;;
            *bitbucket.org*) upstream_icon=$UPSTREAM_BITBUCKET_ICON ;;
            *)               upstream_icon=$UPSTREAM_GIT_ICON ;;
        esac
    fi

    # Walk `git status --porcelain=2` line by line to detect staged vs.
    # unstaged changes. Format per entry type:
    #   "1 XY ...<path>"        ordinary changed file — X=index, Y=worktree
    #   "2 XY ...<path> <orig>" renamed/copied file — same XY meaning
    #   "u XY ...<path>"        unmerged/conflicted file
    # X (or Y) is '.' when that side has no change, any other char means
    # a change is present there.
    while IFS= read -r line; do
        case "$line" in
            '1 '*|'2 '*)
                x=${line[4]}
                y=${line[5]}
                [[ "$x" != '.' ]] && staging=1
                [[ "$y" != '.' ]] && working=1
                ;;
            'u '*) working=1 ;;
        esac
    done <<< "$git_status"

    # The branch header line looks like "# branch.ab +<ahead> -<behind>"
    # when a remote is tracked; absent entirely for a branch with no
    # upstream, in which case ahead/behind stay at their default of 0.
    if [[ "$git_status" =~ '# branch\.ab \+([0-9]+) -([0-9]+)' ]]; then
        ahead=$match[1]
        behind=$match[2]
    fi

    # foreground_templates, in order — later true condition wins.
    fg=$P_BLACK
    (( working || staging ))      && fg=$P_BLACK
    (( ahead > 0 && behind > 0 )) && fg=$P_WHITE
    (( ahead > 0 ))                && fg=$P_WHITE

    # background_templates, in order — later true condition wins.
    bg=$P_GREEN
    (( working || staging ))      && bg=$P_YELLOW
    (( ahead > 0 && behind > 0 )) && bg=$P_RED
    (( ahead > 0 ))                && bg='#49416D'
    (( behind > 0 ))               && bg='#7A306C'

    local info=""
    [[ -n "$upstream_icon" ]] && info+="${upstream_icon} "
    info+="${BRANCH_ICON} ${branch}"
    if (( ahead > 0 )); then
        info+=" ↑${ahead}"
    fi
    if (( behind > 0 )); then
        info+=" ↓${behind}"
    fi
    # "≡" only when there IS a tracked remote and it's fully in sync —
    # a local-only branch (no upstream_icon) shows neither ahead/behind
    # counts nor this symbol, since there's nothing to compare against.
    if [[ $ahead -eq 0 && $behind -eq 0 && -n "$upstream_icon" ]]; then
        info+=" ≡"
    fi
    (( working ))    && info+=" ${WORKING_ICON}"
    (( staging ))    && info+=" ${STAGING_ICON}"

    prompt_segment "$bg" "$fg" "$info"
}

# Root: only shown when running as root, yellow.
prompt_root() {
    (( UID == 0 )) && prompt_segment "$P_YELLOW" "$P_WHITE" "$ROOT_ICON"
}

# Status: exit code of the last command, blue on success, red on failure.
prompt_status() {
    local bg=$P_BLUE icon=$STATUS_OK_ICON
    if (( RETVAL != 0 )); then
        bg=$P_RED
        icon=$STATUS_ERR_ICON
    fi
    prompt_segment "$bg" "$P_WHITE" "$icon"
}

PROMPT_INITIALIZED=0

prompt_main() {
    RETVAL=$?
    CURRENT_BG='NONE'
    prompt_session
    prompt_path
    prompt_git
    prompt_root
    prompt_status
    prompt_end
}

prompt_precmd() {
    if [[ $PROMPT_INITIALIZED -eq 0 ]]; then
        PROMPT='%{%f%b%k%}$(prompt_main) '
        PROMPT_INITIALIZED=1
    else
        PROMPT=$'\n''%{%f%b%k%}$(prompt_main) '
    fi
}

add-zsh-hook precmd prompt_precmd

# Command syntax highlighting and history-based suggestions.
# Installed via apt (zsh-syntax-highlighting, zsh-autosuggestions packages).
[[ -r /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

[[ -r /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
