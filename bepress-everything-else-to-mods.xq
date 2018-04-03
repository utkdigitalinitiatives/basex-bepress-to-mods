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
declare variable $source_filepath as xs:string+ external;

(: initial FLOWR :)
for $doc in doc($source_filepath)//@href/doc(.)
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
let $faculty-mentor := $doc-content/fields/field[@name="faculty_mentor"]/value/text()
let $compilier := $doc-content/fields/field[@name="compilier"]/value/text()
let $honors-advisor := $doc-content/fields/field[@name="advisor3"]/value/text()
(: degree info :)
let $degree-name := $doc-content/fields/field[@name='degree_name']/value/text()
let $embargo-date-xsdate := if ($doc-content/fields/field[@name='embargo_date']/value/text())
                            then (xs:dateTime($doc-content/fields/field[@name='embargo_date']/value/text()))
                            else ()
let $major1 := $doc-content/fields/field[@name='major1']/value/text()
let $major2 := $doc-content/fields/field[@name='major2']/value/text()
let $embargo := if ($doc-content/fields/field[@name='embargo_date']/value/text())
                then (xs:date(substring-before($doc-content/fields/field[@name='embargo_date']/value/text(), 'T')))
                else (xs:date('2011-12-31'))
let $src_ftxt_url := $doc-content/fields/field[@name='source_fulltext_url']/value/text()
let $comments := $doc-content/fields/field[@name='comments']/value/text()
let $discipline := $doc-content/disciplines//discipline/text()
let $abstract := $doc-content/abstract/text()
let $keywords := $doc-content/keywords//keyword/text()
let $subject-areas := $doc-content/subject-areas//subject-area/text()
(: supplemental files :)
let $excludes := ('fulltext.pdf', 'metadata.xml')
let $file-list := file:list($doc-path)
let $suppl-archive-name := $doc-content/supplemental-files/file/archive-name/text()
(: dates :)
let $c-date := format-dateTime(current-dateTime(), '[Y]-[M,2]-[D,2]T[H]:[m]:[s][Z]')
(: custom fields :)
let $form-term := $doc-content/type/text()
let $date-other := $doc-content/fields/field[@name='publication_date']/value/text()
let $citation := $doc-content/fields/field[@name="custom_citation"]/value/text()
let $doi := $doc-content/fields/field[@name="doi"]/value/text()
let $source-publication := $doc-content/fields/field[@name="source_publication"]/value/text()
let $edition := $doc-content/fields/field[@name="submission_type"]/value/text()
let $location := $doc-content/fields/field[@name="location"]/value/text()
let $start-date := $doc-content/fields/field[@name="start_date"]/value/text()
let $end-date := $doc-content/fields/field[@name="end_date"]/value/text()
let $comment-url := $doc-content/fields/field[@name="url"]/value/text()
let $contact-info := $doc-content/fields/field[@name="contact_info"]/value/text()
let $dept-name := $doc-content/fields/field[@name='department']/value/text()
let $college := $doc-content/fields/field[@name='college']/value/text()

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
      let $organization := $n/*:organization/text()
      let $institution := $n/*:institution/text()
      return
        if ($organization)
          then <mods:name type="corporate">
              <mods:namePart>{$organization}</mods:namePart>
              <mods:role>
                  <mods:roleTerm authority="marcrelator" valueURI="http://id.loc.gov/vocabulary/relators/cre">Creator</mods:roleTerm>
              </mods:role>
          </mods:name>
          else <mods:name>
            <mods:namePart type="family">{$author-name-l}</mods:namePart>
            <mods:namePart type="given">{$author-name-g}</mods:namePart>
              {if ($author-name-s)
              then <mods:namePart type="termsOfAddress">{$author-name-s}</mods:namePart>
              else ()}
            <mods:role>
                <mods:roleTerm authority="marcrelator" valueURI="http://id.loc.gov/vocabulary/relators/cre">Creator</mods:roleTerm>
            </mods:role>
            {if ($dept-name or $college or $institution)
              then (<mods:affiliation>{$dept-name}</mods:affiliation>,
                    <mods:affiliation/>,
                    <mods:affiliation/>,
                    <mods:affiliation/>,
                    <mods:affiliation>{$college}</mods:affiliation>,
                    <mods:affiliation>{$institution}</mods:affiliation>
                    )
              else()
            }
        </mods:name>
        }


    {if ($advisor)
        then (<mods:name>
              <mods:displayForm>{$advisor}</mods:displayForm>
              <mods:role>
                  <mods:roleTerm type="text" authority="marcrelator" valueURI="http://id.loc.gov/vocabulary/relators/ths">Thesis advisor</mods:roleTerm>
              </mods:role></mods:name>)
        else()
      }

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

    <mods:originInfo>
      <mods:dateCreated encoding="w3cdtf">{$sub-date}</mods:dateCreated>
      <mods:dateIssued keyDate="yes" encoding="edtf">{$pub-date}</mods:dateIssued>
      {if ($date-other)
        then <mods:dateOther>{$date-other}</mods:dateOther>
        else()
      }
      {if ($edition)
        then <mods:edition>{$edition}</mods:edition>
        else()
      }
      {if ($start-date)
        then <mods:dateOther type="Start date">{$start-date}</mods:dateOther>
        else()
      }
      {if ($end-date)
        then <mods:dateOther type="Start date">{$end-date}</mods:dateOther>
        else()
      }
    </mods:originInfo>

    {if (starts-with($sub-path, 'utk_chanhonoproj'))
      then (<mods:extension>
              <etd:degree>
                  {if ($major1)
                    then <etd:discipline>{$major1}</etd:discipline>
                    else()
                  }
                  {if ($major2)
                    then <etd:discipline>{$major2}</etd:discipline>
                    else()
                  }
                <etd:grantor>University of Tennessee</etd:grantor>
              </etd:degree>
            </mods:extension>,
            <mods:genre valueURI="http://purl.org/coar/resource_type/c_7a1f" authority="coar">bachelor thesis</mods:genre>)
      else ()}


    {for $kw in $keywords
      return
          <mods:subject>
              <mods:topic>{$kw}</mods:topic>
          </mods:subject>
    }

    {for $area in $subject-areas
      return
          <mods:subject>
              <mods:topic>{$area}</mods:topic>
          </mods:subject>
    }

    {if ($comments)
      then <mods:note displayLabel="Submitted Comment">{$comments}</mods:note>
      else ()}

    {if ($comment-url)
      then <mods:note displayLabel="Submitted Comment">{$comment-url}</mods:note>
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
      <mods:titleInfo>
        <mods:title>{$pub-title}</mods:title>
      </mods:titleInfo>
    </mods:relatedItem>

    {if ($embargo >= xs:date(substring-before($c-date, 'T')))
      then (
        for $f in ($file-list)
        (:where (replace($f, '^\d{1,}-', '')):)
        where ($f[matches(., '^\d{1,}-')])
        order by $f ascending
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
            <mods:note displayLabel="supplemental_filename">{$f}</mods:note>
          </mods:relatedItem>
      )
      else (
        for $f in ($file-list)
        where (replace($f, '^\d{1,}-', ''))[(. = $suppl-archive-name)]
        order by $f ascending
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
            <mods:note displayLabel="supplemental_filename">{$f}</mods:note>
          </mods:relatedItem>
)}

    <mods:recordInfo displayLabel="Submission">
      <mods:recordCreationDate encoding="w3cdtf">{$sub-date}</mods:recordCreationDate>
      <mods:recordContentSource authority="isni" valueURI="http://www.isni.org/isni/0000000123151184">University of Tennessee (Knoxville)</mods:recordContentSource>
      <mods:recordOrigin>Converted from BePress XML to MODS using bepress-everything-else-to-mods.xq in general compliance with MODS 3.5.</mods:recordOrigin>
      <mods:recordChangeDate encoding="w3cdtf">{$c-date}</mods:recordChangeDate>
    </mods:recordInfo>

    {if ($withdrawn-status)
      then (<mods:recordInfo displayLabel="Withdrawn">
            <mods:recordChangeDate keyDate="yes">{$withdrawn-status}</mods:recordChangeDate>
           </mods:recordInfo>)
      else ()}

   <mods:physicalDescription>
       <mods:form>{$form-term}</mods:form>
   </mods:physicalDescription>

   {if ($citation)
     then <mods:note displayLabel="citation">{$citation}</mods:note>
     else()
   }

   {if ($doi)
     then <mods:identifier type="doi">{$doi}</mods:identifier>
     else()
   }

   {if ($source-publication)
     then <mods:relatedItem type="host" displayLabel="source">
           <mods:titleInfo>
               <mods:title>{$source-publication}</mods:title>
           </mods:titleInfo>
       </mods:relatedItem>
     else()
   }

   {if ($location)
     then <mods:note displayLabel="Location">{$location}</mods:note>
     else()
   }

   {if ($faculty-mentor)
     then <mods:name>
           <mods:namePart>{$faculty-mentor}</mods:namePart>
           <mods:role>
               <mods:roleTerm authority="local">Faculty Mentor</mods:roleTerm>
           </mods:role>
       </mods:name>
     else()
   }

   {if ($compilier)
     then <mods:name>
           <mods:namePart>
               <mods:role>
                   <mods:roleTerm authority="marcrelators" valueURI="http://id.loc.gov/vocabulary/relators/com">{$compilier}</mods:roleTerm>
               </mods:role>
           </mods:namePart>
       </mods:name>
     else()
   }

   {if ($honors-advisor)
     then <mods:name>
           <mods:namePart>
               <mods:role>
                   <mods:roleTerm authority="local">{$honors-advisor}</mods:roleTerm>
               </mods:role>
           </mods:namePart>
       </mods:name>
     else()
   }

   {if ($contact-info)
     then <mods:note displayLabel="Location">{$contact-info}</mods:note>
     else()
   }

  </mods:mods>
)

