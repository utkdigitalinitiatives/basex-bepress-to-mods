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
for $doc in doc('sample-data-uris.xml')//@href/doc(.)
let $doc-path := replace(document-uri($doc), 'metadata.xml', '')
let $doc-content := $doc/documents/document
let $title := $doc-content/title/text()
let $pub-date-xsdate := xs:dateTime($doc-content/publication-date/text())
let $pub-date := functx:substring-before-match($doc-content/publication-date/text(), '-[0-9]{2}T')
let $pub-title := $doc-content/publication-title/text()
let $sub-date := $doc-content/submission-date/text()
let $withdrawn-status := $doc-content/withdrawn/text()
let $sub-path := $doc-content/submission-path/text()
(: names :)
let $advisor := $doc-content/fields/field[@name='advisor1']/value/text()
let $committee-mem := $doc-content/fields/field[@name='advisor2']/value/text()
(: degree info :)
let $degree-name := $doc-content/fields/field[@name='degree_name']/value/text()
let $dept-name := $doc-content/fields/field[@name='department']/value/text()
let $embargo-date-xsdate := if ($doc-content/fields/field[@name='embargo_date']/value/text())
                            then (xs:dateTime($doc-content/fields/field[@name='embargo_date']/value/text()))
                            else ()
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
(: dates :)
let $c-date := format-dateTime(current-dateTime(), '[Y]-[M,2]-[D,2]T[H]:[m]:[s][Z]')

