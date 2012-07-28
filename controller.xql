xquery version "1.0";

import module namespace login="http://exist-db.org/xquery/app/wiki/session" at "modules/login.xql";

declare variable $exist:path external;
declare variable $exist:resource external;

if ($exist:path eq '') then
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <redirect url="{concat(request:get-uri(), '/')}"/>
        </dispatch>
else if ($exist:path = ("/", "")) then
    (: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="index.html"/>
    </dispatch>
else if ($exist:resource = "edit.html") then
    let $loggedIn := login:set-user("org.exist.login", ())
    (:NB: temporary!:)
    return
        if ($loggedIn) then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <view>
                    <forward url="modules/view.xql">
                    {login:set-user("org.exist.login", ())}
                    </forward>
                </view>
            </dispatch>
        else
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="index.html"/>
                <view>
                    <forward url="modules/view.xql">
                    {login:set-user("org.exist.login", ())}
                    </forward>
                </view>
            </dispatch>
else if (ends-with($exist:resource, ".html")) then
    (: the html page is run through view.xql to expand templates :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <view>
            <forward url="modules/view.xql">
            {login:set-user("org.exist.login", ())}
            </forward>
        </view>
    </dispatch>
(: paths starting with /libs/ will be loaded from the webapp directory on the file system :)
else if (starts-with($exist:path, "/libs/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="/{substring-after($exist:path, 'libs/')}" absolute="yes"/>
    </dispatch>

    
else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>