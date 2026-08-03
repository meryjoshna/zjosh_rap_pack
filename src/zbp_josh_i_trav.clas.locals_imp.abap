CLASS lhc_zjosh_i_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zjosh_i_travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zjosh_i_travel RESULT result.
    METHODS accepttravel FOR MODIFY
      IMPORTING keys FOR ACTION zjosh_i_travel~accepttravel RESULT result.

    METHODS copytravel FOR MODIFY
      IMPORTING keys FOR ACTION zjosh_i_travel~copytravel.

    METHODS recalctolprice FOR MODIFY
      IMPORTING keys FOR ACTION zjosh_i_travel~recalctolprice.

    METHODS rejecttravel FOR MODIFY
      IMPORTING keys FOR ACTION zjosh_i_travel~rejecttravel RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zjosh_i_travel RESULT result.
    METHODS validatecustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR zjosh_i_travel~validatecustomer.
    METHODS validatebookingfee FOR VALIDATE ON SAVE
      IMPORTING keys FOR zjosh_i_travel~validatebookingfee.

    METHODS validatecurrencycode FOR VALIDATE ON SAVE
      IMPORTING keys FOR zjosh_i_travel~validatecurrencycode.

    METHODS validatedates FOR VALIDATE ON SAVE
      IMPORTING keys FOR zjosh_i_travel~validatedates.

    METHODS validatestatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR zjosh_i_travel~validatestatus.
    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zjosh_i_travel~calculatetotalprice.
    METHODS earlynumbering_cba_booking FOR NUMBERING
      IMPORTING entities FOR CREATE zjosh_i_travel\_booking.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE zjosh_i_travel.

ENDCLASS.

