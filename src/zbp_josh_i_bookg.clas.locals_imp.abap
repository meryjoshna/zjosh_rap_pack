CLASS lhc_zjosh_i_bookg DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS earlynumbering_cba_Booknsupp FOR NUMBERING
      IMPORTING entities FOR CREATE zjosh_i_bookg\_Booknsupp.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zjosh_i_bookg RESULT result.
    METHODS validateconnection FOR VALIDATE ON SAVE
      IMPORTING keys FOR zjosh_i_bookg~validateconnection.

    METHODS validatecurrencycode FOR VALIDATE ON SAVE
      IMPORTING keys FOR zjosh_i_bookg~validatecurrencycode.

    METHODS validatecustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR zjosh_i_bookg~validatecustomer.

    METHODS validateflightprice FOR VALIDATE ON SAVE
      IMPORTING keys FOR zjosh_i_bookg~validateflightprice.

    METHODS validatestatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR zjosh_i_bookg~validatestatus.
    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zjosh_i_bookg~calculatetotalprice.

ENDCLASS.

CLASS lhc_zjosh_i_bookg IMPLEMENTATION.

  METHOD earlynumbering_cba_Booknsupp.

    DATA : lv_max_bsupp_id TYPE /dmo/booking_supplement_id.

    READ ENTITIES OF zjosh_i_travel IN LOCAL MODE
    ENTITY zjosh_i_bookg BY \_booknsupp
    FROM CORRESPONDING #( entities )
    LINK DATA(bookingsupps).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<bookings>) GROUP BY <bookings>-%tky.


      lv_max_bsupp_id = REDUCE #( INIT lv_max = CONV  /dmo/booking_supplement_id( '0' )
                                  FOR booksupp IN bookingsupps USING KEY entity
                                  WHERE ( source-TravelId = <bookings>-TravelId
                                          AND source-BookingId = <bookings>-BookingId )
                                  NEXT lv_max = COND #( WHEN booksupp-target-BookingSupplementId > lv_max
                                                        THEN  booksupp-target-BookingSupplementId
                                                        ELSE lv_max ) ).

      lv_max_bsupp_id = REDUCE #( INIT lv_max = lv_max_bsupp_id
                                  FOR entity IN entities USING KEY entity
                                  WHERE ( TravelId = <bookings>-TravelId
                                          AND BookingId = <bookings>-BookingId )
                                  FOR target IN entity-%target
                                  NEXT lv_max = COND #( WHEN target-BookingSupplementId > lv_max
                                                        THEN target-BookingSupplementId
                                                        ELSE lv_max ) ).

      LOOP AT <bookings>-%target ASSIGNING FIELD-SYMBOL(<booksuppl_wo_numbers>).

        APPEND VALUE #( %cid = <booksuppl_wo_numbers>-%cid
                        %key = <booksuppl_wo_numbers>-%key )

        TO mapped-zjosh_i_bookg_supp ASSIGNING FIELD-SYMBOL(<mapped_booksupp>).

        IF <booksuppl_wo_numbers>-BookingSupplementId IS INITIAL.

          lv_max_bsupp_id += 1.
          <mapped_booksupp>-BookingSupplementId = lv_max_bsupp_id.
        ENDIF.

      ENDLOOP.


    ENDLOOP.





  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zjosh_i_travel IN LOCAL MODE
    ENTITY zjosh_i_travel BY \_booking
    FIELDS ( TravelId BookingId BookingStatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_bookra).

    result  = VALUE #( FOR ls_book IN lt_bookra (
                        %tky = ls_book-%tky
                        %features-%assoc-_booknsupp = COND #( WHEN ls_book-BookingStatus = 'X'
                                                              THEN if_abap_behv=>fc-o-disabled )
                        ) ).


  ENDMETHOD.

  METHOD validateConnection.
  ENDMETHOD.

  METHOD validateCurrencyCode.
  ENDMETHOD.

  METHOD validateCustomer.
  ENDMETHOD.

  METHOD validateFlightPrice.
  ENDMETHOD.

  METHOD validateStatus.
  ENDMETHOD.

  METHOD calculateTotalPrice.

    DATA : it_travel TYPE STANDARD TABLE OF zjosh_i_travel WITH UNIQUE HASHED KEY key COMPONENTS TravelId.

    it_travel = CORRESPONDING #( keys DISCARDING DUPLICATES MAPPING TravelId = TravelId ).

    MODIFY ENTITIES OF zjosh_i_travel IN LOCAL MODE
      ENTITY zjosh_i_travel
       EXECUTE recalctolPrice
       FROM CORRESPONDING #( it_travel ).


  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
