@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'consu view for booking approver app'
//@Metadata.ignorePropagatedAnnotations: true

@UI.headerInfo: {
    typeName: 'Booking',
    typeNamePlural: 'Bookings',
    title: {
        type: #STANDARD,
        value: 'BookingId'
       
    }
  
}

@Search.searchable: true
define view entity zjosh_c_bookg_appr
 as projection on zjosh_i_bookg
{
    @UI.facet: [{
       
        id: 'Booking',
        purpose: #STANDARD,
        position:10 ,
        label: 'Booking',
        type: #IDENTIFICATION_REFERENCE
       
    }]
    
    @Search.defaultSearchElement: true
    
    key TravelId,
    
    @UI.lineItem: [{ position:20 , importance :#HIGH}]
    @UI.identification: [{ position:20 }]   
    @Search.defaultSearchElement: true
    key BookingId,
    
    @UI.lineItem: [{ position:30 , importance :#HIGH}]
    @UI.identification: [{ position:30 }]  
    BookingDate,
    
    @UI.lineItem: [{ position : 40}]
     @UI.identification: [{ position: 40 }]
     @Search.defaultSearchElement: true
     @UI.selectionField: [{ position:10 }]
      @ObjectModel.text.element: [ 'customerName' ]
    CustomerId,
    _customer.LastName as customerName,
    
    @UI.lineItem: [{ position : 45}]
    @UI.identification: [{ position: 45 }]
    @ObjectModel.text.element: [ 'carriername' ]
    CarrierId,
     _carrier.Name as carriername,
   
    
    @UI.lineItem: [{ position : 50,importance :#HIGH}]
    @UI.identification: [{ position: 50}]
    ConnectionId,
    
    @UI.lineItem: [{ position : 60}]
    @UI.identification: [{ position: 60}]
    FlightDate,
    
    @UI.lineItem: [{ position : 70}]
    @UI.identification: [{ position: 70}]
    @Semantics.amount.currencyCode: 'CurrencyCode'
    FlightPrice,
    
    CurrencyCode,
    
    @UI.lineItem: [{ position : 80}]
     @UI.identification: [{ position: 80 }]
     @UI.textArrangement: #TEXT_ONLY
    @ObjectModel.text.element: [ 'bookgsta_text' ]
    @Consumption.valueHelpDefinition: [{ 
     entity: {
         name: '/DMO/I_Booking_Status_VH',
         element: 'BookingStatus'
     }
   
    }]
    BookingStatus,
    _book_status._Text.Text as bookgsta_text : localized,
    
    @UI.hidden: true
    lastchangedat,
    /* Associations */
    _booknsupp,
    _book_status,
    _carrier,
    _connection,
    _customer,
    _travel : redirected to parent zjosh_c_travel_appr
}
