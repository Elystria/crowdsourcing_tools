function [ temps_moyen, sigma ] = temps(nom_batch)
% Calcule le temps moyen passé pour chaque OBJET lors de la campagne de
% crowdsourcing. Génère le fichier "nom_batch_temps.txt" qui donne la
% moyenne, la médiane et l'écart type de temps
% Affiche également un histogramme du temps passé sur les tâches
% nom_batch : nom du fichier csv (sans l'extension) fournit par Amazon.
close all

datas = csv2cell([nom_batch, '.csv'],'fromfile');
[nb_colonnes, nb_lignes] = size(datas);
datas = reshape (datas, nb_colonnes, nb_lignes);
indice_rejection = 22;
indice_json = 31;

indice_temps = 24;
temps_moyen = 0;

j = 1;
for i = 2:nb_colonnes

    hit = datas(i, :);
    rejet = hit(indice_rejection);
    
    % On ne prend pas en compte les tâche rejetées dans le calcul
    if isempty(rejet{1})
        % Chercher le contenu du .json
        json = hit(indice_json);
        
        % L'écrire dans un fichier vide
        fidim = fopen('tmp.json','w+');
                
        % Ecrire le contenu du json
        fprintf(fidim, json{1});
        fclose(fidim);

        % Récupérer les coordonnées des outlines et le nom de l'image : 
        aux = Utils.loadjson('tmp.json');

        % Récupérer les outlines les compter sur chaque image
        os = aux.images{1,1}.annotations{1,1}.annotations;
        
        n(j) = size(os,1); % nombre d'outlines 
        t = hit(indice_temps); % temps total passé sur la tâche
        temps(j) = str2num(t{1});

        if n(j) ~= 0
            temps_moyen = temps_moyen + temps(j)/n(j);
            j = j + 1;
        end
    end
end

j = j - 1 ;
temps_moyen = temps_moyen/j; % temps moyen par objet
sigma = sqrt(sum((temps./n - temps_moyen).^2)/j); % ecart-type

% On enlève les données aberrantes
indices = find(temps < temps_moyen + 3 * sigma);
temps = temps(indices);
n = n(indices);

indices = find(temps > temps_moyen - 3 * sigma);
temps = temps(indices);
n = n(indices);

% calcul du nouveau temps moyen 
temps = temps./n; % temps par objet
mediane_temps = median(temps);
temps_moyen = mean(temps);
sigma = sqrt(sum((temps - temps_moyen).^2)/size(temps, 2));

fid = fopen([nom_batch , '_temps.txt'], 'w');
formatSpec = "moyenne : %d \n sigma : %d \n mediane : %d ";
fprintf(fid, formatSpec, temps_moyen, sigma, mediane_temps);

histogram(temps);
xlabel("temps");
ylabel("nb de tâches");


