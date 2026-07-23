CLASS lhc_zjosh_i_bookg DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS earlynumbering_cba_Booknsupp FOR NUMBERING
      IMPORTING entities FOR CREATE zjosh_i_bookg\_Booknsupp.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zjosh_i_bookg RESULT result.

ENDCLASS.

CLASS lhc_zjosh_i_bookg IMPLEMENTATION.

  METHOD earlynumbering_cba_Booknsupp.

      DATA : lv_max_bsupp_id TYPE /dmo/booking_supplement_id.

      read ENTITIES OF zjosh_i_travel IN LOCAL MODE
      entity zjosh_i_bookg by \_booknsupp
      from CORRESPONDING #( entities )
      link data(bookingsupps).

      LOOP at entities assigning FIELD-SYMBOL(<bookings>) GROUP by <bookings>-%tky.


        lv_max_bsupp_id = reduce #( init lv_max = conv  /dmo/booking_supplement_id( '0' )
                                    for booksupp in bookingsupps using key entity
                                    where ( source-TravelId = <bookings>-TravelId
                                            and source-BookingId = <bookings>-BookingId )
                                    next lv_max = cond #( when booksupp-target-BookingSupplementId > lv_max
                                                          then  booksupp-target-BookingSupplementId
                                                          else lv_max ) ).

       lv_max_bsupp_id = reduce #( init lv_max = lv_max_bsupp_id
                                   for entity in entities using key entity
                                   where ( TravelId = <bookings>-TravelId
                                           and BookingId = <bookings>-BookingId )
                                   for target in entity-%target
                                   next lv_max = cond #( when target-BookingSupplementId > lv_max
                                                         then target-BookingSupplementId
                                                         else lv_max ) ).

       LOOP at <bookings>-%target assigning FIELD-SYMBOL(<booksuppl_wo_numbers>).

       APPEND value #( %cid = <booksuppl_wo_numbers>-%cid
                       %key = <booksuppl_wo_numbers>-%key )

       to mapped-zjosh_i_bookg_supp ASSIGNING FIELD-SYMBOL(<mapped_booksupp>).

       if <booksuppl_wo_numbers>-BookingSupplementId is initial.

          lv_max_bsupp_id += 1.
          <mapped_booksupp>-BookingSupplementId = lv_max_bsupp_id.
       endif.

       endloop.


      endloop.





  ENDMETHOD.

  METHOD get_instance_features.

      READ ENTITIES OF zjosh_i_travel in LOCAL MODE
      entity zjosh_i_travel by \_booking
      fields ( TravelId BookingId BookingStatus )
      with CORRESPONDING #( keys )
      result data(lt_bookra).

      result  = value #( for ls_book in lt_bookra (
                          %tky = ls_book-%tky
                          %features-%assoc-_booknsupp = cond #( when ls_book-BookingStatus = 'X'
                                                                then if_abap_behv=>fc-o-disabled )
                          ) ).






  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
