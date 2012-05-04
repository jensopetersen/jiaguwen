module namespace app="http://exist-db.org/xquery/app";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $app:type-options := ('', 'translation', 'transcription');
declare variable $app:subtype-options := ('', 'yuanwen', 'shiwen', 'Takashima');

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";

(:~
 : This function can be called from the HTML templating. It shows which parameters
 : are required for a function to be callable from the templating system. To build 
 : your application, add more functions to this module.
 :)
declare function app:load($node as node(), $params as element(parameters)?, $model as item()*) {
let $doc := collection("/db/tls/data")/(id("uuid-8AAE62E7-6D63-4B6C-AC87-2279FD7F9FDF"))
for $model in $doc
return
    templates:process($node/*, $model)

};

declare function app:title($node as node(), $params as element(parameters)?, $model as item()*) {
    element{node-name($node)}{$node/@*, attribute value{$model/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title}}
};


declare function app:textarea($node as node(), $params as element(parameters)?, $model as item()*) 
{

for $text-element in $model//tei:text/tei:group/tei:text
let $type := $text-element/@type
let $subtype := $text-element/@subtype
return    
    <div class="editor {if($subtype eq 'yuanwen') then 'CHANT' else ''}">
        <select>
        {
        for $option in $app:type-options
        return
            if ($option eq $type)
            then <option selected="selected">{$option}</option>
            else <option>{$option}</option>
        }
        </select>
        <select>
        {
        for $option in $app:subtype-options
        return
            if ($option eq $subtype)
            then <option selected="selected">{$option}</option>
            else <option>{$option}</option>
        }
        </select>
    {
    element{node-name($node)}
    {$node/@*, 
    string-join(
        for $seq in $text-element//tei:seg
            return
        $seq/text(), '&#xA;')
    }}</div>

};

