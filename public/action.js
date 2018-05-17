$(function(){
  $("select").on("change", function(){
    $.get("/charts/" + $(this).val(), function(data){
      var inputs = data.INPUT;

      $("#yaml > textarea").html(JSON.stringify(data, null, 2));

      $("#inputs").empty();

      inputs.forEach(function(input){
        $("<input>").attr({
          type: "text",
          class: "form-control",
          name: input,
          placeholder: input
        }).appendTo($("#inputs"));
      });
    });
  });

  $("#btnGenerate").on("click", function(){
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

    $("#loading").show();

    $.post("/charts/generate?" + $("form").serialize(), function(data){
      window.location.reload(true);
    });
  });
});