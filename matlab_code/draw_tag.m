function [ img ] = draw_tag( img, event, pos )

    if (event == 2)
        [tag, ~, alpha] = imread('img/vio.png');
    elseif (event == 3)
        [tag, ~, alpha] = imread('img/sos.png');
    else
        [tag, ~, alpha] = imread('img/normal.png');
    end
    [h, w, ~] = size(img);
    [h_, w_, ~] = size(tag);
    pos(2) = floor(pos(2)-h_*0.7);
    if (pos(1)>w-50) || (pos(1)<1) || (pos(2)>h-50) || (pos(2)<1)
        return;
    end
    tag = tag(1:min(h_, h-pos(2)), 1:min(w_, w-pos(1)), :);
    alpha = alpha(1:min(h_, h-pos(2)), 1:min(w_, w-pos(1)));
    [h_, w_, ~] = size(tag);
    sub_img = img(pos(2):pos(2)+h_-1, pos(1):pos(1)+w_-1, :);
    rep_sub_img = uint8((double(sub_img).*repmat((255-double(alpha)),1,1,3)+double(tag).*repmat(double(alpha),1,1,3))/255);
    img(pos(2):pos(2)+h_-1, pos(1):pos(1)+w_-1, :) = rep_sub_img;
    
end

