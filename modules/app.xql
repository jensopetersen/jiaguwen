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
declare function app:load($node as node(), $params as element(parameters)?, $model as item()*) {
let $doc := collection("/db/tls/data/BB")/(id("uuid-1C03C3AB-3553-4325-9C69-52EEA33225B6"))
(:let $log := util:log("DEBUG", ("##$doc): ", $doc)):)
    for $model in $doc
    (:let $log := util:log("DEBUG", ("##$model-1): ", $model)):)
    return
        templates:process($node/*, $model)

};

declare function app:title($node as node(), $params as element(parameters)?, $model as item()*) {
    element{node-name($node)}{$node/@*, attribute value{$model/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title}}
};


declare function app:textarea($node as node(), $params as element(parameters)?, $model as item()*) 
{
(:Why does this not catch the included text elements? They are in the model.:)
let $model := $model//tei:text/tei:group/tei:text
for $text-element in $model
    let $count-translation := count($model[@type eq 'translation'])
    let $count-transcription := count($model[@type eq 'transcription'])
    let $width-transcription := 15 
    let $width-translation := (100 - ($count-transcription * $count-translation)) div $count-translation 
    let $log := util:log("DEBUG", ("##$model-2): ", $model))
    let $log := util:log("DEBUG", ("##$text-element-1): ", $text-element))
    let $type := $text-element/@type/string()
    let $subtype := $text-element/@subtype/string()
    return    
        (:<div xmlns="http://www.w3.org/1999/xhtml" class="editor {if($subtype eq 'yuanwen') then 'CHANT' else ()}">:)
        <div class="editor" width="{if ($type eq 'translation') then concat($width-translation, '%') else concat($width-transcription, '%')}">
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
                    return $string
        , '&#xA;'):)
        string-join(
            for $seq in $text-element//tei:seg
                return
            $seq/text(), '&#xA;')
        }}</div>
};