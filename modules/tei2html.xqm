
module namespace tei2html="http://xmlopenfoundation.org/tei2html";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";

declare function tei2html:main($content as node()*) as item()* {
    for $node in $content/node()
    return 
        typeswitch($node)
        
            case text() return $node
            case element(tei:TEI) return tei2html:TEI($node)
            case element(tei:teiHeader) return ()
            case element(tei:p) return tei2html:recurse($node) (:skip <p>, it is only used to store other elements in. :)
            case element(tei:ab) return tei2html:recurse($node) (:skip <ab>, it is only used to store <seg> in. :)
            case element(tei:seg) return tei2html:seg($node)(:no attributes:)
            case element(tei:group) return tei2html:group($node) (:no attributes:)
            case element(tei:text) return tei2html:text($node) 
           
            default return tei2html:recurse($node)
            
};



declare function tei2html:recurse($node as node()) as item()* {
  tei2html:main($node)
};

declare function tei2html:TEI($node as element(tei:TEI)) as element() {
    <html>
       <head>
          <title>TEI to HTML</title>
       </head>
       <body>
       {tei2html:recurse($node)}
       </body>
    </html>
};

declare function tei2html:teiHeader($node as element(tei:teiHeader)) as element() {
    ()
};
   

declare function tei2html:list($node as element(tei:list)) as element() {

<ul>{tei2html:recurse($node)} </ul>

};



declare function tei2html:seg($node as element(tei:seg)) as element() {
    let $type := $node/ancestor::tei:text/@type
    let $subtype := $node/ancestor::tei:text/@subtype
    return
    <li class="seg {$type} {$subtype}">
       {tei2html:recurse($node)}
    </li>
};

declare function tei2html:group($node as element(tei:group)) as element() {
    <div class="group">
       {tei2html:recurse($node)}
    </div>
};

(:declare function tei2html:text($node as element(tei:text)) as element()? {
    if ($node/parent::tei:TEI) (\:an outer text:\)
    then 
        <div class="outer">
            {tei2html:recurse($node)}
        </div>
    else 
        if (($node/parent::tei:group) and ($node/child::tei:group)) (\:an middle text:\)
        then
            <div class="middle">
                <h3>Text {$node/@n/string()}</h3>
                {tei2html:recurse($node)}
            </div>
        else
            if ($node/@subtype eq 'Takashima')
            then
            <div class="inner">
                <h4>{$node/@type/string()}/{$node/@subtype/string()}</h4>
                {tei2html:recurse($node)}
            </div>
            else ()
            
            
};
:)

declare function tei2html:text($node as element(tei:text)) as element()? {
    if ($node/parent::tei:TEI)
    then 
        <div class="outer">
            {tei2html:recurse($node)}
        </div>
    else
        let $doc := $node/ancestor-or-self::tei:TEI
        let $doc-id := $doc/@xml:id
        let $text-n := $node/@n/string()
        let $collection := util:collection-name($doc)
        return
        if (($node/parent::tei:group) and ($node/child::tei:group))
        then
            <div class="middle">
                
                <h3><a href="edit.html?doc-id={$doc-id}&amp;text-number={string($text-n)}"><img src="resources/images/page-edit-icon.png"/></a> Inscription {$node/@n/string()}</h3>
                <div class="text-output">
                {
                if (exists($node/tei:group/tei:text[@subtype eq 'Takashima'])) 
                then
                    for $t in $node/tei:group/tei:text[@subtype eq 'Takashima']
                        return 
                            if ($t/@type eq 'transcription')
                            then
                                <ul class="transcription {$t/@subtype}">{tei2html:recurse($t)}</ul>
                            else
                                <ul class="translation {$t/@subtype}">{tei2html:recurse($t)}</ul>
                else 
                    for $t in $node/tei:group/tei:text
                        return 
                                <ul class="transcription {$t/@subtype}">{tei2html:recurse($t)}</ul>
                }
                </div>
            </div>
        else ()
};
