clear; clc; close all;
load('ev_power_dataset.mat');
X=trainingData(:,1:3);
sigma=std(X);
k=7;
epsilon=0.01;%stopping criterion

num_rows=size(X,1);
random_indices=randperm(num_rows,k);
C=X(random_indices,:);

disp('Initialization completed');
disp('initial centroids (C):');
disp(C);

%% phase 2: the clustering loop
max_iter=100;
iter=0;
U_previous=zeros(num_rows,k);
U=zeros(num_rows,k);%matrix that will store the membership degree
disp('Starting cluster optimization...');
while iter<max_iter
    iter=iter+1;
    for j=1:k
        %calculate the vectorized gaussian distance for centroid j
        C_expandido=repmat(C(j,:), num_rows,1);
        sigma_expandida=repmat(sigma, num_rows,1);
        dist_squared=sum(((X-C_expandido)./sigma_expandida).^2,2);
        U(:,j)=exp(-0.5*dist_squared);
    end
    %Find the cluster with the highest membership for each data point
    %Hint: the function max(Matrix, [],dimension) returns the maximum value
    %and its we want to search along the columns
    [~,assignments]=max(U,[],2);
    
    for j=1:k
        cluster_points=X(assignments==j,:);
        if ~isempty(cluster_points)
            C(j,:)=mean(cluster_points);
        end
    end
    change=max(abs(U(:)-U_previous(:)));
    if change<epsilon
        disp(['Algorithm converged at iteration: ',num2str(iter), '!']);
        break;
    end
    U_previous=U;%Update the matrix for the next iteration
end
disp('Final optimized centroids');
disp(C);
%% phase 3 visualization of discovered clusters
figure('name', 'Gaussian FCM Clusters 3D');
scatter3(X(:,1),X(:,2),X(:,3),20, assignments, 'filled');
hold on;
scatter3(C(:,1),C(:,2),C(:,3),200,'k','p','filled');

title('Optimized Operational States (Battery Clusters)');
xlabel('State of Charge [0-1]');
ylabel('Temperature [0-1]');
zlabel('Driving Style [0-1]');
colormap('jet');
colorbar;
grid on;
view(45,30);

%% phase 4 building and training custom ANFIS
disp('Building custom ANFIS architecture from gaussian clusters..');
fis_custom=newfis('Gaussian_FCM_ANFIS','sugeno');
fis_custom=addvar(fis_custom,'input','Soc',[0 1]);
fis_custom=addvar(fis_custom,'input','Temp',[0 1]);
fis_custom=addvar(fis_custom,'input','Drive',[0 1]);
for j=1:k
    fis_custom=addmf(fis_custom,'input',1,['Cluster',num2str(j)],'gaussmf',[sigma(1) C(j,1)]);
    fis_custom=addmf(fis_custom,'input',2,['Cluster',num2str(j)],'gaussmf',[sigma(2) C(j,2)]);
    fis_custom=addmf(fis_custom,'input',3,['Cluster',num2str(j)],'gaussmf',[sigma(3) C(j,3)]);
end
fis_custom=addvar(fis_custom,'output','SOP',[0 1]);
for j=1:k
    fis_custom=addmf(fis_custom,'output',1,['Out' num2str(j)],'constant',0.5);
end
rule_list=zeros(k,6);
for j=1:k
    rule_list(j,:)=[j,j,j,j,1,1];
end
fis_custom=addrule(fis_custom,rule_list);
training_options=[50,0,0.001,0.9,1.1];
disp('Initialization ANFIS training with 5 gaussian rules');
[trained_custom_fis, custom_error]=anfis(trainingData,fis_custom,training_options);
disp('training completed');

%% phase 5 validation and comparison
figure('Name', 'Custom FCM ANFIS Performance');
subplot(2,1,1);
plot(custom_error, 'LineWidth', 2, 'Color', [0.494,0.184,0.556]);
title(['Reducción del Error (RMSE) - ',num2str(k), ' Reglas Gaussianas']);
xlabel('Épocas');
ylabel('RMSE');
grid on;
inputs_norm = trainingData(:, 1:3);
expected_output = trainingData(:, 4);
custom_nn_output = evalfis(inputs_norm, trained_custom_fis);
subplot(2,1,2);
plot(1:100, expected_output(1:100), '-o', 'LineWidth', 1.5, 'DisplayName', 'Mamdani (Objetivo)');
hold on;
plot(1:100, custom_nn_output(1:100), '-*', 'LineWidth', 1.5, 'DisplayName', 'FCM-Gaussiano ANFIS');
title('SOP Predictivo: Comparación de los primeros 100 escenarios');
xlabel('Muestra');
ylabel('Normalized SOP [0-1]');
legend('Location', 'best');
grid on;

%% phase 6 parameter export to csv
disp('Exporting neural network parameters to CSV...');
%export the centroid matrix C
csvwrite('fcm_centroids.csv',C);
%export the standard deviation vector sigma
csvwrite('fcm_sigmas.csv',sigma);
%extract and export the optimized output weights SOP
output_weights=zeros(k,1);
for j=1:k
    %Extract the parameter from the output membership function of each rule
    output_weights(j)=getfis(trained_custom_fis, 'output',1,'mf',j,'params');
end
csvwrite('anfis_weights.csv',output_weights);
disp('Export completed');