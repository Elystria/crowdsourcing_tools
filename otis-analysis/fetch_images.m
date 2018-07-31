function fetch_images( path )

% Go through the csv file and copy the images needed for the segmentation
% in the path folder

datas = csv2cell([path, '/batch.csv'],'fromfile');
[nb_colonnes, nb_lignes] = size(datas);
datas = reshape (datas, nb_colonnes, nb_lignes);
indice_nom_img = 30;

for i=2:nb_colonnes
    
    hit = datas(i, :);
    
    % trouver le nom de l'image
    URL = hit(indice_nom_img);
    
    nom_image = split(URL, '/');
    nom_image = nom_image(end);
    nom_image = strcat('Train/', nom_image);
    
    % Copier le fichier dans le path
    copyfile(nom_image{1}, path);
    
end

end

