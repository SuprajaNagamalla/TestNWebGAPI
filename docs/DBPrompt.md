# DB Prompt

This README captures the standardized prompt format we use when we need a SQL query
that can be dropped directly into the `rac_pad_db` module.  Following these
instructions ensures that new queries can be mapped into our Jackson-based DTOs
(such as `Agreement` or `CurrencyRecord`) without any ad-hoc clean up and that
test authors always receive both the statement and a representative result set.

## Output requirements

Every DB prompt MUST ask for the following deliverables:

1. **Executable SQL** – the statement should be ready to paste into a new
   constant in `AgreementQueries` (or the appropriate query class) with all
   aliases already applied.
2. **Result set sample** – provide a table that mirrors the output of running
   the SQL, using the exact column names that the Java DTO expects.  This gives
   the test author immediate feedback on the shape of the data.

## Column and aliasing conventions

When you construct prompts for SQL, make sure the expected output follows these
formatting rules:

- Use dot-delimited aliases (`AS "agreement_inventory.inventory_id"`) so the
  JDBC/Jackson mapper can populate nested DTO classes automatically.
- Where DTOs expose alternative property names (for example, via
  `@JsonProperty`/`@JsonAlias` in `CurrencyRecord`), mention both aliases in the
  prompt so the generated SQL remains compatible with existing getters.
- Keep monetary and numeric fields in their numeric form; do not cast to text
  unless the schema requires it.
- Reserve keywords (like `package`) should be prefixed/aliased (e.g. `_package`)
  so they map cleanly to Java fields.

## Prompt template

```text
You are preparing a SQL query for the RAC PAD automation database module.
Return two sections:
1. A SQL statement that already applies the snake_case or dot.notation aliases
   required by the Java DTOs.
2. A markdown table titled "Result Set" that shows a realistic row produced by
   the query, using the exact column names from the SQL.

Make sure the SQL uses the tables <TABLE REFERENCES HERE> and filters the data
according to <BUSINESS RULES HERE>.  Include lateral joins where needed to fetch
latest related records.  All numeric values should retain their numeric types.
```

Replace the bracketed placeholders with the business context you are solving.

## Example

The following example prompt produced the `SQL_SELECT_AGREEMENT_OVERVIEW_BY_ID`
query and the result set used by `AgreementDataUtil.fetchAgreementOverviewById`.

### SQL