CLASS lhc_zjosh_i_travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.

    DATA:
      entity        TYPE STRUCTURE FOR CREATE zjosh_i_travel.


    " Ensure Travel ID is not set yet (idempotent)- must be checked when BO is draft-enabled
    LOOP AT entities INTO entity WHERE TravelId IS NOT INITIAL.
      APPEND CORRESPONDING #( entity ) TO mapped-zjosh_i_travel.
    ENDLOOP.

    DATA(entities_wo_travelid) = entities.
    DELETE entities_wo_travelid WHERE TravelId IS NOT INITIAL.

    " Get Numbers
    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '01'
            object            = '/DMO/TRV_M'
            quantity          = CONV #( lines( entities_wo_travelid ) )
          IMPORTING
            number            = DATA(number_range_key)
            returncode        = DATA(number_range_return_code)
            returned_quantity = DATA(number_range_returned_quantity)
        ).
      CATCH cx_number_ranges INTO DATA(lx_number_ranges).
        LOOP AT entities_wo_travelid INTO entity.
          APPEND VALUE #(  %cid = entity-%cid
                           %key = entity-%key
                           %msg = lx_number_ranges
                        ) TO reported-zjosh_i_travel.
          APPEND VALUE #(  %cid = entity-%cid
                           %key = entity-%key
                        ) TO failed-zjosh_i_travel.
        ENDLOOP.
        EXIT.
    ENDTRY.

    CASE number_range_return_code.
      WHEN '1'.
        " 1 - the returned number is in a critical range (specified under “percentage warning” in the object definition)
        LOOP AT entities_wo_travelid INTO entity.
          APPEND VALUE #( %cid = entity-%cid
                          %key = entity-%key
                          %msg = NEW /dmo/cm_flight_messages(
                                      textid = /dmo/cm_flight_messages=>number_range_depleted
                                      severity = if_abap_behv_message=>severity-warning )
                        ) TO reported-zjosh_i_travel.
        ENDLOOP.

      WHEN '2' OR '3'.
        " 2 - the last number of the interval was returned
        " 3 - if fewer numbers are available than requested,  the return code is 3
        LOOP AT entities_wo_travelid INTO entity.
          APPEND VALUE #( %cid = entity-%cid
                          %key = entity-%key
                          %msg = NEW /dmo/cm_flight_messages(
                                      textid = /dmo/cm_flight_messages=>not_sufficient_numbers
                                      severity = if_abap_behv_message=>severity-warning )
                        ) TO reported-zjosh_i_travel.
          APPEND VALUE #( %cid        = entity-%cid
                          %key        = entity-%key
                          %fail-cause = if_abap_behv=>cause-conflict
                        ) TO failed-zjosh_i_travel.
        ENDLOOP.
        EXIT.
    ENDCASE.

    " At this point ALL entities get a number!
    ASSERT number_range_returned_quantity = lines( entities_wo_travelid ).

    DATA(travel_id_max) = number_range_key - number_range_returned_quantity.

    " Set Travel ID
    LOOP AT entities_wo_travelid INTO entity.
      travel_id_max += 1.
      entity-TravelId = travel_id_max .

      APPEND VALUE #( %cid  = entity-%cid
                      %key  = entity-%key
                    ) TO mapped-zjosh_i_travel.
    ENDLOOP.


  ENDMETHOD.

  METHOD earlynumbering_cba_Booking.

    DATA : lv_max_book_id TYPE /dmo/booking_id.

    READ ENTITIES OF zjosh_i_travel IN LOCAL MODE
      ENTITY zjosh_i_travel BY \_booking
      FROM CORRESPONDING #( entities )
      LINK DATA(bookings).



    LOOP AT entities ASSIGNING FIELD-SYMBOL(<travel>) GROUP BY <travel>-TravelId.

      lv_max_book_id = REDUCE #( INIT lv_max = CONV /dmo/booking_id( '0' )
                              FOR booking IN bookings USING KEY entity
                                WHERE ( source-TravelId = <travel>-TravelId )
                                NEXT lv_max = COND /dmo/booking_id( WHEN booking-target-BookingId > lv_max
                                                                    THEN booking-target-BookingId
                                                                    ELSE lv_max  ) ).

      lv_max_book_id  = REDUCE #( INIT lv_max = lv_max_book_id
                                  FOR entity IN entities USING KEY entity WHERE ( Travelid =  <travel>-TravelId )
                                   FOR target IN entity-%target
                                   NEXT lv_max = COND  /dmo/booking_id( WHEN target-BookingId > lv_max
                                                                        THEN  target-BookingId
                                                                        ELSE lv_max ) ).

      LOOP AT <travel>-%target ASSIGNING FIELD-SYMBOL(<booking_wo_numbers>).
        APPEND CORRESPONDING #( <booking_wo_numbers> ) TO mapped-zjosh_i_bookg ASSIGNING FIELD-SYMBOL(<mapped_book>).
        IF  <booking_wo_numbers>-BookingId IS INITIAL.
          lv_max_book_id  += 10.
          <mapped_book>-BookingId = lv_max_book_id.
        ENDIF.
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD acceptTravel.


    MODIFY ENTITIES OF zjosh_i_travel IN LOCAL MODE
    ENTITY zjosh_i_travel
    UPDATE FIELDS ( overallstatus )
    WITH VALUE #( FOR ls_key IN keys (
                     %tky = ls_key-%tky
                     overallstatus = 'A' ) ).

*the above same in old syntax
*    DATA lt_update TYPE TABLE FOR UPDATE /DMO/I_Travel_M.

*LOOP AT keys INTO DATA(ls_key).
*
*  APPEND VALUE #(
*      %tky = ls_key-%tky
*      overall_status = 'A'
*  ) TO lt_update.
*
*ENDLOOP.
*
*MODIFY ENTITIES OF /DMO/I_Travel_M IN LOCAL MODE
*  ENTITY travel
*  UPDATE FIELDS ( overall_status )
*  WITH lt_update.

