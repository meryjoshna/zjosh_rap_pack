@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'consumption view for travel dra'
@Metadata.ignorePropagatedAnnotations: true

@Metadata.allowExtensions: true
@Search.searchable: true

define root view entity zjosh_c_travel_D
provider contract transactional_query
 as projection on zjosh_i_travel_D
{
key TravelUUID,

      @Search.defaultSearchElement: true
      TravelID,

      @Search.defaultSearchElement: true
      @ObjectModel.text.element: ['AgencyName']
      @Consumption.valueHelpDefinition: [{ entity : {name: '/DMO/I_Agency', element: 'AgencyID'  } }]
      AgencyID,
      _Agency.Name       as AgencyName,

      @Search.defaultSearchElement: true
      @ObjectModel.text.element: ['CustomerName']
      @Consumption.valueHelpDefinition: [{ entity : {name: '/DMO/I_Customer', element: 'CustomerID'  } }]
      CustomerID,
      _Customer.LastName as CustomerName,

      BeginDate,

      EndDate,
      
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,

      @Consumption.valueHelpDefinition: [{entity: {name: 'I_Currency', element: 'Currency' }}]
      CurrencyCode,

      Description,
      
      @ObjectModel.text.element: ['OverallStatusText']
      @Consumption.valueHelpDefinition: [{ entity: {name: '/DMO/I_Overall_Status_VH', element: 'OverallStatus' } }]      
      OverallStatus,
      _OverallStatus._Text.Text as OverallStatusText : localized, 
      

      LocalLastChangedAt,
      /* Associations */
      _Agency,
      _Booking : redirected to composition child zjosh_c_bookg_D,
      _Currency,
      _OverallStatus, 
      _Customer
}


