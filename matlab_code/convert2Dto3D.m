function [coord_3D] = convert2Dto3D( coord_2D )

% primesense parameters
xz_fac = 1.122133;
yz_fac = 0.841600;
res_x = 640;
res_y = 480;

coord_3D = zeros(size(coord_2D));

coord_3D(1) = (coord_2D(1)/res_x-0.5)*coord_2D(3)*xz_fac;
coord_3D(2) = (0.5-coord_2D(2)/res_y)*coord_2D(3)*yz_fac;
coord_3D(3) = coord_2D(3);

end
