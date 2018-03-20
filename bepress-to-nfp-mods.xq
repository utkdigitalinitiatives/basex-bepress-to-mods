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
let $sub-path := $doc-content/submission-path/text()
(: names :)
(: degree info :)
let $src_ftxt_url := $doc-content/fields/field[@name='source_fulltext_url']/value/text()
let $keywords := $doc-content/keywords//keyword/text()
(: dates :)
let $c-date := format-dateTime(current-dateTime(), '[Y]-[M,2]-[D,2]T[H]:[m]:[s][Z]')
(: custom fields :)
let $citation := $doc-content/fields/field[@name='custom_citation']/value/text()
let $abstract := $doc-content/abstract/text()
let $embargo_date := $doc-content/fields/field[@name="embargo_date"]/value/text()
let $doi := $doc-content/fields/field[@name="doi"]/value/text()
let $other_ids := $doc-content/fields/field[@name="comments"]/value/text()
let $isbn := $doc-content/fields/field[@name="identifier"]/value/text()
let $buy_link := $doc-content/fields/field[@name="buy_link"]/value/text()
let $city := $doc-content/fields/field[@name="city"]/value/text()
let $publisher := $doc-content/fields/field[@name="publisher"]/value/text()
let $editor_information := $doc-content/fields/field[@name="editor_information"]/value/text()

(: return a MODS record :)
return file:write(concat($doc-path, 'MODS.xml'),

  <mods:mods xmlns="http://www.loc.gov/mods/v3" version="3.5" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:etd="http://www.ndltd.org/standards/metadata/etdms/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">
    <mods:identifier type="local">{$sub-path}</mods:identifier>

    <mods:titleInfo>
      <mods:title>{$title}</mods:title>
    </mods:titleInfo>

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

    <mods:typeOfResource>text</mods:typeOfResource>

      {if ($abstract)
        then <mods:abstract>{$abstract}</mods:abstract>
        else()
      }

    <mods:originInfo>
      <mods:dateCreated encoding="w3cdtf">{$sub-date}</mods:dateCreated>
      <mods:dateIssued keyDate="yes" encoding="edtf">{$pub-date}</mods:dateIssued>
        {if ($city)
          then <mods:place>{$city}</mods:place>
          else()
        }
        {if ($publisher)
          then <mods:publisher>{$publisher}</mods:publisher>
          else()
        }
    </mods:originInfo>

  <mods:physicalDescription>
      <mods:form valueURI="http://purl.org/coar/resource_type/c_2f33" authority="coar">book</mods:form>
  </mods:physicalDescription>

  <mods:relatedItem type="host" displayLabel="series">
      <mods:titleInfo>
          <mods:title>Newfound Press</mods:title>
      </mods:titleInfo>
      <mods:location>
          <mods:url>https://newfoundpress.utk.edu/</mods:url>
      </mods:location>
  </mods:relatedItem>

    <mods:relatedItem type="series">
        <mods:titleInfo>
            <mods:title>{$pub-title}</mods:title>
        </mods:titleInfo>
    </mods:relatedItem>

      {for $kw in $keywords
        return
            <mods:subject>
                <mods:topic>{$kw}</mods:topic>
            </mods:subject>
      }

    {if ($other_ids)
      then <mods:note displayLabel="Other identifiers">{$other_ids}</mods:note>
      else ()}

    {if ($buy_link)
      then <mods:note displayLabel="Buy link">{$buy_link}</mods:note>
      else ()}

    {if ($citation)
      then
          <mods:note displayLabel="citation">{$citation}</mods:note>
      else()}

    {if ($embargo_date)
      then <mods:note displayLabel="Historical Embargo Date">{$embargo_date}</mods:note>
    else()
    }

    {if ($doi)
      then <mods:identifier type="doi">{$doi}</mods:identifier>
    else()
    }

    {if ($isbn)
      then <mods:identifier type="isbn">{$isbn}</mods:identifier>
      else()
    }
    {if ($editor_information)
      then <mods:name>
            <mods:namePart>{$editor_information}</mods:namePart>
            <mods:role>
                <mods:roleTerm authority="marcrelators" valueURI="http://id.loc.gov/vocabulary/relators/edt">Editor</mods:roleTerm>
            </mods:role></mods:name>
      else()
    }

    <mods:recordInfo displayLabel="Submission">
      <mods:recordCreationDate encoding="w3cdtf">{$sub-date}</mods:recordCreationDate>
      <mods:recordContentSource authority="isni" valueURI="http://www.isni.org/isni/0000000123151184">University of Tennessee (Knoxville)</mods:recordContentSource>
      <mods:recordOrigin>Converted from bepress XML to MODS using bepress-to-nfp-mods.xq in general compliance to the MODS Guidelines (Version 3.5).</mods:recordOrigin>
      <mods:recordChangeDate encoding="w3cdtf">{$c-date}</mods:recordChangeDate>
    </mods:recordInfo>

  </mods:mods>
)

