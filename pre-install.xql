xquery version "1.0";

import module namespace util="http://exist-db.org/xquery/util";
import module namespace xdb="http://exist-db.org/xquery/xmldb";
import module namespace dbutil="http://exist-db.org/xquery/dbutil" at "modules/dbutils.xql";

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
declare variable $jiaguwen-collection-name := "jiaguwen";
declare variable $jiaguwen-data-collection-name := "jiaguwen-data";
declare variable $CHANT-collection-name := "CHANT";
declare variable $BB-collection-name := "BB";
declare variable $Heji-image-collection-name := "Heji-images";

(:~ Collection paths :)
declare variable $jiaguwen-collection := fn:concat($db-root, "/", $jiaguwen-collection-name);
declare variable $jiaguwen-data-collection := fn:concat($db-root, "/", $jiaguwen-data-collection-name);
declare variable $CHANT-collection := fn:concat($jiaguwen-data-collection, "/", $CHANT-collection-name);
declare variable $BB-collection := fn:concat($jiaguwen-data-collection, "/", $BB-collection-name, "/");
declare variable $Heji-image-collection := fn:concat($jiaguwen-data-collection, "/", $Heji-image-collection-name, "/");

declare variable $local:user := "tls-editor";
declare variable $local:group := "tls-editors";
declare variable $local:new-permissions := "rw-rw-r--";
declare variable $local:new-col-permissions := "rwxrwxr-x";
declare variable $local:home-collection-path := "/db/jiaguwen-data";

declare function local:find-resources-recursive($collection-path as xs:string) {
    dbutil:scan(xs:anyURI($collection-path), function($collection, $resource) {
        if (exists($resource)) then (
            sm:chmod($resource, $local:new-permissions),
            sm:chown($resource, $local:user),
            sm:chgrp($resource, $local:group)
        ) else (
            sm:chmod($collection, $local:new-col-permissions),
            sm:chown($collection, $local:user),
            sm:chgrp($collection, $local:group)
        )
    })
};

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
    else xdb:create-user($tls-admin-user, 'BB', $tls-users-group, ()),
util:log($log-level, "Create users and groups: Done."),

(: Load collection.xconf documents :)
util:log($log-level, "Config: Loading collection configuration ..."),
    local:mkcol($system-collection, $jiaguwen-data-collection),
    xdb:store-files-from-pattern(fn:concat($system-collection, $jiaguwen-data-collection), $dir, "*.xconf"),
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
        xdb:store-files-from-pattern($CHANT-collection, concat($dir, "/data/CHANT"), "**/*.xml", 'application/xml', true()),
        local:set-collection-resource-permissions($CHANT-collection, $tls-admin-user, $tls-users-group, util:base-to-integer(0775, 8)),
        xdb:store-files-from-pattern($Heji-image-collection, concat($dir, "/data/Heji-images"), "**/*.png", 'image/png', true()),
        local:set-collection-resource-permissions($Heji-image-collection, $tls-admin-user, $tls-users-group, util:base-to-integer(0444, 8)),
    util:log($log-level, "...Config: Done Uploading data."),
util:log($log-level, "Config: Done."), 

local:find-resources-recursive($local:home-collection-path)
,
util:log($log-level, "Script: Done.")