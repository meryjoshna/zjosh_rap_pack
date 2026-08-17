CLASS lhc_zjosh_i_bsupp_d DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calTotPrice FOR DETERMINE ON MODIFY
       keys FOR zjosh_i_bsupp_d~calTotPrice.

    METHODS setBooksuppNum FOR DETERMINE ON SAVE
       keys FOR zjosh_i_bsupp_d~setBooksuppNum.
    METHODS validateSupplement FOR VALIDATE ON SAVE
      keys FOR zjosh_i_bsupp_d~validateSupplement.

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

  METHOD validateSupplement.

    READ ENTITIES OF zjosh_i_travel_d IN LOCAL MODE
         ENTITY zjosh_i_bsupp_d
         FIELDS ( SupplementID )
         WITH CORRESPONDING #( keys )
         RESULT DATA(bookingsupplements)
         FAILED DATA(read_failed).

    failed = CORRESPONDING #( DEEP read_failed ).

    READ ENTITIES OF zjosh_i_travel_d IN LOCAL MODE
         ENTITY zjosh_i_bsupp_d BY \_Booking
         FROM CORRESPONDING #( bookingsupplements )
         LINK DATA(booksuppl_booking_links).

    READ ENTITIES OF zjosh_i_travel_d IN LOCAL MODE
         ENTITY zjosh_i_bsupp_d BY \_Travel
         FROM CORRESPONDING #( bookingsupplements )
         LINK DATA(booksuppl_travel_links).

    DATA supplements TYPE SORTED TABLE OF /dmo/supplement WITH UNIQUE KEY supplement_id.

    " Optimization of DB select: extract distinct non-initial supplement IDs
    supplements = CORRESPONDING #( bookingsupplements DISCARDING DUPLICATES MAPPING supplement_id = SupplementID EXCEPT * ).
    DELETE supplements WHERE supplement_id IS INITIAL.

    IF supplements IS NOT INITIAL.
      " Check if customer ID exists
      SELECT FROM /dmo/supplement
        FIELDS supplement_id
        FOR ALL ENTRIES IN @supplements
        WHERE supplement_id = @supplements-supplement_id
        INTO TABLE @DATA(valid_supplements).
    ENDIF.

    LOOP AT bookingsupplements ASSIGNING FIELD-SYMBOL(<bookingsupplement>).

      APPEND VALUE #( %tky        = <bookingsupplement>-%tky
                      %state_area = 'VALIDATE_SUPPLEMENT' )
             TO reported-zjosh_i_bsupp_d.

      IF <bookingsupplement>-SupplementID IS INITIAL.
        APPEND VALUE #( %tky = <bookingsupplement>-%tky ) TO failed-zjosh_i_bsupp_d.

        APPEND VALUE #(
            %tky                  = <bookingsupplement>-%tky
            %state_area           = 'VALIDATE_SUPPLEMENT'
            %msg                  = NEW /dmo/cm_flight_messages( textid   = /dmo/cm_flight_messages=>enter_supplement_id
                                                                 severity = if_abap_behv_message=>severity-error )
            %path                 = VALUE #(
                zjosh_i_bookg_d-%tky  = booksuppl_booking_links[ KEY id
                                                                 source-%tky = <bookingsupplement>-%tky ]-target-%tky
                zjosh_i_travel_d-%tky = booksuppl_travel_links[  KEY id
                                                                source-%tky = <bookingsupplement>-%tky ]-target-%tky )
            %element-SupplementID = if_abap_behv=>mk-on )
               TO reported-zjosh_i_bsupp_d.

      ELSEIF <bookingsupplement>-SupplementID IS NOT INITIAL AND NOT line_exists(
          valid_supplements[ supplement_id = <bookingsupplement>-SupplementID ] ).
        APPEND VALUE #( %tky = <bookingsupplement>-%tky ) TO failed-zjosh_i_bsupp_d.

        APPEND VALUE #(
            %tky                  = <bookingsupplement>-%tky
            %state_area           = 'VALIDATE_SUPPLEMENT'
            %msg                  = NEW /dmo/cm_flight_messages( textid   = /dmo/cm_flight_messages=>supplement_unknown
                                                                 severity = if_abap_behv_message=>severity-error )
            %path                 = VALUE #(
                zjosh_i_bookg_d-%tky  = booksuppl_booking_links[ KEY id
                                                                 source-%tky = <bookingsupplement>-%tky ]-target-%tky
                zjosh_i_travel_d-%tky = booksuppl_travel_links[  KEY id
                                                                source-%tky = <bookingsupplement>-%tky ]-target-%tky )
            %element-SupplementID = if_abap_behv=>mk-on )
               TO reported-zjosh_i_bsupp_d.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
