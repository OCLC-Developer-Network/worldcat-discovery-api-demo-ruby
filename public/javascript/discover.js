$(document).ready( function() {
	
	$("#more-info").hide();
	var author = $("#author").attr('resource');
    if (author != null && author !== undefined && author.match("http://viaf.org/viaf/"))
    {
    	$("#more-info").load( "/explore?uri=" + author );
    	$("#more-info").show();
    }
	
});