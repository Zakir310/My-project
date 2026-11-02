# Consignes Holberton School

Je suis étudiant à Holberton School. Respecte ces règles dans mes projets :

## C
- Compilation : `gcc -Wall -Werror -Wextra -pedantic -std=gnu89`
- Style Betty obligatoire : tabulations, 80 colonnes max, 40 lignes max par
  fonction, 5 fonctions max par fichier.
- Chaque fonction a un commentaire de documentation Betty (`/** ... */` avec
  `nom - description`, `@param:` et `Return:`).
- Pas de variables globales sauf si le sujet l'autorise.
- Prototypes dans le fichier `.h` demandé, avec include guard.
- Seules les fonctions autorisées par le sujet sont permises (souvent
  `_putchar`, `malloc`, `free`, `write`...).
- Tous les fichiers finissent par une nouvelle ligne.

## Shell
- Première ligne : `#!/bin/bash`, deuxième ligne : un commentaire qui décrit
  le script.
- Le script doit être exécutable et passer `shellcheck`.
- Souvent : pas de `&&`, `||`, `;`, backticks ni `bc`/`sed`/`awk` si le sujet
  l'interdit. Lis toujours le sujet avant.

## Git
- Un `README.md` à la racine de chaque projet et de chaque dossier.
- Messages de commit courts et clairs.

## Façon d'aider
- Explique-moi le raisonnement, je dois comprendre pour les examens et la
  peer learning. Ne me donne pas juste la solution sans explication.
- Vérifie Betty et la compilation avant de dire qu'un exercice est terminé.
