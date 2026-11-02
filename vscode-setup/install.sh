#!/bin/bash
# Installe l'environnement Holberton (macOS ou Linux/WSL) : outils, Betty,
# extensions et réglages VS Code, dotfiles (emacs, shell, git), Claude Code.
# Usage : ./install.sh            (tout installer)
#         ./install.sh --no-sys   (sans paquets système ni Betty)

set -u
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NO_SYS=0
[ "${1:-}" = "--no-sys" ] || [ "${1:-}" = "--no-apt" ] && NO_SYS=1
OS="$(uname -s)"

info() { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$1"; }

# Sauvegarde un fichier existant avant de le remplacer
backup() {
	if [ -e "$1" ] && [ ! -L "$1" ]; then
		cp "$1" "$1.bak.$(date +%Y%m%d%H%M%S)"
		info "Sauvegarde de $1"
	fi
}

# Ajoute une ligne à un fichier si elle n'y est pas déjà
add_line() {
	grep -qxF "$2" "$1" 2>/dev/null || printf '\n%s\n' "$2" >> "$1"
}

GCC_PATH="/usr/bin/gcc"

# ---------- 1. Paquets système ----------
if [ "$NO_SYS" -eq 1 ]; then
	warn "Paquets système ignorés (--no-sys)"
elif [ "$OS" = "Darwin" ]; then
	if ! xcode-select -p >/dev/null 2>&1; then
		info "Installation des Command Line Tools d'Apple"
		xcode-select --install
		warn "Termine l'installation dans la fenêtre qui s'ouvre, puis relance ./install.sh"
		exit 1
	fi
	if ! command -v brew >/dev/null; then
		info "Installation de Homebrew"
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi
	for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
		[ -x "$b" ] && eval "$("$b" shellenv)" && break
	done
	BREW="$(brew --prefix)"
	add_line "$HOME/.zprofile" "eval \"\$($BREW/bin/brew shellenv)\""

	info "Installation des outils (gcc, emacs, git, shellcheck...)"
	brew install gcc emacs git shellcheck clang-format
	info "Polices Geist Mono et JetBrains Mono (design VS Code)"
	brew install --cask font-geist-mono font-jetbrains-mono ||
		warn "Police non installée"

	# Sur Mac, "gcc" lance clang. On fait pointer "gcc" vers le vrai GCC.
	GCCV="$(find "$BREW/bin" -maxdepth 1 -name 'gcc-[0-9]*' | sort -V | tail -1)"
	if [ -n "$GCCV" ]; then
		ln -sf "$GCCV" "$BREW/bin/gcc"
		GCC_PATH="$BREW/bin/gcc"
		info "gcc -> $(basename "$GCCV")"
	fi
elif command -v apt-get >/dev/null; then
	info "Installation des outils (gcc, gdb, valgrind, emacs, git...)"
	sudo apt-get update
	sudo apt-get install -y build-essential gdb valgrind emacs-nox git \
		shellcheck clang-format perl man-db manpages-dev curl
	sudo apt-get install -y fonts-jetbrains-mono ||
		warn "Police JetBrains Mono non installée (optionnelle)"
else
	warn "Gestionnaire de paquets inconnu : installe gcc, emacs, git, shellcheck à la main"
fi

# ---------- 2. Betty ----------
if [ "$NO_SYS" -eq 0 ] && ! command -v betty >/dev/null; then
	info "Installation de Betty (mot de passe demandé)"
	TMP="$(mktemp -d)"
	if git clone --depth 1 https://github.com/hs-hq/Betty.git "$TMP/Betty"; then
		sudo mkdir -p /usr/local/bin /usr/local/share/man/man1
		# mandb n'existe pas sur Mac : l'erreur finale est sans conséquence
		(cd "$TMP/Betty" && sudo ./install.sh 2>/dev/null)
		if command -v betty >/dev/null; then
			info "Betty installé"
		else
			warn "Betty non installé"
		fi
	else
		warn "Impossible de cloner Betty"
	fi
	rm -rf "$TMP"
fi

# ---------- 3. VS Code ----------
if [ "$OS" = "Darwin" ]; then
	CODE_USER="$HOME/Library/Application Support/Code/User"
	CODE_BIN="/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
	[ -d "$CODE_BIN" ] && PATH="$PATH:$CODE_BIN"
else
	CODE_USER="$HOME/.config/Code/User"
fi
mkdir -p "$CODE_USER/snippets"

if command -v code >/dev/null; then
	info "Installation des extensions VS Code"
	grep -v '^[[:space:]]*#' "$DIR/vscode/extensions.txt" |
		grep -v '^[[:space:]]*$' |
		while read -r ext; do
			[ "$OS" = "Darwin" ] && [ "$ext" = "ms-vscode-remote.remote-wsl" ] && continue
			if code --install-extension "$ext" --force >/dev/null 2>&1; then
				echo "  ok  $ext"
			else
				warn "échec $ext"
			fi
		done
else
	warn "Commande 'code' introuvable. Dans VS Code : Cmd/Ctrl+Shift+P >"
	warn "\"Shell Command: Install 'code' command in PATH\", puis relance."
fi

info "Réglages et snippets VS Code"
backup "$CODE_USER/settings.json"
sed "s|\"/usr/bin/gcc\"|\"$GCC_PATH\"|" "$DIR/vscode/settings.json" \
	> "$CODE_USER/settings.json"
cp "$DIR/vscode/snippets/"*.json "$CODE_USER/snippets/"

# ---------- 4. Modèles de projet ----------
info "Modèles de projet dans ~/.holberton-templates (utilisés par newproj)"
mkdir -p "$HOME/.holberton-templates"
cp -R "$DIR/templates/." "$HOME/.holberton-templates/"

# ---------- 5. Dotfiles ----------
info "Emacs (~/.emacs)"
backup "$HOME/.emacs"
cp "$DIR/dotfiles/emacs" "$HOME/.emacs"

info "Alias (~/.bash_aliases, chargé par bash et zsh)"
backup "$HOME/.bash_aliases"
cp "$DIR/dotfiles/bash_aliases" "$HOME/.bash_aliases"
add_line "$HOME/.bashrc" '[ -f ~/.bash_aliases ] && . ~/.bash_aliases'
[ "$OS" = "Darwin" ] &&
	add_line "$HOME/.zshrc" '[ -f ~/.bash_aliases ] && . ~/.bash_aliases'

info "Git"
cp "$DIR/dotfiles/gitconfig-extra" "$HOME/.gitconfig-holberton"
git config --global include.path "$HOME/.gitconfig-holberton"
if [ -z "$(git config --global user.name)" ]; then
	read -r -p "Ton nom pour git : " GNAME
	git config --global user.name "$GNAME"
fi
if [ -z "$(git config --global user.email)" ]; then
	read -r -p "Ton email GitHub : " GMAIL
	git config --global user.email "$GMAIL"
fi

# ---------- 6. Claude Code ----------
info "Claude Code : consignes et skill holberton-check"
mkdir -p "$HOME/.claude/skills"
if [ -e "$HOME/.claude/CLAUDE.md" ]; then
	warn "$HOME/.claude/CLAUDE.md existe déjà : ajoute à la main $DIR/claude/CLAUDE.md"
else
	cp "$DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
fi
cp -R "$DIR/claude/skills/holberton-check" "$HOME/.claude/skills/"

info "Terminé. Ferme et rouvre le terminal (et VS Code)."
