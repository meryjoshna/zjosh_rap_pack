@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'c sp1'
@Metadata.ignorePropagatedAnnotations: true
define root view entity zjosh_c_sp1 
provider contract transactional_query
as projection on zjosh_i_sp1
{
    key CarrierId,
    key ConnectionId,
    key FlightDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    Price,
    CurrencyCode,
    PlaneTypeId,
    SeatsMax,
    SeatsOccupied
}
