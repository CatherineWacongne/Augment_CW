display = reshape(n.X(2:n.grid_size^2*3+1),n.grid_size,n.grid_size,3);
modul = reshape(n.X(n.grid_size^2*3+3:end),n.grid_size,n.grid_size,3);
hidden = cat(2,n.Y{:}); hidden([1 n.ny+1 n.ny*2+1]) = [];hidden = reshape(hidden, n.grid_size,n.grid_size,3);
Q = reshape(n.qas(2:end),n.grid_size,n.grid_size);

figure('Position', [100,100,800,800], 'Color', [1 1 1]); subplot(2,2,1); image(permute(display,[2,1,3])); hold on;
set(gca, 'XTick', 1:5, 'YTick', 1:5)
title('Input layer')

pos = find(action)-1;
h2 = plot( mod(pos-0.001,n.grid_size) ,floor((pos-1)/n.grid_size)+1,'o');
set(h2, 'MarkerSize', 5, 'MarkerFaceColor', [.98 .98 .98]);

subplot(2,2,2); image(permute(modul,[2,1,3]));title('Modul layer');set(gca, 'XTick', 1:5, 'YTick', 1:5)
subplot(2,2,3); image(permute(hidden,[2,1,3]));title('Hidden layer');set(gca, 'XTick', 1:5, 'YTick', 1:5)
subplot(2,2,4); imagesc(Q');title('Q layer');set(gca, 'XTick', 1:5, 'YTick', 1:5)