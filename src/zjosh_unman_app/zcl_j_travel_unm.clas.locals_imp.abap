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

ENDCLASS.

CLASS lhc_zjosh_i_travel_un IMPLEMENTATION.

  METHOD get_instance_features.
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
  ENDMETHOD.

  METHOD cba_Booking.
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

ENDCLASS.
