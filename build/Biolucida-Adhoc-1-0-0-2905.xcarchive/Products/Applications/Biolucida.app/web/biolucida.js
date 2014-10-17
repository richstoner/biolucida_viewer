function loadBiolucidaImage(server_url, image_id) {

//    http://107.170.194.205:1234
    
    var metadata_url = server_url + '/api/v1/image/' + image_id;
    var tile_url = server_url + '/api/v1/tile/' + image_id + '/';
    
    console.log(metadata_url);
    console.log(tile_url);
    
    $.ajax({
           
        url: metadata_url,
        success: function(data) {

            var w = parseInt(data.levels[0].w);
            var h = parseInt(data.levels[0].h);
            var tsx = parseInt(data.tile_x);
            var tsy = parseInt(data.tile_y);

            // Calculate the number of resolutions - smallest fits into a tile
            var max = (w > h) ? w : h;
            var n = 1;

            while (max > 256) {
                max = Math.floor(max / 2);
                n++;
            }

            var result = {
                'max_size': {
                    w: w,
                    h: h
                },
                'tileSize': {
                    w: tsx,
                    h: tsy
                },
                'num_resolutions': n
            };

            result['url'] = tile_url;
            result['thumbnail'] = data.thumbnail;
            result['servermeta'] = data;

            // save this to load z later
            image_metadata = result;

            console.log(image_metadata);
           
            createViewer(result, image_z_index);

        }
    });
    
    return "";
}


var changeZCallback = function(z_to_load) {

    var z_planes = parseInt(image_metadata.servermeta.focal_planes);
    var new_z = Math.round(z_to_load * z_planes);
    loadPlane(new_z);
}

var loadPlane = function(z_to_load) {

    // console.log("CHANGE Z", z_to_load, new_z);

    if (z_to_load <= 0) {
        z_to_load = 0;
    }

    var imageCenter = [image_metadata.max_size.w / 2, -image_metadata.max_size.h / 2];

    var projection = new ol.proj.Projection({
        code: 'ZOOMIFY',
        units: 'pixels',
        extent: [0, 0, image_metadata.max_size.w, image_metadata.max_size.h]
    });

    var zm = JSON.parse(image_metadata.servermeta.zoom_map);
    var zmu = zm.unique();

    console.log(zm);
    console.log(zmu);

    var crossOrigin = 'anonymous';
    var image_source = new ol.source.Biolucida({
        url: image_metadata.url,
        zoommap: zmu,
        z_index: z_to_load,
        size: [image_metadata.max_size.w, image_metadata.max_size.h],
        crossOrigin: crossOrigin
    });


    // remove the bottom layer
    if (last_image_layer != undefined) {
        layerRecycleQueue.push(last_image_layer);

        if(layerRecycleQueue.length >= 4){
            for(var i=0; i<layerRecycleQueue.length - 4; i++){
                map.removeLayer(layerRecycleQueue[i]);
            }
            layerRecycleQueue.splice(0, layerRecycleQueue.length - 4);
        };
    }

    // make current layer the bottom layer
    if (image_layer != undefined) {
        last_image_layer = image_layer;
    }

    // initialize the new layer on top
    image_layer = new ol.layer.Tile({
        source: image_source,
        preload: 1
    });

    image_z_index = z_to_load;

    map.addLayer(image_layer);

}

function goUp(){
    loadPlane(image_z_index + 1);
};

function goDown(){
    if(image_z_index > 1){
        loadPlane(image_z_index -1);      
    }
}

function createViewer(metadata, base_z) {

    var imageCenter = [metadata.max_size.w / 2, -metadata.max_size.h / 2];

    var projection = new ol.proj.Projection({
        code: 'ZOOMIFY',
        units: 'pixels',
        extent: [0, 0, metadata.max_size.w, metadata.max_size.h]
    });

    var zm = JSON.parse(metadata.servermeta.zoom_map);
    var zmu = zm.unique();

        console.log(metadata);

    var z_spacing = parseInt(metadata.servermeta.focal_spacing);
    var z_planes = parseInt(metadata.servermeta.focal_planes);

    var crossOrigin = 'anonymous';
    var image_source = new ol.source.Biolucida({
        url: metadata.url,
        zoommap: zmu,
        z_index: base_z,
        size: [metadata.max_size.w, metadata.max_size.h],
        crossOrigin: crossOrigin
    });

    // remove the bottom layer
    if (last_image_layer != undefined) {
        map.removeLayer(last_image_layer);
    }

    // make current layer the bottom layer
    if (image_layer != undefined) {
        last_image_layer = image_layer;
    }

    // initialize the new layer on top
    image_layer = new ol.layer.Tile({
        source: image_source,
        preload: 1
    });


//    var static_w = metadata.max_size.w * 0.01;
//    var static_h = metadata.max_size.h * 0.01;
//    
//    var background_layer = new ol.layer.Image({
//      source: new ol.source.ImageStatic({
//        url: metadata.thumbnail,
//        imageSize: [static_w, static_h],
//        projection: projection,
//        imageExtent: [0, 0, static_w, -static_h]
//      })
//    })


//     var pixelProjection = new ol.proj.Projection({
//   code: 'pixel',
//   units: 'pixels',
//   extent: [0, 0, 1024, 968]
// });

// var map = new ol.Map({
//   layers: [
//     new ol.layer.Image({
//       source: new ol.source.ImageStatic({
//         attributions: [
//           new ol.Attribution({
//             html: '&copy; <a href="http://xkcd.com/license.html">xkcd</a>'
//           })
//         ],
//         url: 'http://imgs.xkcd.com/comics/online_communities.png',
//         imageSize: [1024, 968],
//         projection: pixelProjection,
//         imageExtent: pixelProjection.getExtent()
//       })
//     })
//   ],
//   target: 'map',
//   view: new ol.View({
//     projection: pixelProjection,
//     center: ol.extent.getCenter(pixelProjection.getExtent()),
//     zoom: 2
//   })
// });

    

    var mainView = new ol.View({
        projection: projection,
        center: imageCenter,
        zoom: 3,
        maxZoom: metadata.num_resolutions
    });

    map = createMap('map', mainView, false);

//    map.addLayer(background_layer);
    map.addLayer(image_layer);


    map.setView(mainView);

    var overviewView = new ol.control.OverviewMap({
        maximized: true,
        minRatio: 0.5
    });

    map.addControl(overviewView);

    var scaleLineControl = new ol.control.ScaleLine({
        units: 'pixels'
    });
    map.addControl(scaleLineControl);


    if (z_planes > 1) {

        var imageDepthControl = new ol.control.ImageDepthControl({
            z_planes: z_planes,
            z_index: base_z,
            callback: changeZCallback
        });

        map.addControl(imageDepthControl);
    }
    
    

}

function verifyLink(message_to_send){
    
    alert(message_to_send);
    
}

