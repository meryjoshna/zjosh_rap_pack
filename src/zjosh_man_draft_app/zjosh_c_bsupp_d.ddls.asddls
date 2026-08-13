@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'consumption view booking  supp dra'
@Metadata.ignorePropagatedAnnotations: true

@Metadata.allowExtensions: true
@Search.searchable: true

define view entity zjosh_c_bsupp_d as projection on zjosh_i_bsupp_d
{
   key BookSupplUUID,

      TravelUUID,

      BookingUUID,

      @Search.defaultSearchElement: true
      BookingSupplementID,

      @ObjectModel.text.element: ['SupplementDescription']
      @Consumption.valueHelpDefinition: [ {entity: {name: '/DMO/I_Supplement', element: 'SupplementID' } ,
                     additionalBinding: [ { localElement: 'BookSupplPrice',  element: 'Price', usage: #RESULT },
                                          { localElement: 'CurrencyCode', element: 'CurrencyCode', usage: #RESULT }] }] 
      SupplementID,
      _SupplementText.Description as SupplementDescription : localized,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookSupplPrice,

      @Consumption.valueHelpDefinition: [{entity: {name: 'I_Currency', element: 'Currency' }}]
      CurrencyCode,

      LocalLastChangedAt,

      /* Associations */
      _Booking : redirected to parent zjosh_c_bookg_D,
      _Product,
      _SupplementText,
      _Travel  : redirected to zjosh_c_travel_D
}

