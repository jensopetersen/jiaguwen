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

let $input := 
(
'BB-001|H-06834-正',
'BB-002|H-06834-反',
'BB-003|H-07352-正',
'BB-004|H-07352-反',
'BB-005|H-05637-正',
'BB-006|H-05637-反',
'BB-007|H-00466-正',
'BB-008|H-09950-正',
'BB-009|H-09950-反',
'BB-010|H-09788-正',
'BB-011|H-09788-反',
'BB-012|H-06482-正',
'BB-013|H-06482-反',
'BB-014|H-06483-正',
'BB-015|H-06483-反',
'BB-016|H-06484-正',
'BB-017|H-06484-反',
'BB-018|H-06485-正',
'BB-019|H-06485-反',
'BB-020|H-06486-正',
'BB-021|H-06486-反',
'BB-022|H-00032-正',
'BB-023|H-00032-反',
'BB-024|H-06476-正',
'BB-025|H-06474-正',
'BB-026|H-06475-正',
'BB-027|H-06475-反',
'BB-028|H-03946-正',
'BB-029|H-03946-反',
'BB-030|H-03947-正',
'BB-031|H-03947-反',
'BB-032|H-00914-正',
'BB-033|H-00914-反',
'BB-034|H-09520-正',
'BB-035|H-09521-正',
'BB-036|H-09522-正',
'BB-037|H-09523',
'BB-038|H-09524-正',
'BB-039|H-01402-正',
'BB-040|H-01402-反',
'BB-041|H-00248-正',
'BB-042|H-00248-反',
'BB-043|H-01822-正',
'BB-044|H-01822-反',
'BB-045|H-00270-正',
'BB-046|H-00270-反',
'BB-047|H-00721-正',
'BB-048|H-00721-反',
'BB-049|H-01656-正',
'BB-050|H-01656-反',
'BB-051|H-00272-正',
'BB-052|H-00272-反',
'BB-053|H-00766-正',
'BB-054|H-00766-反',
'BB-055|H-06460-正',
'BB-056|H-06460-反',
'BB-057|H-11484-正',
'BB-058|H-11484-反',
'BB-059|H-11483-正',
'BB-060|H-11483-反',
'BB-061|H-11423-正',
'BB-062|H-11423-反',
'BB-063|H-12051-正',
'BB-064|H-12051-反',
'BB-065|H-14129-正',
'BB-066|H-14129-反',
'BB-067|H-10171-正',
'BB-068|H-10171-反',
'BB-069|H-06654-正',
'BB-070|H-06654-反',
'BB-071|H-14209-正',
'BB-072|H-14209-反',
'BB-073|H-14210-正',
'BB-074|H-14210-反',
'BB-075|H-00575-正',
'BB-076|H-06771-正',
'BB-077|H-06771-反',
'BB-078|H-09472-正',
'BB-079|H-09472-反',
'BB-080|H-10656',
'BB-081|H-09525-正',
'BB-082|H-09525-反',
'BB-083|H-05775-正',
'BB-084|H-05775-反',
'BB-085|H-09002',
'BB-086|H-10344-正',
'BB-087|H-10344-反',
'BB-088|H-10345-正',
'BB-089|H-10345-反',
'BB-090|H-00585-正',
'BB-091|H-00585-反',
'BB-092|H-22074-正',
'BB-093|H-14201',
'BB-094|H-07103-正',
'BB-095|H-07103-反',
'BB-096|H-00376-正',
'BB-097|H-00376-反',
'BB-098|H-10613-正',
'BB-099|H-10613-反',
'BB-100|H-11006-正',
'BB-101|H-11006-反',
'BB-102|H-10408-正',
'BB-103|H-10408-反',
'BB-104|H-03458-正',
'BB-105|H-03458-反',
'BB-106|H-00456-正',
'BB-107|H-00456-反',
'BB-108|H-14208-正',
'BB-109|H-14208-反',
'BB-110|H-06033-正',
'BB-111|H-06033-反',
'BB-112|H-14735-正',
'BB-113|H-14735-反',
'BB-114|H-06664-正',
'BB-115|H-06664-反',
'BB-116|H-14732-正',
'BB-117|H-00672-正',
'BB-118|H-00672-反',
'BB-119|H-06959-正',
'BB-120|H-00190-正',
'BB-121|H-00190-反',
'BB-122|H-00418-正',
'BB-123|H-00418-反',
'BB-124|H-01027-正',
'BB-125|H-01027-反',
'BB-126|H-09504-正',
'BB-127|H-09504-反',
'BB-128|H-00152-正',
'BB-129|H-00152-反',
'BB-130|H-04259-正',
'BB-131|H-04259-反',
'BB-132|H-00506-正',
'BB-133|H-00506-反',
'BB-134|H-06648-正',
'BB-135|H-06648-反',
'BB-136|H-04179',
'BB-137|H-04178-正',
'BB-138|H-04178-反',
'BB-139|H-06653-正',
'BB-140|H-06653-反',
'BB-141|H-06016-正',
'BB-142|H-06016-反',
'BB-143|H-07426-正',
'BB-144|H-07426-反',
'BB-145|H-13506-正',
'BB-146|H-13506-反',
'BB-147|H-14206-正',
'BB-148|H-14206-反',
'BB-149|H-05658-正',
'BB-150|H-05658-反',
'BB-151|H-12324-正',
'BB-152|H-12324-反',
'BB-153|H-16131-正',
'BB-154|H-16131-反',
'BB-155|H-00667-正',
'BB-156|H-00667-反',
'BB-157|H-09177-正',
'BB-158|H-09177-反',
'BB-159|H-06477-正',
'BB-160|H-06477-反',
'BB-161|H-01772-正',
'BB-162|H-01772-反',
'BB-163|H-10601-正',
'BB-164|H-10601-反',
'BB-165|H-07772-正',
'BB-166|H-07772-反',
'BB-167|H-09774-正',
'BB-168|H-09774-反',
'BB-169|H-09668-正',
'BB-170|H-09668-反',
'BB-171|H-06572-正',
'BB-172|H-00590-正',
'BB-173|H-00590-反',
'BB-174|H-04855',
'BB-175|H-13750-正',
'BB-176|H-13750-反',
'BB-177|H-06945-正',
'BB-178|H-00267-正',
'BB-179|H-00267-反',
'BB-180|H-10049-正',
'BB-181|H-10049-反',
'BB-182|H-00924-正',
'BB-183|H-00924-反',
'BB-184|H-14659',
'BB-185|H-00096-正',
'BB-186|H-02422-正',
(:'BB-187|H-00694-正',:)
(:'BB-188|H-00694-反',:)
'BB-189|H-03333',
'BB-190|H-13931',
'BB-191|H-07851-正',
'BB-192|H-07851-反',
'BB-193|H-18860-正',
'BB-194|H-18860-反',
'BB-195|H-14929-正',
'BB-196|H-14929-反',
'BB-197|H-00903-正',
'BB-198|H-00903-反',
'BB-199|H-14207-正',
'BB-200|H-14207-反',
'BB-201|H-11018-正',
'BB-202|H-11018-反',
'BB-203|H-00776-正',
'BB-204|H-00776-反',
'BB-205|H-00938-正',
'BB-206|H-00938-反',
'BB-207|H-11497-正',
'BB-208|H-11497-反',
'BB-209|H-11498-正',
'BB-210|H-11498-反',
'BB-211|H-06943',
'BB-212|H-14199-正',
'BB-213|H-14199-反',
'BB-214|H-14211-正',
'BB-215|H-14211-反',
'BB-216|H-14295',
'BB-217|H-01901-正',
'BB-218|H-01901-反',
(:'BB-219|H-02273-正',:)
'BB-220|H-02273-反',
'BB-221|H-14315-正',
'BB-222|H-14315-反',
'BB-223|H-14755-正',
'BB-224|H-14755-反',
'BB-225|H-01779-正',
'BB-226|H-01779-反',
'BB-227|H-00226-正',
'BB-228|H-00226-反',
'BB-229|H-00947-正',
'BB-230|H-00947-反',
'BB-231|H-00944-正',
'BB-232|H-00944-反',
'BB-233|H-00904-正',
'BB-234|H-00904-反',
'BB-235|H-00902-正',
'BB-236|H-00902-反',
'BB-237|H-14198-正',
'BB-238|H-14198-反',
'BB-239|H-13647-正',
'BB-240|H-13647-反',
'BB-241|H-01773-正',
'BB-242|H-01773-反',
'BB-243|H-00641-正',
'BB-244|H-00641-反',
'BB-245|H-14003-正',
'BB-246|H-14003-反',
(:'BB-247|H-14002-正',:)
'BB-248|H-14002-反',
(:'BB-249|H-06948-正',:)
'BB-250|H-06948-反',
'BB-251|H-00709-正',
'BB-252|H-00709-反',
'BB-253|H-02652-正',
'BB-254|H-02652-反',
'BB-255|H-02652-正',
'BB-256|H-12311-反',
'BB-257|H-00454-正',
'BB-258|H-00454-反',
'BB-259|H-07076-正',
'BB-260|H-07076-反',
'BB-261|H-06946-正',
'BB-262|H-06946-反',
'BB-263|H-07768',
(:'BB-264|H-00536-正',:)
'BB-265|H-10299-正',
'BB-266|H-10299-反',
'BB-267|H-02530-正',
'BB-268|H-02530-反',
(:'BB-269|H-05439-正',:)
'BB-270|H-05439-反',
'BB-271|H-00150-正',
'BB-272|H-00150-反',
(:'BB-273|H-06649-正',:)
(:'BB-274|H-06649-反',:)
(:'BB-275|H-13490-正',:)
'BB-276|H-06461-正',
'BB-277|H-06461-反',
'BB-278|H-09743-正',
'BB-279|H-09743-反',
'BB-280|H-10137-正',
'BB-281|H-10137-反',
'BB-282|H-09783-正',
'BB-283|H-09783-反',
'BB-284|H-10198-正',
'BB-285|H-10198-反',
'BB-286|H-10910-正',
'BB-287|H-10910-反',
'BB-288|H-14621',
'BB-289|H-14755-正',
'BB-290|H-14755-反',
'BB-291|H-10346-正',
'BB-292|H-10346-反',
'BB-293|H-00816-正',
'BB-294|H-00816-反',
'BB-295|H-13674',
'BB-296|H-17079-正',
'BB-297|H-17079-反',
'BB-298|H-03291',
'BB-299|H-09811-正',
'BB-300|H-16152-正',
'BB-301|H-16152-反',
'BB-302|H-06571-正',
'BB-303|H-06571-反',
'BB-304|H-06947-正',
'BB-305|H-06947-反',
'BB-306|H-06943',
(:'BB-307|H-06928-正',:)
'BB-308|H-06928-反',
'BB-309|H-03061-正',
'BB-310|H-03061-反',
'BB-311|H-00811-正',
'BB-312|H-00811-反',
(:'BB-313|H-06478-正',:)
'BB-314|H-06478-反',
(:'BB-315|H-06468-正',:)
'BB-316|H-11000',
'BB-317|H-06653-正',
'BB-318|H-06653-反',
(:'BB-319|H-06530-正',:)
'BB-320|H-06530-反',
'BB-321|H-14200-正',
'BB-322|H-14200-反',
(:'BB-323|H-10950-正',:)
'BB-324|H-00893-正',
'BB-325|H-00893-反',
'BB-326|H-07852-正',
'BB-327|H-07852-反',
'BB-328|H-00419-正',
'BB-329|H-00419-反',
'BB-330|H-00904-正',
'BB-331|H-00904-反',
'BB-332|H-09741-正',
'BB-333|H-09741-反',
'BB-334|H-00709-正',
'BB-335|H-00709-反',
'BB-336|H-03216-正',
'BB-337|H-03216-反',
'BB-338|H-01657-正',
'BB-339|H-01657-反',
'BB-340|H-10136-正',
'BB-341|H-10136-反',
'BB-342|H-00945-正',
'BB-343|H-00945-反',
(:'BB-344|H-00894-正',:)
'BB-345|H-13793-正',
'BB-346|H-13793-反',
'BB-347|H-14022-正',
'BB-348|H-14022-反',
'BB-349|H-00974-正',
'BB-350|H-00974-反',
(:'BB-351|H-07773-正',:)
(:'BB-352|H-00368-正',:)
'BB-353|H-11177',
'BB-354|H-01100-正',
'BB-355|H-01100-反',
'BB-356|H-02274-正',
'BB-357|H-02274-反',
'BB-358|H-05298-正',
'BB-359|H-05298-反',
'BB-360|H-00438-正',
'BB-361|H-00438-反',
'BB-362|H-03271-正',
'BB-363|H-03271-反',
'BB-364|H-02498-正',
'BB-365|H-02498-反',
'BB-366|H-00671-正',
'BB-367|H-00671-反',
'BB-368|H-12487-正',
'BB-369|H-12487-反',
(:'BB-370|H-10184-正',:)
'BB-371|H-10174-正',
'BB-372|H-10174-反',
'BB-373|H-09791-正',
'BB-374|H-09791-反',
'BB-375|H-09234-正',
'BB-376|H-09234-反',
'BB-377|H-18911-正',
'BB-378|H-18911-反',
'BB-379|H-11462-正',
'BB-380|H-11462-反',
'BB-381|H-00900-正',
'BB-382|H-00900-反',
'BB-383|H-05532-正',
'BB-384|H-05532-反',
'BB-385|H-09524',
'BB-386|H-09472-正',
'BB-387|H-09472-正',
'BB-388|H-01531-正',
'BB-389|H-01531-反',
'BB-390|H-09608-正',
'BB-391|H-09608-反',
'BB-392|H-01248-正',
'BB-393|H-01248-反',
(:'BB-394|H-01772-正',:)
'BB-395|H-01772-反',
'BB-396|H-00150-正',
'BB-397|H-00150-反',
'BB-398|H-00093-正',
'BB-399|H-00093-反',
(:'BB-400|H-00655-正',:)
(:'BB-401|H-00655-反',:)
'BB-402|H-18353',
'BB-403|H-17230-正',
'BB-404|H-17230-反',
'BB-405|H-13282-正',
'BB-406|H-13282-反',
'BB-407|H-00905-正',
'BB-408|H-00905-反',
'BB-409|H-07440-正',
'BB-410|H-07440-反',
'BB-411|H-17409-正',
'BB-412|H-17409-反',
'BB-413|H-00940-正',
'BB-414|H-00940-反',
'BB-415|H-00201-正',
'BB-416|H-00201-反',
'BB-417|H-10306-正',
'BB-418|H-10306-反',
'BB-419|H-01385-正',
'BB-420|H-01385-反',
'BB-421|H-00140-正',
'BB-422|H-00140-反',
'BB-423|H-10407-正',
'BB-424|H-10407-反',
'BB-425|H-01052-正',
'BB-426|H-01052-反',
'BB-427|H-13604-正',
'BB-428|H-13604-反',
'BB-429|H-10315-正',
'BB-430|H-10315-反',
'BB-431|H-01140-正',
'BB-432|H-01140-反',
'BB-433|H-12342',
'BB-434|H-02357-正',
'BB-435|H-02357-反',
'BB-436|H-01821-正',
'BB-437|H-01821-反',
'BB-438|H-00734-正',
'BB-439|H-00734-反',
'BB-440|H-00478-正',
'BB-441|H-00478-反',
'BB-442|H-14755-正',
'BB-443|H-14755-反',
'BB-444|H-06657-正',
'BB-445|H-06657-反',
'BB-446|H-03217-正',
'BB-447|H-03217-反',
'BB-448|H-00235-正',
'BB-449|H-00235-反',
'BB-450|H-05477-正',
'BB-451|H-05477-反',
'BB-452|H-01878-正',
'BB-453|H-01878-反',
'BB-454|H-12316',
'BB-455|H-00893-正',
'BB-456|H-00893-反',
'BB-457|H-00915-正',
'BB-458|H-00915-反',
'BB-459|H-03201-正',
'BB-460|H-03201-反',
'BB-461|H-02231',
'BB-462|H-02252',
'BB-463|H-07387',
'BB-464|H-05446-正',
'BB-465|H-05446-反',
'BB-466|H-00255',
'BB-467|H-00717-正',
'BB-468|H-00717-反',
'BB-469|H-12842-正',
'BB-470|H-12842-反',
'BB-471|H-08947-正',
'BB-472|H-08947-反',
'BB-473|H-13666-正',
'BB-474|H-13666-反',
'BB-475|H-14787-正',
'BB-476|H-14787-反',
'BB-477|H-13283-正',
'BB-478|H-13283-反',
'BB-479|H-17407-正',
'BB-480|H-17407-反',
'BB-481|H-07571-正',
'BB-482|H-07571-反',
'BB-483|H-01623-正',
'BB-484|H-01623-反',
(:'BB-485|H-06949-正',:)
'BB-486|H-06949-反',
'BB-487|H-00098-正',
'BB-488|H-00098-反',
'BB-489|H-00943-正',
'BB-490|H-00943-反',
'BB-491|H-04121',
'BB-492|H-00014-正',
'BB-493|H-00014-反',
'BB-494|H-02373-正',
'BB-495|H-02373-反',
'BB-496|H-14173-正',
'BB-497|H-14173-反',
'BB-498|H-00947-正',
'BB-499|H-00947-反',
'BB-500|H-08985-正',
'BB-501|H-08985-反',
'BB-502|H-00456-正',
'BB-503|H-00456-反',
'BB-504|H-17271-正',
'BB-505|H-17271-反',
'BB-506|H-00991-正',
'BB-507|H-00991-反',
'BB-508|H-13713-正',
'BB-509|H-13713-反',
'BB-510|H-00891-正',
'BB-511|H-00891-反',
'BB-512|H-00728',
'BB-513|H-00795-正',
'BB-514|H-00795-反',
'BB-515|H-14128-正',
'BB-516|H-14128-反',
'BB-517|H-17397-正',
'BB-518|H-17397-反',
'BB-519|H-00973-正',
'BB-520|H-00973-反',
'BB-521|H-14161-正',
'BB-522|H-14161-反',
'BB-523|H-00809-正',
'BB-524|H-00809-反',
'BB-525|H-03521-正',
'BB-526|H-03521-反',
'BB-527|H-11892-正',
'BB-528|H-11892-反',
(:'BB-529|H-14153-正',:)
(:'BB-530|H-14153-反',:)
(:'BB-531|H-04141-正',:)
(:'BB-532|H-11940-正',:)
'BB-533|H-12948-正',
'BB-534|H-12948-反',
'BB-535|H-14468-正',
'BB-536|H-14468-反',
(:'BB-537|H-14156-正',:)
'BB-538|H-13333-正',
'BB-539|H-13333-反',
'BB-540|H-00775-正',
'BB-541|H-00775-反',
'BB-542|H-01532-正',
'BB-543|H-01532-反',
'BB-544|H-01655-正',
'BB-545|H-01655-反',
(:'BB-546|H-01076-正',:)
(:'BB-547|H-01076-反',:)
'BB-548|H-00702-正',
'BB-549|H-00702-反',
'BB-550|H-07427-正',
'BB-551|H-07427-反',
'BB-552|H-02940',
'BB-553|H-02130',
'BB-554|H-10902',
'BB-555|H-00916-正',
'BB-556|H-00916-反',
'BB-557|H-03481',
'BB-558|H-06830',
'BB-559|H-07942',
'BB-560|H-00133-正',
'BB-561|H-00133-反',
'BB-562|H-11499-正',
'BB-563|H-11499-反',
'BB-564|H-11007-正',
'BB-565|H-11007-反',
'BB-566|H-05884-正',
'BB-567|H-05884-反',
'BB-568|H-00273-正',
'BB-569|H-00273-反',
'BB-570|H-00274-正',
'BB-571|H-00274-反',
'BB-572|H-00275-正',
'BB-573|H-00275-反',
'BB-574|H-00276-正',
'BB-575|H-00276-反',
'BB-578|H-09236-正',
'BB-579|H-09236-反',
(:'BB-580|H-09271-反',:)
'BB-581|H-16335-正',
'BB-582|H-16335-反',
'BB-583|H-05445-正',
'BB-584|H-05445-反',
'BB-585|H-00722-正',
'BB-586|H-00722-反',
'BB-587|H-07267-正',
'BB-588|H-07267-反',
'BB-589|H-17185-正',
'BB-590|H-17185-反',
'BB-591|H-01899-正',
'BB-592|H-01899-反',
'BB-593|H-00488-正',
'BB-594|H-00488-反',
'BB-595|H-09464-正',
'BB-596|H-09464-反',
'BB-597|H-13220-正',
'BB-598|H-13220-反',
'BB-599|H-13624-正',
'BB-600|H-13624-反',
'BB-601|H-08720-正',
'BB-602|H-08720-反',
'BB-603|H-06457-正',
'BB-604|H-06457-反',
'BB-605|H-07075-正',
'BB-606|H-07075-反',
'BB-607|H-01823-正',
'BB-608|H-01823-反',
'BB-609|H-22196',
'BB-610|H-22067',
'BB-611|H-21586',
'BB-612|H-21727',
'BB-613|H-22098',
'BB-614|H-22078',
'BB-615|H-03201-正',
'BB-616|H-03201-反',
'BB-617|H-00893-正',
'BB-618|H-00893-反',
'BB-619|H-05446-正',
'BB-620|H-05446-反',
'BB-621|H-07076-正',
'BB-622|H-07076-反',
'BB-623|H-01773-正',
'BB-624|H-01773-反',
'BB-625|H-06460-正',
'BB-626|H-06460-反',
'BB-627|H-10171-正',
'BB-628|H-10171-反',
'BB-629|H-01656-正',
'BB-630|H-01656-反',
'BB-631|H-00905-正',
'BB-632|H-00905-反')


for $i in $input
let $log := util:log("DEBUG", ("##$i): ", $i))
let $BB-title := substring-before($i, '|')
let $Heji-title := substring-after($i, '|')
let $Heji-uuid := collection('/db/test/out')//tei:title[. eq $Heji-title]/ancestor::tei:TEI/@xml:id/string()
let $Heji-uuid-prefix := substring($Heji-uuid, 6, 1)
let $Heji-doc := collection("/db/test/out")//(id($Heji-uuid))

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

<text xml:id="{$BB-title}" facs="{$bone-image}">
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