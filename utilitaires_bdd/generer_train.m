% Trie toutes les images Train de la base de Pascal dans des dossiers
% correspondant à leur classe.
% Lancer ce script à l'emplacement de SegmentationClass et train.txt pour générer les
% dossiers. Il est nécessaire d'avoir lancé classification_images avant de
% lancer ce script.
% train.txt est la liste des images de train pour la segmentation. On le
% trouve dans le développement kit de Pascal, dans ImageSets/Segmentation. 
% Peut aussi être utilisé avec trainVal et val

categories = ['person', ...
    "bird", "cat", "cow", "dog", "horse", "sheep", ...
    "aeroplane", "bicycle", "bus", "boat", "car", "motorbike", "train", ...
    "bottle", "chair", "dining table", "potted plant", "sofa", "tv"];

nb_categories = size(categories,2);

%Créer une liste de toutes les images par catégorie
for i=1:nb_categories
    
    % Lister toutes les images
    nom_cat = categories(i);
    nom_dossier = strcat('Images_classees/', nom_cat{1});
    noms_dossier_ext = strcat(nom_dossier, '/*.jpg');
    listing = dir(noms_dossier_ext);
    
    % Créer un fichier
    nom_fichier = [nom_dossier, '/liste_images.txt'];
    fid = fopen(nom_fichier,'wt');
    
    % Ecrire les noms des images dans le fichier
    for j=1:size(listing, 1)
        nom_image = listing(j).name;
        splitter = split(nom_image, '.');
        nom_image = splitter{1};
        fprintf(fid, [nom_image, '\n']);
        
    end
    fclose(fid);

end

% Lister la totalité des images train dans une matrice
noms_images_train = [];
fileID = fopen('train.txt', 'r');
ligne = fgetl(fileID);
while ischar(ligne)
   noms_images_train = [noms_images_train; ligne];
   ligne = fgetl(fileID);
end
fclose(fileID);

% Répartir les images de Train dans le bon dossier
for i =1:nb_categories
   
    % Créer le dossier train
    nom_cat = categories(i);
    mkdir(['Train/', nom_cat{1} ,'_train']);
    
    %Lister toutes les images de la catégorie
    noms_images_cat = [];
    fileID = fopen(['Images_classees/', nom_cat{1}, '/liste_images.txt'], 'r');
    ligne = fgetl(fileID);
    while ischar(ligne)
        noms_images_cat = [noms_images_cat; ligne];
        ligne = fgetl(fileID);
    end
    fclose(fileID);
    
    %Chercher les images qui font partie de train et de la catégorie
    images_finales = intersect(noms_images_cat, noms_images_train, 'rows');
    
    % Les mettre dans le dossier train
    for k=1:size(images_finales,1)
        
        copyfile(['Images_classees/', nom_cat{1}, '/', images_finales(k,:), '.jpg'], ['Train/',nom_cat{1},'_train/']);
    end

    
end
