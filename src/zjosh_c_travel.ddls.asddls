@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'consumption view travel processor app'
//@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity zjosh_c_travel 
provider contract transactional_query
as projection on zjosh_i_travel
{
    key TravelId,
    
    @ObjectModel.text.element: [ 'agencyName' ]
    AgencyId,
    _agency.Name as agencyName,
    @ObjectModel.text.element: [ 'customerName' ]
    CustomerId,
    _customer.LastName as customerName,
    BeginDate,
    EndDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    BookingFee,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    TotalPrice,
    CurrencyCode,
    Description,
    
    @ObjectModel.text.element: [ 'overallstatustext' ]
    overallstatus,
    _overallstatus._Text.Text as overallstatustext :localized,
    Createdby,
    Createdat,
    Lastchangedby,
    Lastchangedat,
//    LastChangedAtGlobal,
    /* Associations */
    _agency,
    _booking: redirected to composition child zjosh_c_bookg,
    _currency,
    _customer,
    _overallstatus
}
