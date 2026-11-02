#!/bin/bash
# Installe l'environnement Holberton : outils Linux, Betty, extensions et
# réglages VS Code, dotfiles (emacs, bash, git) et réglages Claude Code.
# Usage : ./install.sh            (tout installer)
#         ./install.sh --no-apt   (sans paquets système, ex. sans sudo)

set -u
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NO_APT=0
[ "${1:-}" = "--no-apt" ] && NO_APT=1

info() { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$1"; }

# Sauvegarde un fichier existant avant de le remplacer
backup() {
	if [ -e "$1" ] && [ ! -L "$1" ]; then
		cp "$1" "$1.bak.$(date +%Y%m%d%H%M%S)"
		info "Sauvegarde de $1"
	fi
}

# ---------- 1. Paquets système ----------
if [ "$NO_APT" -eq 0 ] && command -v apt-get >/dev/null; then
	info "Installation des outils (gcc, gdb, valgrind, emacs, git...)"
	sudo apt-get update
	sudo apt-get install -y build-essential gdb valgrind emacs-nox git \
		shellcheck clang-format perl man-db manpages-dev curl
else
	warn "apt ignoré : installe gcc, gdb, valgrind, emacs, git, shellcheck à la main"
fi

# ---------- 2. Betty ----------
if ! command -v betty >/dev/null && [ "$NO_APT" -eq 0 ]; then
	info "Installation de Betty"
	TMP="$(mktemp -d)"
	if git clone --depth 1 https://github.com/hs-hq/Betty.git "$TMP/Betty"; then
		(cd "$TMP/Betty" && sudo ./install.sh)
	else
		warn "Impossible de cloner Betty"
	fi
	rm -rf "$TMP"
fi

# ---------- 3. VS Code ----------
case "$(uname -s)" in
	Darwin) CODE_USER="$HOME/Library/Application Support/Code/User" ;;
	*) CODE_USER="$HOME/.config/Code/User" ;;
esac
# Sous WSL, les réglages vivent côté Windows : on les écrit quand même ici
# pour le serveur WSL, et le README explique comment les copier côté Windows.
mkdir -p "$CODE_USER/snippets"

if command -v code >/dev/null; then
	info "Installation des extensions VS Code"
	grep -v '^\s*#' "$DIR/vscode/extensions.txt" | grep -v '^\s*$' |
		while read -r ext; do
			if code --install-extension "$ext" --force >/dev/null; then
				echo "  ok  $ext"
			else
				warn "échec $ext"
			fi
		done
else
	warn "Commande 'code' introuvable. Dans VS Code : Ctrl+Shift+P >"
	warn "\"Shell Command: Install 'code' command in PATH\", puis relance."
fi

info "Réglages et snippets VS Code"
backup "$CODE_USER/settings.json"
cp "$DIR/vscode/settings.json" "$CODE_USER/settings.json"
cp "$DIR/vscode/snippets/"*.json "$CODE_USER/snippets/"

# ---------- 4. Modèles de projet ----------
info "Modèles de projet dans ~/.holberton-templates (utilisés par newproj)"
mkdir -p "$HOME/.holberton-templates"
cp -r "$DIR/templates/." "$HOME/.holberton-templates/"

# ---------- 5. Dotfiles ----------
info "Emacs (~/.emacs)"
backup "$HOME/.emacs"
cp "$DIR/dotfiles/emacs" "$HOME/.emacs"

info "Alias bash (~/.bash_aliases)"
backup "$HOME/.bash_aliases"
cp "$DIR/dotfiles/bash_aliases" "$HOME/.bash_aliases"
if ! grep -q 'bash_aliases' "$HOME/.bashrc" 2>/dev/null; then
	printf '\n[ -f ~/.bash_aliases ] && . ~/.bash_aliases\n' >> "$HOME/.bashrc"
fi

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
cp -r "$DIR/claude/skills/holberton-check" "$HOME/.claude/skills/"

info "Terminé. Ouvre un nouveau terminal (ou : source ~/.bashrc)."
