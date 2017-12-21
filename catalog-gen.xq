(: update the $file-path variable binding :)

let $file-path := ''
let $ent := file:list($file-path, true(), 'metadata.xml')
let $out := file:parent(static-base-uri())
return file:write(concat($out, 'data-uris.xml'),
  <catalog>{
    for $e in $ent return
      <doc href="{concat($file-path, $e)}"/>
  }</catalog>
)
