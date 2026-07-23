CLASS zjosh_del_trav DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zjosh_del_trav IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

  DELETE FROM zjosh_travle_dbt.
  DELETE FROM zjosh_bookg_ddt.
  DELETE FROM zjosh_bookg_supp.
  out->write( | data deleted successfully!| ).

  ENDMETHOD.
ENDCLASS.
