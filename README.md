# bepress-to-mods via BaseX #
This is an attempt at providing an XQuery-based utility for processing the 'database' dump XML provided by bepress.

## Requirements ##
* Java 1.8 (Oracle or OpenJDK)
* BaseX
* This repository


## Creating an XML database ##
The metadata.xml records provided by bepress _may_ have some problems[^1]. There are settings in the 

## 


[^1] Things like the following:

* Invalid CONTROL characters serialized into the files,
* An incorrect (IMO) encoding serialization in the XML declaration (the `encoding` should be UTF-8, not iso-8859-1)
* Others?... :)


