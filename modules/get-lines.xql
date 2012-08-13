xquery version "3.0";

declare option exist:serialize "media-type=text/text";

import module namespace tls="http://exist-db.org/xquery/app" at "app.xql";

let $doc := util:expand(collection("/db/tls-data/BB")/(id("uuid-1C03C3AB-3553-4325-9C69-52EEA33225B6")))
let $line := request:get-parameter("line", "1")
let $type := request:get-parameter("type", ())
let $subtype := substring-after($type, "/")
let $type := substring-before($type, "/")
return
    tls:get-lines($doc, $line, $type, $subtype)