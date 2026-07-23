@EndUserText.label: 'TMG Item Projection'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true

@ObjectModel.semanticKey: [
  'MODUL',
  'PROGRAM_NAME',
  'TASK'
]

define view entity ZC_JOSH_TMG_ITEM
  as projection on ZI_JOSH_TMG_ITEM
{
  key modul,
  key program_name,
  key task,

  @Consumption.hidden: true
  SingletonID,

  varkey1,
  varkey2,
  varkey3,
  varkey4,
  varkey5,

  description,
  zkey,
  switch,

  local_last_changed_at,

  _Root : redirected to parent ZC_JOSH_TMG_ROOT
}
