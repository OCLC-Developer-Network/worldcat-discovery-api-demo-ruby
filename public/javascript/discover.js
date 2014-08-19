$(document).ready( function() {
	
	$("#more-info").hide();
	var author = $("#author").attr('resource');
    var title = $("#bibliographic-resource-name").text();
    if (author != null && author !== undefined && author.match("http://viaf.org/viaf/"))
    {
    	$("#more-info").load( "/explore?uri=" + author + '&title=' + encodeURIComponent(title));
    	$("#more-info").show();
    }
	
});