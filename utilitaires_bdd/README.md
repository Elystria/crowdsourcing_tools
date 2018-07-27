# Utilitaire BDD

Ce dossier contient une version très allégée de la base de données PASCAL 2012.
Il contient quelques outils pour utiliser plus facilement les images destinées à être utilisées en segmentation.

## Contenu du dossier
### JPEGImages
Contient toutes les images en vrac de la base de données Pascal

### SegmentationClass
Contient les masques de segmentation des images. Chaque couleur correspond à une classe

### classification_images.m
Trie toutes les images de la BDD par dossiers de classe. 

### generer_train
Sélectionne uniquement les images de la BDD spécifiées dans le fichier train et les trie par classe

### masques.m
Crée les masques binaires des images par classe d'objet. Utile pour calculer les scores de Jaccard par exemple.