** after updating we need to read the data and pass to result parameter for all the keys

    READ ENTITIES OF zjosh_i_travel IN LOCAL MODE
    ENTITY zjosh_i_travel
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    result = VALUE #( FOR ls_res IN lt_result
                       ( %tky = ls_res-%tky
                         %param = ls_res ) ).

  ENDMETHOD.

  METHOD copyTravel.

    DATA : it_travel   TYPE TABLE FOR CREATE zjosh_i_travel,
           it_booking  TYPE TABLE FOR CREATE zjosh_i_travel\_booking,
           it_booksupp TYPE TABLE FOR CREATE zjosh_i_bookg\_booknsupp.


    READ TABLE keys ASSIGNING FIELD-SYMBOL(<ls_withoutcid>) WITH KEY %cid =  '' .

    ASSERT <ls_withoutcid> IS NOT ASSIGNED. "it means when no records without cid are not there
    "if cid not available raise exception

    READ ENTITIES OF zjosh_i_travel IN LOCAL MODE
    ENTITY zjosh_i_travel
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel_re).

    READ ENTITIES OF zjosh_i_travel IN LOCAL MODE
    ENTITY zjosh_i_travel BY \_booking
    ALL FIELDS WITH CORRESPONDING #( lt_travel_re )
    RESULT DATA(lt_booking_re).

    READ ENTITIES OF zjosh_i_travel IN LOCAL MODE
    ENTITY zjosh_i_bookg BY \_booknsupp
    ALL FIELDS WITH CORRESPONDING #( lt_booking_re )
    RESULT DATA(lt_booksuppl_re).

    LOOP AT lt_travel_re ASSIGNING FIELD-SYMBOL(<ls_travel_r>).

