var ShowingsMap = (function($) {

  return {

    rectangle : "",
    map : "",
    infoWindow : "",
    bounds : "",

    initialize : function() {

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

      // Default bounding box (Denver).
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
        ShowingsMap.setBoundingBoxValue(east, north, west, south);
        ShowingsMap.setZoomValue(defaultZoom);
      }

      ShowingsMap.bounds = {
        north: north,
        east: east,
        south: south,
        west: west
      };

      var centerLat = (north + south) / 2.0;
      var centerLong = (east + west) / 2.0;

      ShowingsMap.map = new google.maps.Map(document.getElementById("map"), {
        center: { lat: centerLat, lng: centerLong },
        zoom: zoom,
        mapTypeControlOptions: {
          mapTypeIds: [google.maps.MapTypeId.ROADMAP, "map_style"]
        }
      });

      // Associate the styled map with the MapTypeId and set it to display.
      ShowingsMap.map.mapTypes.set("map_style", styledMap);
      ShowingsMap.map.setMapTypeId("map_style");

      // Define the rectangle and set its editable property to true.
      ShowingsMap.rectangle = new google.maps.Rectangle({
        bounds: ShowingsMap.bounds,
        editable: true,
        draggable: true
      });

      ShowingsMap.rectangle.setMap(ShowingsMap.map);
      ShowingsMap.rectangle.addListener("bounds_changed", ShowingsMap.showNewRect);
      ShowingsMap.map.addListener("zoom_changed", ShowingsMap.showNewZoom);
      ShowingsMap.infoWindow = new google.maps.InfoWindow();
      google.maps.event.addListenerOnce(ShowingsMap.map, "idle", function() {
        ShowingsMap.checkBoundingBoxInWindow(ShowingsMap.bounds);
      });
    },

    showNewRect : function(event) {
      var ne = ShowingsMap.rectangle.getBounds().getNorthEast();
      var sw = ShowingsMap.rectangle.getBounds().getSouthWest();

      ShowingsMap.setBoundingBoxValue(ne.lng(), ne.lat(), sw.lng(), sw.lat());
      // ShowingsMap.infoWindow.setContent("<b>Click update below to save.</b>");
      // ShowingsMap.infoWindow.setPosition(ne);
      // ShowingsMap.infoWindow.open(ShowingsMap.map);
    },

    showNewZoom : function(event) {
      ShowingsMap.setZoomValue(ShowingsMap.map.getZoom());
    },

    setBoundingBoxValue : function(ne_lng, ne_lat, sw_lng, sw_lat) {
      $("#profile_geo_box").val("(" + ne_lng + ", " + ne_lat + "), (" + sw_lng + ", " + sw_lat + ")");
    },

    setZoomValue : function(zoom) {
      $("#profile_geo_box_zoom").val(zoom);
    },

    checkBoundingBoxInWindow : function() {
      var zoom = ShowingsMap.map.getZoom();
      if (zoom <= 0) {
        return;
      }

      var bounds = ShowingsMap.bounds;
      var map_bounds = ShowingsMap.map.getBounds();
      var north = map_bounds.getNorthEast().lat();
      var east = map_bounds.getNorthEast().lng();
      var south = map_bounds.getSouthWest().lat();
      var west = map_bounds.getSouthWest().lng();
      var m = (east - west) * .05 // The map needs to be bigger than the box by this amount. (5% on each side).

      if (bounds.north > north + m || bounds.east > east + m || bounds.south < south + m|| bounds.west < west + m) {
        zoom--;
        ShowingsMap.map.setZoom(zoom);
        ShowingsMap.setZoomValue(zoom);
        ShowingsMap.checkBoundingBoxInWindow();
      }
    }

  };

})(jQuery);
