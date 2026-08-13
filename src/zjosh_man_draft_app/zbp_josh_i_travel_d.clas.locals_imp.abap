CLASS lhc_zjosh_i_travel_D DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zjosh_i_travel_D RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zjosh_i_travel_D RESULT result.
    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE zjosh_i_travel_D.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE zjosh_i_travel_D.

ENDCLASS.

CLASS lhc_zjosh_i_travel_D IMPLEMENTATION.

  METHOD get_instance_authorizations.

*    DATA: lv_update TYPE abp_behv_auth,
*          lv_delete TYPE abp_behv_auth.
*
*
*
*
*    READ ENTITIES OF zjosh_i_travel_D IN LOCAL MODE
*       ENTITY zjosh_i_travel_D
*       FIELDS ( AgencyID )
*       WITH CORRESPONDING #( keys )
*       RESULT DATA(lt_travels)
*       FAILED failed.
*
*    CHECK lt_travels IS NOT INITIAL.
*
*
*    SELECT FROM zjosh_a_travel_t AS a
*      INNER JOIN /dmo/agency AS b
*      ON a~agency_id = b~agency_id
*      FIELDS a~travel_uuid, a~agency_id, b~country_code
*      FOR ALL ENTRIES IN @lt_Travels
*      WHERE a~travel_uuid = @lt_travels-TravelUUID
*      INTO TABLE @DATA(lt_age_ctry).
*
*    LOOP AT lt_travels INTO DATA(ls_travels).
*
**           data(ls_age_ctry) = lt_age_ctry[ travel_uuid = ls_travels-TravelUUID ].
*
*      READ TABLE lt_age_ctry ASSIGNING FIELD-SYMBOL(<ls_age_ctry>)
*      WITH KEY travel_uuid = ls_travels-TravelUUID.
*
*      IF sy-subrc IS INITIAL.
*
*        IF requested_authorizations-%update = if_abap_behv=>mk-on.
*
*          AUTHORITY-CHECK OBJECT '/DMO/TRVL'
*             ID '/dmo/cntry' FIELD <ls_age_ctry>-country_code
*             ID 'ACTVT' FIELD '02'.
*
**          append VALUE #(  TravelUUID = ls_travels-TravelUUID
**                              %update = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
**                                ELSE if_abap_behv=>auth-unauthorized )
**                               ) to result.
*          lv_update = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
*                                ELSE if_Abap_behv=>auth-unauthorized ).
*
*          APPEND VALUE #(  %tky = ls_travels-%tky
*                           %msg = NEW /dmo/cm_flight_messages(
*                                     textid = /dmo/cm_flight_messages=>not_authorized_for_agencyid
*                                     agency_id = ls_travels-AgencyID
*                                     severity = if_abap_behv_message=>severity-error
*                                              )
*                           %element-agencyid = if_abap_behv=>mk-on
*                            ) TO reported-zjosh_i_travel_d.
*
*        ENDIF.
*
*        IF requested_authorizations-%delete = if_abap_behv=>mk-on.
*
*          AUTHORITY-CHECK OBJECT '/DMO/TRVL'
*             ID '/dmo/cntry' FIELD <ls_age_ctry>-country_code
*             ID 'ACTVT' FIELD '06'.
*
**          append VALUE #(  TravelUUID = ls_travels-TravelUUID
**                                 %delete = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
**                                   ELSE if_abap_behv=>auth-unauthorized )
**                                  ) to result.
*
*          lv_delete = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
*                                  ELSE if_Abap_behv=>auth-unauthorized ).
*
*          APPEND VALUE #(  %tky = ls_travels-%tky
*                             %msg = NEW /dmo/cm_flight_messages(
*                                       textid = /dmo/cm_flight_messages=>not_authorized_for_agencyid
*                                       agency_id = ls_travels-AgencyID
*                                       severity = if_abap_behv_message=>severity-error
*                                                )
*                             %element-agencyid = if_abap_behv=>mk-on
*                              ) TO reported-zjosh_i_travel_d.
*        ENDIF.
*
*      ELSE.
*
**         for create [full bo]
*      ENDIF.
*
*      APPEND VALUE #(  TravelUUID = ls_travels-TravelUUID
*                        %update   = lv_update
*                        %delete   = lv_delete
*                                 ) TO result.
*      CLEAR: lv_update,
*             lv_delete.
*
*    ENDLOOP.

  ENDMETHOD.

  METHOD get_global_authorizations.
    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      AUTHORITY-CHECK OBJECT '/DMO/TRVL'
         ID '/dmo/cntry' DUMMY
         ID 'ACTVT' FIELD '01'.

      result-%create = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                   ELSE if_abap_behv=>auth-unauthorized ).
    ENDIF.

    IF requested_authorizations-%update = if_abap_behv=>mk-on.

      AUTHORITY-CHECK OBJECT '/DMO/TRVL'
         ID '/dmo/cntry' DUMMY
         ID 'ACTVT' FIELD '02'.

      result-%update = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                   ELSE if_abap_behv=>auth-unauthorized ).
    ENDIF.

    IF requested_authorizations-%delete = if_abap_behv=>mk-on.

      AUTHORITY-CHECK OBJECT '/DMO/TRVL'
         ID '/dmo/cntry' DUMMY
         ID 'ACTVT' FIELD '06'.

      result-%delete = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                   ELSE if_abap_behv=>auth-unauthorized ).
    ENDIF.
  ENDMETHOD.

  METHOD precheck_create.
  ENDMETHOD.

  METHOD precheck_update.

    DATA : lt_agency TYPE SORTED TABLE OF /dmo/agency WITH UNIQUE KEY agency_id.

    lt_agency = CORRESPONDING #( entities DISCARDING DUPLICATES MAPPING agency_id = AgencyID EXCEPT * ).

    CHECK lt_agency IS NOT INITIAL.

    SELECT FROM /dmo/agency
      FIELDS agency_id, country_code
      FOR ALL ENTRIES IN @lt_agency
      WHERE agency_id = @lt_agency-agency_id
      INTO TABLE @DATA(lt_age_ctry).


    IF sy-subrc IS INITIAL.

      LOOP AT entities INTO DATA(ls_entity).

        READ TABLE lt_age_ctry ASSIGNING FIELD-SYMBOL(<ls_age_ctry>)
           WITH KEY agency_id = ls_entity-AgencyID.

        AUTHORITY-CHECK OBJECT '/DMO/TRVL'
             ID '/dmo/cntry' field <ls_age_ctry>-country_code
             ID 'ACTVT' FIELD '02'.

        IF sy-subrc  IS NOT INITIAL.

          failed-zjosh_i_travel_d = VALUE #( ( %tky = ls_entity-%tky ) ).

          APPEND VALUE #( %tky = ls_entity-%tky
                          %msg = NEW /dmo/cm_flight_messages(

                                           textid = /dmo/cm_flight_messages=>not_authorized_for_agencyid
                                           agency_id = ls_entity-AgencyID
                                           severity = if_abap_behv_message=>severity-error
                                          )

                         %element-agencyid = if_abap_behv=>mk-on

             ) TO reported-zjosh_i_travel_d.
        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.

ENDCLASS.
