# Configuration VS Code pour Holberton

VS Code configuré pour le C (gcc, Betty, gdb, valgrind), le shell, Git et
Emacs, avec Claude Code.

## Installation (une seule commande)

Sur **macOS**, sous Linux ou sous Windows dans **WSL Ubuntu**, dans le
Terminal :

```bash
git clone https://github.com/Zakir310/My-project.git
cd My-project/vscode-setup
./install.sh
```

Pas de droits administrateur ? Lance `./install.sh --no-sys`.

### Spécificités macOS

- Le script installe les *Command Line Tools* d'Apple, puis
  [Homebrew](https://brew.sh), puis GCC, Emacs et shellcheck.
- Sur Mac, `gcc` lance clang. Le script fait donc pointer `gcc` vers le vrai
  GCC de Homebrew, comme à Holberton.
- Il n'y a pas de gdb ni de valgrind sur les Mac récents. Le kit utilise
  **lldb** (extension CodeLLDB) pour déboguer avec `F5`, et l'outil
  **leaks** d'Apple à la place de valgrind (alias `vg`).
- Les raccourcis VS Code utilisent `Cmd` au lieu de `Ctrl` pour
  `Cmd+Shift+B` et `Cmd+Shift+P`.
- La correction de Holberton tourne sous Ubuntu : pour les exercices mémoire
  (valgrind), vérifie aussi dans le sandbox Holberton.

Avant de l'écraser, le script sauvegarde chaque fichier existant
(`settings.json`, `.emacs`, `.bash_aliases`) en `*.bak.<date>`.

> **Sous WSL** : ouvre VS Code depuis le terminal Ubuntu avec `code .`. Pour
> appliquer les réglages côté Windows aussi : `Ctrl+Shift+P` >
> *Preferences: Open User Settings (JSON)*, puis colle le contenu de
> `vscode/settings.json`.

## Ce qui est installé

| Domaine | Contenu |
|---|---|
| Outils | gcc, gdb, valgrind, emacs, git, shellcheck, clang-format, Betty |
| Extensions | C/C++, CodeLLDB, Makefile, ShellCheck, shell-format, Bash IDE, Code Runner, GitLens, Git Graph, GitHub PR, Emacs keymap, Error Lens, indent-rainbow, Todo Tree, Material Icons, Hex Editor, Live Share, Live Server, Prettier, Python, autopep8, Markdown, correcteur FR/EN, SSH/WSL, Claude Code |
| Réglages | tabulations de 8 en C et shell, règle à 80 colonnes, `gnu89`, suppression des espaces en fin de ligne, nouvelle ligne finale |
| Snippets | `bmain`, `bfunc`, `bstruct`, `bheader`, `bputchar` (C), `bash` (shell) |
| Emacs | `~/.emacs` au style Linux/Betty, `F5` compile avec les flags Holberton |
| Bash | alias `gccw`, `gccg`, `vg`, `bettyall`, `gs`, `gl`, `gacp "msg"`, `newproj nom` |
| Git | alias `git st`, `git lg`, `git undo`, branche `main` par défaut |
| Claude Code | `~/.claude/CLAUDE.md` (règles Holberton) + skill `/holberton-check` |

## Utilisation au quotidien

1. `newproj holbertonschool-low_level_programming/0x02-functions` crée le
   dossier, le README, `.vscode/`, `.clang-format` et `.editorconfig`.
2. `code .` pour ouvrir le projet.
3. Tape `bmain` ou `bfunc` puis `Tab` pour avoir le squelette Betty.
4. Raccourcis :

| Action | Raccourci |
|---|---|
| Compiler (flags Holberton) | `Ctrl+Shift+B` |
| Compiler et lancer en un clic | bouton ▶ (Code Runner) ou `Ctrl+Alt+N` |
| Voir le portfolio en direct | clic droit sur `index.html` > *Open with Live Server* |
| Coder à deux (peer learning) | Live Share dans la barre du bas |
| Déboguer avec gdb | `F5` |
| Betty / valgrind / shellcheck | `Ctrl+Shift+P` > *Run Task* |
| Formater (proche de Betty) | `Shift+Alt+F` |
| Terminal intégré | ``Ctrl+` `` |
| Git (stage, commit, push) | `Ctrl+Shift+G` |

5. Les erreurs de Betty et gcc s'affichent directement dans l'onglet
   *Problèmes* et sur les lignes concernées (Error Lens).
6. Avant de pousser, dans Claude Code : `/holberton-check`.
7. `gacp "Add task 0"` pour ajouter, commiter et pousser.

## Design : noir minimaliste

- Thème sur mesure aux couleurs du portfolio : fond `#04060B`, texte blanc
  cassé, mots-clés en bleu `#3B6BFF`, commentaires gris en italique.
- Construit sur le thème intégré *Default Dark Modern* : aucune extension de
  thème à installer.
- Police **Geist Mono** (repli : JetBrains Mono, puis Menlo).
- Pas d'arc-en-ciel ni de bordures inutiles. Icônes sobres (*Symbols*),
  défilement et curseur fluides.
- Pour revenir au thème d'origine : `Cmd+K` puis `Cmd+T` > *Default Dark
  Modern* reste la base. Supprime le bloc `workbench.colorCustomizations`
  dans les réglages si tu veux enlever les couleurs perso.

## Mode Emacs

L'extension *Awesome Emacs Keymap* active les raccourcis Emacs dans VS Code
(`C-x C-s` sauver, `C-a`/`C-e` début/fin de ligne, `C-k` couper, `C-y` coller,
`C-s` chercher). C'est utile pour s'entraîner aux examens qui se font dans le
terminal. Pour revenir aux raccourcis classiques, désactive l'extension.

## Structure

```
vscode-setup/
├── install.sh
├── vscode/        settings.json, extensions.txt, snippets/
├── templates/     .vscode/ (tasks, launch), .clang-format, .editorconfig
├── dotfiles/      emacs, bash_aliases, gitconfig-extra
└── claude/        CLAUDE.md, skills/holberton-check/
```
