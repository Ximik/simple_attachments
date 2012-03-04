//= require_self
//= require simple_attachments

$(function() {
  $(".simple_attachments_singleton_div").bind("new_field", function(event, field) {
    field.appendTo($(this).children(".simple_attachments_add_file_div"));
    field.bind("loaded", function(event, data) {
      $("<img>").attr("src", data.filepath).appendTo(this);
    });
  });
  $(".simple_attachments_multiple_div").bind("new_field", function(event, field) {
    field.appendTo(this);
    field.bind("loaded", function(event, data) {
      data.destroy_link.appendTo(this);
      data.attachment_link.html(data.filename).appendTo(this);
    });
  });
});