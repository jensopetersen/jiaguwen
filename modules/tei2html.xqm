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
            case element(tei:p) return tei2html:p($node)
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

   

declare function tei2html:list($node as element(tei:list)) as element() {

<ul>{tei2html:recurse($node)} </ul>

};



declare function tei2html:p($node as element(tei:p)) as element() {
    <p>
       {tei2html:recurse($node)}
    </p>
};

declare function tei2html:seg($node as element(tei:seg)) as element() {
    <div type="seg">
       {tei2html:recurse($node)}
    </div>
};

declare function tei2html:group($node as element(tei:group)) as element() {
    <div type="group">
       {tei2html:recurse($node)}
    </div>
};

declare function tei2html:text($node as element(tei:text)) as element() {
    if ($node/parent::tei:TEI) (:an outer text:)
    then <div type="outer"> "{tei2html:recurse($node)}"</div>
    else 
        if (($node/parent::tei:group) and ($node/child::tei:group)) (:an middle text:)
        then <div type="middle"> "{tei2html:recurse($node)}"</div>
        else <div type="inner"> "{tei2html:recurse($node)}"</div>
            
};
