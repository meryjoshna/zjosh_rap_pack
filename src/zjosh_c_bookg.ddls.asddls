@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'consumption view bookg'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity zjosh_c_bookg as projection on zjosh_i_bookg
{
    key TravelId,
    key BookingId,
    BookingDate,
    
    @ObjectModel.text.element: [ 'customerName' ]
    CustomerId,
    _customer.LastName as customerName,
    
    @ObjectModel.text.element: [ 'carriername' ]
    CarrierId,
    _carrier.Name as carriername,
    

    ConnectionId,
  
    FlightDate,
    
    @Semantics.amount.currencyCode: 'CurrencyCode'
    FlightPrice,
    CurrencyCode,
    
    @ObjectModel.text.element: [ 'bookgsta_text' ]
    BookingStatus,
    _book_status._Text.Text as bookgsta_text : localized,
    lastchangedat,
    /* Associations */
    _booknsupp : redirected to composition child zjosh_c_bokgsupp,
    _book_status,
    _carrier,
    _connection,
    _customer,
    _travel : redirected to parent zjosh_c_travel
}
