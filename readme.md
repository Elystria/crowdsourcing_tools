# Crowdsourcing tools

Ce git présente un ensemble de scripts utilisés pour faciliter la préparation d'une campagne de crowdsourcing d'annotation d'images de la base PASCAL 2012 sur la plateforme Amazon Mechanical Turk. 
Ces outils ont été utilisés en complétion de l'application située [ici](https://github.com/Elystria/elystria.github.io)


## Contenu du git
### utilitaires_bdd : 
ensemble de scripts destinés à générer des masques binaires de la base et classer les images par catégories

### outils_validation : 
Permet de visualiser les résultats de la campagne en vue de l'acceptation ou du rejet des tâches.
Permet également d'évaluer la vitesse avec laquelle les tâches ont été effectuées

### otis_analysis :
Segmente les images avec Graphcut à partir des outlines récupérés
Permet d'évaluer les scores de Jaccard des résultats
