var include_image = function(e){
    tinyMCE.execCommand('mceInsertContent', false, '<img src="'+e.target.full_res+'" />');
}

var load_grid = function(row_count, col_count){
    asset_idx = 0;
    for(i = 0; i < row_count; i++){
        for( j=0;j<col_count;j++){
            if( asset_idx > myImageList.length ){ break; }
            td_select = 'ag_'+i+'_'+j;
            myImage = myImageList[asset_idx];
            newImg = document.createElement("img");
            newImg.src = myImage[3];
            newImg.full_res = myImage[2];
            $(td_select).appendChild(newImg);
            $(td_select).observe('click', include_image);
            asset_idx++;
        }
    }
}

