figure('Position', [200 100 1000 800], 'Color', [1 1 1])
subplot(3,3,1);imagesc(n.weights_xiyj); title('w x_iy_j')    
subplot(3,3,2);imagesc(n.weights_xkyj); title('w x_ky_j')   
subplot(3,3,3);imagesc(n.weights_xonym); title('w x_o_ny_m')   
subplot(3,3,4);imagesc(n.weights_xoffym); title('w x_o_f_fy_m')  
subplot(3,3,5);imagesc(n.weights_xkonym); title('w x_k_o_ny_m') 
subplot(3,3,6);imagesc(n.weights_xkoffym); title('w x_k_o_f_fy_m') 


subplot(3,3,7);imagesc(n.weights_ymxk); title('w y_mx_k') 
subplot(3,3,8);imagesc(n.weights_yjz); title('w y_jz') 
subplot(3,3,9);imagesc(n.weights_ymz); title('w y_mz') 



%%
figure('Position', [200 100 1000 800], 'Color', [1 1 1])
subplot(3,3,1);imagesc(n.weights_xy{1}); title('w xy')    
subplot(3,3,2);imagesc(n.weights_xy{2}); 
subplot(3,3,3);imagesc(n.weights_xy{3}); 
subplot(3,3,4);imagesc(n.weights_yx{1}); title('w yx')  
subplot(3,3,5);imagesc(n.weights_yx{2}); 
subplot(3,3,6);imagesc(n.weights_yx{3}); 


subplot(3,3,7);imagesc(n.weights_yz{1}); title('w yz') 
subplot(3,3,8);imagesc(n.weights_yz{2}); 
subplot(3,3,9);imagesc(n.weights_yz{3}); 