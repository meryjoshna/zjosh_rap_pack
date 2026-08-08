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
        cid          TYPE abp_behv_cid
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
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
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
                        %fail-cause = zcl_j_travel_aux=>get_cause_from_message(
                                        msgid        = ls_message-msgid
                                        msgno        = ls_message-msgno
*                                          is_dependend = abap_false
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
