$(document).ready(function(){
    $('#office-generate-preview').click(function(){
        var $load = $('<span></span>');
        $load.css({'font-weight' : 'bold'});
        $load.text(mw.msg('loading'));
        var i = 0;
        var iID = setInterval(function(){
            i++;
            var text = mw.msg('loading');
            for (var j = 0; j < i; j++)
            {
                text += '.';
            }
            $load.text(text);
            if (i >= 3)
            {
                i =0;
            }
        }, 300);
        $('#office-generate-preview').replaceWith($load);
        $.ajax({
            type: "GET",
            url: mw.util.wikiScript(),
            data: {
                action:'ajax',
                rs:'OfficeAjax::generatePreview',
                rsargs:[wgPageName]
            },
            dataType: 'json',
            success: function(result){
                clearInterval(iID);
                $load.replaceWith(result.html);
            },
            error : function(result){
                clearInterval(iID);
                $load.text(result.status + ' ' + result.statusText);
            }
        });
        return false;
    });
});
