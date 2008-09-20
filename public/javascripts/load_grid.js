var grid_image_list = new Array( );
var grid_row_count = 4;
var grid_col_count = 4;
var total_image_count = 0;
var grid_page = 1;
var total_page_count = 0;

var include_image = function(e){
    tinyMCE.execCommand('mceInsertContent', false, '<img src="'+e.target.full_res+'" />');
}

var render_next_grid_page = function(){
  grid_page++;
  render_grid(grid_page);
}

var render_prev_grid_page = function(){
  if(grid_page == 1){
    return false;
  }
  grid_page--;
  render_grid(grid_page);
}

var render_grid = function(page){
  new Ajax.Request('/photos?response_format=json&page='+page,
    {
      method:'get',
      onSuccess: function(transport){
        var response = transport.responseText || "no response text";
        //alert("Success! \n\n" + response);
        response = eval('(' + response + ')');
        grid_image_list = response.assets;
        total_image_count = response.asset_count;
        overflow = total_image_count % (grid_row_count * grid_col_count);
        evencount = total_image_count - overflow;
        total_page_count = evencount / (grid_row_count * grid_col_count);
        if(overflow > 0){
          total_page_count++;
        }
        if(grid_page == 1){
          $("prev_grid_page_link").hide();
        }
        if(grid_page >= total_page_count){
          $("next_grid_page_link").hide();
        }else{
          $("prev_grid_page_link").show();
          $("next_grid_page_link").show();
        }
        load_grid();
      },
    onFailure: function(){ alert('Something went wrong...') }
    });
}

/**
 * Usually called from render_grid
 * Renders grid from grid_image_list
 */
var load_grid = function(){
  asset_idx = 0;
  for(i = 0; i < grid_row_count; i++){
    for( j=0;j< grid_col_count;j++){
      if( asset_idx > grid_image_list.length ){ break; }
      td_select = 'ag_'+i+'_'+j;
      myImage = grid_image_list[asset_idx];
      newImg = document.createElement("img");
      newImg.src = myImage["public_thumb"];
      newImg.full_res = myImage["public_bigthumb"];
      oldImgs = $(td_select).childElements();
      for(c = 0; c < oldImgs.length; c++ ){
        oldImgs[c].remove();
      }
      $(td_select).appendChild(newImg);
      $(td_select).observe('click', include_image);
      asset_idx++;
    }
  }
}