*         append initial LINE to it_travel assigning FIELD-symbol(<ls_travel>).
*         <ls_travel>-%cid = keys[ key entity TravelId = <ls_travel_r>-TravelId ]-%cid.
*         <ls_travel>-%data = CORRESPONDING #( <ls_travel_r> except TravelId ).

      APPEND VALUE #(  %cid =  keys[ KEY entity TravelId = <ls_travel_r>-TravelId ]-%cid
                    %data = CORRESPONDING #( <ls_travel_r> EXCEPT TravelId ) )
                    TO it_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      <ls_travel>-BeginDate = cl_abap_context_info=>get_system_date( ).
      <ls_travel>-EndDate = cl_abap_context_info=>get_system_date( ) + 30.
      <ls_travel>-overallstatus = 'O'.

      "fill bookingtable cid_ref with travel cid
      APPEND VALUE #( %cid_ref = <ls_travel>-%cid ) TO it_booking ASSIGNING FIELD-SYMBOL(<ls_booking>).

      LOOP AT lt_booking_re ASSIGNING FIELD-SYMBOL(<ls_booking_r>)
         USING KEY entity
         WHERE TravelId = <ls_travel_r>-TravelId.

        "we have fill the cid in target for booking,
        "but for travel we got from the interface keys
        " just combined with booking id to create a new cid
        APPEND VALUE #( %cid = <ls_travel>-%cid && <ls_booking_r>-BookingId
                        %data = CORRESPONDING #( <ls_booking_r> EXCEPT travelid ) )
                        " going to use the same booking id
                        TO  <ls_booking>-%target ASSIGNING FIELD-SYMBOL(<ls_booking_n>).

        <ls_booking_n>-BookingStatus = 'N'.

        APPEND VALUE #( %cid_ref = <ls_booking_n>-%cid ) TO it_booksupp ASSIGNING FIELD-SYMBOL(<ls_booksupp>).


        LOOP AT lt_booksuppl_re ASSIGNING FIELD-SYMBOL(<ls_booksuppl_r>)
           USING KEY entity
           WHERE TravelId = <ls_travel_r>-TravelId
           AND BookingId = <ls_booking_r>-BookingId.

          APPEND VALUE #( %cid = <ls_travel>-%cid && <ls_booking_r>-BookingId
                           && <ls_booksuppl_r>-BookingSupplementId

                           %data = CORRESPONDING #( <ls_booksuppl_r> EXCEPT travelid bookingid )

                            ) TO <ls_booksupp>-%target.


        ENDLOOP.

      ENDLOOP.

    ENDLOOP.

    "we filled all tables based on the copied travel and now we have to create new instance
    MODIFY ENTITIES OF zjosh_i_travel IN LOCAL MODE
      ENTITY zjosh_i_travel

      CREATE FIELDS ( AgencyId CustomerId BeginDate EndDate BookingFee
      TotalPrice CurrencyCode overallstatus Description )
      WITH it_travel

      ENTITY zjosh_i_travel
       CREATE BY \_booking
       FIELDS ( BookingId BookingDate CustomerId CarrierId ConnectionId
       FlightDate FlightPrice CurrencyCode BookingStatus )
       WITH it_booking

       ENTITY zjosh_i_bookg
       CREATE BY \_booknsupp
       FIELDS ( BookingSupplementId SupplementId price CurrencyCode  )
        WITH it_booksupp
        MAPPED DATA(it_mapped).

    "the new travel we created should be mapped to the frontend
    mapped-zjosh_i_travel = it_mapped-zjosh_i_travel.



  ENDMETHOD.

  METHOD recalctolPrice.


    TYPES : BEGIN OF lty_tprices,
              price TYPE /dmo/total_price,
              curr  TYPE /dmo/currency_code,
            END OF lty_tprices.


    DATA : lt_tprices TYPE TABLE OF lty_tprices.

    READ ENTITIES OF zjosh_i_travel IN LOCAL MODE
      ENTITY zjosh_i_travel
      FIELDS ( BookingFee CurrencyCode )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travels).

    READ ENTITIES OF zjosh_i_travel IN LOCAL MODE
      ENTITY zjosh_i_travel BY \_booking
      FIELDS ( FlightPrice CurrencyCode )
      WITH CORRESPONDING #( lt_travels )
      RESULT DATA(lt_bookgs).

    READ ENTITIES OF zjosh_i_travel IN LOCAL MODE
      ENTITY zjosh_i_bookg BY \_booknsupp
      FIELDS ( Price CurrencyCode )
      WITH CORRESPONDING #( lt_bookgs )
      RESULT DATA(lt_booksupp).


    DELETE lt_travels WHERE CurrencyCode IS INITIAL.

*     append all prices with corresponding currency to an internal table
    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<ls_travel>).

      "creates a new internal table for every travel, shouldnt use append
      lt_tprices = VALUE #( ( price = <ls_travel>-BookingFee
                            curr = <ls_travel>-CurrencyCode ) ).

      LOOP AT lt_bookgs ASSIGNING FIELD-SYMBOL(<ls_bookg>) USING KEY entity
                      WHERE travelid = <ls_travel>-TravelId AND CurrencyCode IS NOT INITIAL.
*        can use collect instead of append
        COLLECT VALUE lty_tprices( price = <ls_bookg>-FlightPrice
                        curr = <ls_bookg>-CurrencyCode ) INTO lt_tprices.


        LOOP AT lt_booksupp ASSIGNING FIELD-SYMBOL(<ls_booksupp>) USING KEY entity
                           WHERE TravelId  = <ls_bookg>-TravelId AND
                                 BookingId = <ls_bookg>-BookingId AND
                                 CurrencyCode IS NOT INITIAL.

          COLLECT VALUE lty_tprices( price = <ls_booksupp>-Price
                          curr = <ls_booksupp>-CurrencyCode ) INTO lt_tprices.

        ENDLOOP.

      ENDLOOP.

