function display_outlines(img_path, nom_batch, nom_dossier)
% Affiche les outlines tracées lors d'une campagne de crowdsourcing
% stockées dans un le fichier <nom_batch>

% img_path : dossier où sont stockées les images utilisées pour la campagne
% d'outlining (par exemple "../utilitaires_bdd/JPEGImages/")

% nom_bactch : nom du fichier csv qui contient les outlines (par exemple :
% "batch.csv" )

% nom_dossier : nom du dossier où seront stockés les figures résultat

close all

datas = csv2cell(nom_batch,'fromfile');
[nb_colonnes, nb_lignes] = size(datas);
datas = reshape(datas, nb_colonnes, nb_lignes);

mkdir(nom_dossier);

indice_json = 31;
% indice_worker = 16;
% indice_hit = 1;
indice_id = 15;
indice_rejection = 22;
% indice_temps = 24;

fig = figure('Position', [10,10,800,800]);

for i=2:nb_colonnes
    hit = datas(i, :);
    
    rejet = hit(indice_rejection);
    
    % On n'affiche pas les outlines qui on été rejetées
    if isempty(rejet{1})
        
        % Générer le .json
        json = hit(indice_json);
        id_assignement = hit(indice_id);
        fidim = fopen('tmp.json','w+');

        % Ecrire le contenu du json
        fprintf(fidim, json{1});
        fclose(fidim);

        % Récupérer les coordonnées des outlines et le nom de l'image : 
        aux = Utils.loadjson('tmp.json');

        % Récupérer l'image correspondante
        URL = aux.images{1,1}.image;
        URL= split(URL, '/');
        URL = URL(end);
        im_name=[ img_path '/' URL{1}];

        imshow(im_name);
        hold on
        title(id_assignement); %  identifiant unique de la tâche

        % Récupérer les outlines et les afficher
        os = aux.images{1,1}.annotations{1,1}.annotations;

        % afficher les outlines
        if size(os,1) ~= 0
            for k=1:size(os, 1 )
                coord = os{k};
                hold on
                plot(coord(:,1), coord(:,2),'LineWidth',2);
            end
        end

        % Sauver les figures
        saveas(fig, [nom_dossier ,'/', num2str(i), '_' ,id_assignement{1}, '.jpg']);
        hold off
     
    end

end
delete tmp.json
