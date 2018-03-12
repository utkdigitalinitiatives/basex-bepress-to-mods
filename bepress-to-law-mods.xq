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
for $doc in doc('data-uris.xml')//@href/doc(.)
let $doc-path := replace(document-uri($doc), 'metadata.xml', '')
let $doc-content := $doc/documents/document
let $title := $doc-content/title/text()
let $pub-date-xsdate := xs:dateTime($doc-content/publication-date/text())
let $pub-date := functx:substring-before-match($doc-content/publication-date/text(), '-[0-9]{2}T')
let $pub-title := $doc-content/publication-title/text()
let $sub-date := $doc-content/submission-date/text()
let $sub-path := $doc-content/submission-path/text()
(: names :)
let $organization := $doc-content/authors/author/organization/text()
(: degree info :)
let $src_ftxt_url := $doc-content/fields/field[@name='source_fulltext_url']/value/text()
let $comments := $doc-content/fields/field[@name='comments']/value/text()
let $discipline := $doc-content/disciplines/discipline/text()
let $keywords := $doc-content/keywords/keyword/text()
(: dates :)
let $c-date := format-dateTime(current-dateTime(), '[Y]-[M,2]-[D,2]T[H]:[m]:[s][Z]')
(: custom fields :)
let $citation := $doc-content/fields/field[@name='custom_citation']/value/text()
let $hearing_date := $doc-content/fields/field[@name='start_date']/value/text()
let $docket_number := $doc-content/fields/field[@name='docket_num']/value/text()
let $judge := $doc-content/fields/field[@name='judge']/value/text()
let $attorney := $doc-content/fields/field[@name='attorney']/value/text()
let $party := $doc-content/fields/field[@name='party']/value/text()
let $notification_date := $doc-content/fields/field[@name="notification_date"]/value/text()
let $division := $doc-content/fields/field[@name="division"]/value/text()
let $decision_date := $doc-content/fields/field[@name="date"]/value/text()

(: return a MODS record :)
return file:write(concat($doc-path, 'MODS.xml'),

  <mods:mods xmlns="http://www.loc.gov/mods/v3" version="3.5" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:etd="http://www.ndltd.org/standards/metadata/etdms/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">
    <mods:identifier type="local">{$sub-path}</mods:identifier>

    <mods:titleInfo>
      <mods:title>{$title}</mods:title>
    </mods:titleInfo>

    {for $s in $discipline
      return
        <mods:subject>
          <mods:topic>{$s}</mods:topic>
        </mods:subject>}

    {if ($organization)
      then <mods:name type="corporate">
             <mods:namePart>{$organization}</mods:namePart>
               <mods:role>
                 <mods:roleTerm authority="marcrelator" valueURI="http://id.loc.gov/vocabulary/relators/cre">Creator</mods:roleTerm>
               </mods:role>
           </mods:name>
     else()
    }

    <mods:typeOfResource>text</mods:typeOfResource>

    <mods:originInfo>
      <mods:dateCreated encoding="w3cdtf">{$sub-date}</mods:dateCreated>
      <mods:dateIssued keyDate="yes" encoding="edtf">{$pub-date}</mods:dateIssued>
        {if ($hearing_date)
          then <mods:dateOther type="Hearing date" encoding="w3cdtf">{$hearing_date}</mods:dateOther>
         else()
        }
        {if ($notification_date)
          then <mods:dateOther type="Notification date" encoding="w3cdtf">{$notification_date}</mods:dateOther>
         else()
        }
        {if ($decision_date)
          then <mods:dateOther type="Decision date" encoding="w3cdtf">{$decision_date}</mods:dateOther>
          else()
        }
    </mods:originInfo>

    <mods:relatedItem type="series">
        <mods:titleInfo>
            <mods:title>{$pub-title}</mods:title>
        </mods:titleInfo>
    </mods:relatedItem>

      {for $kw in $keywords
        return
            <mods:subject>
                <mods:name>
                    <mods:namePart>{$kw}</mods:namePart>
                </mods:name>
            </mods:subject>
      }

    {if ($comments)
      then <mods:note displayLabel="Submitted Comment">{$comments}</mods:note>
      else ()}

    {if ($citation)
      then
          <mods:note displayLabel="citation">{$citation}</mods:note>
      else()}

    {if ($docket_number)
      then <mods:note displayLabel="Docket number">{$docket_number}</mods:note>
      else()
    }

    {if ($division)
      then <mods:note displayLabel="Agency and Division">{$division}</mods:note>
      else()
    }

    {if ($judge)
      then <mods:name>
            <mods:namePart>{$judge}</mods:namePart>
            <mods:role>
                <mods:roleTerm authority="local">Judge</mods:roleTerm>
            </mods:role>
           </mods:name>
      else()
    }

    {if($attorney)
      then <mods:name>
            <mods:namePart>{$attorney}</mods:namePart>
            <mods:role>
                <mods:roleTerm authority="local">Attorney</mods:roleTerm>
            </mods:role>
        </mods:name>
      else()
    }

    {if($party)
      then <mods:name>
            <mods:namePart>{$party}</mods:namePart>
            <mods:role>
                <mods:roleTerm authority="local">Party</mods:roleTerm>
            </mods:role>
        </mods:name>
      else()
    }

    <mods:recordInfo displayLabel="Submission">
      <mods:recordCreationDate encoding="w3cdtf">{$sub-date}</mods:recordCreationDate>
      <mods:recordContentSource>University of Tennessee, Knoxville Libraries</mods:recordContentSource>
      <mods:recordOrigin>Converted from bepress XML to MODS using bepress-to-law-mods.xq in general compliance to the MODS Guidelines (Version 3.5).</mods:recordOrigin>
      <mods:recordChangeDate encoding="w3cdtf">{$c-date}</mods:recordChangeDate>
    </mods:recordInfo>

  </mods:mods>
)

