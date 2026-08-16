CLASS lhc_zjosh_i_bsupp_d DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calTotPrice FOR DETERMINE ON MODIFY
       keys FOR zjosh_i_bsupp_d~calTotPrice.

    METHODS setBooksuppNum FOR DETERMINE ON SAVE
       keys FOR zjosh_i_bsupp_d~setBooksuppNum.

ENDCLASS.

CLASS lhc_zjosh_i_bsupp_d IMPLEMENTATION.

  METHOD calTotPrice.

    READ ENTITIES OF zjosh_i_travel_d IN LOCAL MODE
    ENTITY zjosh_i_bsupp_d BY \_Travel
    FIELDS ( TravelUUID )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travels).


    MODIFY ENTITIES OF zjosh_i_travel_D IN LOCAL MODE
    ENTITY zjosh_i_travel_D
    EXECUTE recalcTotalPrice
    FROM CORRESPONDING #( lt_travels ).

  ENDMETHOD.

  METHOD setBooksuppNum.

    DATA : lv_max_booksuppId TYPE /dmo/booking_supplement_id.
    DATA : lt_booksupp_upda TYPE TABLE FOR UPDATE zjosh_i_travel_D\\zjosh_i_bsupp_d.

*     read all bookings for the requested booking supple
    READ ENTITIES OF zjosh_i_travel_D IN LOCAL MODE
    ENTITY zjosh_i_bsupp_d BY \_Booking
    FIELDS ( BookingUUID )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_bookings).

    LOOP AT lt_bookings INTO DATA(ls_booking).

      READ ENTITIES OF zjosh_i_travel_d IN LOCAL MODE
      ENTITY zjosh_i_bookg_D BY \_BookingSupplement
      FIELDS ( BookingSupplementID )
      WITH VALUE #( (   %tky = ls_booking-%tky ) )
      RESULT DATA(lt_booksupp).

*        find max used booksupp id
      lv_max_booksuppid = '00'.

      LOOP AT lt_booksupp INTO DATA(ls_booksupp).
        IF ls_booksupp-BookingSupplementID > lv_max_booksuppid.
          lv_max_booksuppid  = ls_booksupp-BookingSupplementID.
        ENDIF.
      ENDLOOP.

*       provide a booking supp id for all book supp of this booking that have do not have

      LOOP AT lt_booksupp INTO ls_booksupp WHERE BookingSupplementID IS INITIAL.
        lv_max_booksuppid += 1.

        APPEND VALUE #( %tky = ls_booksupp-%tky
                        BookingSupplementID = lv_max_booksuppid ) TO lt_booksupp_upda.

      ENDLOOP.

    ENDLOOP.

    MODIFY ENTITIES OF zjosh_i_travel_d IN LOCAL MODE
    ENTITY zjosh_i_bsupp_d
    UPDATE FIELDS ( BookingSupplementID )
    WITH lt_booksupp_upda.

  ENDMETHOD.

ENDCLASS.
