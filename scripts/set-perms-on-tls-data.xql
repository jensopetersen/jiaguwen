xquery version "1.0";

import module namespace util="http://exist-db.org/xquery/util";
import module namespace xdb="http://exist-db.org/xquery/xmldb";

(: file path pointing to the exist installation directory :)
declare variable $home external;
(: path to the directory in expathrepo containing the unpacked .xar package :)
(:NB: not used.:)
declare variable $log-level := "INFO";
declare variable $db-root := "/db";
declare variable $system-collection := fn:concat($db-root, "/system/config");

(:~ Biblio security - admin user and users group :)
declare variable $tls-admin-user := "tls-editor";
declare variable $tls-users-group := "tls-editors";

(:~ Collection names :)
declare variable $tls-collection-name := "tls";
declare variable $tls-data-collection-name := "tls-data";
declare variable $CHANT-collection-name := "CHANT";
declare variable $BB-collection-name := "BB";
declare variable $Heji-image-collection-name := "Heji-images";

(:~ Collection paths :)
declare variable $tls-collection := fn:concat($db-root, "/", $tls-collection-name);
declare variable $tls-data-collection := fn:concat($db-root, "/", $tls-data-collection-name);
declare variable $CHANT-collection := fn:concat($tls-data-collection, "/", $CHANT-collection-name);
declare variable $BB-collection := fn:concat($tls-data-collection, "/", $BB-collection-name, "/");
declare variable $Heji-image-collection := fn:concat($tls-data-collection, "/", $Heji-image-collection-name, "/");

declare variable $local:user := "tls-editor";
declare variable $local:group := "tls-editors";
declare variable $local:new-permissions := "rw-rw-r--";
declare variable $local:new-col-permissions := "rwxrwxr-x";
declare variable $local:home-collection-path := "/db/tls-data";


declare function local:set-collection-resource-permissions($collection as xs:string, $owner as xs:string, $group as xs:string, $permissions as xs:int) {
    for $resource in xdb:get-child-resources($collection) return
        xdb:set-resource-permissions($collection, $resource, $owner, $group, $permissions)
};


(: Set permissions :)
    for $col in ($BB-collection, $CHANT-collection, $Heji-image-collection) return
    (
        xdb:set-collection-permissions($col, $tls-admin-user, $tls-users-group, util:base-to-integer(0775, 8))
    ),
    util:log($log-level, "...Config: Uploading data..."),
        local:set-collection-resource-permissions($BB-collection, $tls-admin-user, $tls-users-group, util:base-to-integer(0775, 8)),
        local:set-collection-resource-permissions($CHANT-collection, $tls-admin-user, $tls-users-group, util:base-to-integer(0775, 8)),
        local:set-collection-resource-permissions($Heji-image-collection, $tls-admin-user, $tls-users-group, util:base-to-integer(0444, 8))