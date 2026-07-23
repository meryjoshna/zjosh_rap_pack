@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@EndUserText.label: 'TMG Item'

define view entity ZI_JOSH_TMG_ITEM
  as select from zjosh_rap_tmg1

  association to parent ZI_JOSH_TMG_ROOT
      as _Root
      on $projection.SingletonID = _Root.SingletonID
{
  key modul,
  key program_name,
  key task,

  1 as SingletonID,

  varkey1,
  varkey2,
  varkey3,
  varkey4,
  varkey5,

  description,
  zkey,
  switch,

  @Semantics.user.createdBy: true
  local_created_by,

  @Semantics.systemDateTime.createdAt: true
  local_created_at,

  @Semantics.user.lastChangedBy: true
  local_last_changed_by,

  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at,

  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at,

  _Root
}
