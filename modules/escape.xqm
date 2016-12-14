(:~
: User: bridger
: Date: 10/23/16
: Time: 9:57 PM
: A function for processing text(), stripping embedded HTML
:)

module namespace cob = "http://cob.net/ns";

declare function cob:escape($text-in as xs:string) as xs:string
{
  if (fn:contains($text-in, '&lt;'))
  then (if (fn:contains($text-in, '&lt;a'))
        then (fn:normalize-space(fn:replace($text-in, '&lt;/?\p{L}+&gt;|&lt;a href=&quot;([A-Za-z0-9:/.]+)&quot;&gt;[A-Za-z0-9:/.]+&lt;/?\p{L}+&gt;', '$1')))
        else (fn:normalize-space(fn:replace($text-in, '&lt;/?\p{L}+&gt;', ''))))
  else (fn:normalize-space($text-in))
};
