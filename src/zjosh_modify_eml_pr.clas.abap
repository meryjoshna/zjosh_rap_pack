CLASS zjosh_modify_eml_pr DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zjosh_modify_eml_pr IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

*1->
*  or can be passed an internal table after filling instead of inline
*  data : lt_book type table for create zjosh_i_travel\_booking
    modify entity zjosh_i_travel
    CREATE from value #( (

         %cid = 'travel1'
         %data-BeginDate = '20260717'
         %control-BeginDate = if_abap_behv=>mk-on
    ) )
   CREATE by \_booking
   from value #( (

               %cid_ref = 'travel1'
               %target = value #( (
                           %cid = 'book1'
                           %data-BookingDate = '20260717'
                           %control-BookingDate = if_abap_behv=>mk-on
                            ) )


                ) )
    failed final(it_failed)
    mapped final(it_mapped)
    reported final(it_reported).


    if it_failed is NOT initial.
      out->write(  it_failed ).
     else.
        COMMIT ENTITIES.
    endif.

* 2->

*    modify entity zjosh_i_travel
*      DELETE from value #( ( %key-TravelId = '4162' ) )
*      failed final(it_failed1)
*      mapped final(it_mapped1)
*      reported final(it_reported1).
*
*    if it_failed1 is NOT initial.
*      out->write(  it_failed1 ).
*     else.
*        COMMIT ENTITIES.
*    endif.
*
*   modify entity zjosh_i_travel
*      create auto fill cid with value #( ( %data-BeginDate = '20260718'
*                                           %control-BeginDate = if_abap_behv=>mk-on ) )
*      failed final(it_failed2)
*      mapped final(it_mapped2)
*      reported final(it_reported2).
*
*    if it_failed2 is not initial.
*      out->write( it_failed2 ).
*    else.
*      commit entities.
*    endif.


*3->
*  [ auto fill cid] fields (comp1 comp2 ) with fields_tab
*   modify entities of zjosh_i_travel
*     entity zjosh_i_travel
*     update fields ( BeginDate )
*     with value #( ( %key-TravelId = '4179'
*                     BeginDate = '20260729' ) )
*
*     entity zjosh_i_travel
*        DELETE from value #( ( TravelId = '4179' ) ).
*   commit entities.

*4->
*no need to pass control or field list explicitly
*  modify entity zjosh_i_travel
* update SET fields with value #( ( %key-TravelId = '4179'
*                                    BeginDate = '20260826' ) ).
*
* commit entities.

  ENDMETHOD.
ENDCLASS.
