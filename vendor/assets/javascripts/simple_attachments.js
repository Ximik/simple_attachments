$(function() {
  $("div.simple_attachments_main_div").each(function() {
    $(this).data("input_name", $(this).attr("data-container")+"["+$(this).attr("data-attachments")+"][]");
    $(this).data("new_path", $(this).attr("data-new-attachment"));
    this.newField_pt = function() {
      var field = this.newField();
      $(field).data("div", $(this));
      field.setData_pt = function(data) {
        data.hidden_input = $("<input>").attr("type", "hidden").attr("name", $(this).data("div").data("input_name")).attr("value", data.id);
        var destroy_link = $("<a>").attr("class", "simple_attachments_destroy").attr("href", data.filepath);
        destroy_link.data("field", $(this));
        destroy_link.click(function() {
          $.post(this.href, { _method: "delete" });
          $(this).data("field").remove();
          return false;
        });
        data.destroy_link = destroy_link;
        this.setData(data);
      }
      return field;
    }
    this.addInputField = function() {
      var input = $("<input>").attr("type", "file").attr("class", "simple_attachments_input").attr("name", "file");
      input.appendTo($(this).find(".simple_attachments_add_file_div"));
      input.data("div", $(this));
      input.change(function() { //When user clicks the add file button
        $(this).off();
        var iframe = $("<iframe>").attr("class", "simple_attachments_iframe");
        iframe.appendTo($("body"));
        iframe.data("inputs", [ $(this),
                                $("<input>").attr("type", "hidden").attr("name", "container_id").attr("value", $(this).data("div").attr("data-container-id")),
                                $("<input>").attr("type", "hidden").attr("type", "container_type").attr("value", $(this).data("div").attr("data-container"))
                              ]);
        iframe.data("field", $(this).data("div").get(0).newField_pt());
        iframe.load(function() { //When iframe is ready for file uploading
          var inputs = $(this).data("inputs");
          var div = input.data("div");
          var form = $("<form>").attr("method", "post").attr("action", div.data("new_path")).attr("enctype", "multipart/form-data").attr("accept-charset", "UTF-8");
          form.appendTo($(this).contents().find("body"));
          for (i in inputs) inputs[i].appendTo(form);
          $(this).off();
          $(this).load(function() { //When file uploading is ended
            var field = $(this).data("field");
            var answer = $.parseJSON($(this).contents().find("body").text());
            if (answer.succeed) {
              field.setData_pt(answer.data);
            }else{
              field.raiseErrors(answer.data);
            }
            $(this).remove();
          });
          div.get(0).addInputField();
          form.submit();
        });
      });
    }
    this.addInputField();
    var attached = $.parseJSON($(this).attr("data-attached"));
    for (i in attached) {
      var data = attached[i];
      var field = this.newField_pt();
      field.setData_pt(attached[i]);
    }
    var data = $.parseJSON($(this).attr("data-other"));
    this.init(data);
  });
})
