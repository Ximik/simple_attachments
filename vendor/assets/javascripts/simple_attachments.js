var simple_attachments = {
  //Creates new field with service data in it
  newField_pt: function(input_name, destroy) {
    //Create new field
    var field = this.newField();
    //Add service data
    $(field).data("input_name", input_name);
    $(field).data("destroy", destroy);
    //Sets attachment data for field
    field.setData_pt = function(data) {
      //Prepare service data
      var hidden_input = $("<input>").attr("type", "hidden").attr("name", input_name).attr("value", data.id);
      var destroy_link = $("<a>").attr("class", "simple_attachments_destroy").attr("href", data.filepath);
      destroy_link.data("field", $(this));
      if (destroy) {
        destroy_link.click(function() {
          //Delete record and field
          $.post(this.href, { _method: "delete" });
          $(this).data("field").remove();
          return false;
        });
      }else{
        destroy_link.click(function() {
          //Delete only field
          $(this).data("field").remove();
           return false;
        });
      }
      data.hidden_input = hidden_input;
      data.destroy_link = destroy_link;
      //Call engine with service data
      this.setData(data);
    }
    return field;
  }
}

$(function() {
  $("div.simple_attachments_multiple_file_field_div").each(function() {
    $(this).data("new_path", $(this).attr("data-new-path"));
    var input_name = $(this).attr("data-container")+"["+$(this).attr("data-attachments")+"][]";
    var destroy = $(this).attr("destroy") == 'true' ? true : false;
    this.newField_pt = newField_pt(input_name, destroy);
    //Creates new field with service data in it
    this.newField_pt = function() {
      //Create new field
      var field = this.newField();
      //Add service data
      $(field).data("div", $(this));
      field.setData_pt = function(data) {
        //Prepare service data
        data.hidden_input = $("<input>").attr("type", "hidden").attr("name", $(this).data("div").data("input_name")).attr("value", data.id);
        var destroy_link = $("<a>").attr("class", "simple_attachments_destroy").attr("href", data.filepath);
        destroy_link.data("field", $(this));
        if ($(this).data("div").data("destroy") == 'true') {
          destroy_link.click(function() {
            //Delete record and field
            $.post(this.href, { _method: "delete" });
            $(this).data("field").remove();
            return false;
          });
        }else{
          destroy_link.click(function() {
            //Delete only field
            $(this).data("field").remove();
            return false;
          });
        }
        data.destroy_link = destroy_link;
        //Call engine with service data
        this.setData(data);
      }
      return field;
    }
    //Creates input file field inside the div
    this.addInputField = function() {
      var input = $("<input>").attr("type", "file").attr("class", "simple_attachments_input").attr("name", "file");
      input.appendTo($(this).find(".simple_attachments_add_file_div"));
      input.data("div", $(this));
      //Catches file choice
      input.change(function() {
        $(this).off();
        var iframe = $("<iframe>").attr("class", "simple_attachments_iframe");
        iframe.appendTo($("body"));
        iframe.data("inputs", [ $(this),
                                $("<input>").attr("type", "hidden").attr("name", "container_id").attr("value", $(this).data("div").attr("data-container-id")),
                                $("<input>").attr("type", "hidden").attr("name", "container_type").attr("value", $(this).data("div").attr("data-container"))
                              ]);
        iframe.data("field", $(this).data("div").get(0).newField_pt());
        //Catches iframe creation
        iframe.load(function() {
          $(this).off();
          var div = input.data("div");
          //Create form
          var inputs = $(this).data("inputs");
          var form = $("<form>").attr("method", "post").attr("action", div.data("new_path")).attr("enctype", "multipart/form-data").attr("accept-charset", "UTF-8");
          form.appendTo($(this).contents().find("body"));
          for (i in inputs) inputs[i].appendTo(form);
          //Catches iframe form send
          $(this).load(function() {
            var field = $(this).data("field");
            var answer = $.parseJSON($(this).contents().find("body").text());
            if (answer.succeed) {
              field.setData_pt(answer.data);
            }else{
              field.rescueErrors(answer.data);
            }
            $(this).remove();
          });
          //Create new input field
          div.get(0).addInputField();
          //Submit form
          form.submit();
        });
      });
    }
    //Create first input field
    this.addInputField();
    //Show already added attachments
    var attached = $.parseJSON($(this).attr("data-attached"));
    for (i in attached) {
      var data = attached[i];
      var field = this.newField_pt();
      field.setData_pt(attached[i]);
    }
    //Init engine with optional data
    var data = $.parseJSON($(this).attr("data-other"));
    this.init(data);
  });
})
