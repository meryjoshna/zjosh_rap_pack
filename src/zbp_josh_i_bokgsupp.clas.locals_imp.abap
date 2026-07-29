CLASS lhc_zjosh_i_bookg_supp DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS valiatePrice FOR VALIDATE ON SAVE
      IMPORTING keys FOR zjosh_i_bookg_supp~valiatePrice.

    METHODS validateCurrencyCode FOR VALIDATE ON SAVE
      IMPORTING keys FOR zjosh_i_bookg_supp~validateCurrencyCode.

    METHODS validateSupplement FOR VALIDATE ON SAVE
      IMPORTING keys FOR zjosh_i_bookg_supp~validateSupplement.

ENDCLASS.

CLASS lhc_zjosh_i_bookg_supp IMPLEMENTATION.

  METHOD valiatePrice.
  ENDMETHOD.

  METHOD validateCurrencyCode.
  ENDMETHOD.

  METHOD validateSupplement.
  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

