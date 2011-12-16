function simple_attachments_add_input_file(div) {
  var input = $("<input>").attr("type", "file").attr("class", "simple_attachments_input").attr("name", "file");
  input.appendTo(div.find(".simple_attachments_add_file_div"));
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
      $(this).off();
      $(this).load(function() {
        var body = $(this).contents().find("body");
        var options = $(this).data("options");
        var answer = $.parseJSON($(this).contents().find("body").text());
        if (answer.succeed) {
          answer.data.input_tag = $("<input>").attr("type", "hidden").attr("name", options.input_name).attr("value", answer.data.id);
          options.div.trigger("uploaded", [answer.data]);
        }else{
          options.div.trigger("error", [answer.data]);
        }
        $(this).remove();
      });
      simple_attachments_add_input_file(options.div);
      form.submit();
    });
  });
}

$(function() {
  $("div.simple_attachments_main_div").each(function() {
    simple_attachments_add_input_file($(this));
  });
})
