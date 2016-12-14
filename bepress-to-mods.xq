(:
: A conversion for bepress-specific metadata.xml files to MODS xml,
: using BaseX as an XQuery processor and data manipulation layer.
:)

(: imports :)
import module namespace cob = 'http://cob.net/ns' at 'modules/escape.xqm';


(: namespaces and options :)
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace xlink = "http://www.w3.org/2001/XMLSchema-instance";
declare namespace file = "http://expath.org/ns/file";
declare namespace fetch = "http://basex.org/modules/fetch";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "xml";
declare option output:omit-xml-declaration "no";
declare option output:encoding "UTF-8";
declare option output:indent "yes";

(: initial FLOWR :)
for $doc in db:open('bepress-small-sample')
let $doc-path := fn:replace(fn:document-uri($doc), 'metadata.xml', '')
let $doc-db-path := db:path($doc)
let $doc-content := $doc/documents/document
let $title := cob:escape($doc-content/title/text())
let $pub-date := fn:substring-before($doc-content/publication-date/text(), 'T')
let $pub-title := $doc-content/publication-title/text()
let $sub-date := $doc-content/submission-date/text()
let $withdrawn-status := $doc-content/withdrawn
let $sub-path := $doc-content/submission-path/text()
(: names :)
let $author-l := $doc-content/authors/author/lname/text()
let $author-f := $doc-content/authors/author/fname/text()
let $author-s := $doc-content/authors/author/suffix/text()
let $advisor := $doc-content/fields/field[@name='advisor1']/value/text()
let $committee-mem := $doc-content/fields/field[@name='advisor2']/value/text()


let $abstract := cob:escape($doc-content/abstract/text())


return (
  (: example output for testing :)
  <test>
    <path>{$doc-path}</path>
    <db>{$doc-db-path}</db>
    {for $c in $committee-mem return <com>{$c}</com>}
  </test>
), file:write(fn:concat($doc-db-path, 'MODS.xml'),
  <mods xmlns="http://www.loc.gov/mods/v3" version="3.5" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">
    <!-- build us a mods document here -->
  </mods>
)