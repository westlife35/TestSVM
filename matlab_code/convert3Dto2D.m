function [coord_2D] = convert3Dto2D( coord_3D )

% primesense parameters
xz_fac = 1.122133;
yz_fac = 0.841600;
res_x = 640;
res_y = 480;

coord_2D = zeros(size(coord_3D));

coord_2D(1) = (coord_3D(1)/coord_3D(3)/xz_fac+0.5)*res_x;
coord_2D(2) = (0.5-coord_3D(2)/coord_3D(3)/yz_fac)*res_y;
coord_2D(3) = coord_3D(3);

end
