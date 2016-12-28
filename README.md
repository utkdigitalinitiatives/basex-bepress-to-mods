# bepress-to-mods via BaseX #
This is an attempt at providing an XQuery-based utility for processing the 'database' dump XML provided by bepress.

It is currently geared towards converting UTKnoxville-specific bepress metadata to MODS (v3.5). With minimal changes, it could be used for other institutions.

## Requirements ##
* Java 1.8 (Oracle or OpenJDK)
* BaseX
* This repository


## Processing ##

Currently, I'm having some confusion with file paths and the database, so the current default branch uses a catalog file for parsing and generating MODS. I'm working on fixing my confusion.