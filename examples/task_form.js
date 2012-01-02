//= require_self
//= require simple_attachments

$(function() {
  $(".simple_attachments_main_div").each(function() {
    this.newField = function() {
      var field = $("<div>").attr("class", "file_row");
      $("<div>").attr("class", "simple_attachments_loading").appendTo(field);
      field.appendTo($(this).children(".simple_attachments_add_file_div"));
      field = field.get(0);
      field.setData = function(data) {
        $(this).children(".simple_attachments_loading").remove();
        var size = data.filesize;
        if (size >= 1048576)
          size = (size/1048576).toFixed(1) + ' MiB';
        else if (size >= 1024)
          size = (size/1024).toFixed(1) + ' KiB';
        else
          size = size + ' B';
        var filename = data.filename;
        if (filename.length > 20) filename = filename.substring(0,20) + '~';
        $(this).append(data.hidden_input);
        $(this).append(data.destroy_link);
        $("<span>").attr("class", "simple_attachments_filename").html(filename).appendTo(this);
        $("<span>").attr("class", "simple_attachments_filesize").html("("+size+")").appendTo(this);
      }
      field.raiseErrors = function(errors) {
        for(i in errors) {
          var li = $("<li>").attr("class", "simple_attachments").html(errors[i]);
          li.appendTo("#errors ul");
        }
        $(this).remove();
      }
      return field;
    }
  });
});
