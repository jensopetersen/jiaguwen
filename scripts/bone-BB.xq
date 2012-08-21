xquery version "3.0";
(:make BB document:)

declare namespace util="http://exist-db.org/xquery/util";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace functx = "http:/www.functx.com";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=yes indent=yes";

declare variable $username as xs:string := "admin";
declare variable $password as xs:string := "";
declare variable $in-collection := collection('/db/test/in');

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

let $input := ('BB-493|H-00014-反')
(:'BB-493|H-00014-反', 'BB-492|H-00014-正', 'BB-023|H-00032-反', 'BB-022|H-00032-正', 'BB-399|H-00093-反', 'BB-398|H-00093-正', 'BB-185|H-00096-正', 'BB-488|H-00098-反', 'BB-487|H-00098-正', 'BB-561|H-00133-反', 'BB-560|H-00133-正', 'BB-422|H-00140-反', 'BB-421|H-00140-正', 'BB-272|H-00150-反', 'BB-397|H-00150-反', 'BB-271|H-00150-正', 'BB-396|H-00150-正', 'BB-129|H-00152-反', 'BB-128|H-00152-正', 'BB-121|H-00190-反', 'BB-120|H-00190-正', 'BB-416|H-00201-反', 'BB-415|H-00201-正', 'BB-228|H-00226-反', 'BB-227|H-00226-正', 'BB-449|H-00235-反', 'BB-448|H-00235-正', 'BB-042|H-00248-反', 'BB-041|H-00248-正', 'BB-466|H-00255', 'BB-179|H-00267-反', 'BB-178|H-00267-正', 'BB-046|H-00270-反', 'BB-045|H-00270-正', 'BB-052|H-00272-反', 'BB-051|H-00272-正', 'BB-569|H-00273-反', 'BB-568|H-00273-正', 'BB-571|H-00274-反', 'BB-570|H-00274-正', 'BB-573|H-00275-反', 'BB-572|H-00275-正', 'BB-575|H-00276-反', 'BB-574|H-00276-正', 'BB-352|H-00368-正', 'BB-097|H-00376-反', 'BB-096|H-00376-正', 'BB-123|H-00418-反', 'BB-122|H-00418-正', 'BB-329|H-00419-反', 'BB-328|H-00419-正', 'BB-361|H-00438-反', 'BB-360|H-00438-正', 'BB-258|H-00454-反', 'BB-257|H-00454-正', 'BB-107|H-00456-反', 'BB-503|H-00456-反', 'BB-106|H-00456-正', 'BB-502|H-00456-正', 'BB-007|H-00466-正', 'BB-441|H-00478-反', 'BB-440|H-00478-正', 'BB-594|H-00488-反', 'BB-593|H-00488-正', 'BB-133|H-00506-反', 'BB-132|H-00506-正', 'BB-264|H-00536-正', 'BB-075|H-00575-正', 'BB-091|H-00585-反', 'BB-090|H-00585-正', 'BB-173|H-00590-反', 'BB-172|H-00590-正', 'BB-244|H-00641-反', 'BB-243|H-00641-正', 'BB-401|H-00655-反', 'BB-400|H-00655-正', 'BB-156|H-00667-反', 'BB-155|H-00667-正', 'BB-367|H-00671-反', 'BB-366|H-00671-正', 'BB-118|H-00672-反', 'BB-117|H-00672-正', 'BB-188|H-00694-反', 'BB-187|H-00694-正', 'BB-549|H-00702-反', 'BB-548|H-00702-正', 'BB-252|H-00709-反', 'BB-335|H-00709-反', 'BB-251|H-00709-正', 'BB-334|H-00709-正', 'BB-468|H-00717-反', 'BB-467|H-00717-正', 'BB-048|H-00721-反', 'BB-047|H-00721-正', 'BB-586|H-00722-反', 'BB-585|H-00722-正', 'BB-512|H-00728', 'BB-439|H-00734-反', 'BB-438|H-00734-正', 'BB-054|H-00766-反', 'BB-053|H-00766-正', 'BB-541|H-00775-反', 'BB-540|H-00775-正', 'BB-204|H-00776-反', 'BB-203|H-00776-正', 'BB-514|H-00795-反', 'BB-513|H-00795-正', 'BB-524|H-00809-反', 'BB-523|H-00809-正', 'BB-312|H-00811-反', 'BB-311|H-00811-正', 'BB-294|H-00816-反', 'BB-293|H-00816-正', 'BB-511|H-00891-反', 'BB-510|H-00891-正', 'BB-325|H-00893-反', 'BB-456|H-00893-反', 'BB-618|H-00893-反', 'BB-324|H-00893-正', 'BB-455|H-00893-正', 'BB-617|H-00893-正', 'BB-344|H-00894-正', 'BB-382|H-00900-反', 'BB-381|H-00900-正', 'BB-236|H-00902-反', 'BB-235|H-00902-正', 'BB-198|H-00903-反', 'BB-197|H-00903-正', 'BB-234|H-00904-反', 'BB-331|H-00904-反', 'BB-233|H-00904-正', 'BB-330|H-00904-正', 'BB-408|H-00905-反', 'BB-632|H-00905-反', 'BB-407|H-00905-正', 'BB-631|H-00905-正', 'BB-033|H-00914-反', 'BB-032|H-00914-正', 'BB-458|H-00915-反', 'BB-457|H-00915-正', 'BB-556|H-00916-反', 'BB-555|H-00916-正', 'BB-183|H-00924-反', 'BB-182|H-00924-正', 'BB-206|H-00938-反', 'BB-205|H-00938-正', 'BB-414|H-00940-反', 'BB-413|H-00940-正', 'BB-490|H-00943-反', 'BB-489|H-00943-正', 'BB-232|H-00944-反', 'BB-231|H-00944-正', 'BB-343|H-00945-反', 'BB-342|H-00945-正', 'BB-230|H-00947-反', 'BB-499|H-00947-反', 'BB-229|H-00947-正', 'BB-498|H-00947-正', 'BB-520|H-00973-反', 'BB-519|H-00973-正', 'BB-350|H-00974-反', 'BB-349|H-00974-正', 'BB-507|H-00991-反', 'BB-506|H-00991-正', 'BB-125|H-01027-反', 'BB-124|H-01027-正', 'BB-426|H-01052-反', 'BB-425|H-01052-正', 'BB-547|H-01076-反', 'BB-546|H-01076-正', 'BB-355|H-01100-反', 'BB-354|H-01100-正', 'BB-432|H-01140-反', 'BB-431|H-01140-正', 'BB-393|H-01248-反', 'BB-392|H-01248-正', 'BB-420|H-01385-反', 'BB-419|H-01385-正', 'BB-040|H-01402-反', 'BB-039|H-01402-正', 'BB-389|H-01531-反', 'BB-388|H-01531-正', 'BB-543|H-01532-反', 'BB-542|H-01532-正', 'BB-484|H-01623-反', 'BB-483|H-01623-正', 'BB-545|H-01655-反', 'BB-544|H-01655-正', 'BB-050|H-01656-反', 'BB-630|H-01656-反', 'BB-049|H-01656-正', 'BB-629|H-01656-正', 'BB-339|H-01657-反', 'BB-338|H-01657-正', 'BB-162|H-01772-反', 'BB-395|H-01772-反', 'BB-161|H-01772-正', 'BB-394|H-01772-正', 'BB-242|H-01773-反', 'BB-624|H-01773-反', 'BB-241|H-01773-正', 'BB-623|H-01773-正', 'BB-226|H-01779-反', 'BB-225|H-01779-正', 'BB-437|H-01821-反', 'BB-436|H-01821-正', 'BB-044|H-01822-反', 'BB-043|H-01822-正', 'BB-608|H-01823-反', 'BB-607|H-01823-正', 'BB-453|H-01878-反', 'BB-452|H-01878-正', 'BB-592|H-01899-反', 'BB-591|H-01899-正', 'BB-218|H-01901-反', 'BB-217|H-01901-正', 'BB-553|H-02130', 'BB-461|H-02231', 'BB-462|H-02252', 'BB-220|H-02273-反', 'BB-219|H-02273-正', 'BB-357|H-02274-反', 'BB-356|H-02274-正', 'BB-435|H-02357-反', 'BB-434|H-02357-正', 'BB-495|H-02373-反', 'BB-494|H-02373-正', 'BB-186|H-02422-正', 'BB-365|H-02498-反', 'BB-364|H-02498-正', 'BB-268|H-02530-反', 'BB-267|H-02530-正', 'BB-254|H-02652-反', 'BB-253|H-02652-正', 'BB-255|H-02652-正', 'BB-552|H-02940', 'BB-310|H-03061-反', 'BB-309|H-03061-正', 'BB-460|H-03201-反', 'BB-616|H-03201-反', 'BB-459|H-03201-正', 'BB-615|H-03201-正', 'BB-337|H-03216-反', 'BB-336|H-03216-正', 'BB-447|H-03217-反', 'BB-446|H-03217-正', 'BB-363|H-03271-反', 'BB-362|H-03271-正', 'BB-298|H-03291', 'BB-189|H-03333', 'BB-105|H-03458-反', 'BB-104|H-03458-正', 'BB-557|H-03481', 'BB-526|H-03521-反', 'BB-525|H-03521-正', 'BB-029|H-03946-反', 'BB-028|H-03946-正', 'BB-031|H-03947-反', 'BB-030|H-03947-正', 'BB-491|H-04121', 'BB-531|H-04141-正', 'BB-138|H-04178-反', 'BB-137|H-04178-正', 'BB-136|H-04179', 'BB-131|H-04259-反', 'BB-130|H-04259-正', 'BB-174|H-04855':)

