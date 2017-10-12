display = reshape(n.X(2:end),n.grid_size,n.grid_size,3);
modul = reshape(n.Xmod(2:end),n.grid_size,n.grid_size,3);
hidden1 = cat(2,n.Y1{:}); hidden1([1 n.ny+1 n.ny*2+1]) = [];hidden1 = reshape(hidden1, n.grid_size,n.grid_size,3);
modulh = cat(2,n.Y1mod{:}); modulh([1 n.ny+1 n.ny*2+1]) = [];modulh = reshape(modulh, n.grid_size,n.grid_size,3);
hidden2 = cat(2,n.Y2{:}); hidden2([1 n.ny+1 n.ny*2+1]) = [];hidden2 = reshape(hidden2, n.grid_size,n.grid_size,3);
Q = reshape(n.qas(2:end),n.grid_size,n.grid_size);

figure('Position', [100,100,800,800], 'Color', [1 1 1]); subplot(3,2,1); image(permute(display,[2,1,3])); hold on;
set(gca, 'XTick', 1:n.grid_size, 'YTick', 1:n.grid_size)
title('Input layer')

pos = find(action)-1;
h2 = plot( mod(pos-0.001,n.grid_size) ,floor((pos-1)/n.grid_size)+1,'o');
set(h2, 'MarkerSize', 5, 'MarkerFaceColor', [.98 .98 .98]);
subplot(3,2,2); image(3*permute(modul/5,[2,1,3]));title('Modul layer');set(gca, 'XTick', 1:n.grid_size, 'YTick', 1:n.grid_size)
if 0
    subplot(3,2,3); image(permute(hidden,[2,1,3]));title('Hidden layer');set(gca, 'XTick', 1:n.grid_size, 'YTick', 1:n.grid_size)
else 
    subplot(6,4,9); imagesc(hidden1(:,:,1)');title('Hidden layer 1');set(gca, 'XTick', 1:n.grid_size, 'YTick', 1:n.grid_size)
    subplot(6,4,10); imagesc(hidden1(:,:,2)');set(gca, 'XTick', 1:n.grid_size, 'YTick', 1:n.grid_size)
    subplot(6,4,13); imagesc(hidden1(:,:,3)');set(gca, 'XTick', 1:n.grid_size, 'YTick', 1:n.grid_size)
    
    subplot(6,4,11); imagesc(modulh(:,:,1)');title('mod Hidden layer');set(gca, 'XTick', 1:n.grid_size, 'YTick', 1:n.grid_size)
    subplot(6,4,12); imagesc(modulh(:,:,2)');set(gca, 'XTick', 1:n.grid_size, 'YTick', 1:n.grid_size)
    subplot(6,4,15); imagesc(modulh(:,:,3)');set(gca, 'XTick', 1:n.grid_size, 'YTick', 1:n.grid_size)
    
    subplot(6,4,17); imagesc(hidden2(:,:,1)');title('Hidden layer 2');set(gca, 'XTick', 1:n.grid_size, 'YTick', 1:n.grid_size)
    subplot(6,4,18); imagesc(hidden2(:,:,2)');set(gca, 'XTick', 1:n.grid_size, 'YTick', 1:n.grid_size)
    subplot(6,4,21); imagesc(hidden2(:,:,3)');set(gca, 'XTick', 1:n.grid_size, 'YTick', 1:n.grid_size)
end

subplot(3,2,6); imagesc(Q');title('Q layer');set(gca, 'XTick', 1:n.grid_size, 'YTick', 1:n.grid_size)