xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:media-type "application/json";

declare function local:replace($doc as element(), $text-n as xs:integer, $type as xs:string, $subtype as xs:string, 
    $data as element()) {
    let $title := $doc/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[1]/string()
    let $line := $doc/tei:text/tei:group/tei:text[@n = $text-n]/tei:group/tei:text[@type = $type][@subtype = $subtype]/tei:body
    let $segs := $data//li
    let $content :=
        <ab xmlns="http://www.tei-c.org/ns/1.0">
        {
            for $seg at $i in $segs
            return
                <seg xml:id="{($title || '.text-' || $text-n || '.text-' || $type || '-' ||$subtype || '.seg-' || $i)}" n="{$i}">{
                translate($seg/text(), '&#160;', '')
                }</seg>
        }
        </ab>
    let $log := util:log("DEBUG", ($segs, "
        replace:
        ", $line/tei:ab,
        "
        with:
        ", $content))
    return (
        update replace $line/tei:ab with $content,
        <status>ok</status>
    )
};

let $id := request:get-parameter("id", ())
let $doc := collection("/db/jiaguwen-data/BB")/(id($id))
let $data := util:parse-html(request:get-parameter("data", ()))/*
let $type := request:get-parameter("type", ())
let $text-n := request:get-parameter("line", "3")
let $subtype := substring-after($type, "/")
let $type := substring-before($type, "/")
return
    local:replace($doc, $text-n, $type, $subtype, $data)