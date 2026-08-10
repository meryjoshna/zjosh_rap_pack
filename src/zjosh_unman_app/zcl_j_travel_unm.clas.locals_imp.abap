CLASS lhc_zjosh_i_travel_un DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zjosh_i_travel_un RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zjosh_i_travel_un RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE zjosh_i_travel_un.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zjosh_i_travel_un.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zjosh_i_travel_un.

    METHODS read FOR READ
      IMPORTING keys FOR READ zjosh_i_travel_un RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zjosh_i_travel_un.

    METHODS rba_Booking FOR READ
      IMPORTING keys_rba FOR READ zjosh_i_travel_un\_Booking FULL result_requested RESULT result LINK association_links.

    METHODS cba_Booking FOR MODIFY
      IMPORTING entities_cba FOR CREATE zjosh_i_travel_un\_Booking.

    TYPES : tt_failed   TYPE TABLE FOR FAILED EARLY zjosh_i_travel_un,
            tt_reported TYPE TABLE FOR REPORTED EARLY zjosh_i_travel_un.
    METHODS map_messages
      IMPORTING
        cid          TYPE abp_behv_cid OPTIONAL
        travelid     TYPE /dmo/travel_id OPTIONAL
        messages     TYPE /dmo/t_message
      EXPORTING
        failed_added TYPE abap_boolean
      CHANGING
        failed       TYPE tt_failed
        reported     TYPE tt_reported.

    TYPES :   tt_bookg_failed  type table for failed early zjosh_i_bookg_u,
              tt_bookg_reported  type table for reported early zjosh_i_bookg_u.

    METHODS map_messages_assoc_to_booking
      IMPORTING
        cid          TYPE string
        is_dependend TYPE abap_bool  default abap_false
        messages     TYPE /dmo/t_message
       exporting
         failed_added TYPE abap_bool
      CHANGING
        failed       TYPE tt_bookg_failed
        reported     TYPE tt_bookg_reported.

ENDCLASS.

CLASS lhc_zjosh_i_travel_un IMPLEMENTATION.

  METHOD get_instance_features.

     read ENTITIES of zjosh_i_travel_un in LOCAL mode
       entity zjosh_i_travel_un
         fields ( travelid Status )
         with CORRESPONDING #( keys )
         result data(lt_travels)
         FAILED failed.

         result = value #( for ls_travel in lt_travels (

                        %tky = ls_travel-%tky
                        %assoc-_Booking = cond #( when ls_travel-Status = 'B' or ls_travel-Status = 'X'
                                                  then if_abap_behv=>fc-o-disabled else if_abap_behv=>fc-o-enabled  )

                           ) ).




  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD create.


    DATA : ls_travel_in  TYPE /dmo/travel,
           ls_travel_out TYPE /dmo/travel,
           lt_messages   TYPE /dmo/t_message.

    LOOP AT entities INTO DATA(ls_entity).

      ls_Travel_in = CORRESPONDING #( ls_entity MAPPING FROM ENTITY USING CONTROL ).
      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_CREATE'
        EXPORTING
          is_travel         = CORRESPONDING /dmo/s_travel_in( ls_travel_in )
*         it_booking        =
*         it_booking_supplement =
          iv_numbering_mode = /dmo/if_flight_legacy=>numbering_mode-late
        IMPORTING
          es_travel         = ls_travel_out
