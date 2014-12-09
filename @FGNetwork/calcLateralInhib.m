function calcLateralInhib(obj)

    Wi1 = zeros(obj.size_net^2, obj.size_net^2);% lat inhib
    [index_x, index_y] = meshgrid(1:obj.size_net, 1:obj.size_net);
    lin_indx = reshape(index_x, 1,obj.size_net^2);
    lin_indy = reshape(index_y, 1,obj.size_net^2);
    
    
for n1 = 1:obj.size_net^2
    for n2 = 1:obj.size_net^2
        Wi1(n1,n2) = -exp(-((lin_indx(n2) - lin_indx(n1))^2+(lin_indy(n2) - lin_indy(n1))^2)/(2*obj.rad_i));
        
    end
end


    obj.weights_xx(1:obj.size_net^2, 1:obj.size_net^2) = obj.wi * Wi1;
    obj.weights_xx(1+obj.size_net^2:2*obj.size_net^2, 1+obj.size_net^2:2*obj.size_net^2) = obj.wi * Wi1;

end