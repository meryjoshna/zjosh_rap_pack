CLASS zjosh_cl_trav_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zjosh_cl_trav_data IMPLEMENTATION.


METHOD if_oo_adt_classrun~main.


    "-----------------------------------
    " 1. TRAVEL DATA
    "-----------------------------------
    SELECT * FROM /dmo/travel_m INTO TABLE @DATA(lt_travel).

    LOOP AT lt_travel INTO DATA(ls_travel).

      DATA(ls_ztravel) =
        CORRESPONDING zjosh_travle_dbt( ls_travel ).

      MODIFY zjosh_travle_dbt FROM @ls_ztravel.

    ENDLOOP.

    out->write( |Travel Data Copied| ).

    "-----------------------------------
    " 2. BOOKING DATA
    "-----------------------------------
    SELECT * FROM /dmo/booking_m INTO TABLE @DATA(lt_booking).

    LOOP AT lt_booking INTO DATA(ls_booking).

      DATA(ls_zbooking) =
        CORRESPONDING zjosh_bookg_ddt( ls_booking ).

      MODIFY zjosh_bookg_ddt FROM @ls_zbooking.

    ENDLOOP.

    out->write( |Booking Data Copied| ).

    "-----------------------------------
    " 3. BOOKING SUPPLEMENT DATA
    "-----------------------------------
    SELECT * FROM /dmo/booksuppl_m INTO TABLE @DATA(lt_supp).

    LOOP AT lt_supp INTO DATA(ls_supp).

      DATA(ls_zsupp) =
        CORRESPONDING zjosh_bookg_supp( ls_supp ).

      MODIFY zjosh_bookg_supp FROM @ls_zsupp.

    ENDLOOP.

    out->write( |Booking Supplement Data Copied| ).

    "-----------------------------------
    " FINAL MESSAGE
    "-----------------------------------
    out->write( | All data copied successfully!| ).


  ENDMETHOD.


ENDCLASS.