```sql
SELECT   a.agreement_id                           AS agreement_id,
         a.agreement_number                       AS agreement_number,
         ac.customer_id                           AS "agreement_customer.customer_id",
         s.store_number                           AS "store.store_number",
         ai.inventory_id                          AS "agreement_inventory.inventory_id",
         CASE ps.ref_code
             WHEN 'WK' THEN COALESCE(ai.weekly_rate, ai.original_weekly_rate)
             WHEN 'BW' THEN ai.original_biweekly_rate
             WHEN 'SM' THEN ai.original_semi_monthly_rate
             WHEN '4W' THEN ai.original_fourweek_rate
             WHEN 'MO' THEN ai.original_monthly_rate
         END                                      AS "agreement_inventory.weekly_rate",
         CASE ps.ref_code
             WHEN 'WK' THEN COALESCE(ai.weekly_term, ai.original_weekly_term)
             WHEN 'BW' THEN ai.original_biweekly_term
             WHEN 'SM' THEN ai.original_semi_monthly_term
             WHEN '4W' THEN ai.original_fourweek_term
             WHEN 'MO' THEN ai.original_monthly_term
         END                                      AS "agreement_inventory.weekly_term",
         ip.cash_price                            AS "agreement_inventory.cash_price",
         ip.inventory_price_id                    AS "inventory_price.inventory_price_id",
         c.first_name                             AS "customer.first_name",
         c.dob                                    AS "customer.dob",
         addr.customer_id                         AS "address.customer_id",
         addr.zip                                 AS "address.zip",
         addr.plus4                               AS "address.plus4",
         a.agreement_id                           AS "address.agreement_id",
         s.store_number                           AS "address.store_number",
         sp.abbreviation                          AS "state_province.abbreviation",
         s.store_number                           AS "transfer.store_number",
         it.from_store_id                         AS "inventory_transfer.from_store_id",
         a.agreement_id                           AS "transfer.agreement_id",
         ai.inventory_id                          AS "transfer.inventory_id",
         c.customer_id                            AS "raf.customer_id",
         c.global_customer_id                     AS "raf.global_customer_id",
         c.first_name                             AS "raf.first_name",
         c.last_name                              AS "raf.last_name",
         a.agreement_id                           AS "raf.agreement_id",
         a.open_date                              AS agreement_open_date,
         pms.next_due_date                        AS next_due_date,
         rim.rms_item_number                      AS "item.rms_item_number",
         NULL::text                               AS "item.extended_aisle",
         NULL::text                               AS "item.location",
         inv.inventory_number                     AS "item.inventory_number",
         inv.inventory_desc                       AS "item.inventory_desc",
         inv.inventory_id                         AS "item.inventory_id",
         a.package_name                           AS _package,
         ps.ref_code                              AS schedule,
         asrc.ref_code                            AS source,
         ast.ref_code                             AS status,
         atp.ref_code                             AS type,
         appt_latest.appointment_completion_date  AS "delivery.delivered_date",
         s.store_number                           AS "api.store_number",
         (a.close_date IS NULL)                   AS "api.active",
         a.agreement_number                       AS "api.agreement_number"
FROM     racadm.agreement a
         JOIN racadm.store s
           ON s.store_id = a.store_id
         LEFT JOIN racadm.state_province sp
                ON sp.state_province_id = s.state_province_id
         JOIN racadm.agreement_type atp
           ON atp.agreement_type_id = a.agreement_type_id
         JOIN racadm.agreement_status_type ast
           ON ast.agreement_status_type_id = a.agreement_status_type_id
         LEFT JOIN racadm.agreement_source asrc
                ON asrc.agreement_source_id = a.agreement_source_id
         LEFT JOIN racadm.payment_schedule ps
                ON ps.payment_schedule_id = a.payment_schedule_id
         LEFT JOIN racadm.payment_summary pms
                ON pms.contract_id = a.agreement_id
               AND pms.contract_type_id = (
                   SELECT ct.contract_type_id
                     FROM racadm.contract_type ct
                    WHERE ct.ref_code = 'AGREEMENT')
         LEFT JOIN LATERAL (
             SELECT ac1.*
               FROM racadm.agreement_customer ac1
              WHERE ac1.agreement_id = a.agreement_id
              ORDER BY ac1.priority NULLS LAST,
                       ac1.end_date NULLS FIRST,
                       ac1.last_modified_date DESC
              LIMIT 1) ac ON TRUE
         LEFT JOIN racadm.customer c
                ON c.customer_id = ac.customer_id
         LEFT JOIN LATERAL (
             SELECT ai1.*
               FROM racadm.agreement_inventory ai1
              WHERE ai1.agreement_id = a.agreement_id
              ORDER BY ai1.end_date NULLS FIRST,
                       ai1.last_modified_date DESC
              LIMIT 1) ai ON TRUE
         LEFT JOIN racadm.inventory inv
                ON inv.inventory_id = ai.inventory_id
         LEFT JOIN LATERAL (
             SELECT ip1.*
               FROM racadm.inventory_price ip1
              WHERE ip1.inventory_id = inv.inventory_id
              ORDER BY ip1.last_modified_date DESC
              LIMIT 1) ip ON TRUE
         LEFT JOIN racadm.rms_item_master rim
                ON rim.rms_item_master_id = inv.rms_item_master_id
         LEFT JOIN LATERAL (
             SELECT ap.*
               FROM racadm.appointment ap
               JOIN racadm.appointment_inventory api
                 ON api.appointment_id = ap.appointment_id
              WHERE api.agreement_id = a.agreement_id
                AND api.inventory_id = ai.inventory_id
              ORDER BY ap.appointment_completion_date DESC NULLS LAST,
                       ap.last_modified_date DESC
              LIMIT 1) appt_latest ON TRUE
         LEFT JOIN LATERAL (
             SELECT ad.*
               FROM racadm.address ad
              WHERE ad.customer_id = c.customer_id
                AND COALESCE(ad.active = 1, TRUE)
              ORDER BY ad.last_modified_date DESC NULLS LAST,
                       ad.created_date DESC
              LIMIT 1) addr ON TRUE
         LEFT JOIN LATERAL (
             SELECT it1.*
               FROM racadm.inventory_transfer it1
              WHERE it1.inventory_id = ai.inventory_id
              ORDER BY it1.transfer_completion_date DESC NULLS LAST,
                       it1.last_modified_date DESC
              LIMIT 1) it ON TRUE
WHERE    a.agreement_id = 137175602;
```

### Result Set

| Name | Value |
| --- | --- |
| agreementid | 137175602 |
| agreementnumber | 8172897188 |
| agreementcustomer_customerid | 113786502 |
| store_storenumber | 04891 |
| agreementinventory_inventoryid | 122862744 |
| agreementinventory_weeklyrate | 28.99 |
| agreementinventory_weeklyterm | 34 |
| agreementinventory_cashprice | 616.04 |
| inventoryprice_inventorypriceid | 1110460 |
| customer_firstname | RickieA |
| address_customerid | 113786502 |
| address_zip | 01666 |
| address_plus | 8727 |
| address_agreementid | 137175602 |
| address_storenumber | 04891 |
| stateprovince_abbreviation | TX |
| customer_dob | 3b6161ce2c16c46f226e6e58b8193b33 |
| transfer_store_storenumber | 04891 |
| inventorytransfer_fromstoreid |  |
| transfer_agreementid | 137175602 |
| transfer_inventoryid | 122862744 |
| raf_customerid | 113786502 |
| raf_globalcustomerid | 878ff264-92ed-4ea8-8c63-af96225db721 |
| raf_firstname | RickieA |
| raf_lastname | Verbavdoc |
| raf_agreementid | 137175602 |
| agreementopendate | 2025-09-15 |
| nextduedate |  |
| item_rmsitemnumber | 200022659 |
| item_extendedaisle |  |
| item_location |  |
| item_inventorynumber | 9999221192020 |
| item_inventorydesc | GE 7,800 BTU SACC Portable Air Conditioner for Medium Rooms up to 350 sq ft. (11,000 BTU ASHRAE) |
| item_inventoryid | 122862744 |
| _package |  |
| schedule | WK |
| source | ARCO |
| status | PEND |
| type | RTO |
| delivery_delivereddate |  |
| api_storenumber | 04891 |
| api_active | true |
| api_agreementnumber | 8172897188 |

Use this structure as the blueprint for future prompts so new SQL additions
remain consistent and fully documented.
