$(document).ready( function() {
	
	$("#more-info").hide();
	var author = $("#author").attr('resource');
	$("#more-info").load( "/explore?uri=" + author );
	$("#more-info").show();
	
});