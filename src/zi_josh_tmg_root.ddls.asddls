@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'interface view tmg ml edit'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZI_JOSH_TMG_ROOT
  as select from I_Language
    left outer join zjosh_rap_tmg1 as tmg on 0 = 0

  composition [0..*] of ZI_JOSH_TMG_ITEM as _Items
{
  key 1 as SingletonID,

      max( tmg.last_changed_at ) as LastChangedAtMax,

      _Items
}
where I_Language.Language = $session.system_language
