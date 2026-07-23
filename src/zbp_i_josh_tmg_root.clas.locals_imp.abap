CLASS lhc_TMGRoot DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR TMGRoot RESULT result.

*    METHODS earlynumbering_cba_Items FOR NUMBERING
*      IMPORTING entities FOR CREATE TMGRoot\_Items.

ENDCLASS.

CLASS lhc_TMGRoot IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

*  METHOD earlynumbering_cba_Items.
*  DATA lv_max_modul TYPE zjosh_rap_tmg1-modul.
*
*  SELECT MAX( modul )
*
*    FROM zjosh_rap_tmg1 INTO @lv_max_modul.
*
*  IF lv_max_modul IS INITIAL.
*    lv_max_modul = 0.
*  ENDIF.
*
*  LOOP AT entities ASSIGNING FIELD-SYMBOL(<parent>).
*
*    LOOP AT <parent>-%target ASSIGNING FIELD-SYMBOL(<item>).
*
*      IF <item>-modul IS NOT INITIAL.
*
*        APPEND VALUE #(
*          %cid = <item>-%cid
*          %key = <item>-%key
*        ) TO mapped-items.
*
*        CONTINUE.
*
*      ENDIF.
*
*      lv_max_modul += 1.
*
*      APPEND VALUE #(
*        %cid = <item>-%cid
*
*        %key = VALUE #(
*          modul        = lv_max_modul
*          program_name = <item>-program_name
*          task         = <item>-task
*        )
*      ) TO mapped-items.
*
*    ENDLOOP.
*
*  ENDLOOP.

*ENDMETHOD.

ENDCLASS.

CLASS lhc_Items DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS set_varkey_values_modify FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Items~set_varkey_values_modify.

    METHODS validate_switch FOR VALIDATE ON SAVE
      IMPORTING keys FOR Items~validate_switch.

    METHODS validate_task_number FOR VALIDATE ON SAVE
      IMPORTING keys FOR Items~validate_task_number.

ENDCLASS.

CLASS lhc_Items IMPLEMENTATION.

  METHOD set_varkey_values_modify.

    READ ENTITIES OF zi_josh_tmg_root
      IN LOCAL MODE
      ENTITY Items
      FIELDS ( task )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_data).

    DATA lv_task_num TYPE i.

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<ls_data>).

      IF <ls_data>-task IS INITIAL.
        CONTINUE.
      ENDIF.

      TRY.
          lv_task_num = CONV i( <ls_data>-task ).
        CATCH cx_sy_conversion_no_number.
          CONTINUE.
      ENDTRY.

      MODIFY ENTITIES OF zi_josh_tmg_root
        IN LOCAL MODE
        ENTITY Items
        UPDATE FIELDS (
          varkey1
          varkey2
          varkey3
          varkey4
          varkey5
        )
        WITH VALUE #(
          (
            %tky    = <ls_data>-%tky
            varkey1 = lv_task_num * 1
            varkey2 = lv_task_num * 2
            varkey3 = lv_task_num * 3
            varkey4 = lv_task_num * 4
            varkey5 = lv_task_num * 5
          )
        ).

    ENDLOOP.

  ENDMETHOD.

  METHOD validate_switch.

    READ ENTITIES OF zi_josh_tmg_root
      IN LOCAL MODE
      ENTITY Items
      FIELDS ( switch )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<ls_data>).

      IF <ls_data>-switch IS NOT INITIAL
         AND <ls_data>-switch <> 'X'.

        APPEND VALUE #(
          %tky = <ls_data>-%tky
        ) TO failed-items.

*        APPEND VALUE #(
*          %tky            = <ls_data>-%tky
*          %state_area     = 'VALIDATE_SWITCH'
*          %msg            = new_message_with_text(
*                               severity = if_abap_behv_message=>severity-error
*                               text     = 'Switch must be X or empty'
*                             )
*          %element-switch = if_abap_behv=>mk-on
*        ) TO reported-items.
         APPEND VALUE #(
           %tky = <ls_data>-%tky

           %msg = new_message(
                          id       = 'ZJOSH_MSSG'
                          number   = '001'
                          severity = if_abap_behv_message=>severity-error )
           %element-switch = if_abap_behv=>mk-on
         ) TO reported-items.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validate_task_number.

    READ ENTITIES OF zi_josh_tmg_root
      IN LOCAL MODE
      ENTITY Items
      FIELDS ( task )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<ls_data>).

      DATA(lv_task) = condense( <ls_data>-task ).

      IF lv_task IS NOT INITIAL
         AND NOT lv_task CO '0123456789'.

        APPEND VALUE #(
          %tky = <ls_data>-%tky
        ) TO failed-items.

*        APPEND VALUE #(
*          %tky          = <ls_data>-%tky
*          %state_area   = 'VALIDATE_TASK'
*          %msg          = new_message_with_text(
*                             severity = if_abap_behv_message=>severity-error
*                             text     = 'Task must contain only digits'
*                           )
*          %element-task = if_abap_behv=>mk-on
*        ) TO reported-items.
        APPEND VALUE #(
           %tky = <ls_data>-%tky
           %msg = new_message(
                          id       = 'ZJOSH_MSSG'
                          number   = '002'
                          severity = if_abap_behv_message=>severity-error )
           %element-task = if_abap_behv=>mk-on
         ) TO reported-items.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_JOSH_TMG_ROOT DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_JOSH_TMG_ROOT IMPLEMENTATION.

  METHOD save_modified.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
