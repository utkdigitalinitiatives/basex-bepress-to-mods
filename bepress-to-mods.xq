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
(:
  note: two different dbs for testing:
  1) bepress-small-sample doesn't have binaries
  2) bepress-small-sample-all does

  second approach: processing using collection against a directory
  /usr/home/bridger/bin/basex/repo/basex-bepress-to-mods/sample-data
:)
(: for $doc in db:open('bepress-small-sample') :)
(:for $doc in collection('/usr/home/bridger/bin/basex/repo/basex-bepress-to-mods/sample-data/'):)

for $doc in doc('/usr/home/bridger/bin/basex/repo/basex-bepress-to-mods/sample-data-uris.xml')//@href/doc(.)
let $test-doc := document-uri($doc)
let $doc-path := replace(document-uri($doc), 'metadata.xml', '')
(:let $doc-db-path := replace(db:path($doc), 'metadata.xml', ''):)
let $doc-content := $doc/documents/document
let $title := $doc-content/title/text()
let $pub-date := substring-before($doc-content/publication-date/text(), 'T')
let $pub-title := $doc-content/publication-title/text()
let $sub-date := $doc-content/submission-date/text()
let $withdrawn-status := $doc-content/withdrawn
let $sub-path := $doc-content/submission-path/text()
(: names :)
let $author-name-l := $doc-content/authors/author/lname/text()
(: multiple authors? :)
let $author-name-g := if ($doc-content/authors/author/mname)
                      then ($doc-content/authors/author/fname || ' ' || $doc-content/authors/author/mname/text())
                      else ($doc-content/authors/author/fname)
let $author-name-s := $doc-content/authors/author/suffix/text()
let $advisor := $doc-content/fields/field[@name='advisor1']/value/text()
let $committee-mem := $doc-content/fields/field[@name='advisor2']/value/text()

let $degree-name := $doc-content/fields/field[@name='degree_name']/value/text()
let $dept-name := $doc-content/fields/field[@name='department']/value/text()
let $embargo := substring-before($doc-content/fields/field[@name='embargo_date']/value/text(), 'T')

let $src_ftxt_url := $doc-content/fields/field[@name='source_fulltext_url']/value/text()

let $comments := $doc-content/fields/field[@name='comments']/value/text()
let $discipline := $doc-content/disciplines/discipline/text()
let $abstract := $doc-content/abstract/text()
let $keywords := for $k in ($doc-content/keywords/keyword/text()) return string-join($k, ', ')

(: supplemental files :)
let $suppl-archive-name := $doc-content/supplemental-files/file/archive-name/text()
let $suppl-mimetype := $doc-content/supplemental-files/file/mimetype/text()
let $suppl-desc := $doc-content/supplemental-files/file/description/text()

  (: dates :)
let $c-date := format-dateTime(current-dateTime(), '[Y]-[M,2]-[D,2]T[H]:[m]:[s][Z]')


(: theses/dissertations-specific :)
(: genre authority :)
(: ?? :)


return file:write(concat($doc-path, 'MODS.xml'),
  <mods xmlns="http://www.loc.gov/mods/v3" version="3.5" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">
    <identifer type="local">{$sub-path}</identifer>
    <name>
      <namePart type="family">{$author-name-l}</namePart>
      <namePart type="given">{$author-name-g}</namePart>
      {if ($author-name-s) then <namePart type="termsOfAddress">{$author-name-s}</namePart> else ()}
      <role>
        <roleTerm type="text" authority="marcrelator" valueURI="http://id.loc.gov/vocabulary/relators/aut">Author</roleTerm>
      </role>
    </name>
    <name>
      <displayForm>{$advisor}</displayForm>
      <role>
        <roleTerm type="text" authority="marcrelator" valueURI="http://id.loc.gov/vocabulary/relators/ths">Thesis advisor</roleTerm>
      </role>
    </name>
    {for $n in $committee-mem return  <name>
                                        <displayForm>{$n}</displayForm>
                                        <role>
                                          <roleTerm authority="marcrelator">Committee member</roleTerm>
                                        </role>
                                      </name>}
    <titleInfo>
      <title>{$title}</title>
    </titleInfo>
    <abstract>{$abstract}</abstract>

    <originInfo>
      <dateIssued keyDate="yes">{$pub-date}</dateIssued>
    </originInfo>
    {if (some-thing-utk_grad_whatever) then (make_the_extension_element) else ()}
    <note displayLabel="Submitted Comment">{$comments}</note>
    <relatedItem type="series">
      <titleInfo lang="eng">
        <title>{$pub-title}</title>
      </titleInfo>
    </relatedItem>
    <recordInfo>
      <recordCreationDate encoding="w3cdtf">{$sub-date}</recordCreationDate>
      <recordContentSource>University of Tennessee, Knoxville Libraries</recordContentSource>
      <recordOrigin>Converted from bepress XML to MODS in general compliance to the MODS Guidelines (Version 3.5).</recordOrigin>
      <recordChangeDate encoding="w3cdtf">{$c-date}</recordChangeDate>
    </recordInfo>
    {if (some-thing-utk_grad_whatever) then (make_the_genre_stuff) else ()}
  </mods>
)