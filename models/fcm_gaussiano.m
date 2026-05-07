clear; clc; close all;
load('ev_power_dataset.mat');
X=trainingData(:,1:3);
sigma=std(X);
k=5;
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