for $i in $input
let $log := util:log("DEBUG", ("##$i): ", $i))
let $BB-title := substring-before($i, '|')
let $log := util:log("DEBUG", ("##$BB-title): ", $BB-title))
let $Heji-title := substring-after($i, '|')
let $log := util:log("DEBUG", ("##$Heji-title): ", $Heji-title))
let $Heji-uuid := collection('/db/test/out')//tei:title[. eq $Heji-title]/ancestor::tei:TEI/@xml:id/string()
let $log := util:log("DEBUG", ("##$Heji-title): ", $Heji-title))
let $Heji-uuid-prefix := substring($Heji-uuid, 6, 1)
let $log := util:log("DEBUG", ("##$Heji-uuid): ", $Heji-uuid))
let $Heji-doc := collection("/db/test/out")//(id($Heji-uuid))
let $log := util:log("DEBUG", ("##$Heji-doc): ", $Heji-doc))
let $log := util:log("DEBUG", ("##$Heji-doc): ", $Heji-doc))

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
let $log := util:log("DEBUG", ("##$bone-image-2): ", $bone-image))

let $count-Heji-text := count($Heji-doc/tei:text/tei:group/tei:text)
let $log := util:log("DEBUG", ("##$count-Heji-text): ", $count-Heji-text))

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

<text xml:id="{$BB-title}" facs="{$bone-image}">
<group>
    {
        for $t in (1 to $count-Heji-text)
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
                    <ab>
                        <seg xml:id="{concat($BB-title, '.text-', $t, '.text-transcription-Takashima.seg-1')}">&#xA0;</seg>
                    </ab>
                </body>
            </text>
            <text type="translation" subtype="Takashima" xml:id="{concat($BB-title, '.text-', $t, '.text-tranlation-Takashima')}">
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
let $log := util:log("DEBUG", ("##$a): ", $a))
let $a := $a/functx:add-attribute($a, "xml:id", $my-uuid)
let $log := util:log("DEBUG", ("##$a): ", $a))
return
    local:save-file($a)