*        as all prices needed to calculate total prices are in an internal table lt_tprices
*        loop through the table and add to total price when same currency when not convert to travel currency and add to total price
      CLEAR <ls_travel>-TotalPrice.
      LOOP AT lt_tprices ASSIGNING FIELD-SYMBOL(<ls_prices>).

        IF <ls_prices>-curr = <ls_travel>-CurrencyCode.
          <ls_travel>-TotalPrice += <ls_prices>-price.

        ELSE.
          "convert currency to travel currency if not matched
          /dmo/cl_flight_amdp=>convert_currency(
            EXPORTING
              iv_amount               = <ls_prices>-price
              iv_currency_code_source = <ls_prices>-curr
              iv_currency_code_target = <ls_travel>-CurrencyCode
              iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )
            IMPORTING
              ev_amount               = DATA(lv_conv_price)
          ).

          <ls_travel>-TotalPrice += lv_conv_price.

        ENDIF.
      ENDLOOP.

    ENDLOOP.

    "we have updated the total price  above need to update on ui now

    MODIFY ENTITIES OF zjosh_i_travel IN LOCAL MODE
    ENTITY zjosh_i_travel
    UPDATE FIELDS ( TotalPrice )
    WITH CORRESPONDING #( lt_travels ).


  ENDMETHOD.

  METHOD rejectTravel.

    MODIFY ENTITIES OF zjosh_i_travel IN LOCAL MODE
      ENTITY zjosh_i_travel
      UPDATE FIELDS ( overallstatus )
      WITH VALUE #( FOR ls_key IN keys (
                       %tky = ls_key-%tky
                       overallstatus = 'X' ) ).

    READ ENTITIES OF zjosh_i_travel IN LOCAL MODE
      ENTITY zjosh_i_travel
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    result = VALUE #( FOR ls_res IN lt_result
                       ( %tky = ls_res-%tky
                         %param = ls_res ) ).
  ENDMETHOD.

  METHOD get_instance_features.

*  read instances from the keys

    READ ENTITIES OF zjosh_i_travel IN LOCAL MODE
      ENTITY zjosh_i_travel
      FIELDS ( TravelId overallstatus )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travel).

    result = VALUE #( FOR ls_travel IN lt_travel
                       ( %tky = ls_travel-%tky
                         %features-%action-acceptTravel = COND #( WHEN ls_travel-overallstatus = 'A'
                                                                  THEN if_abap_behv=>fc-o-disabled
                                                                  ELSE if_abap_behv=>fc-o-enabled )
                         %features-%action-rejectTravel = COND #( WHEN ls_travel-overallstatus = 'X'
                                                                  THEN if_abap_behv=>fc-o-disabled
                                                                  ELSE if_abap_behv=>fc-o-enabled )
                         %features-%assoc-_booking = COND #( WHEN ls_travel-overallstatus = 'X'
                                                                  THEN if_abap_behv=>fc-o-disabled
                                                                  ELSE if_abap_behv=>fc-o-enabled )
                          ) ).


  ENDMETHOD.

  METHOD validateCustomer.

*  read customer for the travels in keys , and validate if it correct using demo customer table
    READ ENTITY IN LOCAL MODE zjosh_i_travel
    FIELDS ( CustomerId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).

