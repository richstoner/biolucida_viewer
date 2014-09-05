Array.prototype.contains = function(v) {
    for(var i = 0; i < this.length; i++) {
        if(this[i] === v) return true;
    }
    return false;
};

Array.prototype.unique = function() {
    var arr = [];
    for(var i = 0; i < this.length; i++) {
        if(!arr.contains(this[i])) {
            arr.push(this[i]);
        }
    }
    return arr;
};



var createMap = function(divId, viewToUse, rotate) {
    rotate = rotate || false;
    var mapOptions = {
        layers: [],
        renderer: "webgl",
        target: divId,
        view: viewToUse
    };
    if (rotate) {
        mapOptions.interactions = ol.interaction.defaults().extend([
            new ol.interaction.DragRotateAndZoom()
        ]);
    }
    return new ol.Map(mapOptions);
};


var styleFunction = (function() {
    return function(feature, resolution) {
        if (feature.get('hexcolor')) {
            return [new ol.style.Style({
                stroke: new ol.style.Stroke({
                    color: feature.get('hexcolor'),
                    width: 3
                }),
                fill: new ol.style.Fill({
                    color: 'rgba(0,0,0,0.0)'
                }),
                text: new ol.style.Text({
                    textAlign: "start",
                    textBaseline: "top",
                    font: "20px Arial",
                    text: feature.get('title'),
                    fill: new ol.style.Fill({
                        color: "#000000"
                    }),
                    stroke: new ol.style.Stroke({
                        color: feature.get('hexcolor'),
                        width: 3
                    }),
                    offsetX: 0,
                    offsetY: 0,
                    rotation: 0
                })
            })]
        } else {
            return [new ol.style.Style({
                fill: new ol.style.Fill({
                    color: 'rgba(255, 255, 255, 0.2)'
                }),
                stroke: new ol.style.Stroke({
                    color: 'ffffff',
                    width: 1
                }),
                image: new ol.style.Circle({
                    radius: 1,
                    fill: new ol.style.Fill({
                        color: '#ffffff'
                    })
                })
            })]
        }
    };
})();

