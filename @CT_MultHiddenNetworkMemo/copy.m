% Make a copy of a handle object.
function new = copy(obj)
% Instantiate new object of the same class.
new = feval(class(obj));

% Copy all non-hidden properties.
p = properties(obj);
for i = 1:length(p)
    new.(p{i}) = obj.(p{i});
end
end