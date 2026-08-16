CLASS lhc_zjosh_i_bookg_D DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calTotprice FOR DETERMINE ON MODIFY
       keys FOR zjosh_i_bookg_D~calTotprice.

    METHODS setBookingdate FOR DETERMINE ON SAVE
       keys FOR zjosh_i_bookg_D~setBookingdate.

    METHODS setBookingNumber FOR DETERMINE ON SAVE
       keys FOR zjosh_i_bookg_D~setBookingNumber.

ENDCLASS.

CLASS lhc_zjosh_i_bookg_D IMPLEMENTATION.

  METHOD calTotprice.

    READ ENTITIES OF zjosh_i_travel_d IN LOCAL MODE
    ENTITY zjosh_i_bookg_D BY \_Travel
    FIELDS ( TravelUUID )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travels).

    MODIFY ENTITIES OF zjosh_i_travel_d IN LOCAL MODE
    ENTITY zjosh_i_travel_d
    EXECUTE recalcTotalPrice
    FROM CORRESPONDING #( lt_travels ).

  ENDMETHOD.

  METHOD setBookingdate.

    READ ENTITIES OF zjosh_i_travel_d IN LOCAL MODE
    ENTITY zjosh_i_bookg_D
    FIELDS ( BookingDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_bookings).

    DELETE lt_bookings WHERE BookingDate IS NOT INITIAL.

    IF lt_bookings IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_bookings ASSIGNING FIELD-SYMBOL(<ls_booking>).

      <ls_booking>-BookingDate = cl_abap_context_info=>get_system_date( ).

    ENDLOOP.

    MODIFY ENTITIES OF zjosh_i_travel_d IN LOCAL MODE
    ENTITY zjosh_i_bookg_D
    UPDATE FIELDS ( BookingDate )
    WITH CORRESPONDING #( lt_bookings ).




  ENDMETHOD.

  METHOD setBookingNumber.

    DATA: lv_max_bookingid TYPE /dmo/booking_id.
    DATA : lt_bookings_upda TYPE TABLE FOR UPDATE zjosh_i_travel_D\\zjosh_i_bookg_D.


    " read all travels for the requested bookings

    READ ENTITIES OF zjosh_i_travel_d IN LOCAL MODE
    ENTITY zjosh_i_bookg_D BY \_Travel
    FIELDS ( TravelUUID )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travels).

    "process all affected travels and read respective bookings

    LOOP AT lt_travels INTO DATA(ls_travel).

      READ ENTITIES OF zjosh_i_travel_d IN LOCAL MODE
      ENTITY zjosh_i_travel_D BY \_Booking
       FIELDS ( BookingID )
       WITH VALUE #( ( %tky = ls_travel-%tky ) )
       RESULT DATA(lt_bookings).

      "find max used booking number in all bookings for this travel
      lv_max_bookingid = '0000'.

      LOOP AT lt_bookings INTO DATA(booking).
        IF booking-BookingID > lv_max_bookingid.
          lv_max_bookingid = booking-BookingID.
        ENDIF.
      ENDLOOP.

      "provide booking id for all the bookings of this travel that have none.

      LOOP AT lt_bookings INTO booking WHERE BookingID IS INITIAL.

        lv_max_bookingid += 1.

        APPEND VALUE #(  %tky = booking-%tky
                         bookingId = lv_max_bookingid
                     ) TO lt_bookings_upda.

      ENDLOOP.

    ENDLOOP.

    MODIFY ENTITIES OF zjosh_i_travel_d IN LOCAL MODE
    ENTITY zjosh_i_bookg_D
    UPDATE FIELDS ( BookingID )
    WITH lt_bookings_upda.

  ENDMETHOD.

ENDCLASS.
