CLASS lhc_zjosh_i_bookg_supp DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS valiatePrice FOR VALIDATE ON SAVE
      IMPORTING keys FOR zjosh_i_bookg_supp~valiatePrice.

    METHODS validateCurrencyCode FOR VALIDATE ON SAVE
      IMPORTING keys FOR zjosh_i_bookg_supp~validateCurrencyCode.

    METHODS validateSupplement FOR VALIDATE ON SAVE
      IMPORTING keys FOR zjosh_i_bookg_supp~validateSupplement.
    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zjosh_i_bookg_supp~calculateTotalPrice.

ENDCLASS.

CLASS lhc_zjosh_i_bookg_supp IMPLEMENTATION.

  METHOD valiatePrice.
  ENDMETHOD.

  METHOD validateCurrencyCode.
  ENDMETHOD.

  METHOD validateSupplement.
  ENDMETHOD.

  METHOD calculateTotalPrice.

    DATA : it_travel TYPE STANDARD TABLE OF zjosh_i_travel WITH UNIQUE HASHED KEY key COMPONENTS TravelId.

    it_travel = CORRESPONDING #( keys DISCARDING DUPLICATES MAPPING TravelId = TravelId ).

    MODIFY ENTITIES OF zjosh_i_travel IN LOCAL MODE
      ENTITY zjosh_i_travel
       EXECUTE recalctolPrice
       FROM CORRESPONDING #( it_travel ).

  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

