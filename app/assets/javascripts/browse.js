$(function() {
    var offset = 0;
    var previous_themes = new Array();
    var previous_platforms = new Array();
    $('form.browse_form').on('submit', function(e){
        e.preventDefault();
        var payload = {
            browse: {
                theme: '',
                platform: '',
                offset: offset
            }
        }
        $.get("/browse_games", payload).success(function(data){
            
        });
    });
});