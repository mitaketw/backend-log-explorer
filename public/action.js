$(function(){
  $("select").on("change", function(){
    $.get("/charts/" + $(this).val(), function(data){
      var inputs = data.INPUT;

      $("#yaml > textarea").html(JSON.stringify(data, null, 2));

      $("#inputs").empty();

      inputs.forEach(function(input){
        var name = Object.keys(input)[0];
        var type = Object.keys(input).map(function(q){
          return input[q];
        })[0];

        $("<input>").attr({
          type: type,
          class: "form-control",
          name: name,
          placeholder: name
        }).appendTo($("#inputs"));
      });
    });
  });

  $("#btnGenerate").on("click", function(){
    if ($("select").prop("selectedIndex") === 0) {
      alert("Please select a chart");

      return false;
    }

    var valid = true;

    $("#inputs > input").each(function(i, e){
      if(!$(e).val()){
        valid = false;
      }
    });

    if (!valid) {
      alert("Please input some value");

      return false;
    }

    var selectedYaml = $("select").val();
    var selectedNo = selectedYaml.split("_")[0];
    var serializeData = $("form").serialize();
    var queryStr = new URLSearchParams(serializeData);

    queryStr.delete("optFile");

    var b64 = btoa(selectedNo + "@" + queryStr.toString());
    var bid = b64.substring(0, b64.length - 1);

    if ($("#" + bid).length) {
      alert(selectedYaml + ", " + queryStr.toString() + " exists");

      return false;
    }

    $("#loading").show();

    $.post("/charts/generate?" + serializeData, function(data){
      window.location.reload(true);
    });
  });
});
