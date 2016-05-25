$(document).ready(function() {
  L.mapbox.accessToken = "pk.eyJ1IjoiYWxleGJyaW5rbWFuIiwiYSI6ImNpb2V3ZGFmMzAwcmF5OG0ybmIxOGpodngifQ.7UJJ4bmNAwY9b46NSTxGmw";
  var map = L.mapbox.map("map", "mapbox.streets").setView([39.720, -105.000], 12);

  var featureGroup = L.featureGroup().addTo(map);

  var drawControl = new L.Control.Draw({
    edit: {
      featureGroup: featureGroup
    },
    draw: {
      polygon: false,
      polyline: false,
      rectangle: true,
      circle: false,
      marker: false
    }
  }).addTo(map);

  map.on("draw:created", showRectangleArea);
  map.on("draw:edited", showRectangleAreaEdited);

  function showRectangleAreaEdited(e) {
    e.layers.eachLayer(function(layer) {
      showRectangleArea({ layer: layer });
    });
  }

  function showRectangleArea(e) {
    featureGroup.clearLayers();
    featureGroup.addLayer(e.layer);
    var bounds = e.layer.getBounds()
    var northEast = bounds.getNorthEast();
    var southWest = bounds.getSouthWest();

    $("#profile_geo_box").val("(" + northEast.lng + ", " + northEast.lat + "), (" + southWest.lng + ", " + southWest.lat + ")");
    e.layer.bindPopup("(" + northEast.lng + ", " + northEast.lat + "), (" + southWest.lng + ", " + southWest.lat + ")");
    e.layer.openPopup();
  }
});