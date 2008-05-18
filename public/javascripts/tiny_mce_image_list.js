if(parent.myImageList)
{
    // for inlinepopups
    tinyMCEImageList = parent.myImageList;
}
else{
    // for external popups
    tinyMCEImageList = opener.parent.myImageList;
}