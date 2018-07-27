function fetch_images( path )
% Go through the csv file and copy the images needed for the segmentation
% in the path folder

fid = fopen([path, '/batch.csv']);

ligne = fgetl(fid);
splitter = split(ligne, '|');
indice_nom_img = find(strcmp(splitter, 'Input.img_url'));
indice_approve = find(strcmp(splitter, 'Approve'));
indice_reject = find(strcmp(splitter, 'Reject'));

while ischar(ligne)
    
    % ligne vide : sortir
    ligne = fgetl(fid);
    if ~ischar(ligne)
        break;
    end
        
    splitter = split(ligne, '|');
    
    if isempty(splitter{indice_reject}) 
        % trouver le nom de l'image
        URL = splitter{indice_nom_img};
        
        nom_image = split(URL, '/');
        nom_image = nom_image(end);
        nom_image = strcat('Train/', nom_image);
        
        % Copier le fichier dans le path
        copyfile(nom_image{1}, path);  
    end
    
    
end
fclose(fid);

end

