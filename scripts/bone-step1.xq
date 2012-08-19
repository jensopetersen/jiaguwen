(:gather texts into bones (bone-parts into bones):)
declare namespace util="http://exist-db.org/xquery/util";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace functx = "http:/www.functx.com";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=yes indent=yes";

declare variable $username as xs:string := "admin";
declare variable $password as xs:string := "";

declare variable $out-collection := 'xmldb:exist:///db/test/in';


declare function functx:add-attribute ($element as element(), $name as xs:string, $value as xs:string?) as element() {
element { node-name($element)}
{ attribute {$name} {$value},
$element/@*,
$element/node() }
};


  let $input := doc('/db/test/bones.2.xml')
  let $bone-ids := distinct-values($input//bone-id)
  
  for $bone-id in $bone-ids
    let $same := $input//bone[bone-id eq $bone-id]
    let $myuid := concat("uuid-",util:uuid())
    let $a := <TEI xmlns="http://www.tei-c.org/ns/1.0" xmlns:xi="http://www.w3.org/2001/XInclude">{$same}</TEI>
    let $a := $a/functx:add-attribute($a, "xml:id", $myuid)
    return
        xmldb:store($out-collection,  concat($myuid, ".xml"), $a)