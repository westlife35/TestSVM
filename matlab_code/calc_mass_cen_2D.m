function [ mass_cen ] = calc_mass_cen_2D( img )

h = size(img, 1);
w = size(img, 2);
[rows, cols] = find(img~=0);
mass_cen = zeros(3,1);
if isempty(rows)
    mass_cen(1) = floor(w/2);
    mass_cen(2) = floor(h/2);
    mass_cen(3) = 0;
else 
    mass_cen(1) = floor(mean(cols));
    mass_cen(2) = floor(mean(rows));
    mass_cen(3) = floor(mean(img(img>0)));
end

end

