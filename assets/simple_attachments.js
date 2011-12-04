function simple_attachments_add_input_file(div) {
  var input = $("<input>").attr("type", "file").attr("class", "simple_attachments_input").attr("name", "file");
  input.appendTo(div);
  input.data("iframe_options", { new: div.attr("data-new-attachment"),
                                 input_name: div.attr("data-container")+"["+div.attr("data-attachments")+"][]",
                                 div: div
                               });
  input.change(function() {
    $(this).off();
    var iframe = $("<iframe>").attr("class", "simple_attachments_iframe");
    iframe.appendTo($("body"));
    iframe.data("options", $(this).data("iframe_options"));
    iframe.data("input", $(this));
    iframe.load(function() {
      var options = $(this).data("options");
      var input = $(this).data("input");
      var form = $("<form>").attr("method", "post").attr("action", options.new).attr("enctype", "multipart/form-data").attr("accept-charset", "UTF-8");
      form.appendTo($(this).contents().find("body"));
      input.appendTo(form);
      simple_attachments_add_input_file(options.div);
      $(this).off();
      $(this).load(function() {
        var body = $(this).contents().find("body");
        var options = $(this).data("options");
        var errors = body.children("div");
        if (errors.size()) {
          var errors_array = []
          errors.each(function() {
            errors_array.push($(this).text());
          });
          options.div.trigger("upload_error", errors_array);
        }else{
          var input = $("<input>").attr("type", "hidden").attr("name", options.input_name).attr("value", body.text());
          input.appendTo(options.div);
        }
        $(this).remove();
      });
      form.submit();
    });
  });
}

$(function() {
  $("div.simple_attachments_main_div").each(function() {
    simple_attachments_add_input_file($(this));
  });
})
