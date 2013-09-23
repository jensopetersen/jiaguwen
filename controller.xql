xquery version "1.0";

import module namespace login="http://exist-db.org/xquery/app/wiki/session" at "modules/login.xql";

declare variable $exist:path external;
declare variable $exist:resource external;

if ($exist:path eq '') then
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <redirect url="{concat(request:get-uri(), '/')}"/>
        </dispatch>
else if ($exist:path = ("/", "")) then
    (: forward root path to search.html :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="search.html"/>
    </dispatch>
else if (ends-with($exist:resource, ".html")) then
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
                <!--<forward url="index.html"/>-->
                <!--uncomment if users are required to log in-->
                <view>
                    <forward url="modules/view.xql">
                    {login:set-user("org.exist.login", ())}
                    </forward>
                </view>
            </dispatch>
    
else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>