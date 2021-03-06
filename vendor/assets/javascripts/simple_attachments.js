var simple_attachments = {

  getCSRF: function() {
    var name = $("meta[name=csrf-param]");
    var value = $("meta[name=csrf-token]");
    name = (name.length ? name.attr("content") : "authenticity_token");
    value = (value.length ? value.attr("content") : "");
    return {name: name, value: value}
  },

  setFieldsData: function(event, data) {
    var field = $(event.currentTarget);
    var div = event.data.div;
    var options = div.options;
    $("<input>").attr("type", "hidden").attr("name", div.input_name).attr("value", data.id).appendTo(field);
    data.destroy_link = null;
    if (options.can_destroy) {
      data.destroy_link = $("<a>").attr("class", "simple_attachments_destroy_link").attr("href", data.filepath);
      data.destroy_link.bind("click", {field: field, destroy_remote: options.destroy_remote}, function(event) {
        if (event.data.destroy_remote) {
          var csrf = simple_attachments.getCSRF();
          var post = {_method: "delete"};
          post[csrf.name] = csrf.value;
          $.post(this.href, post);
        }
        event.data.field.remove();
        return false;
      });
    }
    data.attachment_link = $("<a>").attr("class", "simple_attachments_attachment_link").attr("href", data.filepath);
    data.div = div;
    field.trigger("loaded", [data]);
  },

  createInput: function(event) {
    var div = $(event.currentTarget);
    var input = $("<input>").attr("type", "file").attr("class", "simple_attachments_input").attr("name", "file");
    input.appendTo(div.find(".simple_attachments_add_file_div"));
    var form = $("<form>").attr("method", "post").attr("action", div.attr("data-attachments-path")).attr("enctype", "multipart/form-data").attr("accept-charset", "UTF-8");
    var csrf = simple_attachments.getCSRF();
    $("<input>").attr("type", "hidden").attr("name", csrf.name).attr("value", csrf.value).appendTo(form);
    $("<input>").attr("type", "hidden").attr("name", "container_id").attr("value", div.attr("data-container-id")).appendTo(form);
    $("<input>").attr("type", "hidden").attr("name", "container_model").attr("value", div.attr("data-container-model")).appendTo(form);
    $("<input>").attr("type", "hidden").attr("name", "method").attr("value", div.attr("data-method")).appendTo(form);
    input.bind("change", {div: div, form: form}, simple_attachments.createIframe);
  },

  createIframe: function(event) {
    var input = $(event.currentTarget);
    var div = event.data.div;
    var form = event.data.form;
    var iframe = $("<iframe>").attr("class", "simple_attachments_iframe");
    input.off();
    $("body").append(iframe);
    input.appendTo(form);
    div.trigger("create_input");
    iframe.bind("load", event.data, simple_attachments.sendForm);
  },

  sendForm: function(event) {
    var iframe = $(event.currentTarget);
    var div = event.data.div;
    var form = event.data.form;
    iframe.off();
    form.appendTo(iframe.contents().find("body"));
    form.submit();
    iframe.bind("load", {field: div.get(0).giveField()}, simple_attachments.receiveForm);
  },

  receiveForm: function(event) {
    var iframe = $(event.currentTarget);
    var field = event.data.field;
    var answer = $.parseJSON(iframe.contents().find("body").text());
    var data = [answer.data];
    if (answer.succeed) {
      field.trigger("uploaded", data);
    } else {
      field.trigger("failed", data);
      field.remove();
    }
    iframe.remove();
  }

}

$(function() {

  $(".simple_attachments_multiple_div").each(function() {
    this.input_name = $(this).attr("data-container-model")+"["+$(this).attr("data-method")+"_][]";
    this.giveField = function() {
      return this.createField();
    }
    this.loadAttached = function(attached) {
     for (i in attached) {
       var data = attached[i];
       var field = this.createField();
       field.trigger("uploaded", [attached[i]]);
     }
    }
  });

  $(".simple_attachments_singleton_div").each(function() {
    this.input_name = $(this).attr("data-container-model")+"["+$(this).attr("data-method")+"_]";
    this.giveField = function() {
      var old_field = $(this).find(".simple_attachments_field_div");
      var field = this.createField();
      field.bind("uploaded", {old_field: old_field}, function(event) {
        event.data.old_field.remove();
      });
      return field;
    }
    this.loadAttached = function(attached) {
      if (attached) {
        var field = this.createField();
        field.trigger("uploaded", [attached]);
      }
    }
  });

  $(".simple_attachments_div").each(function() {
    var attached = $.parseJSON($(this).attr("data-attached"));
    this.options = $.parseJSON($(this).attr("data-options"));
    this.createField = function() {
      var field = $("<div>").attr("class", "simple_attachments_field_div");
      field.bind("uploaded", {div: this}, simple_attachments.setFieldsData);
      $(this).trigger("new_field", [field]);
      return field;
    }
    $(this).bind("create_input", simple_attachments.createInput);
    $(this).trigger("init");
    this.loadAttached(attached);
    if (this.options.can_create)
      $(this).trigger("create_input");
    else
      $(this).find(".simple_attachments_add_file_div").hide();
  });

});
