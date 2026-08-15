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
    METHODS acceptTravel FOR MODIFY
       keys FOR ACTION zjosh_i_travel_D~acceptTravel RESULT result.

    METHODS deductDiscount FOR MODIFY
       keys FOR ACTION zjosh_i_travel_D~deductDiscount RESULT result.

    METHODS recalcTotalPrice FOR MODIFY
       keys FOR ACTION zjosh_i_travel_D~recalcTotalPrice.

    METHODS rejectTravel FOR MODIFY
       keys FOR ACTION zjosh_i_travel_D~rejectTravel RESULT result.

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
             ID '/dmo/cntry' FIELD <ls_age_ctry>-country_code
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

  METHOD acceptTravel.


    "Modify travel instance
    MODIFY ENTITIES OF zjosh_i_travel_d IN LOCAL MODE
      ENTITY zjosh_i_travel_d
        UPDATE FIELDS (  OverallStatus )
        WITH VALUE #( FOR key IN keys ( %tky          = key-%tky
                                        OverallStatus = 'A' ) ).

    "Read changed data for action result
    READ ENTITIES OF zjosh_i_travel_d IN LOCAL MODE
      ENTITY zjosh_i_travel_d
        ALL FIELDS WITH
        CORRESPONDING #( keys )
      RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels ( %tky   = travel-%tky
                                              %param = travel ) ).


  ENDMETHOD.

  METHOD deductDiscount.


    DATA travels_for_update TYPE TABLE FOR UPDATE zjosh_i_travel_d.
    DATA(keys_with_valid_discount) = keys.

    LOOP AT keys_with_valid_discount ASSIGNING FIELD-SYMBOL(<key_with_valid_discount>) WHERE %param-discount_percent IS INITIAL
                                                        OR %param-discount_percent > 100
                                                        OR %param-discount_percent <= 0.

      APPEND VALUE #( %tky                       = <key_with_valid_discount>-%tky ) TO failed-zjosh_i_travel_d.

      APPEND VALUE #( %tky                       = <key_with_valid_discount>-%tky
                      %msg                       = NEW /dmo/cm_flight_messages(
                                                       textid = /dmo/cm_flight_messages=>discount_invalid
                                                       severity = if_abap_behv_message=>severity-error )
                      %element-bookingFee        = if_abap_behv=>mk-on
                      %action-deductDiscount = if_abap_behv=>mk-on
                    ) TO reported-zjosh_i_travel_d.

      DELETE keys_with_valid_discount.
    ENDLOOP.

    CHECK keys_with_valid_discount IS NOT INITIAL.

    "get total price
    READ ENTITIES OF zjosh_i_travel_d IN LOCAL MODE
      ENTITY zjosh_i_travel_d
        FIELDS ( BookingFee )
        WITH CORRESPONDING #( keys_with_valid_discount )
      RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      DATA percentage TYPE decfloat16.
      DATA(discount_percent) = keys_with_valid_discount[ KEY id  %tky = <travel>-%tky ]-%param-discount_percent.
      percentage =  discount_percent / 100 .
      DATA(reduced_fee) = <travel>-BookingFee - ( <travel>-BookingFee * percentage ).

      APPEND VALUE #( %tky       = <travel>-%tky
                      BookingFee = reduced_fee
                    ) TO travels_for_update.
    ENDLOOP.

    "update total price with reduced price
    MODIFY ENTITIES OF zjosh_i_travel_d  IN LOCAL MODE
      ENTITY zjosh_i_travel_d
       UPDATE FIELDS ( BookingFee )
       WITH travels_for_update.

    "Read changed data for action result
    READ ENTITIES OF zjosh_i_travel_d IN LOCAL MODE
      ENTITY zjosh_i_travel_d
        ALL FIELDS WITH
        CORRESPONDING #( travels )
      RESULT DATA(travels_with_discount).

    result = VALUE #( FOR travel IN travels_with_discount ( %tky   = travel-%tky
                                                            %param = travel ) ).


  ENDMETHOD.

  METHOD recalcTotalPrice.



    TYPES: BEGIN OF ty_amount_per_currencycode,
             amount        TYPE /dmo/total_price,
             currency_code TYPE /dmo/currency_code,
           END OF ty_amount_per_currencycode.

    DATA: amounts_per_currencycode TYPE STANDARD TABLE OF ty_amount_per_currencycode.

    " Read all relevant travel instances.
    READ ENTITIES OF zjosh_i_travel_d IN LOCAL MODE
         ENTITY zjosh_i_travel_d
            FIELDS ( BookingFee CurrencyCode )
            WITH CORRESPONDING #( keys )
         RESULT DATA(travels).

    DELETE travels WHERE CurrencyCode IS INITIAL.

    " Read all associated bookings and add them to the total price.
    READ ENTITIES OF zjosh_i_travel_d IN LOCAL MODE
      ENTITY zjosh_i_travel_d BY \_Booking
        FIELDS ( FlightPrice CurrencyCode )
      WITH CORRESPONDING #( travels )
      LINK DATA(booking_links)
      RESULT DATA(bookings).

    " Read all associated booking supplements and add them to the total price.
    READ ENTITIES OF zjosh_i_travel_d IN LOCAL MODE
      ENTITY zjosh_i_bookg_d BY \_BookingSupplement
        FIELDS ( BookSupplPrice CurrencyCode )
      WITH CORRESPONDING #( bookings )
      LINK DATA(bookingsupplement_links)
      RESULT DATA(bookingsupplements).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      " Set the start for the calculation by adding the booking fee.
      amounts_per_currencycode = VALUE #( ( amount        = <travel>-bookingfee
                                            currency_code = <travel>-currencycode ) ).

      LOOP AT booking_links INTO DATA(booking_link) USING KEY id WHERE source-%tky = <travel>-%tky.
        " Short dump occurs if link table does not match read table, which must never happen
        DATA(booking) = bookings[ KEY id  %tky = booking_link-target-%tky ].
        COLLECT VALUE ty_amount_per_currencycode( amount        = booking-flightprice
                                                  currency_code = booking-currencycode ) INTO amounts_per_currencycode.

        LOOP AT bookingsupplement_links INTO DATA(bookingsupplement_link) USING KEY id WHERE source-%tky = booking-%tky.
          DATA(bookingsupplement) = bookingsupplements[ KEY id  %tky = bookingsupplement_link-target-%tky ].
          COLLECT VALUE ty_amount_per_currencycode( amount        = bookingsupplement-booksupplprice
                                                    currency_code = bookingsupplement-currencycode ) INTO amounts_per_currencycode.
        ENDLOOP.
      ENDLOOP.

      DELETE amounts_per_currencycode WHERE currency_code IS INITIAL.

      CLEAR <travel>-TotalPrice.
      LOOP AT amounts_per_currencycode INTO DATA(amount_per_currencycode).
        " If needed do a Currency Conversion
        IF amount_per_currencycode-currency_code = <travel>-CurrencyCode.
          <travel>-TotalPrice += amount_per_currencycode-amount.
        ELSE.
            /DMO/CL_FLIGHT_AMDP=>convert_currency(
             EXPORTING
               iv_amount                   =  amount_per_currencycode-amount
               iv_currency_code_source     =  amount_per_currencycode-currency_code
               iv_currency_code_target     =  <travel>-CurrencyCode
               iv_exchange_rate_date       =  cl_abap_context_info=>get_system_date( )
             IMPORTING
               ev_amount                   = DATA(total_booking_price_per_curr)
            ).
          <travel>-TotalPrice += total_booking_price_per_curr.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    " write back the modified total_price of travels
    MODIFY ENTITIES OF zjosh_i_travel_d IN LOCAL MODE
      ENTITY zjosh_i_travel_d
        UPDATE FIELDS ( TotalPrice )
        WITH CORRESPONDING #( travels ).



  ENDMETHOD.

  METHOD rejectTravel.


    "Modify travel instance
    MODIFY ENTITIES OF zjosh_i_travel_d IN LOCAL MODE
      ENTITY zjosh_i_travel_d
        UPDATE FIELDS (  OverallStatus )
        WITH VALUE #( FOR key IN keys ( %tky          = key-%tky
                                        OverallStatus = 'X' ) ).

    "Read changed data for action result
    READ ENTITIES OF zjosh_i_travel_d IN LOCAL MODE
      ENTITY zjosh_i_travel_d
        ALL FIELDS WITH
        CORRESPONDING #( keys )
      RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels ( %tky   = travel-%tky
                                              %param = travel ) ).

  ENDMETHOD.

ENDCLASS.
