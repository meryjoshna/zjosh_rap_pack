@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'interface view travel'
@Metadata.ignorePropagatedAnnotations: true
define root view entity zjosh_i_travel
  as select from zjosh_travle_dbt
  composition [0..*] of zjosh_i_bookg           as _booking

  association [0..1] to /DMO/I_Agency           as _agency       on $projection.AgencyId = _agency.AgencyID
  association [0..1] to /DMO/I_Customer         as _customer     on $projection.CustomerId = _customer.CustomerID
  association [1..1] to I_Currency              as _currency     on $projection.CurrencyCode = _currency.Currency
  association [1..1] to /DMO/I_Overall_Status_VH as _overallstatus on $projection.overallstatus = _overallstatus.OverallStatus

{
  key travel_id       as TravelId,

      agency_id       as AgencyId,
      customer_id     as CustomerId,
      begin_date      as BeginDate,
      end_date        as EndDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      booking_fee     as BookingFee,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price     as TotalPrice,
      currency_code   as CurrencyCode,
      description     as Description,
      overall_status   as overallstatus,
      
      @Semantics.user.createdBy: true
      createdby       as Createdby,
      
      @Semantics.systemDateTime.createdAt: true
      createdat       as Createdat,
      
      @Semantics.user.localInstanceLastChangedBy: true
      lastchangedby   as Lastchangedby,
      
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      lastchangedat   as Lastchangedat,
//     last_changed_at as LastChangedAtGlobal,   draft
      _agency,
      _customer,
      _currency,
      _overallstatus,
      _booking

}
