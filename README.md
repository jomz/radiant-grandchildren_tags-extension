Radiant Grandchildren Tags Extension
===

About
---

An extension by [Benny Degezelle][jomz] that adds r:grandchildren tags. Think of this tag like r:aggregate, where the paths attribute would be the urls of all the children of the current page. All features of r:children are implemented, see Available Tags.

Tested on [Radiant CMS][radiant] 1.0.0.rc2, but should work for 0.9.1+ (uses Radiant's render_children_with_pagination)

Installation
---
  
    git clone git://github.com/jomz/radiant-grandchildren_tags-extension.git vendor/extensions/grandchildren_tags


###Available Tags

* See the "available tags" documentation built into the Radiant page admin for more details.

* <r:grandchildren:count>
* <r:grandchildren:first>
* <r:grandchildren:last>
* <r:grandchildren:each>
* <r:grandchildren:each:if_first>
* <r:grandchildren:each:unless_first>
* <r:grandchildren:each:if_last>
* <r:grandchildren:each:unless_last>
* <r:grandchildren:each:header>

[jomz]: http://github.com/jomz
[radiant]: http://radiantcms.org/

