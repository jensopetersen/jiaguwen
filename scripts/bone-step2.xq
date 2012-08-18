(:make basic document:)

declare namespace util="http://exist-db.org/xquery/util";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace functx = "http:/www.functx.com";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=yes indent=yes";

declare variable $username as xs:string := "admin";
declare variable $password as xs:string := "";
declare variable $in-collection := collection('/db/test/in');
declare variable $out-collection := 'xmldb:exist:///db/test/out';

declare function local:save-file($doc) {
  let $login := xmldb:login($out-collection, $username, $password)
  let $doc-uid := $doc/@xml:id
  return
    xmldb:store($out-collection,  concat($doc-uid, ".xml"), $doc)
};

declare function functx:wrap-values-in-elements 
  ( $values as xs:anyAtomicType* ,
    $elementName as xs:QName )  as element()* {   
   for $value in $values
   return element {$elementName} {$value}
};
 
declare function local:remove-named-element($nodes as node()*, $name as xs:string)  as node()* {
   for $node in $nodes
   return
     if ($node instance of element())
     then if (name($node) = $name)
          then ()
          else element { node-name($node)}
                { $node/@*,
                  local:remove-named-element($node/node(), $name)}
     else if ($node instance of document-node())
     then local:remove-named-element($node/node(), $name)
     else $node
};

declare function functx:add-attribute($element as element(), $name as xs:string, $value as xs:string?) as element() {
element { node-name($element)}
{ attribute {$name} {$value},
$element/@*,
$element/node() }
};

declare function functx:number-of-matches 
  ( $arg as xs:string?, $pattern as xs:string )  as xs:integer {
   count(tokenize($arg, $pattern)) - 1
 } ;

for $doc in $in-collection
let $log := util:log("DEBUG", ("##$doc): ", $doc))
let $bone-n := $doc//bone[1]/@n/string()
let $log := util:log("DEBUG", ("##$bone-n): ", $bone-n))

let $comments := 
    for $inscription in $doc/tei:TEI/bone
    let $log := util:log("DEBUG", ("##$inscription): ", $inscription))
    let $bone-id := $inscription/bone-id/text()
    let $bone-part := $inscription/bone-part/text()
    let $target := concat($bone-id, if ($bone-part) then '-' else (), if ($bone-part) then $bone-part else '-1')
    let $log := util:log("DEBUG", ("##$target): ", $target))
    let $comment := $inscription/comments/text()
	let $comment := 
        if (functx:number-of-matches($comment, "[(&#xff08;]") eq 1 and functx:number-of-matches($comment, "[)&#xff09;]") eq 1)
        then replace(replace($comment, "[(&#xff08;]", ""), "[)&#xff09;]", "")
        else $comment
	let $log := util:log("DEBUG", ("##$comment): ", $comment))
	return
	if ($comment) then
	<tei:note type="contents" target="#{$target}">{$comment}</tei:note>
	else ()
	let $comments-wrapper := 
    	if (string-length(string-join($comments, ''))) then <tei:p>{$comments}</tei:p> else ()
let $doc-minus-comments := 
    local:remove-named-element($doc, 'comments')
let $log := util:log("DEBUG", ("##$doc-minus-comments): ", $doc-minus-comments))

