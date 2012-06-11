module namespace app="http://exist-db.org/xquery/app";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $app:type-options := ('transcription', 'translation');
declare variable $app:subtype-options := ('yuanwen', 'shiwen', 'Serruys', 'Takashima');

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";

(:~
 : This function can be called from the HTML templating. It shows which parameters
 : are required for a function to be callable from the templating system. To build 
 : your application, add more functions to this module.
 :)
declare function app:load($node as node(), $model as map(*)) {
let $host-id := "uuid-1C03C3AB-3553-4325-9C69-52EEA33225B6"
let $doc := collection("/db/tls/data/BB")/(id($host-id))
    return
        map { "data" := $doc }

};

declare function app:title($node as node(), $model as map(*)) {
    element{node-name($node)}{$node/@*, attribute value{$model("data")/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title}}
};

declare 
    %templates:wrap
function app:line-select($node as node(), $model as map(*)) {
    for $line at $i in $model("data")/tei:text[1]/tei:group[1]/tei:text
    return
        <option>{$i}</option>
};

declare function app:get-lines($model as element(tei:TEI), $line-number as xs:string, 
    $type as xs:string, $subtype as xs:string) {
    let $host-id := $model/@xml:id/string()
    let $text :=
        $model/tei:text[1]/tei:group[1]/tei:text[@n eq $line-number]/tei:group[1]/tei:text[@type eq $type][@subtype eq $subtype]
    let $text-id := $text/@xml:id/string()
    let $doc := collection("/db/tls/data")/(id($text-id))/ancestor::tei:TEI    
    let $doc-id := $doc/@xml:id/string()
    let $editable :=  if ($host-id eq $doc-id) then "true" else "false"
    return
        <ol 
            contenteditable="{$editable}" 
            class="{if($type eq 'transcription') then 'CHANT' else ''}">
        {
            for $line in $text//tei:seg/text()
            return
                <li>{normalize-space($line)}</li>
        }
        </ol>
};

declare function app:editor($node as node(), $model as map(*), $type as xs:string, $subtype as xs:string) {
    let $model := util:expand($model("data"))
    let $line-number := '1'
    let $lines := app:get-lines($model, $line-number, $type, $subtype)
    let $width := if ($type = "translation") then 9 else 3
    let $texts := $model/tei:text[1]/tei:group[1]/tei:text[@n eq $line-number]/tei:group[1]/tei:text
    let $options :=
        for $text in $texts return concat($text/@type, "/", $text/@subtype)
        let $currentOption := concat($type, "/", $subtype)
        return
            <div class="editor-container span{$width}">
                <div class="selects">
                    <select class="type-select" name="type">
                    {
                        for $option in $options
                        return
                            <option>
                            { if ($option = $currentOption) then attribute selected { "selected" } else () }
                            {$option}
                            </option>
                    }
                    </select>
                    <button class="btn editor-save">Save</button>
                </div>
                <div class="editor">{$lines}</div>
            </div>
};

