xquery version "3.0";

declare option exist:serialize "media-type=text/text";

import module namespace tls="http://exist-db.org/xquery/app" at "app.xql";

let $doc := util:expand(collection("/db/tls-data/BB")/(id("uuid-1c03c3ab-3553-4325-9c69-52eea33225b6")))
let $line := request:get-parameter("line", "1")
let $type := request:get-parameter("type", ())
let $subtype := substring-after($type, "/")
let $type := substring-before($type, "/")
return
    tls:get-lines($doc, $line, $type, $subtype)