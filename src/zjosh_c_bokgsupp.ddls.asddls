@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'consump view booksupp'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity zjosh_c_bokgsupp as projection on zjosh_i_bookg_supp
{
    key TravelId,
    key BookingId,
    key BookingSupplementId,
    
    @ObjectModel.text.element: [ 'SupplementDesc' ]
    SupplementId,
    _SupplementText.Description as SupplementDesc : localized,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    Price,
    CurrencyCode,
    LastChangedAt,
    /* Associations */
    _bookng : redirected to parent zjosh_c_bookg,
    _supplement,
    _SupplementText,
    _travel : redirected to zjosh_c_travel
}
