// TODO: wrap all code into an object.

var rectangle;
var map;
var infoWindow;
var bounds;

function initMap() {

  // Map styling.
  var styles = [
    {
      stylers: [
        { hue: "#00ffe6" },
        { saturation: -20 }
      ]
    },
    {
      featureType: "road",
      elementType: "geometry",
      stylers: [
        { lightness: 100 },
        { visibility: "simplified" }
      ]
    },
    {
      featureType: "road",
      elementType: "labels",
      stylers: [
        { visibility: "off" }
      ]
    }
  ];

  var styledMap = new google.maps.StyledMapType(styles, { name: "Styled Map" });

  // Default bounding box (Denver)
  var north = 39.730;
  var east = -104.980;
  var south = 39.710;
  var west = -105.010;
  var defaultZoom = 12;

  var zoom = $("#profile_geo_box_zoom").val() * 1;
  var rawBounds = $("#profile_geo_box").val();
  if (rawBounds) {
    var boundsArray = rawBounds.replace(/\(/g, "").replace(/\)/g, "").split(","); // Pull out just lats/longs.
    north = boundsArray[1] * 1.0;
    east = boundsArray[0] * 1.0;
    south = boundsArray[3] * 1.0;
    west = boundsArray[2] * 1.0;
  }
  else {
    setBoundingBoxValue(east, north, west, south);
    setZoomValue(defaultZoom);
  }

  bounds = {
    north: north,
    east: east,
    south: south,
    west: west
  };

  var centerLat = (north + south) / 2.0;
  var centerLong = (east + west) / 2.0;

  map = new google.maps.Map(document.getElementById("map"), {
    center: { lat: centerLat, lng: centerLong },
    zoom: zoom,
    mapTypeControlOptions: {
      mapTypeIds: [google.maps.MapTypeId.ROADMAP, "map_style"]
    }
  });

  // Associate the styled map with the MapTypeId and set it to display.
  map.mapTypes.set("map_style", styledMap);
  map.setMapTypeId("map_style");

  // Define the rectangle and set its editable property to true.
  rectangle = new google.maps.Rectangle({
    bounds: bounds,
    editable: true,
    draggable: true
  });

  rectangle.setMap(map);
  rectangle.addListener("bounds_changed", showNewRect);
  map.addListener("zoom_changed", showNewZoom);
  infoWindow = new google.maps.InfoWindow();
  google.maps.event.addListenerOnce(map, "idle", function() {
    checkBoundingBoxInWindow(bounds);
  });
}

function showNewRect(event) {
  var ne = rectangle.getBounds().getNorthEast();
  var sw = rectangle.getBounds().getSouthWest();
  setBoundingBoxValue(ne.lng(), ne.lat(), sw.lng(), sw.lat());
  infoWindow.setContent("<b>Showing area moved - click update below to save.</b>");
  infoWindow.setPosition(ne);
  infoWindow.open(map);
}

function showNewZoom(event) {
  setZoomValue(map.getZoom());
}

function setBoundingBoxValue(ne_lng, ne_lat, sw_lng, sw_lat) {
  $("#profile_geo_box").val("(" + ne_lng + ", " + ne_lat + "), (" + sw_lng + ", " + sw_lat + ")");
}

function setZoomValue(zoom) {
  $("#profile_geo_box_zoom").val(zoom);
}

function checkBoundingBoxInWindow() {
  var zoom = map.getZoom();
  if (zoom <= 0) {
    return;
  }

  var map_bounds = map.getBounds();
  var north = map_bounds.getNorthEast().lat();
  var east = map_bounds.getNorthEast().lng();
  var south = map_bounds.getSouthWest().lat();
  var west = map_bounds.getSouthWest().lng();

  // Only works for western hemisphere?
  if (bounds.north > north || bounds.east > east || bounds.south < south || bounds.west < west) {
    zoom--;
    map.setZoom(zoom);
    setZoomValue(zoom);
    checkBoundingBoxInWindow();
  }
}
