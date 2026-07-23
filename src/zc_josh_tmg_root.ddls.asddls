@EndUserText.label: 'TMG Root Projection'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true

@ObjectModel.semanticKey: ['SingletonID']

define root view entity ZC_JOSH_TMG_ROOT
provider contract transactional_query
  as projection on ZI_JOSH_TMG_ROOT
{
  key SingletonID,

  @Consumption.hidden: true
  LastChangedAtMax,

  _Items : redirected to composition child ZC_JOSH_TMG_ITEM
}
