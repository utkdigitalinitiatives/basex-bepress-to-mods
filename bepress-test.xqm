(: basic notes :)

(: return file:write(
  fn:concat('/usr/home/bridger/Documents/metadata-notes/bepress-to-mods/sample-data/', $doc-parent-directory, '/bxMODS.xml'),
  <mods xmlns:xlink="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.loc.gov/mods/v3" version="3.5" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd"> 
    <titleInfo><title>{$title}</title></titleInfo>
    <originInfo></originInfo>
  </mods> 
) :)



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