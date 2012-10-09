xquery version "3.0";
(:make BB documents for files with incorrect H titles:)

declare namespace util="http://exist-db.org/xquery/util";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace functx = "http:/www.functx.com";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=yes indent=yes";

declare variable $username as xs:string := "admin";
declare variable $password as xs:string := "";
declare variable $in-collection := collection('/db/tls-data/CHANT');

declare function local:save-file($doc) {
  let $doc-uid := $doc/@xml:id
  let $out-collection := 'xmldb:exist:///db/test/BB'
  let $login := xmldb:login($out-collection, $username, $password)
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

let $input := 
(
'BB-187|H-00697-正',
'BB-188|H-00697-反',
'BB-219|H-02273-正反',
'BB-247|H-14002-正',
'BB-249|H-06948-正',
'BB-264|H-00536-正',
'BB-269|H-05439-正',
'BB-273|H-06649-正甲',
'BB-274|H-06649-反甲',
'BB-275|H-13490-正',
'BB-307|H-06928-正',
'BB-313|H-06478-正',
'BB-315|H-06468-正',
'BB-319|H-06530-正',
'BB-323|H-10950-正',
'BB-344|H-00894-正',
'BB-351|H-07773-正',
'BB-352|H-00368-正',
'BB-370|H-10184-正',
'BB-394|H-01772-正',
'BB-400|H-00655-正甲',
'BB-401|H-00655-反甲',
'BB-485|H-06949-正反',
'BB-529|H-14153-正乙',
'BB-530|H-14153-反乙',
'BB-531|H-04141-正',
'BB-532|H-11940-正',
'BB-537|H-14156-正',
'BB-546|H-01076-正甲',
'BB-547|H-01076-反甲',
'BB-580|H-09271-反'
)


for $i in $input
let $log := util:log("DEBUG", ("##$i): ", $i))
let $BB-title := substring-before($i, '|')
let $Heji-title := substring-after($i, '|')
let $Heji-uuid := collection('/db/tls-data/CHANT')//tei:title[. eq $Heji-title]/ancestor::tei:TEI/@xml:id/string()
let $Heji-uuid-prefix := substring($Heji-uuid, 6, 1)
let $Heji-doc := collection("/db/tls-data/CHANT")//(id($Heji-uuid))

let $bone-image := substring-after($Heji-title, '-')
let $bone-side := substring-after($bone-image, '-')
let $bone-number := 
    if (functx:number-of-matches($bone-image, '-')) (:if there is a side:)
    then substring-before($bone-image, '-')
    else $bone-image
let $bone-image := 
    if ($bone-side) 
    then concat($bone-number, 
        if ($bone-side eq '正') 
        then '.1' 
            else 
                if ($bone-side eq '反') 
                then '.2'
                else '.3'
        )
    else $bone-number
let $bone-image := concat($bone-image, '.png')

let $count-Heji-text := count($Heji-doc/tei:text/tei:group/tei:text)

let $Takashima-transcription := '.text-transcription-Takashima'
let $Takashima-translation := '.text-translation-Takashima'
let $my-uuid := concat("uuid-",util:uuid())
let $a := 
(<TEI xmlns="http://www.tei-c.org/ns/1.0" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:svg="http://www.w3.org/2000/svg">    <teiHeader>
        <fileDesc>
            <titleStmt>
                <title>{$BB-title}</title>
            </titleStmt>
            <publicationStmt>
                <p>Publication Information</p>
            </publicationStmt>
            <sourceDesc>
                <p>Information about the source</p>
            </sourceDesc>
        </fileDesc>
    </teiHeader>

<text xml:id="{$BB-title}" facs="{$bone-image}" corresp="{$Heji-title}">
<group>
    {
        for $t in (1 to $count-Heji-text)
        let $shiwen := $Heji-doc/tei:text[1]/tei:group[1]/tei:text[$t]/tei:group/tei:text[2]/tei:body/tei:ab
        return 
    <text xml:id="{concat($BB-title, '.text-', $t)}" n="{$t}">
        <group>
            <xi:include href="{concat('/db/tls-data/CHANT/', $Heji-uuid-prefix, '/', $Heji-uuid, '.xml')}" xpointer="{concat($Heji-title, '.text-', $t, '.text-transcription-yuanwen')}">
                <xi:fallback><note>XInclude failed!</note></xi:fallback>
            </xi:include>
            <xi:include href="{concat('/db/tls-data/CHANT/', $Heji-uuid-prefix, '/', $Heji-uuid, '.xml')}" xpointer="{concat($Heji-title, '.text-', $t, '.text-transcription-shiwen')}">
                    <xi:fallback><note>XInclude failed!</note></xi:fallback>
            </xi:include>
            <text type="transcription" subtype="Takashima" xml:id="{concat($BB-title, '.text-', $t, '.text-transcription-Takashima')}">
                <body>
                    <ab>{
                        for $seg at $i in $shiwen/*
                        return
                        <seg xml:id="{concat($BB-title, '.text-', $t, '.text-transcription-Takashima.seg-', $i)}">
                        {$seg/text()}
                        </seg>
                    }</ab>
                </body>
            </text>
            <text type="translation" subtype="Takashima" xml:id="{concat($BB-title, '.text-', $t, '.text-translation-Takashima')}">
                <body>
                    <ab>
                        <seg xml:id="{concat($BB-title, '.text-', $t, '.text-translation-Takashima.seg-1')}">&#xA0;</seg>
                    </ab>
                </body>
            </text>
        </group>
    </text>
    }

    
</group>
</text>
</TEI>
)   
let $a := $a/functx:add-attribute($a, "xml:id", $my-uuid)
let $log := util:log("DEBUG", ("##$a): ", $a))
return
    local:save-file($a)