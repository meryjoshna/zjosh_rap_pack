@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'interface view for book supp'
@Metadata.ignorePropagatedAnnotations: true
define view entity zjosh_i_bookg_supp
  as select from zjosh_bookg_supp
  association        to parent zjosh_i_bookg  as _bookng         on  $projection.TravelId  = _bookng.TravelId
                                                                 and $projection.BookingId = _bookng.BookingId

  association [1..1] to zjosh_i_travel        as _travel         on  $projection.TravelId = _travel.TravelId
  association [1..1] to /DMO/I_Supplement     as _supplement     on  $projection.SupplementId = _supplement.SupplementID
  association [1..*] to /DMO/I_SupplementText as _SupplementText on  $projection.SupplementId = _SupplementText.SupplementID
{
  key travel_id             as TravelId,
  key booking_id            as BookingId,
  key booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,
      lastchangedat       as LastChangedAt,
      _supplement,
      _SupplementText,
      _bookng,
      _travel
}
