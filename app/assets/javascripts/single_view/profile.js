$(document).ready(function() {
  Profile.init();
});

var Profile = (function($) {

  return {

    init : function() {
      debugger;
      Profile.showHideMap();
      $("[name='profile[agent_type]']").change(Profile.showHideMap);
    },

    showHideMap : function() {
      debugger;
      agentType = $("[name='profile[agent_type]']:checked").val();
      if (agentType == "both" || agentType == "sellers_agent") {
        $("#map-feature").show("slow");
      }
      else {
        $("#map-feature").hide("slow");
      }
    }

  }

})(jQuery);