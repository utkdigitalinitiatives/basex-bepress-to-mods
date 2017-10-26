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
  <mods xmlns="http://www.loc.gov/mods/v3" version="3.5" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">
    <identifier type="local">{$sub-path}</identifier>

    {for $n in $doc-content/*:authors/*:author
      let $author-name-l := $n/*:lname/text()
      (: multiple authors? :)
      let $author-name-g := if ($n/*:mname)
                            then ($n/*:fname/text() || ' ' || $n/*:mname/text())
                            else ($n/*:fname/text())
      let $author-name-s := $n/*:suffix/text()
      return
        <name>
          <namePart type="family">{$author-name-l}</namePart>
          <namePart type="given">{$author-name-g}</namePart>
          {if ($author-name-s)
            then <namePart type="termsOfAddress">{$author-name-s}</namePart>
            else ()}
          <role>
            <roleTerm authority="marcrelator" valueURI="http://id.loc.gov/vocabulary/relators/aut">Author</roleTerm>
          </role>
        </name>}

    <name>
      <displayForm>{$advisor}</displayForm>
      <role>
        <roleTerm type="text" authority="marcrelator" valueURI="http://id.loc.gov/vocabulary/relators/ths">Thesis advisor</roleTerm>
      </role>
    </name>

    {for $n in $committee-mem
      return
        <name>
          <displayForm>{$n}</displayForm>
          <role>
            <roleTerm authority="local">Committee member</roleTerm>
          </role>
        </name>}

    <titleInfo>
      <title>{$title}</title>
    </titleInfo>

    {for $s in $discipline
      return
        <subject>
          <topic>{$s}</topic>
        </subject>}

    <abstract>{$abstract}</abstract>

    <typeOfResource>text</typeOfResource>

    <originInfo>
      <dateCreated encoding="w3cdtf">{$sub-date}</dateCreated>
      <dateIssued keyDate="yes" encoding="edtf">{$pub-date}</dateIssued>
    </originInfo>

    {if (starts-with($sub-path, 'utk_grad'))
      then (<extension xmlns:etd="http://www.ndltd.org/standards/etdms/1.1">
              <etd:degree><etd:name>{$degree-name}</etd:name></etd:degree>
              <etd:discipline>{$dept-name}</etd:discipline>
              <etd:grantor>University of Tennessee</etd:grantor>
            </extension>,
            <genre authority="lcgft" valueURI="http://id.loc.gov/authorities/genreForms/gf2014026039">Academic theses</genre>)
      else ()}

    {if (matches($pub-title, 'Doctoral Dissertations'))
      then (<genre authority="coar" valueURI="http://purl.org/coar/resource_type/c_db06">doctoral thesis</genre>)
        else if (matches($pub-title, 'Masters Theses'))
        then (<genre authority="coar" valueURI="http://purl.org/coar/resource_type/c_bdcc">masters thesis</genre>)
          else ()}

    <note displayLabel="Keywords submitted by author">{string-join( ($keywords), ', ')}</note>

    {if ($comments)
      then <note displayLabel="Submitted Comment">{$comments}</note>
      else ()}

    <accessCondition type="restriction on access">Restricted: cannot be viewed until {$embargo}</accessCondition>

    <relatedItem type="series">
      <titleInfo lang="eng">
        <title>Graduate Theses and Dissertations</title>
      </titleInfo>
    </relatedItem>

    {for $f in ($file-list)
      where (replace($f, '^\d{1,}-', '')[(not(. = ($suppl-archive-name, $excludes)))])
        or (replace($f, '^\d{1,}-', '')[(. = $suppl-archive-name)])
      group by $f
      count $count
      return
        <relatedItem type="constituent">
          <titleInfo><title>{replace($f, '^\d{1,}-', '')}</title></titleInfo>
          <physicalDescription>
            <internetMediaType>
              {if (replace($f, '^\d{1,}-', '') = $suppl-archive-name)
              then ($doc-content/*:supplemental-files/*:file/*:archive-name[. = replace($f, '^\d{1,}-', '')]/following-sibling::*:mime-type/text())
              else (fetch:content-type(concat($doc-path, $f)))}
            </internetMediaType>
          </physicalDescription>
          {if ($doc-content/*:supplemental-files/*:file/*:archive-name[. = replace($f, '^\d{1,}-', '')]/following-sibling::*:description)
            then (<abstract>{$doc-content/*:supplemental-files/*:file/*:archive-name[. = replace($f, '^\d{1,}-', '')]/following-sibling::*:description/text()}</abstract>)
            else()}
          <note displayLabel="supplemental_file">{'SUPPL_' || $count}</note>
        </relatedItem>}

    <recordInfo displayLabel="Submission">
      <recordCreationDate encoding="w3cdtf">{$sub-date}</recordCreationDate>
      <recordContentSource>University of Tennessee, Knoxville Libraries</recordContentSource>
      <recordOrigin>Converted from bepress XML to MODS in general compliance to the MODS Guidelines (Version 3.5).</recordOrigin>
      <recordChangeDate encoding="w3cdtf">{$c-date}</recordChangeDate>
    </recordInfo>

    {if ($withdrawn-status)
      then (<recordInfo displayLabel="Withdrawn">
            <recordChangeDate keyDate="yes">{$withdrawn-status}</recordChangeDate>
           </recordInfo>)
      else ()}

  </mods>
)

