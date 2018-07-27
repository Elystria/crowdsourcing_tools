function generate_json(path)
% Post-traitement : 

% Convertit le .csv récupéré depuis mturk en plusieurs .json compatible avec notre
% implémentation de otis

% Ouvrir le .csv
fid = fopen([path, '/batch.csv']);

% On passe la première ligne
ligne = fgetl(fid);
splitter = split(ligne, '|');
indice_nom_img = find(strcmp(splitter, 'Input.img_url'));
indice_json = find(strcmp(splitter, 'Answer.annotation-data'));
indice_approve = find(strcmp(splitter, 'Approve'));
indice_reject = find(strcmp(splitter, 'Reject'));

while ischar(ligne)
    
    %ligne vide : sortir
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
        
        nom_fichier = split(nom_image, '.');
        nom_fichier = nom_fichier(end-1);
        nom_fichier = strcat(path, '/', nom_fichier{1}, '.json');
        
        % Créer le fichier
        fidim = fopen(nom_fichier,'w');
        
        %Adapter le contenu :
        str = splitter{indice_json};
        str = str(2:end-1);
        str = strrep(str, '""', '"');
        
        % Ecrire le contenu du json
        fprintf(fidim, str);
        
        fclose(fidim);
    end
end
fclose(fid);


% Séparer chaque 