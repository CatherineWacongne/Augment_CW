display = reshape(n.Xi(2:end),n.grid_size,n.grid_size,3);
modul = reshape(n.Xk(2:end),n.grid_size,n.grid_size,3);
hidden = reshape(n.Yj(2:end),n.grid_size,n.grid_size);
hidden_m =  reshape(n.Ym(2:end),n.grid_size,n.grid_size);
Q = reshape(n.qas(2:end),n.grid_size,n.grid_size);
figure('Position', [100,100,800,800], 'Color', [1 1 1]); subplot(5,2,1); image(permute(display,[2,1,3])); hold on;
set(gca, 'XTick', 1:5, 'YTick', 1:5)
title('Input layer')

pos = find(action)-1;
h2 = plot( mod(pos-0.001,n.grid_size) ,floor((pos-1)/n.grid_size)+1,'o');
set(h2, 'MarkerSize', 5, 'MarkerFaceColor', [.98 .98 .98]);
 subplot(5,2,3); image(permute(modul,[2,1,3]));title('Modul layer');set(gca, 'XTick', 1:5, 'YTick', 1:5)

 subplot(5,2,5); imagesc(hidden');title('Hidden layer');set(gca, 'XTick', 1:5, 'YTick', 1:5)
 subplot(5,2,7); imagesc(hidden_m');title('Memory units');set(gca, 'XTick', 1:5, 'YTick', 1:5)
 subplot(5,2,9); imagesc(Q');title('Q layer');set(gca, 'XTick', 1:5, 'YTick', 1:5)
 
subplot(5,2,2); imagesc(permute(reshape(n.Xon(2:end), n.grid_size,n.grid_size,3), [2,1,3]));title('Xon');set(gca, 'XTick', 1:5, 'YTick', 1:5)
subplot(5,2,4); imagesc(permute(reshape(n.Xoff(2:end), n.grid_size,n.grid_size,3), [2,1,3]));title('Xoff');set(gca, 'XTick', 1:5, 'YTick', 1:5)
subplot(5,2,6); imagesc(permute(reshape(n.Xkon(2:end), n.grid_size,n.grid_size,3), [2,1,3]));title('Xkon');set(gca, 'XTick', 1:5, 'YTick', 1:5)
subplot(5,2,8); imagesc(permute(reshape(n.Xkoff(2:end), n.grid_size,n.grid_size,3), [2,1,3]));title('Xkoff');set(gca, 'XTick', 1:5, 'YTick', 1:5)