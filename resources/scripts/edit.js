$(document).ready(function() {
    var editors = [];
    var line = $("#line-select").val();
    $(".editor-container").each(function() {
        editors.push(new TLS.Editor(this, line));
    });
    $("#line-select").change(function(ev) {
        var line = $(this).val();
        for (var i = 0; i < editors.length; i++) {
            editors[i].setLine(line);
        }
    });
});

var TLS = TLS || {};

/**
 * Namespace function. Required by all other classes.
 */
TLS.namespace = function (ns_string) {
    var parts = ns_string.split('.'),
        parent = TLS,
		i;
	if (parts[0] == "Atomic") {
		parts = parts.slice(1);
	}
	
	for (i = 0; i < parts.length; i++) {
		// create a property if it doesn't exist
		if (typeof parent[parts[i]] == "undefined") {
			parent[parts[i]] = {};
		}
		parent = parent[parts[i]];
	}
	return parent;
};

TLS.Editor = (function() {
    
    Constr = function(container, line) {
        this.container = $(container);
        this.line = line;
        
        this.editor = new TLS.Ace($(".editor", container)[0]);
        
        var $this = this;
        $(".type-select", container).click(function(ev) {
            ev.preventDefault();
            $this.load();
        });
        $(".editor-save", container).click(function(ev) {
            ev.preventDefault();
            var value = $this.editor.getValue();
            var type = $this.getType();
            $.post("modules/store.xql", { data: value, type: type });
        });
    };
    
    Constr.prototype.getType = function() {
        return this.container.find("select[name='type']").val();
    };
    
    Constr.prototype.setLine = function(line) {
        console.log("Changing to line %s", line);
        this.line = line;
        this.load();
    };
    
    Constr.prototype.load = function() {
        var $this = this;
        var type = this.getType();
        $.get("modules/get-lines.xql", { type: type, line: this.line },
            function(data) {
                $this.editor.setValue(data);
            }
        );
    };
    return Constr;
}());

TLS.Ace = (function () {
    
    var Renderer = require("ace/virtual_renderer").VirtualRenderer;
    var Editor = require("ace/editor").Editor;
	var EditSession = require("ace/edit_session").EditSession;
    var UndoManager = require("ace/undomanager").UndoManager;
    
    Constr = function(container) {
        var $this = this;
        this.container = $(container);
        this.input = $("textarea", container);
        var text = this.input.text();
        if (text.length === 0) {
            text = "\n";
        }
        
        this.input.empty().hide();
        
        var div = document.createElement("div");
        div.className = "code-editor " + this.container.className;
        this.container.append(div);
        
        var doc = new EditSession(text);
        doc.setUndoManager(new UndoManager());
        doc.setUseWrapMode(true);
        doc.setWrapLimitRange(0, 80);

        var renderer = new Renderer(div, "ace/theme/tomorrow");

        this.editor = new Editor(renderer, doc);
        this.editor.resize();
        
    };
    
    Constr.prototype.resize = function() {
        this.editor.resize();
    };
    
    Constr.prototype.focus = function() {
        this.editor.focus();
    };
    
    Constr.prototype.update = function() {
        var value = this.editor.getSession().getValue();
        this.input.val(value);
    };
    
    Constr.prototype.getValue = function() {
        return this.editor.getSession().getValue();
    }
    
    Constr.prototype.setValue = function(data) {
        this.editor.getSession().setValue(data);
    };
    
    return Constr;
}());