(: return a MODS record :)
return file:write(concat($doc-path, 'MODS.xml'),

  <mods:mods xmlns="http://www.loc.gov/mods/v3" version="3.5" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:etd="http://www.ndltd.org/standards/metadata/etdms/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">
    <mods:identifier type="local">{$sub-path}</mods:identifier>

    {for $n in $doc-content/*:authors/*:author
      let $author-name-l := $n/*:lname/text()
      (: multiple authors? :)
      let $author-name-g := if ($n/*:mname)
                            then ($n/*:fname/text() || ' ' || $n/*:mname/text())
                            else ($n/*:fname/text())
      let $author-name-s := $n/*:suffix/text()
      return
        <mods:name>
          <mods:namePart type="family">{$author-name-l}</mods:namePart>
          <mods:namePart type="given">{$author-name-g}</mods:namePart>
          {if ($author-name-s)
            then <mods:namePart type="termsOfAddress">{$author-name-s}</mods:namePart>
            else ()}
          <mods:role>
            <mods:roleTerm authority="marcrelator" valueURI="http://id.loc.gov/vocabulary/relators/aut">Author</mods:roleTerm>
          </mods:role>
        </mods:name>}

    <mods:name>
      <mods:displayForm>{$advisor}</mods:displayForm>
      <mods:role>
        <mods:roleTerm type="text" authority="marcrelator" valueURI="http://id.loc.gov/vocabulary/relators/ths">Thesis advisor</mods:roleTerm>
      </mods:role>
    </mods:name>

    {for $possible-cms in $committee-mem
    let $cms := tokenize($possible-cms, ',')
    for $cm in $cms
      return
        <mods:name>
          <mods:displayForm>{$cm}</mods:displayForm>
          <mods:role>
            <mods:roleTerm authority="local">Committee member</mods:roleTerm>
          </mods:role>
        </mods:name>}

    <mods:titleInfo>
      <mods:title>{$title}</mods:title>
    </mods:titleInfo>

    {for $s in $discipline
      return
        <mods:subject>
          <mods:topic>{$s}</mods:topic>
        </mods:subject>}

    <mods:abstract>{$abstract}</mods:abstract>

    <mods:typeOfResource>text</mods:typeOfResource>

    <mods:originInfo>
      <mods:dateCreated encoding="w3cdtf">{$sub-date}</mods:dateCreated>
      <mods:dateIssued keyDate="yes" encoding="edtf">{$pub-date}</mods:dateIssued>
    </mods:originInfo>

    {if (starts-with($sub-path, 'utk_grad'))
      then (<mods:extension>
              <etd:degree>
                <etd:name>{$degree-name}</etd:name>
                <etd:discipline>{$dept-name}</etd:discipline>
                <etd:grantor>University of Tennessee</etd:grantor>
              </etd:degree>
            </mods:extension>,
            <mods:genre authority="lcgft" valueURI="http://id.loc.gov/authorities/genreForms/gf2014026039">Academic theses</mods:genre>)
      else ()}

    {if (matches($pub-title, 'Doctoral Dissertations'))
      then (<mods:genre authority="coar" valueURI="http://purl.org/coar/resource_type/c_db06">doctoral thesis</mods:genre>)
        else if (matches($pub-title, 'Masters Theses'))
        then (<mods:genre authority="coar" valueURI="http://purl.org/coar/resource_type/c_bdcc">masters thesis</mods:genre>)
          else ()}

    <mods:note displayLabel="Keywords submitted by author">{string-join( ($keywords), ', ')}</mods:note>

    {if ($comments)
      then <mods:note displayLabel="Submitted Comment">{$comments}</mods:note>
      else ()}

    {if ($embargo-date-xsdate <= $pub-date-xsdate)
      then ()
        else if (($embargo-date-xsdate = xs:dateTime('2011-12-01T00:00:00-08:00')) or ($embargo-date-xsdate = xs:dateTime('2011-12-01T00:00:00-08:00')))
        then ()
          else if (($embargo-date-xsdate > $pub-date-xsdate) and ($embargo-date-xsdate < xs:dateTime($c-date)))
          then (<mods:note displayLabel="Historical embargo date">{$embargo-date-xsdate}</mods:note>)
            else if (not(xs:string($embargo-date-xsdate)))
            then ()
              else (<mods:accessCondition type="restriction on access">This item may not be viewed until: {$embargo-date-xsdate}</mods:accessCondition>)}

    <mods:relatedItem type="series">
      <mods:titleInfo lang="eng">
        <mods:title>Graduate Theses and Dissertations</mods:title>
      </mods:titleInfo>
    </mods:relatedItem>

    {for $f in ($file-list)
      where (replace($f, '^\d{1,}-', '')[(not(. = ($suppl-archive-name, $excludes)))])
        or (replace($f, '^\d{1,}-', '')[(. = $suppl-archive-name)])
      group by $f
      count $count
      return
        <mods:relatedItem type="constituent">
          <mods:titleInfo><mods:title>{replace($f, '^\d{1,}-', '')}</mods:title></mods:titleInfo>
          <mods:physicalDescription>
            <mods:internetMediaType>
              {if (replace($f, '^\d{1,}-', '') = $suppl-archive-name)
              then ($doc-content/*:supplemental-files/*:file/*:archive-name[. = replace($f, '^\d{1,}-', '')]/following-sibling::*:mime-type/text())
              else (fetch:content-type(concat($doc-path, $f)))}
            </mods:internetMediaType>
          </mods:physicalDescription>
          {if ($doc-content/*:supplemental-files/*:file/*:archive-name[. = replace($f, '^\d{1,}-', '')]/following-sibling::*:description)
            then (<mods:abstract>{$doc-content/*:supplemental-files/*:file/*:archive-name[. = replace($f, '^\d{1,}-', '')]/following-sibling::*:description/text()}</mods:abstract>)
            else()}
          <mods:note displayLabel="supplemental_file">{'SUPPL_' || $count}</mods:note>
        </mods:relatedItem>}

    <mods:recordInfo displayLabel="Submission">
      <mods:recordCreationDate encoding="w3cdtf">{$sub-date}</mods:recordCreationDate>
      <mods:recordContentSource>University of Tennessee, Knoxville Libraries</mods:recordContentSource>
      <mods:recordOrigin>Converted from bepress XML to MODS in general compliance to the MODS Guidelines (Version 3.5).</mods:recordOrigin>
      <mods:recordChangeDate encoding="w3cdtf">{$c-date}</mods:recordChangeDate>
    </mods:recordInfo>

    {if ($withdrawn-status)
      then (<mods:recordInfo displayLabel="Withdrawn">
            <mods:recordChangeDate keyDate="yes">{$withdrawn-status}</mods:recordChangeDate>
           </mods:recordInfo>)
      else ()}

  </mods:mods>
)

