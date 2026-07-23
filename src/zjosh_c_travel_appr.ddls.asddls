@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'consumption view for travel approver app'
//@Metadata.ignorePropagatedAnnotations: true

@UI:{

    headerInfo: {
    typeName: 'Travel',
    typeNamePlural: 'Travels',
    title: {
        type: #STANDARD,
        
        value: 'TravelId'
        
          }  
  }
}

@Search.searchable: true
define root view entity zjosh_c_travel_appr 
provider contract transactional_query
as projection on zjosh_i_travel

{   
    @UI.facet: [{
        
        id: 'Travel',
        purpose: #STANDARD,
        type: #IDENTIFICATION_REFERENCE,
        position: 10,           
        label: 'Travel'
        },
        {
        
        id: 'Booking',
        purpose: #STANDARD,
        type: #LINEITEM_REFERENCE,
        position: 20,           
        label: 'Bookings',
        targetElement: '_booking'
        }
        
        
    ]
    
   @UI.lineItem: [{ position:10, importance: #HIGH}]              
   @UI.identification: [{ position: 10 }]
   @Search.defaultSearchElement: true
   @Search.fuzzinessThreshold: 0.7
    key TravelId,
    
    
   @UI.lineItem: [{ position:20 , importance: #HIGH}]
   @UI.selectionField: [{position: 20 }]
   @Search.defaultSearchElement: true
   @Search.fuzzinessThreshold: 0.7
   @Consumption.valueHelpDefinition: [{ 
     entity: {
         name: '/DMO/I_Agency',
         element: 'AgencyID'
     }
   
    }]
   @UI.identification: [{ position: 20 }]
   @ObjectModel.text.element: [ 'agencyName' ]
    AgencyId,
     _agency.Name as agencyName,
     
   @UI.lineItem: [{ position:30 }]
   @UI.selectionField: [{position: 30 }]
   @Search.defaultSearchElement: true
   @Search.fuzzinessThreshold: 0.7
   @Consumption.valueHelpDefinition: [{ 
     entity: {
         name: '/DMO/I_Customer',
         element: 'CustomerID'
     }
   
    }]
     @UI.identification: [{ position: 30 }]
    @ObjectModel.text.element: [ 'customerName' ]
    CustomerId,
    _customer.LastName as customerName,
    
    
    @UI.identification: [{ position: 40 }]
    BeginDate,
     @UI.identification: [{ position: 41 }]
    EndDate,
    
    
    @UI.lineItem: [{ position: 42 , importance: #MEDIUM  }]
    @UI.identification: [{ position: 42 }]
    @Semantics.amount.currencyCode: 'CurrencyCode'
    BookingFee,
    
    
     @UI.lineItem: [{ position: 43 , importance: #MEDIUM  }]
    @UI.identification: [{ position: 43 }]
    @Semantics.amount.currencyCode: 'CurrencyCode'
    TotalPrice,
    
    
    @Consumption.valueHelpDefinition: [{ 
     entity: {
         name: 'I_Currency',
         element: 'Currency'
     }
   
    }]
    CurrencyCode,
    
 //  @UI.lineItem: [{ position: 45 , importance: #MEDIUM  }]
    @UI.identification: [{ position: 45 }]
    Description,
    
    @UI.lineItem: [{ position:15 , importance : #HIGH  },
                {type:#FOR_ACTION , dataAction: 'acceptTravel', label:'Accept Travel', position: 10 },
                {type:#FOR_ACTION , dataAction: 'rejectTravel', label:'Reject Travel',position: 20 }]
                
    
    @UI.identification: [{  position :15},
                {type:#FOR_ACTION , dataAction: 'acceptTravel', label:'Accept Travel',position: 10 },
                {type:#FOR_ACTION , dataAction: 'rejectTravel', label:'Reject Travel',position: 20 }]
    
    @UI.textArrangement: #TEXT_ONLY
    @UI.selectionField: [{ position :40 }]
    @EndUserText.label: 'OverAll Status'
    @Consumption.valueHelpDefinition: [{ 
     entity: {
         name: '/DMO/I_Overall_Status_VH',
         element: 'OverallStatus'
     }  
    }]
     @ObjectModel.text.element: [ 'overallstatustext' ]
    overallstatus,
    @UI.hidden: true
     _overallstatus._Text.Text as overallstatustext :localized,
    
    @UI.hidden: true
    Createdby,
    @UI.hidden: true
    Createdat,
    
    @UI.hidden: true
    Lastchangedby,
    @UI.hidden: true
    Lastchangedat,
    /* Associations */
    _agency,
    _booking : redirected to composition child zjosh_c_bookg_appr,
    _currency,
    _customer,
    _overallstatus
}
