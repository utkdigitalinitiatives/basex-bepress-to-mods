(: namespaces :)
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace xlink = "http://www.w3.org/2001/XMLSchema-instance";
declare namespace file = "http://expath.org/ns/file";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

(: options :)
declare option output:method "xml";
declare option output:omit-xml-declaration "no";
declare option output:encoding "UTF-8";
declare option output:indent "yes";

for $doc in collection('bepress-to-mods')
let $doc-path := fn:replace(fn:document-uri($doc), 'metadata.xml', '')
let $doc-content := $doc/documents/document
let $doc-parent-directory := $doc-content/label/text()
let $title := $doc-content/title/text()
let $pub-date := substring-before($doc-content/publication-date/text(), 'T')
let $pub-title := $doc-content/publication-title/text()
let $sub-date := $doc-content/submission-date/text()
let $withdrawn-status := $doc-content/withdrawn
let $sub-path := $doc-content/submission-path/text()
let $lname := $doc-content/authors/author/lname/text()
let $fname := $doc-content/authors/author/fname/text()
let $suffix := $doc-content/foo

return file:write(
  fn:concat('/usr/home/bridger/Documents/metadata-notes/bepress-to-mods/sample-data/', $doc-parent-directory, '/bxMODS.xml'),
  <mods xmlns:xlink="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.loc.gov/mods/v3" version="3.5" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd"> 
    <titleInfo><title>{$title}</title></titleInfo>
    <originInfo></originInfo>
  </mods> 
)



(:
for $doc in fn:collection("bepress-to-mods")/documents/document
let $title := $doc/title/text()
let $pub-date := substring-before($doc/publication-date, 'T')
let $author-given := concat(($doc/authors/author/fname/text(),
                            $doc/authors/author/mname/text()), 
                            ' ')
let $author-last := $doc/authors/author/lname/text()
let $keywords := $doc/keywords/keyword/text()
let $discipline := $doc/disciplines/discipline/text()
let $abstract := replace($doc/abstract/text(), '&lt;p&gt;|&lt;/p&gt;', '')
let $advisor-main := $doc/fields/field[@name = 'advisor1']/value/text()
let $advisor-committee := $doc/fields/field[@name = 'advisor2']/value/text()
let $degree-name := $doc/fields/field[@name = 'degree_name']/value/text()
let $department := $doc/fields/field[@name = 'department']/value/text()
let $sub-date-short := substring-before($doc/submission-date/text(), 'T')
let $sub-date-full := $doc/submission-date/text()
let $pub-date := $doc/fields/field[@name = 'publication_date']/value/text()
let $supplemental-files := $doc/supplemental-files/file
return(
  <mods>
    <title>{$title}</title>
  </mods>
)
:)