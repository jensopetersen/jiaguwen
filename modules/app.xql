xquery version "3.0";

module namespace tls="http://exist-db.org/xquery/app";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $tls:type-options := ('transcription', 'translation');
declare variable $tls:subtype-options := ('yuanwen', 'shiwen', 'Serruys', 'Takashima');

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace config="http://exist-db.org/xquery/apps/config" at "config.xql";
import module namespace tei2html="http://xmlopenfoundation.org/tei2html" at "tei2html.xqm";

(:~
 : This function can be called from the HTML templating. It shows which parameters
 : are required for a function to be callable from the templating system. To build 
 : your application, add more functions to this module.
 :)
declare function tls:load($node as node(), $model as map(*), $doc-id as xs:string) {
let $doc := collection("/db/tls/data")/(id($doc-id))
    return
        map { "data" := $doc }

};

(:declare function tls:title($node as node(), $model as map(*)) {
    element{node-name($node)}{$node/@*, attribute value{$model("data")/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title}}
};
:)

declare 
    %templates:wrap    
function tls:title($node as node(), $model as map(*)) {
    let $title := $model("data")/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/string()
    let $log := util:log("DEBUG", ("##$title): ", $title))

    return $title
};

declare 
    %templates:wrap
function tls:line-select($node as node(), $model as map(*), $text-n as xs:string) {
    for $line at $i in $model("data")/tei:text[1]/tei:group[1]/tei:text
    return
        if (number($text-n) eq $i) then
        <option selected="selected">{$i}</option>
        else
        <option>{$i}</option>
};

declare function tls:get-lines($model as element(tei:TEI), $line-number as xs:string, 
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
            let $segs := $text//tei:seg/text()
            let $segs := if (empty($segs)) then " " else $segs
            for $line in $segs
            return
                <li>{normalize-space($line)}</li>
        }
        </ol>
};

declare 
    %templates:default("text-n", "1")
function tls:editor($node as node(), $model as map(*), $type as xs:string, $subtype as xs:string, $text-n as xs:string) {
    let $model := util:expand($model("data"))
    let $lines := tls:get-lines($model, $text-n, $type, $subtype)
    let $width := if ($type = "translation") then 12 else 3
    let $texts := $model/tei:text[1]/tei:group[1]/tei:text[@n eq $text-n]/tei:group[1]/tei:text
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

declare %private function tls:get-collections($collections as xs:string*) {
    for $collection in $collections
    return
        collection($config:app-root || "/data/" || $collection)
};

declare 
    %templates:default("type", "text")
function tls:search($node as node(), $model as map(*), $type as xs:string, $query as xs:string?, $collection as xs:string*) {
    let $log := util:log("DEBUG", ("##$query: ", $query))
    let $collections := tls:get-collections($collection)
    let $result := 
        switch ($type)
            case "text" return
                $collections//tei:seg[ngram:contains(., $query)]
            case "translation" return
                $collections//tei:seg[ft:query(., $query)]
            default return
                $collections//tei:title[ft:query(., $query)]
    return (
        session:set-attribute("tls.result", $result),
        map { "search":= $result }
    )
};

declare function tls:from-session($node as node(), $model as map(*)) {
    let $results := session:get-attribute("tls.result")
    return
        map { "search" := $results }
};

declare
    %templates:default("start", 1)
function tls:display-line($node as node(), $model as map(*), $start as xs:integer) {
    let $results := $model("search")
    for $hit in subsequence($results, $start, 10)
    let $log := util:log("DEBUG", ("##$hit): ", $hit))
    let $doc-id := $hit/ancestor::tei:TEI/@xml:id/string()
    let $log := util:log("DEBUG", ("##$doc-id): ", $doc-id))
    let $editable :=  exists(collection("/db/tls/data/BB")/(id($doc-id))/@xml:id/string())
    let $log := util:log("DEBUG", ("##$editable): ", $editable))
    let $text-n := $hit/ancestor::tei:text[2]/@n/string()
    let $log := util:log("DEBUG", ("##$text-n): ", $text-n))
    let $text-id := $hit/ancestor::tei:text[1]/@xml:id
    let $hit-title := $hit/ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/text()
    let $type := $hit/ancestor::tei:text[1]/@type/string()
    let $subtype := $hit/ancestor::tei:text[1]/@subtype/string()
    let $log := util:log("DEBUG", ("##$hit-title): ", $hit-title))
    return
        (
        <tr class="hit-info">
            <td class="hit-link">
                <a href="display.html?doc-id={$doc-id}"><img src="resources/images/text.png"/></a>
            </td>
            <td class="hit-title">{$hit-title}</td>
            <td class="hit-link">
            {
            if ($editable) then 
                <a href="edit.html?doc-id={$doc-id}&amp;text-n={string($text-n)}"><img src="resources/images/page-edit-icon.png"/></a>
                else 
                ()
            }
            </td>
            <td class="text-n">{$text-n}</td>
            <td class="hit-type">{$type}/{$subtype}</td>
        </tr>,
        <tr class="hit-text">
            <td colspan="5" class="{$type}">{$hit/text()}</td>
        </tr>
        )
};


declare 
    %templates:wrap
function tls:hit-count($node as node(), $model as map(*)) {
    "Found: " || count($model("search"))
    
};

declare function tls:link-to-home($node as node(), $model as map(*)) {
    <a href="{request:get-context-path()}/apps/tls">{ 
        $node/@* except $node/@href,
        $node/node() 
    }</a>
};

declare 
    %templates:wrap
function tls:display-link-to-text($node as node(), $model as map(*), $doc-id as xs:string) {
let $doc-id := $doc-id
return
        <a href="display.html?doc-id={$doc-id}"><img src="resources/images/text.png"/></a>

};

declare 
    %templates:wrap
function tls:display-text($node as node(), $model as map(*), $doc-id as xs:string) {
let $doc := collection("/db/tls/data")/(id($doc-id))
let $doc := util:expand($doc)
return
        tei2html:main($doc)

};

declare 
    %templates:wrap
function tls:display-image($node as node(), $model as map(*), $doc-id as xs:string) {
    let $doc := collection("/db/tls/data")/(id($doc-id))
    let $doc := util:expand($doc)
    let $log := util:log("DEBUG", ("##$doc): ", $doc))
    let $image := $doc/tei:text[1]//tei:text[1]//tei:text[1]/@xml:id/string()
    let $log := util:log("DEBUG", ("##$image): ", $image))
    let $image := substring-after($image, 'H')
    let $image-part := substring-before(substring-after($image, '-'), '-')
    let $log := util:log("DEBUG", ("##$image-part): ", $image-part))
    let $image := substring-before($image, '-')
    let $log := util:log("DEBUG", ("##$image): ", $image))
    let $image := concat($image, if ($image-part eq '正') then '.00001' else '.00002', '.png')
    let $log := util:log("DEBUG", ("##$image): ", $image))
    let $image := concat('data/Heji/images/', $image)
    let $log := util:log("DEBUG", ("##$image): ", $image))
    return
        <a href="{$image}" class="cloud-zoom"
            rel="zoomWidth: 400">
            <img src="{$image}" alt="" title="" />
        </a>
};
