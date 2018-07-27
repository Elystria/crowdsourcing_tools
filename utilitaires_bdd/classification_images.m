% Trie toutes les images de la base de Pascal dans des dossiers
% correspondant à leur classe.
% Lancer ce script à l'emplacement de SegmentationClass et JPEGImages pour générer le
% dossier Images_classees

clear;

% classes = ["Person", "Animal", "Vehicle", "Indoor"];
% % indice de fin de catégorie pour chaque classe
% corresponding_Classes = [1, 7, 14, 20];

categories = ['person', ...
    "bird", "cat", "cow", "dog", "horse", "sheep", ...
    "aeroplane", "bicycle", "bus", "boat", "car", "motorbike", "train", ...
    "bottle", "chair", "dining table", "potted plant", "sofa", "tv"];



% Couleurs associées à chaque catégories (RGB, utiles pour Python)
% mask_colors = [[192; 128; 128], [128;128;0] , [64; 0; 0],...
%                [64; 128;0], [64; 0; 128], [192; 0; 128],...
%                [128; 64; 0] , [128; 0; 0] , [0; 128; 0] ,...
%                [0; 128; 128] ,[0; 0; 128] ,[128; 128; 128],...
%                [64; 128; 128], [128; 192; 0], [128; 0 ; 128],...
%                [192; 0; 0], [192; 128; 0], [0; 64; 0],...
%                [0; 192; 0], [0; 64; 128]];

mask_colors = [15, ...
    3, 8, 10, 12, 13, 17, ...
    1, 2, 6, 4, 7, 14, 19, ...
    5, 9, 11, 16, 18, 20];

% Paramètres
nb_categories = size(categories,2);

% Créer les dossiers
mkdir('Images_classees/');

for i=1:nb_categories
    nom_cat = categories(i);
    mkdir(['Images_classees/' nom_cat{1}]);
end

% Parcourir tous les masques
% Liste toutes les images
liste = dir('SegmentationClass/*.png');
nb_images = size(liste, 1);

for i=1:nb_images
    
    % Charger le masque
    nom_image = liste(i);
    Im = imread(['SegmentationClass/', nom_image.name]);
    
    % Trouver l'image correspondante
    nom_png = nom_image.name;
    splitter = split(nom_png, '.');
    nom_jpg = ['JPEGImages/' splitter{1} '.jpg'];
    
    % Trouver les catégories dans le masque
    cat_presentes = [];
    for j=1:nb_categories
        couleur_act = mask_colors(j);
        ind = find(Im == couleur_act);
        if ~isempty(ind)
            cat_presentes = [cat_presentes categories(j)]; % On ajoute la catégorie
        end
        
    end
    
    % La copier dans le(s) dossier(s) correspondant(s)
    for k=1:size(cat_presentes,2)
        nom_cat = cat_presentes(k);
        copyfile(nom_jpg, ['Images_classees/' nom_cat{1}, '/']);
    end

end

