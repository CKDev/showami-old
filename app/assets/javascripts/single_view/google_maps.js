// This example adds a user-editable rectangle to the map.
// When the user changes the bounds of the rectangle,
// an info window pops up displaying the new bounds.

// TODO: wrap all code into an object.

var rectangle;
var map;
var infoWindow;

function initMap() {

  var rawBounds = $("#profile_geo_box").val();
  // TODO: this could be done better.  Move into it's own function, falling back to Denver.
  if (rawBounds) {
    var boundsArray = rawBounds.replace(/\(/g, "").replace(/\)/g, "").split(","); // Pull out just lats/longs.
    var north = boundsArray[1] * 1.0;
    var east = boundsArray[0] * 1.0;
    var south = boundsArray[3] * 1.0;
    var west = boundsArray[2] * 1.0;
    var bounds = {
      north: north,
      east: east,
      south: south,
      west: west
    };

    var centerLat = (north + south) / 2.0;
    var centerLong = (east + west) / 2.0;

    map = new google.maps.Map(document.getElementById("map"), {
      center: { lat: centerLat, lng: centerLong },
      zoom: 12
    });
  }
  else {
    var bounds = {
      north: 39.730,
      east: -104.980,
      south: 39.710,
      west: -105.010
    };

    map = new google.maps.Map(document.getElementById("map"), {
      center: { lat: 39.720, lng: -105.000 }, // Denver
      zoom: 12
    });
  }

  // Define the rectangle and set its editable property to true.
  rectangle = new google.maps.Rectangle({
    bounds: bounds,
    editable: true,
    draggable: true
  });

  rectangle.setMap(map);

  // Add an event listener on the rectangle.
  rectangle.addListener("bounds_changed", showNewRect);

  // Define an info window on the map.
  infoWindow = new google.maps.InfoWindow();
}
// Show the new coordinates for the rectangle in an info window.

/** @this {google.maps.Rectangle} */
function showNewRect(event) {
  var ne = rectangle.getBounds().getNorthEast();
  var sw = rectangle.getBounds().getSouthWest();
  $("#profile_geo_box").val("(" + ne.lng() + ", " + ne.lat() + "), (" + sw.lng() + ", " + sw.lat() + ")");

  var contentString = "<b>Showing area moved - click update below to save.</b>";

  // Set the info window's content and position.
  infoWindow.setContent(contentString);
  infoWindow.setPosition(ne);

  infoWindow.open(map);
}
