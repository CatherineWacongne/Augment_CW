function ET = check_traces(obj, new_traces, exp_value, action)
%calc_traces contains the traces added traces computed in the time step
dw = 0.01;
%% weight_xy
for f = 1:obj.n_hidden_features
    for x = 1:obj.nx+1
        for y = 1:obj.ny
            
            obj2 = obj.copy();% copy current values
            obj2.weights_xy{f}(x,y) = obj2.weights_xy{f}(x,y)+dw;% modify one weight
            % compute the effect on the q value
            obj2.calc_Input();% sets input incl xk
            obj2.calc_Hiddens();% sets yj
            obj2.calc_Output();
            ET.wxy_new_trace{f}(x,y) = (obj2.qas(action) - exp_value)/dw;
        end
    end
end
%% weight_yx
for f = 1:obj.n_hidden_features
    for y = 1:obj.ny
        for x = 1:obj.nx
            
            obj2 = obj.copy();% copy current values
            obj2.weights_yx{f}(y,x) = obj2.weights_yx{f}(y,x)+dw;% modify one weight
            % compute the effect on the q value
            obj2.calc_Input();% sets input incl xk
            obj2.calc_Hiddens();% sets yj
            obj2.calc_Output();
            ET.wyx_new_trace{f}(y,x) = (obj2.qas(action) - exp_value)/dw;
        end
    end
end

%% weight_yz
for f = 1:obj.n_hidden_features
    for y = 1:obj.ny+1
        for z = 1:obj.nz
            
            obj2 = obj.copy();% copy current values
            obj2.weights_yz{f}(y,z) = obj2.weights_yz{f}(y,z)+dw;% modify one weight
            % compute the effect on the q value
            obj2.calc_Input();% sets input incl xk
            obj2.calc_Hiddens();% sets yj
            obj2.calc_Output();
            ET.wyz_new_trace{f}(y,z) = (obj2.qas(action) - exp_value)/dw;
        end
    end
end

%% compare with math results; 

figure; for f = 1:3;subplot(3,2,2*(f-1)+1); imagesc( ET.wyz_new_trace{f}); subplot(3,2,2*f); imagesc(new_traces{1}{f});end
figure; for f = 1:3;subplot(3,2,2*(f-1)+1); imagesc( ET.wxy_new_trace{f}); subplot(3,2,2*f); imagesc(new_traces{2}{f});end
figure; for f = 1:3;subplot(3,2,2*(f-1)+1); imagesc( ET.wyx_new_trace{f}); subplot(3,2,2*f); imagesc(new_traces{3}{f});end


keyboard;
