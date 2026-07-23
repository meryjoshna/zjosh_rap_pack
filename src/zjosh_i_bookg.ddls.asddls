@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'interface view bookngs'
@Metadata.ignorePropagatedAnnotations: true
define view entity zjosh_i_bookg
  as select from zjosh_bookg_ddt
  association        to parent zjosh_i_travel    as _travel      on  $projection.TravelId = _travel.TravelId

  composition [0..*] of zjosh_i_bookg_supp       as _booknsupp

  association [1..1] to /DMO/I_Carrier           as _carrier     on  $projection.CarrierId = _carrier.AirlineID
  association [1..1] to /DMO/I_Customer          as _customer    on  $projection.CustomerId = _customer.CustomerID
  association [1..1] to /DMO/I_Connection        as _connection  on  $projection.CarrierId    = _connection.AirlineID
                                                                 and $projection.ConnectionId = _connection.ConnectionID
  association [0..1] to /DMO/I_Booking_Status_VH as _book_status on  $projection.BookingStatus = _book_status.BookingStatus
{
  key travel_id       as TravelId,
  key booking_id      as BookingId,
      booking_date    as BookingDate,
      customer_id     as CustomerId,
      carrier_id      as CarrierId,
      connection_id   as ConnectionId,
      flight_date     as FlightDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price    as FlightPrice,
      currency_code   as CurrencyCode,
      booking_status  as BookingStatus,
      lastchangedat as lastchangedat,
      _travel,
      _booknsupp,
      _carrier,
      _customer,
      _connection,
      _book_status

}
