(:
: A conversion for bepress-specific metadata.xml files to MODS xml,
: using BaseX as an XQuery processor and data manipulation layer.
:)

(: imports :)
import module namespace cob = 'http://cob.net/ns' at 'modules/escape.xqm';
import module namespace functx = 'http://www.functx.com';


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
for $doc in doc('/usr/home/bridger/bin/basex/repo/basex-bepress-to-mods/sample-data-uris.xml')//@href/doc(.)
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
                      then ($doc-content/authors/author/fname/text() || ' ' || $doc-content/authors/author/mname/text())
                      else ($doc-content/authors/author/fname/text())
let $author-name-s := $doc-content/authors/author/suffix/text()
let $advisor := $doc-content/fields/field[@name='advisor1']/value/text()
let $committee-mem := $doc-content/fields/field[@name='advisor2']/value/text()

let $degree-name := $doc-content/fields/field[@name='degree_name']/value/text()
let $dept-name := $doc-content/fields/field[@name='department']/value/text()
let $embargo := if ($doc-content/fields/field[@name='embargo_date']/value/text())
                then (xs:date(substring-before($doc-content/fields/field[@name='embargo_date']/value/text(), 'T')))
                else (xs:date('2011-12-31'))

let $src_ftxt_url := $doc-content/fields/field[@name='source_fulltext_url']/value/text()

let $comments := $doc-content/fields/field[@name='comments']/value/text()
let $discipline := $doc-content/disciplines/discipline/text()
let $abstract := $doc-content/abstract/text()
let $keywords := $doc-content/keywords//keyword/text()

(: supplemental files :)
let $excludes := ('fulltext.pdf', 'metadata.xml')
let $file-list := file:list($doc-path)
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
      {if ($author-name-s)
        then <namePart type="termsOfAddress">{$author-name-s}</namePart>
        else ()}
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

    {for $n in $committee-mem
      return  <name>
                <displayForm>{$n}</displayForm>
                <role>
                  <roleTerm authority="marcrelator">Committee member</roleTerm>
                </role>
              </name>}

    <titleInfo>
      <title>{$title}</title>
    </titleInfo>

    {for $s in $discipline
      return  <subject>
                <topic>{$s}</topic>
              </subject>}

    <abstract>{$abstract}</abstract>

    <originInfo>
      <dateIssued keyDate="yes">{$pub-date}</dateIssued>
    </originInfo>

    {if (starts-with($sub-path, 'utk_grad'))
      then (<extension xmlns:etd="http://www.ndltd.org/standards/etdms/1.1">
              <etd:degree><etd:name>{$degree-name}</etd:name></etd:degree>
              <etd:discipline>{$dept-name}</etd:discipline>
              <etd:grantor>Some Kind of Programmatic Value or Should We Be Doing Something Different?</etd:grantor>
            </extension>)
      else ()}

    <note displayLabel="Keywords submitted by author">{string-join( ($keywords), ', ')}</note>

    <note displayLabel="Submitted Comment">{$comments}</note>

    {if ($embargo >= xs:date(substring-before($c-date, 'T')))
      then (<accesssCondition type="restriction on access">Restricted: cannot be viewed until {$embargo}</accesssCondition>)
      else ()}

    <relatedItem type="series">
      <titleInfo lang="eng">
        <title>{$pub-title}</title>
      </titleInfo>
    </relatedItem>

    <testFILE_LIST>{$file-list}</testFILE_LIST>
    <testSUPPL_LIST>{$suppl-archive-name}</testSUPPL_LIST>

    {for $f in (file:list($doc-path))
      let $f-less := replace($f, '^\d{1,}-', '')
      where ($f-less[(not(. = ($suppl-archive-name, $excludes)))])
        or ($f-less[(. = $suppl-archive-name)])
      return
        <relatedItem type="constituent">
          <titleInfo><title>{$f-less}</title></titleInfo>
          <physicalDescription>
            <internetMediaType>
              {if ($f-less = $suppl-archive-name)
                then ($doc-content/supplemental-files/file/archive-name[. = $f-less]/following-sibling::mime-type/text())
                else (fetch:content-type(fn:concat($doc-path, $f)))}
            </internetMediaType>
          </physicalDescription>
          {if ($suppl-desc) then (<abtract>{$suppl-desc}</abtract>) else()}
        </relatedItem>}


    {if (some-thing-utk_grad_whatever) then (make_the_genre_stuff) else ()}

    <recordInfo>
      <recordCreationDate encoding="w3cdtf">{$sub-date}</recordCreationDate>
      <recordContentSource>University of Tennessee, Knoxville Libraries</recordContentSource>
      <recordOrigin>Converted from bepress XML to MODS in general compliance to the MODS Guidelines (Version 3.5).</recordOrigin>
      <recordChangeDate encoding="w3cdtf">{$c-date}</recordChangeDate>
    </recordInfo>

  </mods>
)