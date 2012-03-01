//= require_self
//= require simple_attachments

$(function() {
  $(".simple_attachments_div").each(function() {
    this.init = function() {}
  });
  $(".simple_attachments_multiple_div").each(function() {
    this.newField = function(field) {
      clear_errors();
      $("<div>").attr("class", "simple_attachments_loading").appendTo(field);
      field.insertBefore($(this).children(".simple_attachments_add_file_div"));
      field.bind("loaded", function(event, data) {
        $(this).children(".simple_attachments_loading").remove();
        var size = data.filesize;
        if (size >= 1048576)
          size = (size/1048576).toFixed(1) + " MiB";
        else if (size >= 1024)
          size = (size/1024).toFixed(1) + " KiB";
        else
          size = size + " B";
        var filename = data.filename;
        if (filename.length > 20)
          filename = filename.substring(0,15) + "~" + filename.substring(filename.lastIndexOf("."));
        $(this).append(data.hidden_input);
        $(this).append(data.destroy_link);
        $("<a>").attr("href", data.filepath).attr("class", "simple_attachments_filename").html(filename).appendTo(this);
        $("<span>").attr("class", "simple_attachments_filesize").html("("+size+")").appendTo(this);
      });
      field.bind("failed", function(event, errors) {
        for(i in errors) add_error(errors[i]);
        $(this).remove();
      });
      return field;
    }
  });
});