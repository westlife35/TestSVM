function [ hog ] = extract_HOG( img )

std_h = 64;
std_w = 64;
cell_size = 8;

[r, c] = find(img~=0);
if (length(r)==0)
    hog = zeros(cell_size*cell_size*31, 1);
else
    img = img(min(r):max(r),min(c):max(c));
    img = imresize_old(img, [std_h, std_w]);
    hog = vl_hog(im2single(img), cell_size) ;
    hog = hog(:);
    hog = hog/sum(hog.^2);
end

end

