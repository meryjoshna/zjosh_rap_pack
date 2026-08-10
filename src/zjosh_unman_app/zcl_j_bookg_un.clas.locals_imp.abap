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


    TYPES : tt_bookg_failed TYPE table for failed zjosh_i_bookg_u,
            tt_bookg_reported type table for reported zjosh_i_bookg_u.

    METHODS map_messages
      IMPORTING
        cid        TYPE string optional
        travelid   TYPE /dmo/travel_id optional
        booking_id TYPE /dmo/booking_id optional
        messages   TYPE /dmo/t_message
      exporting
         failed_added type abap_bool
      CHANGING
        failed     TYPE tt_bookg_failed
        reported   TYPE tt_bookg_reported.

ENDCLASS.

CLASS lhc_zjosh_i_bookg_u IMPLEMENTATION.

  METHOD update.

    DATA messages TYPE /dmo/t_message.
    DATA booking  TYPE /dmo/booking.
    DATA bookingx TYPE /dmo/s_booking_inx.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<booking>).

      booking = CORRESPONDING #( <booking> MAPPING FROM ENTITY ).

      bookingx-booking_id  = <booking>-BookingID.
      bookingx-_intx       = CORRESPONDING #( <booking> MAPPING FROM ENTITY ).
      bookingx-action_code = /dmo/if_flight_legacy=>action_code-update.

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
        EXPORTING
          is_travel   = VALUE /dmo/s_travel_in( travel_id = <booking>-travelid )
          is_travelx  = VALUE /dmo/s_travel_inx( travel_id = <booking>-travelid )
          it_booking  = VALUE /dmo/t_booking_in( ( CORRESPONDING #( booking ) ) )
          it_bookingx = VALUE /dmo/t_booking_inx( ( bookingx ) )
        IMPORTING
          et_messages = messages.


      map_messages(

         exporting
           cid =  <booking>-%cid_ref
           travelid = <booking>-TravelID
           booking_id  = <booking>-BookingID
           messages = messages

           changing
             failed = failed-zjosh_i_bookg_u
             reported = reported-zjosh_i_bookg_u  ).



    ENDLOOP.

  ENDMETHOD.

  METHOD delete.

     DATA messages TYPE /dmo/t_message.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<booking>).

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
        EXPORTING
          is_travel   = VALUE /dmo/s_travel_in( travel_id = <booking>-travelid )
          is_travelx  = VALUE /dmo/s_travel_inx( travel_id = <booking>-travelid )
          it_booking  = VALUE /dmo/t_booking_in( ( booking_id = <booking>-bookingid ) )
          it_bookingx = VALUE /dmo/t_booking_inx( ( booking_id  = <booking>-bookingid
                                                    action_code = /dmo/if_flight_legacy=>action_code-delete ) )
        IMPORTING
          et_messages = messages.

      map_messages(
        EXPORTING
          cid        = <booking>-%cid_ref
          travelid  = <booking>-travelid
          booking_id = <booking>-bookingid
          messages   = messages
        CHANGING
          failed   = failed-zjosh_i_bookg_u
          reported = reported-zjosh_i_bookg_u ).

    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    DATA: travel_out   TYPE /dmo/travel,
          bookings_out TYPE /dmo/t_booking,
          messages     TYPE /dmo/t_message.

    "Only one function call for each requested travelid
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<booking_by_travel>)
                               GROUP BY <booking_by_travel>-travelid .

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = <booking_by_travel>-travelid
        IMPORTING
          es_travel    = travel_out
          et_booking   = bookings_out
          et_messages  = messages.

      map_messages(
        EXPORTING
          travelid  = <booking_by_travel>-travelid
          booking_id = <booking_by_travel>-bookingid
          messages   = messages
        IMPORTING
          failed_added = DATA(failed_added)
        CHANGING
          failed   = failed-zjosh_i_bookg_u
          reported = reported-zjosh_i_bookg_u ).


      IF failed_added = abap_false.
        "For each travelID find the requested bookings
        LOOP AT GROUP <booking_by_travel> ASSIGNING FIELD-SYMBOL(<booking>)
                                          GROUP BY <booking>-%tky.

          READ TABLE bookings_out INTO DATA(booking_out) WITH KEY travel_id  = <booking>-%key-TravelID
                                                                  booking_id = <booking>-%key-BookingID .
          "if read was successful
          IF sy-subrc = 0.
            INSERT CORRESPONDING #( booking_out MAPPING TO ENTITY ) INTO TABLE result.
          ELSE.
            "BookingID not found
            INSERT VALUE #( travelid    = <booking>-TravelID
                            bookingid   = <booking>-BookingID
                            %fail-cause = if_abap_behv=>cause-not_found )
              INTO TABLE failed-zjosh_i_bookg_u.
          ENDIF.
        ENDLOOP.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD rba_Travel.

     DATA: travel   TYPE /dmo/travel,
          messages TYPE /dmo/t_message.

    "Only one function call for each requested travelid
    LOOP AT keys_rba ASSIGNING FIELD-SYMBOL(<booking_by_travel>)
                               GROUP BY <booking_by_travel>-travelid .

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = <booking_by_travel>-travelid
        IMPORTING
          es_travel    = travel
          et_messages  = messages.

      map_messages(
        EXPORTING
          travelid  = <booking_by_travel>-travelid
          booking_id = <booking_by_travel>-bookingid
          messages   = messages
        IMPORTING
          failed_added = DATA(failed_added)
        CHANGING
          failed   = failed-zjosh_i_bookg_u
          reported = reported-zjosh_i_bookg_u ).


      IF failed_added = abap_false.
        LOOP AT keys_rba ASSIGNING FIELD-SYMBOL(<travel>) USING KEY entity WHERE TravelID = <booking_by_travel>-TravelID.
          INSERT VALUE #(
              source-%tky     = <travel>-%tky
              target-travelid = <travel>-TravelID
            ) INTO TABLE association_links.

          IF result_requested = abap_true.
            APPEND CORRESPONDING #( travel MAPPING TO ENTITY ) TO result.
          ENDIF.
        ENDLOOP.
      ENDIF.

    ENDLOOP.

    SORT association_links BY source ASCENDING.
    DELETE ADJACENT DUPLICATES FROM association_links COMPARING ALL FIELDS.

    SORT result BY %tky ASCENDING.
    DELETE ADJACENT DUPLICATES FROM result COMPARING ALL FIELDS.
  ENDMETHOD.


  METHOD map_messages.

  failed_added = abap_false.

  LOOP at messages into data(message).
   if message-msgty = 'E' or message-msgty = 'A'.
      APPEND value #( %cid = cid
                      travelid = travelid
                      bookingid = booking_id
                      %fail-cause = zcl_j_travel_aux=>get_cause_from_message(
                                      msgid        = message-msgid
                                      msgno        = message-msgno
*                                      is_dependend = abap_false
                                    ) ) to failed.
             failed_added = abap_true.

     endif.

     append value #(  %cid = cid
                        travelid = travelid
                        bookingid = booking_id
                            %msg = new_message(
                                     id       = message-msgid
                                     number   = message-msgno
                                     severity = if_abap_behv_message=>severity-error
                                     v1       = message-msgv1
                                     v2       = message-msgv2
                                     v3       = message-msgv3
                                     v4       = message-msgv4
                                   ) )   to reported.


      endloop.

  ENDMETHOD.

ENDCLASS.