*
    DATA : lt_cust TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    lt_cust = CORRESPONDING #( lt_travel DISCARDING DUPLICATES MAPPING customer_id = CustomerId ).

    DELETE lt_cust WHERE customer_id IS INITIAL.

    IF lt_cust IS NOT INITIAL.

      SELECT FROM /dmo/customer
      FIELDS customer_id
      FOR ALL ENTRIES IN @lt_cust
      WHERE customer_id = @lt_cust-customer_id
      INTO TABLE @DATA(lt_cust_db).  " we get customers that are in database for our travel customers
    ENDIF.



    "loop at travels and check if customer id is inital and doesnt exist in demo customer table

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      IF <ls_travel>-CustomerId IS INITIAL OR NOT
         line_exists( lt_cust_db[ customer_id = <ls_travel>-CustomerId ] ).

        APPEND VALUE #( %tky = <ls_travel>-%tky )
         TO failed-zjosh_i_travel.

        APPEND VALUE #( %tky = <ls_travel>-%tky
                        %msg = NEW /dmo/cm_flight_messages(
                                      textid                = /dmo/cm_flight_messages=>customer_unkown
                                      customer_id           = <ls_travel>-CustomerId
                                      severity              =  if_abap_behv_message=>severity-error
                                      )
                        %element-customerid = if_abap_behv=>mk-on


                 ) TO reported-zjosh_i_travel.


      ENDIF.


    ENDLOOP.

  ENDMETHOD.

  METHOD validateBookingFee.
  ENDMETHOD.

  METHOD validateCurrencyCode.
  ENDMETHOD.

  METHOD validateDates.

    READ ENTITY IN LOCAL MODE zjosh_i_travel
     FIELDS ( BeginDate EndDate )
     WITH CORRESPONDING #( keys )
     RESULT DATA(lt_travel).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      IF <ls_travel>-EndDate < <ls_travel>-BeginDate.  "end_date before begin_date show error message

        APPEND VALUE #( %tky = <ls_travel>-%tky ) TO failed-zjosh_i_travel.

        APPEND VALUE #( %tky = <ls_travel>-%tky
                        %msg = NEW /dmo/cm_flight_messages(
                                     textid                = /dmo/cm_flight_messages=>begin_date_bef_end_date
                                     travel_id             = <ls_travel>-TravelId
                                     begin_date            = <ls_travel>-BeginDate
                                     end_date              = <ls_travel>-EndDate

                                     severity              = if_abap_behv_message=>severity-error

                                     )
                         %element-BeginDate = if_abap_behv=>mk-on
                         %element-EndDate = if_abap_behv=>mk-on

                  ) TO reported-zjosh_i_travel.

      ELSEIF <ls_travel>-BeginDate < cl_abap_context_info=>get_system_date( ).   "begin_date must be in the future

        APPEND VALUE #( %tky = <ls_travel>-%tky ) TO failed-zjosh_i_travel.

        APPEND VALUE #( %tky = <ls_travel>-%tky
                        %msg = NEW /dmo/cm_flight_messages(
                                  textid                = /dmo/cm_flight_messages=>begin_date_on_or_bef_sysdate
                                  travel_id             = <ls_travel>-TravelId
                                  begin_date            = <ls_travel>-BeginDate
                                  severity              = if_abap_behv_message=>severity-error
                                  )
                       %element-BeginDate = if_abap_behv=>mk-on


               ) TO reported-zjosh_i_travel.
      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD validateStatus.

    READ ENTITIES OF zjosh_i_travel IN LOCAL MODE
      ENTITY zjosh_i_travel
      FIELDS ( overallstatus )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travel).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).
      CASE <ls_travel>-overallstatus.
        WHEN 'A'.   "other than those 3 show error mssg
        WHEN 'O'.
        WHEN 'X'.
        WHEN OTHERS.

          APPEND VALUE #( %tky = <ls_travel>-%tky ) TO failed-zjosh_i_travel.

          APPEND VALUE #( %tky = <ls_travel>-%tky
                          %msg = NEW /dmo/cm_flight_messages(
                                       textid                = /dmo/cm_flight_messages=>status_invalid
                                       travel_id             = <ls_travel>-TravelId
                                       status                = <ls_travel>-overallstatus
                                       severity              = if_abap_behv_message=>severity-error

                                        )
                        %element-overallstatus = if_abap_behv=>mk-on
               ) TO reported-zjosh_i_travel.

      ENDCASE.

    ENDLOOP.

  ENDMETHOD.

  METHOD calculateTotalPrice.

* calling internal action

    MODIFY ENTITIES OF zjosh_i_travel IN LOCAL MODE
     ENTITY zjosh_i_travel
     EXECUTE recalctolPrice
     FROM CORRESPONDING #( keys ).

  ENDMETHOD.

ENDCLASS.


