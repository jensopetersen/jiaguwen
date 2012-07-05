xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function local:replace($doc as element(), $line as xs:integer, $type as xs:string, $subtype as xs:string, 
    $data as element()) {
    let $line := $doc/tei:text/tei:group/tei:text[@n = $line]/tei:group/tei:text[@type = $type][@subtype = $subtype]/tei:body
    let $segs := $data//li
    let $content :=
        <p xmlns="http://www.tei-c.org/ns/1.0">
        {
            for $seg in $segs
            return
                <seg>{
                translate($seg/text(), '&#160;', '')
                }</seg>
        }
        </p>
    let $log := util:log("DEBUG", ($segs, " Replace: ", $line/tei:p, " with ", $content))
    return
        update replace $line/tei:p with $content
};

let $doc := collection("/db/tls/data/BB")/(id("uuid-1C03C3AB-3553-4325-9C69-52EEA33225B6"))
let $data := util:parse-html(request:get-parameter("data", ()))/*
let $type := request:get-parameter("type", ())
let $line := request:get-parameter("line", "3")
let $subtype := substring-after($type, "/")
let $type := substring-before($type, "/")
return
    local:replace($doc, $line, $type, $subtype, $data)
    
    