let $chant-ids := distinct-values($doc//chant-id)
let $chant-ids-wrapper := functx:wrap-values-in-elements($chant-ids, xs:QName('tei:note'))
let $log := util:log("DEBUG", ("##$chant-ids-wrapper): ", $chant-ids-wrapper))
let $chant-ids-wrapper := 
    <tei:ab>{
    (for $n in $chant-ids-wrapper
    return $n/functx:add-attribute($n, "type", "chant-id")
    )
    }</tei:ab>
let $doc-minus-chant-ids := 
    local:remove-named-element($doc-minus-comments, 'chant-id')
let $log := util:log("DEBUG", ("##$doc-minus-chant-ids): ", $doc-minus-chant-ids))

let $bone-id := $doc//bone-id
let $bone-id := distinct-values($bone-id)
let $bone-id := tokenize($bone-id, '=')
let $log := util:log("DEBUG", ("##$bone-id): ", $bone-id))
let $bone-sub-id := $bone-id[2]
let $bone-id := $bone-id[1]
let $log := util:log("DEBUG", ("##$bone-sub-id): ", $bone-sub-id))
let $bone-type := 
    if (substring($bone-id, 1, 2) eq 'SM') 
    then substring($bone-id, 1, 2)
    else substring($bone-id, 1, 1)
let $bone-id := concat($bone-type, '-', 
    if (substring($bone-id, 1, 2) eq 'SM') 
    then substring($bone-id, 3)
    else substring($bone-id, 2))
let $bone-sub-type := 
    if (substring($bone-sub-id, 1, 2) eq 'SM') 
    then substring($bone-sub-id, 1, 2)
    else substring($bone-sub-id, 1, 1)
let $bone-sub-id := concat($bone-sub-type, '-', 
    if (substring($bone-sub-id, 1, 2) eq 'SM') 
    then substring($bone-sub-id, 3)
    else substring($bone-sub-id, 2))

let $bone-image := substring-after($bone-id, '-')
(:gets part after H:)
let $log := util:log("DEBUG", ("##$bone-image-1): ", $bone-image))
let $bone-side := substring-after($bone-image, '-')
(:gets part after number, i.e. 正 or 反:)
let $bone-number := 
    if (functx:number-of-matches($bone-image, '-')) (:if there is a side:)
    then substring-before($bone-image, '-')
    else $bone-image
let $bone-image := 
    if ($bone-side) 
    then concat($bone-number, if ($bone-side eq '正') then '.1' else '.2')
    else $bone-number
let $bone-image := concat($bone-image, '.png')
let $log := util:log("DEBUG", ("##$bone-image-2): ", $bone-image))

let $doc-minus-bone-ids := 
    local:remove-named-element($doc-minus-chant-ids, 'bone-id')
let $log := util:log("DEBUG", ("##$doc-minus-bone-ids): ", $doc-minus-bone-ids))
let $doc-minus-bone-ids := functx:add-attribute($doc-minus-bone-ids, "n", $bone-n)

let $bone-part := $doc-minus-bone-ids//bone-part
let $log := util:log("DEBUG", ("##$bone-part1): ", $bone-part))
let $title :=
    if (string-length($bone-sub-id) gt 1)
    then <tei:titleStmt><tei:title>{$bone-id}</tei:title><tei:title>{$bone-sub-id}</tei:title></tei:titleStmt>
    else <tei:titleStmt><tei:title>{$bone-id}</tei:title></tei:titleStmt>
let $document :=
        element{node-name($doc-minus-bone-ids)}
        {$doc-minus-bone-ids/@*,
        <teiHeader><fileDesc>
        {
        $title,
        <publicationStmt><p>Publication Information</p></publicationStmt>,
            <sourceDesc>{
                $comments-wrapper, 
                $chant-ids-wrapper
            }</sourceDesc>
        }</fileDesc></teiHeader>
        ,
        if ($bone-type eq 'H') then
        <text xml:id="{$bone-id}" facs="{$bone-image}"><group>{
        for $bone at $i in $doc-minus-bone-ids/*
        let $text-id := concat($bone-id, '-', $i)
        
        let $transcription-1 := $bone//transcription-1
        let $log := util:log("DEBUG", ("##$transcription-1-0): ", $transcription-1))
        let $transcription-2 := $bone//transcription-2
        let $log := util:log("DEBUG", ("##$transcription-2-0): ", $transcription-2))

        for $t-1 in $transcription-1
        let $t-1 := replace(replace(replace($t-1, '。','。¿'), '：','：¿'), '，','，¿')
        let $log := util:log("DEBUG", ("##$t-1-1): ", $t-1))
        let $tokenized := tokenize($t-1,'¿')
        let $t-1 :=
            for $item at $i in $tokenized
            return <seg xml:id="{concat($text-id, '-yuanwen-', $i)}">{$item}</seg>
        let $log := util:log("DEBUG", ("##$t-1-2): ", $t-1))
        
        for $t-2 in $transcription-2
        let $t-2 := replace(replace(replace($t-2, '。','。¿'), '：','：¿'), '，','，¿')
        let $log := util:log("DEBUG", ("##$t-2-1): ", $t-2))
        let $tokenized := tokenize($t-2,'¿')
        let $t-2 :=
            for $item at $i in $tokenized
            return <seg xml:id="{concat($text-id, '-shiwen-', $i)}">{$item}</seg>
        let $log := util:log("DEBUG", ("##$t-2-2): ", $t-2))

        return
            
            <text xml:id="{$text-id}">
                <group>
                    <text type="transcription" subtype="yuanwen" xml:id="{$text-id}-yuanwen">
                        <body>
                            <ab>
                                {$t-1}
                            </ab>
                        </body>
                    </text>
                    <text type="transcription" subtype="shiwen" xml:id="{$text-id}-shiwen">
                        <body>
                            <ab>
                                {$t-2}
                            </ab>
                        </body>
                    </text>
                </group>
            </text>
        }
        </group>
    </text>    
    else
            <text xml:id="{$bone-id/string()}"><group>{
        for $bone at $i in $doc-minus-bone-ids/*
        let $text-id := concat($bone-id/string(), '-', $i)
        
        let $transcription-1 := $bone//transcription-1
        let $log := util:log("DEBUG", ("##$transcription-1-0): ", $transcription-1))
        let $transcription-2 := $bone//transcription-2
        let $log := util:log("DEBUG", ("##$transcription-2-0): ", $transcription-2))

        for $t-1 in $transcription-1
        let $t-1 := replace(replace(replace($t-1, '。','。¿'), '：','：¿'), '，','，¿')
        let $log := util:log("DEBUG", ("##$t-1-1): ", $t-1))
        let $tokenized := tokenize($t-1,'¿')
        let $t-1 :=
            for $item at $i in $tokenized
            return <seg xml:id="{concat($text-id, '-yuanwen-', $i)}">{$item}</seg>
        let $log := util:log("DEBUG", ("##$t-1-2): ", $t-1))
        
        for $t-2 in $transcription-2
        let $t-2 := replace(replace(replace($t-2, '。','。¿'), '：','：¿'), '，','，¿')
        let $log := util:log("DEBUG", ("##$t-2-1): ", $t-2))
        let $tokenized := tokenize($t-2,'¿')
        let $t-2 :=
            for $item at $i in $tokenized
            return <seg xml:id="{concat($text-id, '-shiwen-', $i)}">{$item}</seg>
        let $log := util:log("DEBUG", ("##$t-2-2): ", $t-2))

        return
            
            <text xml:id="{$text-id}">
                <group>
                    <text type="transcription" subtype="yuanwen" xml:id="{$text-id}-yuanwen">
                        <body>
                            <ab>
                                {$t-1}
                            </ab>
                        </body>
                    </text>
                    <text type="transcription" subtype="shiwen" xml:id="{$text-id}-shiwen">
                        <body>
                            <ab>
                                {$t-2}
                            </ab>
                        </body>
                    </text>
                </group>
            </text>
        }
        </group>
    </text>    
        }

return
    local:save-file($document)