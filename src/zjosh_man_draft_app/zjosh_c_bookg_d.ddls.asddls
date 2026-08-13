@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'consumption view booking dra'
@Metadata.ignorePropagatedAnnotations: true

@Metadata.allowExtensions: true
@Search.searchable: true

define view entity zjosh_c_bookg_D as projection on zjosh_i_bookg_D
{
   key BookingUUID,

      TravelUUID,

      @Search.defaultSearchElement: true
      BookingID,

      BookingDate,

      @ObjectModel.text.element: ['CustomerName']
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{entity: {name: '/DMO/I_Customer', element: 'CustomerID' }}]
      CustomerID,
      _Customer.LastName as CustomerName,

      @ObjectModel.text.element: ['CarrierName']
      @Consumption.valueHelpDefinition: [{entity: {name: '/DMO/I_Carrier', element: 'AirlineID' }}]
      AirlineID,
      _Carrier.Name      as CarrierName,

      @Consumption.valueHelpDefinition: [ {entity: {name: '/DMO/I_Flight', element: 'ConnectionID'},
                     additionalBinding: [ { localElement: 'FlightDate',   element: 'FlightDate'},
                                          { localElement: 'AirlineID',    element: 'AirlineID'},
                                          { localElement: 'FlightPrice',  element: 'Price', usage: #RESULT},
                                          { localElement: 'CurrencyCode', element: 'CurrencyCode', usage: #RESULT } ] } ]
      ConnectionID,

      FlightDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      @Consumption.valueHelpDefinition: [ {entity: {name: '/DMO/I_Flight', element: 'ConnectionID'},
                     additionalBinding: [ { localElement: 'FlightDate',   element: 'FlightDate'},
                                          { localElement: 'AirlineID',    element: 'AirlineID'},
                                          { localElement: 'FlightPrice',  element: 'Price', usage: #RESULT },
                                          { localElement: 'CurrencyCode', element: 'CurrencyCode', usage: #RESULT } ] } ]
      FlightPrice,

      @Consumption.valueHelpDefinition: [{entity: {name: 'I_Currency', element: 'Currency' }}]
      CurrencyCode,

      @ObjectModel.text.element: ['BookingStatusText']
      @Consumption.valueHelpDefinition: [{entity: {name: '/DMO/I_Booking_Status_VH', element: 'BookingStatus' }}]
      BookingStatus,
      _BookingStatus._Text.Text as BookingStatusText: localized, 

      LocalLastChangedAt,

      /* Associations */
      _BookingSupplement: redirected to composition child zjosh_c_bsupp_D,
      _BookingStatus,
      _Carrier,
      _Connection,
      _Customer,
      _Travel: redirected to parent zjosh_c_travel_D
      
}


