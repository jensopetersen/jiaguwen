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
let $doc := collection("/db/tls/data/BB")/(id("uuid-1C03C3AB-3553-4325-9C69-52EEA33225B6"))
(:let $log := util:log("DEBUG", ("##$doc): ", $doc)):)
(:let $log := util:log("DEBUG", ("##$model-1): ", $model)):)
return
    map { "data" := $doc }

};

declare function app:title($node as node(), $model as map(*)) {
    element{node-name($node)}{$node/@*, attribute value{$model("data")/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title}}
};

declare 
    %templates:wrap
function app:line-select($node as node(), $model as map(*)) {
    for $line in $model("data")/tei:text[1]/tei:group[1]/tei:text/@n
    return
        <option>{$line/string()}</option>
};

declare function app:get-lines($body as element(tei:TEI), $line-number as xs:string, 
    $type as xs:string, $subtype as xs:string) {
    let $text :=
        $body/tei:text[1]/tei:group[1]/tei:text[@n eq $line-number]/tei:group[1]/tei:text[@type = $type][@subtype = $subtype]
    let $editable := (: if ($text/@xml:id) then "false" else "true" :) "true"
    return
        <ol contenteditable="{$editable}">
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
    let $width := if ($type = "translation") then 6 else 6
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

declare function app:textarea($node as node(), $model as item()*) 
{
let $model := util:expand($model)
let $log := util:log("DEBUG", ("##$model-1): ", $model))
let $line-number := '3'
let $model := $model/tei:text[1]/tei:group[1]/tei:text[@n eq $line-number]/tei:group[1]/tei:text
let $log := util:log("DEBUG", ("##$model-2): ", $model))
for $text-element in $model
    let $log := util:log("DEBUG", ("##$text-element): ", $text-element))
    let $count-translation := count($model[@type eq 'translation'])
    let $count-transcription := count($model[@type eq 'transcription'])
    let $editorWidth := 12 idiv ($count-transcription + $count-translation)
    let $width-transcription := 15 
    let $width-translation := (100 - ($count-transcription * $count-translation)) div $count-translation 
    let $type := $text-element/@type/string()
    let $subtype := $text-element/@subtype/string()
    return
        (:<div xmlns="http://www.w3.org/1999/xhtml" class="editor {if($subtype eq 'yuanwen') then 'CHANT' else ()}">:)
        (:<div class="editor" style="width:{if ($type eq 'translation') then concat($width-translation, '%') else concat($width-transcription, '%')}">:)
        <div class="editor span{$editorWidth}">
        <div class="selects">
                <select class="type">
                {
                    for $option in $app:type-options
                    return
                        if ($option eq $type)
                        then <option selected="selected">{$option}</option>
                        else <option>{$option}</option>
                    }
                    </select>
                    <select class="subtype">
                    {
                    for $option in $app:subtype-options
                    return
                        if ($option eq $subtype)
                        then <option selected="selected">{$option}</option>
                        else <option>{$option}</option>
                    }
                </select>
            </div>
        {
        element{node-name($node)}
        {$node/@*, 
        (:NB: How do I get this html to render here?:)
        (:string-join(
            for $seg in $text-element//tei:seg
                let $string := $seg/text()
                let $string := replace($string, '(\p{Co})', '<span xmlns="http://www.w3.org/1999/xhtml" class="CHANT">$1</span>')
                let $string := replace($string, '(\p{IsCJKUnifiedIdeographs})', '<span xmlns="http://www.w3.org/1999/xhtml" class="CJK">$1</span>')
                let $string := replace($string, '(\p{IsCJKUnifiedIdeographsExtensionA})', '<span xmlns="http://www.w3.org/1999/xhtml" class="CJK-A">$1</span>')
                let $string := replace($string, '(\p{IsCJKUnifiedIdeographsExtensionB})', '<span xmlns="http://www.w3.org/1999/xhtml" class="CJK-B">$1</span>')
                let $log := util:log("DEBUG", ("##$string): ", $string))
                    return util:parse(concat('<span>',$string,'</span>'))/span
        , '&#xA;'):)
        string-join(
            for $seq in $text-element//tei:seg
                return
            $seq/text(), '&#xA;')
        }}</div>
};