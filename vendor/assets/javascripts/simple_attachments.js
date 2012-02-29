//jQuery hack
//http://www.bennadel.com/blog/2268-Appending-An-Array-Of-jQuery-Objects-To-The-DOM.htm
jQuery.fn.appendEach = function( arrayOfWrappers ){
  var rawArray = jQuery.map(
    arrayOfWrappers,
    function(value, index){
      return(value.get());
    }
  );
  this.append(rawArray);
  return(this);
};

var simple_attachments = {
  //Creates new field with service data in it
  newField_pt: function(object, input_name, destroy) {
    //Create new field
    var field = $("<div>").attr("class", "simple_attachments_field_div");
    object.newField(field);
    field.data("input_name", input_name);
    field.data("destroy", destroy);
    field = field.get(0);
    //Prepares data for field
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
  },

  //Creates input file field inside the div
  addInput_pt: function(object, container_model, container_id, method, attachments_path, field_fn) {
    //Create input file field
    var input = $("<input>").attr("type", "file").attr("class", "simple_attachments_input").attr("name", "file");
    input.appendTo($(object).find(".simple_attachments_add_file_div"));
    //Create form
    var inputs = [ $(input),
                   $("<input>").attr("type", "hidden").attr("name", $("meta[name=csrf-param]").attr("content")).attr("value",  $("meta[name=csrf-token]").attr("content")),
                   $("<input>").attr("type", "hidden").attr("name", "container_id").attr("value", container_id),
                   $("<input>").attr("type", "hidden").attr("name", "container_type").attr("value", container_model),
                   $("<input>").attr("type", "hidden").attr("name", "method").attr("value", method)
                 ];
    var form = $("<form>").attr("method", "post").attr("action", attachments_path).attr("enctype", "multipart/form-data").attr("accept-charset", "UTF-8");
    input.data("object", object);
    input.data("form", form);
    input.data("inputs", inputs);
    input.data("field_fn", field_fn);
    //Catch file choice
    input.change(function() {
      $(this).off();
      var form = $(this).data("form");
      var inputs = $(this).data("inputs");
      var object = $(this).data("object");
      var field = $(this).data("field_fn")(object);
      form.appendEach(inputs);
      object.addInput();
      simple_attachments.sendForm(form, field);
    });
  },

  //Creates iframe, submit form in it and apply answer to field
  sendForm: function(form, field) {
    var iframe = $("<iframe>").attr("class", "simple_attachments_iframe");
    iframe.appendTo($("body"));
    iframe.data("form", form);
    iframe.data("field", field);
    //Catches iframe creation
    iframe.load(function() {
      $(this).off();
      var form = iframe.data("form");
      form.appendTo($(this).contents().find("body"));
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
      //Submit form
      form.submit();
    });
  }
}

$(function() {
  //For SimpleAttachmentsFormHelper multiple_file_field
  $(".simple_attachments_multiple_div").each(function() {
    this.newField_pt = function() {
      var input_name = $(this).attr("data-container-model")+"["+$(this).attr("data-method")+"_][]";
      var destroy = $(this).attr("destroy") == 'true' ? true : false;
      return simple_attachments.newField_pt(this, input_name, destroy);
    }
    this.addInput = function() {
      var container_model = $(this).attr("data-container-model");
      var container_id = $(this).attr("data-container-id");
      var method = $(this).attr("data-method");
      var attachments_path = $(this).attr("data-attachments-path");
      simple_attachments.addInput_pt(this, container_model, container_id, method, attachments_path, function(object) {
        return object.newField_pt();
      });
    }
    //Init engine with optional data
    var data = $.parseJSON($(this).attr("data-other"));
    this.init(data);
    //Create first input field
    this.addInput();
    //Show already added attachments
    var attached = $.parseJSON($(this).attr("data-attached"));
    for (i in attached) {
      var data = attached[i];
      var field = this.newField_pt();
      field.setData_pt(attached[i]);
    }
  });
  //For SimpleAttachmentsTagHelper file_tag
//   $(".simple_attachments_singelton_div").each(function() {
//     $(this).newField_pt = function() {
//       var input_name = $(this).attr("data-container-model")+"["+$(this).attr("data-method")+"][]";
//       return simple_attachments.newField_pt(this, input_name, true);
//     }
//     this.addInput = function() {
//       var container_model = $(this).attr("data-container-model");
//       var container_id = $(this).attr("data-container-id");
//       var attachments_path = $(this).attr("data-attachments-path");
//       simple_attachments.addInput(this, container_model, container_id, attachments_path, function(object) {
//         var field = object.find(".simple_attachments_field_div");
//         if (field.length) {
//           field = field.get(0);
//         }else{
//           field = this.newField_pt();
//         }
//         return field;
//       });
//     }
//     //Init engine with optional data
//     var data = $.parseJSON($(this).attr("data-other"));
//     this.init(data);
//     //Create first input field
//     this.addInput();
//     //Show already added attachment
//     var attached = $.parseJSON($(this).attr("data-attached"));
//     if (attached.length) {
//       var data = attached[0];
//       var field = this.newField_pt();
//       field.setData_pt(attached[0]);
//     }
//   });
});
