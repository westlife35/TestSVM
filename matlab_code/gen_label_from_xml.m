function gen_label_from_xml( data_path, out_path )

    sub_path = dir(data_path);
    for i=1:length(sub_path)
        if strcmpi(sub_path(i).name , '.')==1 || strcmpi(sub_path(i).name , '..')==1
            continue;
        end
        data_label = false(3000,1);
        for j=1:length(data_label)
            if exist(sprintf('%s/%s/%06d.jpg', data_path, sub_path(i).name, j))==2
                data_label(j)=true;
            end
        end
        save([out_path '/' sub_path(i).name '.mat'], 'data_label');
        clear data_label;
    end
    
end

