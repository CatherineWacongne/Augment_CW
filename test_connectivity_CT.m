% function test_connectivity_CT
RH = [2 0;-3 1]; %Rn0 Rnperif Rm0 Rmp
GH = [0 0; 2 2];
BH = [0 0;3 0];
HR = [1 0]; %Rm0 Rmperif
HG = [1 2];
HB = [1 3];
grid_size = 5;
n_inputs = grid_size^2*3+1;
ny_normal = grid_size^2+1;
use_class_connections = 1;
W_XY_values = [RH GH BH]*.3;
W_XY_values = reshape(W_XY_values',1,12);
W_YX_values = [HR HG HB]*.3;

hd_transform_normal = @(in) 0.02*log(1+exp(50*in));
%% create weights
[X,Y] = meshgrid(1:grid_size);
X = reshape(X,[1,grid_size^2]);
Y = reshape(Y,[1,grid_size^2]);
W = sqrt(min(abs(ones(grid_size^2,1) *X - X'*ones(1,grid_size^2)),grid_size-abs(ones(grid_size^2,1) *X - X'*ones(1,grid_size^2)) ).^2 +...
    min(abs(ones(grid_size^2,1) *Y - Y'*ones(1,grid_size^2)),grid_size-abs(ones(grid_size^2,1) *Y - Y'*ones(1,grid_size^2)) ).^2);
class_connection =0*W;

class_connection(abs(W)<1.01) = 2;
class_connection(abs(W)<0.01) = 1;
W = abs(W)<1.001;


% Set weights for Input->Hidden
weights_xy =  rand(n_inputs*2+1, ny_normal);%- xy_weight_range;
weights_xy( 3:2+3*grid_size^2,2:end) = weights_xy( 3:2+3*grid_size^2,2:end).*repmat(W,3,1)+0.05.*repmat(W,3,1);
weights_xy( 4+3*grid_size^2:end,2:end) = weights_xy(4+3*grid_size^2:end,2:end).*repmat(W,3,1)+0.05.*repmat(W,3,1);
weights_xy([2 3+3*grid_size^2],2:end) = 0;
weights_xy([3:2+3*grid_size^2  4+3*grid_size^2:end],1) = 0;
weights_xy(1,2:end) = mean(weights_xy(1,2:end));
wxy_class = 0*weights_xy;
for col = 1:3
    wxy_class( 3+(col-1)*grid_size^2:2+col*grid_size^2,2:end) = W *2*(col-1)+class_connection;
    wxy_class( 4+(col+2)*grid_size^2:3+(col+3)*grid_size^2,2:end) =  W *2*(col+2)+ class_connection;
end
if use_class_connections
    for conn_type = 1:12
        weights_xy(wxy_class==conn_type) = W_XY_values(conn_type);
    end
end

% Set weights for Hidden->Input
weights_yx = weights_xy';
weights_yx(:,1) = [];
weights_yx(1,:) = 0;
weights_yx(:,1:end/2)=0;
weights_yx = (abs(weights_yx)>0).*rand(size(weights_yx,1),size(weights_yx,2));
wyx_class = wxy_class';
wyx_class(:,1) = [];
wyx_class(:,1:end/2)=0;
if use_class_connections
    for conn_type = 7:12    
        weights_yx(wyx_class==conn_type) = W_YX_values(conn_type-6);%weights_yx(wyx_class==conn_type) = 0;
    end
end


%% test propagation
current_input = zeros(1,n_inputs);
current_input([ 23    26    27    38    43    46    62    75]+1) = 1;
X = zeros(1, n_inputs * 2);
Y = zeros(1,ny_normal);

figure('Position',[100 100 1000 500])
for ti = 1:4
    % calc Input
    modul_input =  Y *weights_yx(:,end/2+1:end); 
    modul_normal = modul_input.*current_input;
   
    modul_transformed = hd_transform_normal(modul_normal );
    modul_transformed(modul_normal>4) = modul_normal(modul_normal>4);
    
    X = [current_input  modul_transformed];
    
    % calc hidden
    activations_normal = [-.1 X] * weights_xy;  
    normal_transformed = hd_transform_normal(activations_normal);    
    normal_transformed(activations_normal > 4) = activations_normal(activations_normal > 4);
    Y = normal_transformed;
    
    % plot results
    display = reshape(X(2:grid_size^2*3+1),grid_size,grid_size,3);
    modul = reshape(X(grid_size^2*3+3:end),grid_size,grid_size,3);
    hidden =  reshape(Y(2:end),grid_size,grid_size);
    subplot(3,4,ti); image(permute(display,[2,1,3])); hold on;
    set(gca, 'XTick', 1:5, 'YTick', 1:5)
    title('Input layer')
    subplot(3,4,4+ti);  image(permute(modul,[2,1,3]));title('Modul layer');set(gca, 'XTick', 1:5, 'YTick', 1:5)
    subplot(3,4,8+ti); imagesc(hidden');title('Hidden layer');set(gca, 'XTick', 1:5, 'YTick', 1:5)
    keyboard;
    
end
    


