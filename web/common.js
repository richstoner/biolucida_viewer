// we keep the last layer in case we navigate in z
var image_layer = undefined;
var last_image_layer = undefined;
var image_z_index = 0;
var image_metadata = undefined;
var current_z = 0;
var map = undefined;
var layerRecycleQueue = [];

// Debug
console = new Object();
console.log = function(log) {
    var iframe = document.createElement("IFRAME");
    iframe.setAttribute("src", "ios-log:#iOS#" + log);
    document.documentElement.appendChild(iframe);
    iframe.parentNode.removeChild(iframe);
    iframe = null;
};
console.debug = console.log;
console.info = console.log;
console.warn = console.log;
console.error = console.log;

console.log('Application loaded.');
