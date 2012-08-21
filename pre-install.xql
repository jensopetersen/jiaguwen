xquery version "1.0";

import module namespace util="http://exist-db.org/xquery/util";
import module namespace xdb="http://exist-db.org/xquery/xmldb";

(: file path pointing to the exist installation directory :)
declare variable $home external;
(: path to the directory in expathrepo containing the unpacked .xar package :)
declare variable $dir external;
(: the target collection into which the app is deployed :)
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

declare function local:mkcol-recursive($collection, $components) {
    if (fn:exists($components)) then
        let $newColl := fn:concat(
            $collection, 
            if(fn:starts-with($components[1], "/"))then($components[1])else(fn:concat("/", $components[1]))
        )
        return (
            xdb:create-collection($collection, $components[1]),
            local:mkcol-recursive($newColl, fn:subsequence($components, 2))
        )
    else
        ()
};

(: Helper function to recursively create a collection hierarchy. :)
declare function local:mkcol($collection, $path) {
    local:mkcol-recursive($collection, fn:tokenize($path, "/"))
};

declare function local:set-collection-resource-permissions($collection as xs:string, $owner as xs:string, $group as xs:string, $permissions as xs:int) {
    for $resource in xdb:get-child-resources($collection) return
        xdb:set-resource-permissions($collection, $resource, $owner, $group, $permissions)
};

declare function local:strip-prefix($str as xs:string, $prefix as xs:string) as xs:string? {
    fn:replace($str, $prefix, "")
};


util:log($log-level, "Script: Running pre-install script ..."),
util:log($log-level, fn:concat("...Script: using $home '", $home, "'")),
util:log($log-level, fn:concat("...Script: using $dir '", $dir, "'")),

(: Create users and groups :)
util:log($log-level, fn:concat("Security: Creating user '", $tls-admin-user, "' and group '", $tls-users-group, "' ...")),
    if (xdb:group-exists($tls-users-group)) then ()
    else xdb:create-group($tls-users-group),
    if (xdb:exists-user($tls-admin-user)) then ()
    else xdb:create-user($tls-admin-user, $tls-admin-user, $tls-users-group, ()),
util:log($log-level, "Create users and groups: Done."),

(: Load collection.xconf documents :)
util:log($log-level, "Config: Loading collection configuration ..."),
    local:mkcol($system-collection, $tls-data-collection),
    xdb:store-files-from-pattern(fn:concat($system-collection, $tls-data-collection), $dir, "*.xconf"),
util:log($log-level, "Loading collection.xconf documents: Done."),

(: Create data collections :)
util:log($log-level, fn:concat("Config: Creating data collection '", $CHANT-collection, "'...")),
    for $col in ($BB-collection, $CHANT-collection, $Heji-image-collection) return
    (
        local:mkcol($db-root, local:strip-prefix($col, fn:concat($db-root, "/"))),
        xdb:set-collection-permissions($col, $tls-admin-user, $tls-users-group, util:base-to-integer(0775, 8))
    ),
    util:log($log-level, "...Config: Uploading data..."),
        xdb:store-files-from-pattern($BB-collection, $dir, "data/BB/*.xml"),
        local:set-collection-resource-permissions($BB-collection, $tls-admin-user, $tls-users-group, util:base-to-integer(0775, 8)),
        xdb:store-files-from-pattern($CHANT-collection, $dir, "data/CHANT/*.xml"),
        local:set-collection-resource-permissions($CHANT-collection, $tls-admin-user, $tls-users-group, util:base-to-integer(0775, 8)),
        xdb:store-files-from-pattern($Heji-image-collection, $dir, "data/Heji-images/*.png"),
        local:set-collection-resource-permissions($Heji-image-collection, $tls-admin-user, $tls-users-group, util:base-to-integer(0444, 8)),
    util:log($log-level, "...Config: Done Uploading data."),
util:log($log-level, "Config: Done."), 

util:log($log-level, "Script: Done.")