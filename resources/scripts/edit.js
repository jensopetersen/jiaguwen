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
        
        this.editable = $(".editor", container);
        
        var $this = this;
        $(".type-select", container).click(function(ev) {
            ev.preventDefault();
            $this.load();
        });
        $(".editor-save", container).click(function(ev) {
            ev.preventDefault();
            var value = $this.editable.html();
            var type = $this.getType();
            $.post("modules/store.xql", { data: value, type: type, line: $this.line });
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
                $this.editable.html(data);
            }
        );
    };
    return Constr;
}());