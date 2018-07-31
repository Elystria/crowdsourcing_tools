function[nb_images] = generate_json(path)
% Post-traitement :

% Convertit le .csv récupéré depuis mturk en plusieurs .json compatible avec notre
% implémentation de otis

% Ouvrir le .csv
% fid = fopen([path, '/batch.csv']);
%
% % On passe la première ligne
% ligne = fgetl(fid);
% splitter = split(ligne, '|');
% indice_nom_img = find(strcmp(splitter, 'Input.img_url'));
% indice_json = find(strcmp(splitter, 'Answer.annotation-data'));
% indice_approve = find(strcmp(splitter, 'Approve'));
% indice_reject = find(strcmp(splitter, 'Reject'));

datas = csv2cell([path, '/batch.csv'],'fromfile');
[nb_colonnes, nb_lignes] = size(datas);
datas = reshape (datas, nb_colonnes, nb_lignes);
indice_nom_img = 30;
indice_json = 31;
indice_rejet = 22;

nb_images = 0;

for i=2:nb_colonnes
    
    hit = datas(i, :);
    rejet = hit(indice_rejet);
    
    if isempty(rejet{1})
        nb_images = nb_images + 1;
%         % trouver le nom de l'image
%         URL = hit(indice_nom_img);
%         num_version = 1;
% 
%         nom_image = split(URL, '/');
%         nom_image = nom_image(end);
% 
%         nom_fichier = split(nom_image, '.');
%         nom_fichier = nom_fichier(end-1);
%         nom_json = strcat(path, '/', nom_fichier{1}, '_', int2str(num_version), '.json');
% 
%         while exist(nom_json, 'file') == 2
%             num_version = num_version + 1;
%             nom_json = strcat(path, '/', nom_fichier{1}, '_', int2str(num_version), '.json');
%         end

        nom_json = [path '/' num2str(nb_images) '.json'];

        % Créer le fichier
        fidim = fopen(nom_json,'w');

        %Adapter le contenu :
        json = hit(indice_json);
        % Ecrire le contenu du json
        fprintf(fidim, json{1});

        fclose(fidim);
    
    end
end

end