# API Documentation

This project provides API automation for the `dev2-ltopurchaseorder` service and related endpoints.
The API base path is `/lto/purchaseorder`.

It also covers the `dev2-packagepricing` service which uses the base path `/pricing`.
The project additionally automates the `dev2-pricingreport` service which uses the
base path `/pricing/report`.

The APIs for the `dev2-pricing` service are also supported. Those endpoints share
the base path `/pricing/info`.

Support is also included for the `dev2-legalengine` service which uses the base path `/legalengine`.

Automation support is also available for the `dev2-promoscheduler` service which uses the base path `/promo`.

Automation support is available for the `dev2-deapproval` service which uses the base path `/approval/dea123`.
Automation support is also available for the `dev2-customerorder` service which uses the base path `/customerorder`.
Automation support is also available for the `dev2-ltopurchaseorder` service which uses the base path `/lto/purchaseorder`.
Automation support is also available for the `dev2-leads` service which uses the base path `/leads`.
Automation support is also available for the `dev2-digitalauthoritativecopy` service which uses the base path `/documents/digitalauthoritativecopy`.

Automation support is also available for the `dev2-generatedocument` service which uses the base path `/documents`.

Automation support is also available for the `dev2-customerletter` service which uses the base path `/documents/customer`.

Automation support is also available for the `dev2-emprefinfo` service which uses the base path `/customer/employerref`.

Automation support is also available for the `dev2-deliveryreceipt` service which uses the base path `/agreement/deliveryreceipt`.

Automation support is also available for the `dev2-addressdoctor` service which uses the base path `/ens/address`.

Automation support is also available for the `dev2-promotionrewards` service which uses the base path `/promotion`.
Automation support is also available for the `dev2-manageemail` service which uses the base path `/email`.

Automation support is also available for the `dev2-raceventpublisher` service which uses the base path `/event`.




---

## dev-taxengine

Calcuate tax api calls taxengine shared module and return calculated response.

Cache Keys
  TAX_STATE_TEMPLATE_CACHE => This cache contains each state specific template information.
  TAX_REVENUE_STREAM_CACHE => This chche contains receipt item category and associated revenue stream.
  TAX_RECEIPT_ITEM_CATEGORY_CACHE => This cache contains receipt item category code and receitp item category id.
  TAX_RATE_TYPE_CACHE => This cache contains rate type code and rate type id.
  TAX_CLUB_TAXABLE_CACHE => This cache contains store profile config informaiton for club payment is taxable or not (IsClubCoverageNonTaxable).

Customer information is optional

Sample request
```json
{
  "postalCode": "92530-4568",
  "customerState": "CA",
  "customerId": "11244641",
  "taxExemptAsOfToday": "N",
  "dateOfBirth": "1950-02-03",
  "storeInputs": [{
    "storeNumber": "02720",
    "taxInputs": [{
      "itemCategory": "RPAY",
      "amount": "3.00",
      "taxInputId": "10"
    }]
  }]
}
```

