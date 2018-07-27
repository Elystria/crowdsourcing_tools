% Crée les masques logiques des images de la base de Pascal par classes 
% Si une image contient des objets de classe differentes, un masque sera
% généré pour chaque classe, et ne représentera que les objets de la classe
% considée

classes = ["Person", "Animal", "Vehicle", "Indoor"];
categories = ['person', ...
    "bird", "cat", "cow", "dog", "horse", "sheep", ...
    "aeroplane", "bicycle", "bus", "boat", "car", "motorbike", "train", ...
    "bottle", "chair", "dining table", "potted plant", "sofa", "tv"];

% indice de fin de catégorie pour chaque classe
% corresponding_Classes = [1, 7, 14, 20];

% Couleurs associées à chaque catégories
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
mkdir('Masques/');
for i=1:nb_categories
    nom_cat = categories(i);
    mkdir(['Masques/' nom_cat{1}]);
end

% Parcourir tous les masques
% Liste toutes les images
liste = dir('SegmentationClass/*.png');
nb_images = size(liste, 1);

for i=1:nb_images
    
    % Charger le masque
    nom_image = liste(i);
    nom_png = nom_image.name;
    Im = imread(['SegmentationClass/', nom_png]);
    splitter = split(nom_png, '.');

    cats = unique(Im);
    nb_cat = length(unique(Im));
    
    % Générer les masques
    for j = 1:nb_cat
        cat = cats(j);
        ind = find(cat==mask_colors);
        
        if ~isempty(ind)
            
            % Créer le masque
            indices_nuls = find(Im ~= cat);
            Im_mask = Im;
            Im_mask(indices_nuls) = 0;
            Im_mask = Im_mask * 255;
            
            % Trouver la classe
            classe = categories(ind);
            
            nom_masque = strcat('Masques/', classe, '/', nom_png);
            % Enregistrer le masque
            imwrite(Im_mask, nom_masque{1});
            
        end
        
    end

end