*         et_booking        =
*         et_booking_supplement =
          et_messages       = lt_messages.

      map_messages(

        EXPORTING
          cid = ls_entity-%cid
          messages = lt_messages
        IMPORTING
         failed_Added = DATA(lv_failed_added)
        CHANGING
          failed = failed-zjosh_i_travel_un
          reported = reported-zjosh_i_travel_un

        ).

      IF lv_failed_added = abap_false.
        INSERT VALUE #(  %cid = ls_entity-%cid
                          travelid = ls_travel_out-travel_id
                      ) INTO TABLE mapped-zjosh_i_travel_un.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD update.

    DATA: ls_travel_in TYPE /dmo/travel,
          ls_travelx   TYPE /dmo/s_travel_inx,
          lt_messages  TYPE /dmo/t_message.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_travel_upd>).

      ls_travel_in = CORRESPONDING #( <ls_travel_upd> MAPPING FROM ENTITY ).

      ls_travelx-travel_id = <ls_travel_upd>-TravelID.
      ls_travelx-_intx = CORRESPONDING #( <ls_travel_upd> MAPPING FROM ENTITY ).


      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
        EXPORTING
          is_travel   = CORRESPONDING /dmo/s_travel_in( ls_travel_in )
          is_travelx  = ls_travelx
        IMPORTING
          et_messages = lt_messages.

      map_messages(
          EXPORTING
            cid       = <ls_travel_upd>-%cid_ref
            travelid = <ls_travel_upd>-travelid
            messages  = lt_messages
          CHANGING
            failed    = failed-zjosh_i_travel_un
            reported  = reported-zjosh_i_travel_un
        ).

    ENDLOOP.
  ENDMETHOD.

  METHOD delete.


    DATA: lt_messages TYPE /dmo/t_message.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<travel_delete>).

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_DELETE'
        EXPORTING
          iv_travel_id = <travel_delete>-travelid
        IMPORTING
          et_messages  = lt_messages.

      map_messages(
          EXPORTING
            cid       = <travel_delete>-%cid_ref
            travelid = <travel_delete>-travelid
            messages  = lt_messages
          CHANGING
            failed    = failed-zjosh_i_travel_un
            reported  = reported-zjosh_i_travel_un
        ).

    ENDLOOP.




  ENDMETHOD.

  METHOD read.


    DATA: ls_travel_out TYPE /dmo/travel,
          lt_messages   TYPE /dmo/t_message.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_travel_to_read>) GROUP BY <ls_travel_to_read>-%tky.

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = <ls_travel_to_read>-travelid
        IMPORTING
          es_travel    = ls_travel_out
          et_messages  = lt_messages.

      map_messages(
          EXPORTING
            travelid        = <ls_travel_to_read>-TravelID
            messages         = lt_messages
            IMPORTING
            failed_added = DATA(failed_added)
          CHANGING
            failed           = failed-zjosh_i_travel_un
            reported         = reported-zjosh_i_travel_un
        ).

      IF failed_added = abap_false.
        INSERT CORRESPONDING #( ls_travel_out MAPPING TO ENTITY ) INTO TABLE result.
      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD lock.


    TRY.
        "Instantiate lock object
        DATA(lr_lock) = cl_abap_lock_object_factory=>get_instance( iv_name = '/DMO/ETRAVEL' ).
      CATCH cx_abap_lock_failure INTO DATA(exception).
        RAISE SHORTDUMP exception.
    ENDTRY.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<travel>).
      TRY.
          "enqueue travel instance
          lr_lock->enqueue(
              it_parameter  = VALUE #( (  name = 'TRAVEL_ID' value = REF #( <travel>-travelid ) ) )
          ).
          "if foreign lock exists
        CATCH cx_abap_foreign_lock INTO DATA(foreign_lock).
          map_messages(
           EXPORTING
                travelid = <travel>-TravelID
                messages  =  VALUE #( (
                                           msgid = '/DMO/CM_FLIGHT_LEGAC'
                                           msgty = 'E'
                                           msgno = '032'
                                           msgv1 = <travel>-travelid
                                           msgv2 = foreign_lock->user_name )
                          )
              CHANGING
                failed    = failed-zjosh_i_travel_un
                reported  = reported-zjosh_i_travel_un
            ).

        CATCH cx_abap_lock_failure INTO exception.
          RAISE SHORTDUMP exception.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD rba_Booking.



    DATA: travel_out  TYPE /dmo/travel,
          booking_out TYPE /dmo/t_booking,
          booking     LIKE LINE OF result,
          messages    TYPE /dmo/t_message.


    LOOP AT keys_rba ASSIGNING FIELD-SYMBOL(<travel_rba>) GROUP BY <travel_rba>-TravelID.

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = <travel_rba>-travelid
        IMPORTING
          es_travel    = travel_out
          et_booking   = booking_out
          et_messages  = messages.

      map_messages(
          EXPORTING
            travelid        = <travel_rba>-TravelID
            messages         = messages
            IMPORTING
            failed_added = DATA(failed_added)
          CHANGING
            failed           = failed-zjosh_i_travel_un
            reported         = reported-zjosh_i_travel_un
        ).

      IF failed_added = abap_false.
        LOOP AT booking_out ASSIGNING FIELD-SYMBOL(<booking>).
          "fill link table with key fields

          INSERT
            VALUE #(
              source-%tky = <travel_rba>-%tky
              target-%tky = VALUE #(
                                TravelID  = <booking>-travel_id
                                BookingID = <booking>-booking_id
              ) )
            INTO TABLE association_links.

          IF result_requested = abap_true.
            booking = CORRESPONDING #( <booking> MAPPING TO ENTITY ).
            INSERT booking INTO TABLE result.
          ENDIF.

        ENDLOOP.
      ENDIF.

    ENDLOOP.

    SORT association_links BY target ASCENDING.
    DELETE ADJACENT DUPLICATES FROM association_links COMPARING ALL FIELDS.

    SORT result BY %tky ASCENDING.
    DELETE ADJACENT DUPLICATES FROM result COMPARING ALL FIELDS.



  ENDMETHOD.

  METHOD cba_Booking.

     DATA: lt_messages        TYPE /dmo/t_message,
          booking_old     TYPE /dmo/t_booking,
          booking         TYPE /dmo/booking,
          last_booking_id TYPE /dmo/booking_id VALUE '0'.

    LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<travel>).

      DATA(travelid) = <travel>-travelid.

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = travelid
        IMPORTING
          et_booking   = booking_old
          et_messages  = lt_messages.

      map_messages(
          EXPORTING
            cid       = <travel>-%cid_ref
            travelid = <travel>-TravelID
            messages  = lt_messages
          IMPORTING
            failed_added = DATA(failed_added)
          CHANGING
            failed           = failed-zjosh_i_travel_un
            reported         = reported-zjosh_i_travel_un
        ).

      IF failed_added = abap_true.
        LOOP AT <travel>-%target ASSIGNING FIELD-SYMBOL(<booking>).
          map_messages_assoc_to_booking(
            EXPORTING
              cid          = <booking>-%cid
              is_dependend = abap_true
              messages     =  lt_messages
            CHANGING
              failed       = failed-zjosh_i_bookg_u
              reported     = reported-zjosh_i_bookg_u
          ).
        ENDLOOP.

      ELSE.

        " Set the last_booking_id to the highest value of booking_old booking_id or initial value if none exist
        last_booking_id = VALUE #( booking_old[ lines( booking_old ) ]-booking_id OPTIONAL ).

        LOOP AT <travel>-%target ASSIGNING FIELD-SYMBOL(<booking_create>).

          booking = CORRESPONDING #( <booking_create> MAPPING FROM ENTITY USING CONTROL ) .

          last_booking_id += 1.
          booking-booking_id = last_booking_id.

          CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
            EXPORTING
              is_travel   = VALUE /dmo/s_travel_in( travel_id = travelid )
              is_travelx  = VALUE /dmo/s_travel_inx( travel_id = travelid )
              it_booking  = VALUE /dmo/t_booking_in( ( CORRESPONDING #( booking ) ) )
              it_bookingx = VALUE /dmo/t_booking_inx(
                (
                  booking_id  = booking-booking_id
                  action_code = /dmo/if_flight_legacy=>action_code-create
                )
              )
            IMPORTING
              et_messages = lt_messages.

          map_messages_assoc_to_booking(
              EXPORTING
                cid              =  <booking_create>-%cid
                messages         = lt_messages
                IMPORTING
                failed_added = failed_added
              CHANGING
                failed           = failed-zjosh_i_bookg_u
                reported         = reported-zjosh_i_bookg_u
            ).

          IF failed_added = abap_false.
            INSERT
              VALUE #(
                %cid      = <booking_create>-%cid
                travelid  = travelid
                bookingid = booking-booking_id
              ) INTO TABLE mapped-zjosh_i_bookg_u.
          ENDIF.

        ENDLOOP.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD map_messages.

    failed_added = abap_false.
    LOOP AT messages INTO DATA(ls_message).

      IF ls_message-msgty = 'E' OR ls_message-msgty = 'A'.

        APPEND VALUE #(  %cid = cid
                         travelid = travelid
                        %fail-cause = zcl_j_travel_aux=>get_cause_from_message(
                                        msgid        = ls_message-msgid
                                        msgno        = ls_message-msgno
*                                          is_dependend = abap_false
                                      )
                      ) TO failed.
        failed_added = abap_true.

      ENDIF.

      reported = VALUE #( ( %cid = cid
                            travelid = travelid
                            %msg = new_message(
                                     id       = ls_message-msgid
                                     number   = ls_message-msgno
                                     severity = if_abap_behv_message=>severity-error
                                     v1       = ls_message-msgv1
                                     v2       = ls_message-msgv2
                                     v3       = ls_message-msgv3
                                     v4       = ls_message-msgv4
                                   ) ) ) .


    ENDLOOP.

  ENDMETHOD.


  METHOD map_messages_assoc_to_booking.

   assert cid is NOT initial.
   failed_added = abap_false.
    LOOP AT messages INTO DATA(ls_message).

      IF ls_message-msgty = 'E' OR ls_message-msgty = 'A'.

        APPEND VALUE #(  %cid = cid
                        %fail-cause = zcl_j_travel_aux=>get_cause_from_message(
                                        msgid        = ls_message-msgid
                                        msgno        = ls_message-msgno
                                        is_dependend = is_dependend
                                      )
                      ) TO failed.
        failed_added = abap_true.

      ENDIF.

      reported = VALUE #( ( %cid = cid

                            %msg = new_message(
                                     id       = ls_message-msgid
                                     number   = ls_message-msgno
                                     severity = if_abap_behv_message=>severity-error
                                     v1       = ls_message-msgv1
                                     v2       = ls_message-msgv2
                                     v3       = ls_message-msgv3
                                     v4       = ls_message-msgv4
                                   ) ) ) .


    ENDLOOP.


  ENDMETHOD.

ENDCLASS.
