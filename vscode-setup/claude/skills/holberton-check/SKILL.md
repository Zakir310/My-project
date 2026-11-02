---
name: holberton-check
description: Vérifie un projet Holberton avant de pousser : compilation gcc avec les flags Holberton, style Betty, shellcheck, README, fichiers exécutables et fin de ligne. Utiliser quand l'étudiant demande "vérifie mon projet", "est-ce que c'est prêt", "check betty", ou avant un commit/push d'un exercice Holberton.
---

# Vérification d'un projet Holberton

Fais ces contrôles dans le dossier du projet, puis donne un résumé clair :
ce qui passe, ce qui échoue, et comment corriger chaque problème.

1. **README** : il existe un `README.md` non vide.
2. **Fichiers C** : pour chaque `*.c`
   - `betty <fichier>` : aucune ERROR ni WARNING.
   - Compile avec `gcc -Wall -Werror -Wextra -pedantic -std=gnu89`. Si le
     fichier n'a pas de `main`, compile avec le fichier de test fourni
     (`*-main.c`) ou utilise `-c` pour vérifier seulement la compilation.
   - Si un exécutable est produit, lance `valgrind --leak-check=full` quand
     le code utilise `malloc`.
3. **Fichiers .h** : `betty` et include guard présent.
4. **Scripts shell** (fichiers sans extension commençant par `#!` ou `*.sh`)
   - Première ligne `#!/bin/bash`, deuxième ligne commentaire.
   - `shellcheck` sans erreur.
   - Bit exécutable : `test -x`.
5. **Tous les fichiers** : se terminent par une nouvelle ligne
   (`[ -z "$(tail -c1 fichier)" ]` est vrai quand c'est bon).

Si `betty` n'est pas installé, explique comment l'installer :
`git clone https://github.com/hs-hq/Betty.git && cd Betty && sudo ./install.sh`.

Ne corrige pas automatiquement le code de l'étudiant : propose les
corrections et explique pourquoi, sauf s'il demande de corriger.
