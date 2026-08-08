CLASS lhc_zjosh_i_bookg_u DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zjosh_i_bookg_u.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zjosh_i_bookg_u.

    METHODS read FOR READ
      IMPORTING keys FOR READ zjosh_i_bookg_u RESULT result.

    METHODS rba_Travel FOR READ
      IMPORTING keys_rba FOR READ zjosh_i_bookg_u\_Travel FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_zjosh_i_bookg_u IMPLEMENTATION.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Travel.
  ENDMETHOD.

ENDCLASS.
