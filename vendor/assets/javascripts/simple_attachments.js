var simple_attachments = {

  setFieldsData: function(event, data) {
    var field = event.currentTarget;
    var options = event.data.options;
    var hidden_input = $("<input>").attr("type", "hidden").attr("name", input_name).attr("value", data.id);
    var destroy_link = null;
    if (options.can_destroy) {
      destroy_link = $("<a>").attr("class", "simple_attachments_destroy").attr("href", data.filepath);
      destroy_link.bind("click", {field: field, destroy_remote: options.destroy_remote}, function(event) {
        if (event.data.destroy_remote) $.post(this.href, { _method: "delete" });
        event.data.field.remove();
        return false;
      });
    }
    field.trigger("loaded", [data]);
  },

  createInput: function(event) {
    var div = event.currentTarget;
    var input = $("<input>").attr("type", "file").attr("class", "simple_attachments_input").attr("name", "file");
    input.appendTo(div.find(".simple_attachments_add_file_div"));
    var form = $("<form>").attr("method", "post").attr("action", div.attr("data-attachments-path")).attr("enctype", "multipart/form-data").attr("accept-charset", "UTF-8");
    $("<input>").attr("type", "hidden").attr("name", $("meta[name=csrf-param]").attr("content")).attr("value",  $("meta[name=csrf-token]").attr("content")).appendTo(form);
    $("<input>").attr("type", "hidden").attr("name", "container_id").attr("value", div.attr("data-container-id")).appendTo(form);
    $("<input>").attr("type", "hidden").attr("name", "container_model").attr("value", div.attr("data-container-model")).appendTo(form);
    $("<input>").attr("type", "hidden").attr("name", "method").attr("value", div.attr("data-method")).appendTo(form);
    input.bind("change", {div: div.get(0), form: form}, simple_attachments.createIframe);
  },

  createIframe: function(event) {
    var input = event.currentTarget;
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
    var iframe = event.currentTarget;
    var div = event.data.div;
    var form = event.data.form;
    iframe.off();
    form.appendTo(iframe.contents().find("body"));
    form.submit();
    iframe.bind("load", {field: div.giveField()}, simple_attachments.receiveForm);
  },
  
  receiveForm: function(event) {
    var iframe = event.currentTarget;
    var field = event.data.field;
    var answer = $.parseJSON(iframe.contents().find("body").text());
    var data = answer.data;
    if (answer.succeed)
      field.trigger("uploaded", [data]);
    else
      field.trigger("failed", [data]);
    iframe.remove();
  }

}

$(function() {

  $(".simple_attachments_multiple_div").each(function() {
    this.input_name = $(this).attr("data-container-model")+"["+$(this).attr("data-method")+"_][]";
    this.giveField = function() {
      this.createField();
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
      var field = $(this).find(".simple_attachments_field_div");
      if (field.length)
        field = field;
      else
        field = this.createField();
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
      this.newField(field);
      field.bind("uploaded", {options: this.options}, simple_attachments.setFieldsData);
    }
    this.bind("create_input", simple_attachments.createInput);
    this.init();
    this.loadAttached(attached);
    this.trigger("create_input");
  });

});