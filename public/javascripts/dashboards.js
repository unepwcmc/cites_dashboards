Event.observe(window,'load', function(){


    initializeLavaLamp();

    setCluetip('a.tooltip');
    tamingselect();

    FireUpdate();


    var selectedtab = document.getElementById('importers');
    if (selectedtab != null)
    {
        selectedtab.style.background="url('"+RAILS_ROOT+"/images/roundedtab.gif') no-repeat";

        Event.observe('importers','click',function(){;
            document.getElementById('controlpanel_reportertype_i').checked = true;
            this.style.background="url('"+RAILS_ROOT+"/images/roundedtab.gif') no-repeat";
            document.getElementById('exporters').style.background="url('"+RAILS_ROOT+"/images/roundedtabbarinverted.gif') no-repeat";
            FireUpdate();
        });
        Event.observe('exporters','click',function(){
            document.getElementById('controlpanel_reportertype_e').checked = true;
            this.style.background="url('"+RAILS_ROOT+"/images/roundedtab.gif') no-repeat";
            document.getElementById('importers').style.background="url('"+RAILS_ROOT+"/images/roundedtabbarinverted.gif') no-repeat";
            FireUpdate();
        });
    }
});

function initializeLavaLamp(){

    var path = location.pathname;
    if(path.lastIndexOf('/') == path.length-1 )
        path = path.substr(0, path.length-1);
    if(path.lastIndexOf('/') > 0)
        path = path.substr(path.lastIndexOf('/'), path.length-1);
    var startItem = 1;  //Site is set to default to global
    switch(path)
    {
        case "/about":
            startItem = 0;
            break;
        case "/global":
            startItem = 1;
            break;
        case "/national":
            startItem = 2;
            break;
        default:
            break;
    }
    jQuery('#lavaLampBorderOnly').lavaLamp({
        startItem: startItem
    });
}

function setCluetip(elementidentifier)
{
    jQuery(elementidentifier).cluetip({local:true, showTitle: false, mouseOutClose: true, sticky: true });
}
function drawMap() {
    if (dataarray.length == 0)
        return;
    var data = new google.visualization.DataTable();
    data.addRows(dataarray.length + 1);
    data.addColumn('string', 'Country');
    data.addColumn('number', legend);
    // Commented to be googleChart compatible
    //data.addColumn('string', 'Partner');

    // Requirement for legend to start from 0 instead of minimum number in data set
    data.setValue(0, 0, '');
    data.setValue(0, 1, 0);
    // Commented to be googleChart compatible
    //data.setValue(0, 2, '');

    for (var i = 0; i < dataarray.length; i++)
    {
        data.setValue(i+1, 0, dataarray[i][2]);
        data.setValue(i+1, 1, dataarray[i][1]);
        // Commented to be googleChart compatible
        //data.setValue(i+1, 2, dataarray[i][2]);
    }

    var options = {};
    options['dataMode'] = 'regions';
    options['colors'] = ['F6E8C3','BF812D','543005']; //earth colors
    //options['width'] = '300px';
    //options['height'] = '250px';

    var container = document.getElementById("map");
    if (container != null)
    {
        var geomap = new google.visualization.GeoChart(container);
        geomap.draw(data, options);
    }
};

function showLoadingIcon(dashboard)
{
    if (dashboard == 'national')
    {
        document.getElementById('legend').innerHTML = '';
        document.getElementById('map').innerHTML = '';
        document.getElementById('reporttype').innerHTML = '';
        document.getElementById('distribution').innerHTML = '';
    }

    document.getElementById('chart').innerHTML = '<div style="height:' +
                                                 $('chart').getHeight() + 'px;text-align:center"><img src="'+RAILS_ROOT+'/images/loading.gif" alt="Loading..."/><div>';
}

function generate_species_trade()
{
    var url = RAILS_ROOT +'/shared/load_species_chart';
    var params = 'speciescode=' + jQuery("#speciesselect option:selected").val();
    var target = 'speciesdiv';
    var myAjax = new Ajax.Updater(target, url, {method: 'get', parameters: params, onComplete : function () {setCluetip("#speciesanchor");}});
}

function generate_families_trade()
{
    var url = RAILS_ROOT + '/national/load_families_chart';
    var params = 'familyname=' + jQuery("#speciesselect option:selected").val();
    var target = 'speciesdiv';
    var myAjax = new Ajax.Updater(target, url, {method: 'get', parameters: params, onComplete : function () {setCluetip("#familiesanchor");}});
}
