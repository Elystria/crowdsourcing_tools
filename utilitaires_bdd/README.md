# Utilitaire 
Ce dossier contient quelques outils pour exploiter plus facilement les images de Pascal destinées à être utilisées en segmentation.
Avant de commencer, il est nécessaire de copier les dossiers JPEGImages et SegmentationClass du dévelopment kit pascal dans ce dossier
http://host.robots.ox.ac.uk/pascal/VOC/voc2012/#devkit 

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
