$(document).ready(function() {
    var editors = [];
    var line = $("#line-select").val();
    var id = $("#text-id").val();
    $(".editor-container").each(function() {
        editors.push(new TLS.Editor(this, id, line));
    });
    $("#line-select").change(function(ev) {
        var line = $(this).val();
        for (var i = 0; i < editors.length; i++) {
            editors[i].setLine(line);
        }
    });
    
    /*
     * We use the onScrollBeyond jQuery plugin to dynamically load
     * additional search results when the users scrolls down the page.
     */
    var itemsPerPage = 10;
    var current = 1;
    var loading = false;
    jQuery(document).ready(function () {
        $("#results").onScrollBeyond(function () {
            if (loading) {
                return;
            }
            loading = true;
            current = current + itemsPerPage;
            $.ajax("ajax.html", {
                data: { start: current },
                success: function (data) {
                    $("#results").append(data);
                    loading = false;
                }
            });
        });
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
    
    Constr = function(container, id, line) {
        this.container = $(container);
        this.line = line;
        this.id = id;
        
        this.editable = $(".editor", container);
        
        var $this = this;
        $(".type-select", container).change(function(ev) {
            ev.preventDefault();
            $this.load();
        });
        $(".editor-save", container).click(function(ev) {
            ev.preventDefault();
            var value = $this.editable.html();
            var type = $this.getType();
            $.ajax({
                type: "POST",
                url: "modules/store.xql",
                data: { id: $this.id, data: value, type: type, line: $this.line },
                success: function(data) {
                    
                },
                error: function(xhr) {
                    alert("Save failed! " + xhr.responseText);
                }
            });
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
        $.get("modules/get-lines.xql", { id: this.id, type: type, line: this.line },
            function(data) {
                $this.editable.html(data);
            }
        );
    };
    return Constr;
}());