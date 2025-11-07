# RacPad Automation Framework

Welcome to the automated testing project for **RacPad**. This is a Maven multi‑module project that allows you to interact with the RacPad application through the API, the database and the browser UI.

The framework keeps the test logic separated into modules while sharing common utilities. Tests can be executed independently or together depending on what you are validating. It is designed for parallel execution and can drive browsers on a remote Selenium Grid whether the nodes are onshore or offshore. Test results are published to Jira Zephyr for full traceability.
An HTML version of this README is available as `README.html`.

## Modules

- **rac_pad_api** – API tests using Rest-Assured.
- **rac_pad_ui** – UI tests built with Selenium.
- **rac_pad_commons** – Shared utilities for logging, data providers, YAML helpers and random data generation.
- **rac_pad_db** – Lightweight utilities for executing database queries.
- **ODS MySQL connection** – Optional MySQL database used in some environments. The
  project includes the `mysql-connector-java` driver so these URLs can be pooled
  via `DBManager` when defined in `DbConfig`. When pooling MySQL connections the
  driver class `com.mysql.cj.jdbc.Driver` is automatically loaded.

## Project Structure

Below is a simplified view of the most important folders and classes:

```text
rac_paD
├── pom.xml
├── rac_pad_api
│   ├── pom.xml
│   └── src
│       ├── main/java/com/rentacenter/racpad
│       │   ├── base/                 # Rest client utilities
│       │   ├── data/                 # DTO models and request helpers
│       │   │   ├── address/
│       │   │   ├── agreement/create/
│       │   │   ├── agreement/epo/
│       │   │   ├── dap/
│       │   │   ├── documents/generate/
│       │   │   ├── payment/receipt/
│       │   │   ├── paymentsummary/
│       │   │   └── customer/
│       │   ├── dtos/
│       │   │   ├── address/
│       │   │   ├── agreement/create/
│       │   │   ├── agreement/epo/
│       │   │   ├── dap/
│       │   │   ├── documents/generate/
│       │   │   ├── payment/receipt/
│       │   │   ├── paymentsummary/
│       │   │   └── customer/
│       │   ├── endpoints/
│       │   │   ├── address/
│       │   │   ├── agreement/create/
│       │   │   ├── agreement/epo/
│       │   │   ├── dap/
│       │   │   ├── findcustomer/
│       │   │   ├── documents/generate/
│       │   │   ├── payment/receipt/
│       │   │   └── paymentsummary/
│       │   ├── macros/
│       │   │   └── customer/
│       │   └── services/
│       │       ├── address/
│       │       ├── agreement/create/
│       │       ├── agreement/epo/
│       │       ├── dap/
│       │       ├── findcustomer/
│       │       ├── documents/generate/
│       │       ├── payment/receipt/
│       │       ├── paymentsummary/
│       │       └── customer/
│       ├── test/java/api/tests       # API test classes
│       └── test/resources
│           ├── testSuites/smoke.xml
│           ├── testData/customer.yaml
│           ├── testData/login.yaml
│           ├── testData/agreement/create.yaml
│           ├── testData/findcustomer.yaml
│           ├── testData/updatecustomer.yaml
│           ├── allure.properties
│           ├── chaintest.properties
│           └── zephyr.properties
├── rac_pad_ui
│   ├── pom.xml
│   └── src
│       ├── main/java/com/rentacenter/racpad/pages
│       │   ├── AccountManagement/
│       │   ├── Admin/
│       │   ├── Customer/
│       │   ├── DashBoard/
│       │   ├── Inventory/
│       │   ├── Operations/
│       │   ├── Payment/
│       │   └── Store/
│       ├── test/java/com/rentacenter/racpad/tests    # UI test classes
│       └── test/resources
│           ├── testSuites/smoke.xml
│           ├── testData/account_management.yaml
│           ├── testData/customer_create.yaml
│           ├── testData/customer.yaml
│           ├── testData/login.yaml
│           ├── allure.properties
│           ├── chaintest.properties
│           └── zephyr.properties
├── rac_pad_commons
│   ├── pom.xml
│   └── src/main/java/com/rentacenter/racpad/commons
│       ├── annotations/
│       ├── datautil/
│       ├── enums/
│       ├── exceptions/
│       ├── logs/
│       ├── supportutil/
│       ├── ui_testutil/
│       └── Listeners/
├── rac_pad_db
│   ├── pom.xml
│   └── src/main/java/com/rentacenter/racpad/db
│       ├── DBManager.java
│       ├── DBUtil.java
│       └── QueryBuilder.java
└── src/main/resources
    └── log4j2.xml                # Logging configuration
```

## Features

- End-to-end automation covering API, DB and UI flows
- Common utilities to read test data, generate random values and perform assertions
- Modular design so API and UI tests can run together or separately
- Detailed reports via Allure
- Parallel execution enabled via TestNG
- Connects to Selenium Grid nodes onshore or offshore
- Publishes execution results to Jira Zephyr

## Test Data in YAML

Test data for each feature lives in the `src/test/resources/testData` folders as YAML files. Using YAML keeps the test data next to the code and under version control.

### Why YAML instead of Excel?

* **Readable diffs** – Git can easily show line by line changes
* **Flexible structures** – nested maps/lists without messy cell merges
* **In-file changes (IFC)** – make quick edits without exporting and importing spreadsheets
* **Plain text** – any IDE or text editor can read it

With IFC you simply update the YAML file in place and commit the change. No more exporting Excel sheets or losing track of versions.

Every test class uses a TestNG `@DataProvider` to read rows from YAML via `YamlUtil` and `DataProviderFactory`. Example:

```java
@Test(dataProvider = "yaml-provider", dataProviderClass = DataProviderFactory.class)
@TestDetails(featureName = "customer", testCaseIds = {"TC_002"})
public void testManageCustomer(Map<String, Object> data) {
    // test logic here
}
```
Each YAML record may include an optional `runMode` flag. When set to `false`,
that row is excluded from the DataProvider so the test does not execute for that
dataset. You can also restrict a data row to specific TestNG groups by adding a
`groups` list.

* When the test method does not declare groups, **all** rows are included.
* When you specify groups (via the `@Test` annotation or your TestNG XML), a row
  must define a `groups` list containing at least one of those groups to be used.
* Rows without a `groups` property are ignored whenever any groups are active.
* Groups declared in your XML suite are detected across TestNG versions so the
  same YAML file works consistently.

This allows a single YAML file to drive smoke, regression and other group-based
executions without duplication.
### Random Data Tokens

The YAML files support special placeholders that the framework replaces with random values. Below is the full list of supported tokens from `TestDataRandomizer`:

- `randomfirstname`
- `randomlastname`
- `randomfullname`
- `randomusername`
- `randomemail`
- `randomphonenumber`
- `randomstreetaddress`
- `randomsecondaryaddress`
- `randomcity`
- `randomstate`
- `randomzipcode`
- `randompostalcode`
- `randomcountry`
- `randomcountrycode`
- `randomuuid` / `randomguid`
- `randomcompanyname`
- `randomcompany`
- `randomcompanysuffix`
- `randomjobtitle`
- `randomjob`
- `randomurl`
- `randomipv4`
- `randomipv6`
- `randompassword`
- `randomcreditcard`
- `randomiban`
- `randomdogname`
- `randomdogbreed`
- `randomcatname`
- `randompokemon`
- `randomsuperhero`
- `randomgameofthronescharacter`
- `randomharrypottercharacter`
- `randomchucknorrisfact`
- `randomyodawisdom`
- `randomrickandmortycharacter`
- `randomshakespearequote`
- `randomshakespeareking`
- `randomspaceplanet`
- `randomweathertemperature`
- `randomwitchermonster`
- `randombacktothefuturequote`
- `randomdragonballcharacter`
- `randomancientgod`
- `randomaviationaircraft`
- `randombeername`
- `randombeerstyle`
- `randombooktitle`
- `randombookauthor`
- `randombookpublisher`
- `randomcolorname`
- `randomfoodspice`
- `randomfooddish`
- `randomhackerabbreviation`
- `randomhipsterword`
- `randomhobbitquote`
- `randomhowimetyourmothercharacter`
- `randommusicgenre`
- `randommusicinstrument`
- `randomnationcapital`
- `randomnationlanguage`
- `randomprogramminglanguage`
- `randomsoftware`
- `randomstocksymbol`
- `randomstockexchange`
- `randomteamname`
- `randomuniversity`
- `randomuniversitysuffix`
- `randomavatarimage`
- `randomeducationcollege`
- `randomeducationsecondaryschool`
- `randomesportsteam`
- `randomfilemime`
- `randomfilefilename`
- `randomcaffeineblend`
- `randomusstate`
- `randomcellphone<N>` – digits only, length defined by `<N>`
- `randomdigits<N>` – sequence of `<N>` digits
- `randomyear_<start>_<end>` – random year within the given range
- `randomyearpast2` – year within the last two years
- `randomyearfuture2` – year within the next two years
- `randomdate` – random date between 1970‑01‑01 and today
- `randomdate_yyyy_mm_dd_between_<start>_<end>` – date within the given range
- `randomdate_past_<N>_days` – date within the past `<N>` days
- `randomdate_future_<N>_days` – date within the next `<N>` days
- `randomtoday_<pattern>` – today's date using the given format
- `randomtodayplus<N>_<pattern>` – date `<N>` days after today using the format
- `randomtodayminus<N>_<pattern>` – date `<N>` days before today using the format
- `randomnow` – current date and time in ISO 8601 format
- `randomnow_<pattern>` – current date and time using the given format
- `randomnowplus<N>_<pattern>` – date/time `<N>` days after now using the format
- `randomnowminus<N>_<pattern>` – date/time `<N>` days before now using the format
- All date/time tokens use the US Central time zone by default
- Append `@<zone>` to any of the above—including `randomtodayplus*`, `randomtodayminus*`, and all `randomnow*` variants—to override the time zone (e.g. `randomnow@UTC` or `randomtoday_yyyy-MM-dd'T'HH:mm:ss.SSSXXX@UTC`)
  - Examples: `randomtodayplus1_yyyy-MM-dd@UTC`, `randomtodayminus2_yyyy-MM-dd@UTC`, `randomnow_yyyy-MM-dd'T'HH:mm:ss.SSSXXX@UTC`
- Use `MM` for months in date patterns (e.g. `yyyy-MM-dd`)
- `randomoption_<value1>_<value2>_..._<valueN>` – choose one of the listed options
- `randomoptionkc_<value1>_<value2>_..._<valueN>` – choose one option preserving case

Example snippet:

```yaml
firstName: "randomfirstName"
lastName: "randomlastName"
emailAddress: "randomemail"
phoneNumber: "randomcellphone10"
addressLine1: "randomstreetaddress"
city: "randomcity"
state: "randomusstate"
postalCode: "randomzipcode"
```

### Example Random Values

| Token | Sample Output |
|-------|---------------|
| `randomfirstname` | `Alice` |
| `randomlastname` | `Johnson` |
| `randomfullname` | `Alice Johnson` |
| `randomusername` | `alicej` |
| `randomemail` | `alice.johnson@example.com` |
| `randomphonenumber` | `555-010-1234` |
| `randomstreetaddress` | `742 Evergreen Terrace` |
| `randomsecondaryaddress` | `Apt 2B` |
| `randomcity` | `Springfield` |
| `randomstate` | `Illinois` |
| `randomzipcode` | `62704` |
| `randompostalcode` | `90420` |
| `randomcountry` | `United States` |
| `randomcountrycode` | `US` |
| `randomuuid` | `d290f1ee-6c54-4b01-90e6-d701748f0851` |
| `randomcompanyname` | `Globex Corporation` |
| `randomcompany` | `Initech` |
| `randomcompanysuffix` | `LLC` |
| `randomjobtitle` | `QA Engineer` |
| `randomjob` | `Software Tester` |
| `randomurl` | `https://example.com` |
| `randomipv4` | `203.0.113.42` |
| `randomipv6` | `2001:db8::1` |
| `randompassword` | `s3cr3tP@ss` |
| `randomcreditcard` | `4111-1111-1111-1111` |
| `randomiban` | `GB33BUKB20201555555555` |
| `randomdogname` | `Rover` |
| `randomdogbreed` | `Labrador Retriever` |
| `randomcatname` | `Whiskers` |
| `randompokemon` | `Pikachu` |
| `randomsuperhero` | `Spider-Man` |
| `randomgameofthronescharacter` | `Arya Stark` |
| `randomharrypottercharacter` | `Hermione Granger` |
| `randomchucknorrisfact` | `Chuck Norris counted to infinity... Twice.` |
| `randomyodawisdom` | `Do or do not. There is no try.` |
| `randomrickandmortycharacter` | `Rick Sanchez` |
| `randomshakespearequote` | `To be, or not to be` |
| `randomshakespeareking` | `Henry V` |
| `randomspaceplanet` | `Mars` |
| `randomweathertemperature` | `72°F` |
| `randomwitchermonster` | `Striga` |
| `randombacktothefuturequote` | `Great Scott!` |
| `randomdragonballcharacter` | `Goku` |
| `randomancientgod` | `Zeus` |
| `randomaviationaircraft` | `Boeing 747` |
| `randombeername` | `Imperial Stout` |
| `randombeerstyle` | `IPA` |
| `randombooktitle` | `The Great Adventure` |
| `randombookauthor` | `Jane Austen` |
| `randombookpublisher` | `Penguin Books` |
| `randomcolorname` | `Crimson` |
| `randomfoodspice` | `Cinnamon` |
| `randomfooddish` | `Spaghetti Bolognese` |
| `randomhackerabbreviation` | `CPU` |
| `randomhipsterword` | `artisan` |
| `randomhobbitquote` | `Second breakfast, anyone?` |
| `randomhowimetyourmothercharacter` | `Barney Stinson` |
| `randommusicgenre` | `Jazz` |
| `randommusicinstrument` | `Guitar` |
| `randomnationcapital` | `London` |
| `randomnationlanguage` | `English` |
| `randomprogramminglanguage` | `Java` |
| `randomsoftware` | `Photoshop` |
| `randomstocksymbol` | `RAC` |
| `randomstockexchange` | `NYSE` |
| `randomteamname` | `Racers` |
| `randomuniversity` | `State University` |
| `randomuniversitysuffix` | `Institute of Technology` |
| `randomavatarimage` | `https://example.com/avatar.png` |
| `randomeducationcollege` | `RacPad College` |
| `randomeducationsecondaryschool` | `Springfield High` |
| `randomesportsteam` | `Team Alpha` |
| `randomfilemime` | `image/png` |
| `randomfilefilename` | `document.pdf` |
| `randomcaffeineblend` | `House Blend` |
| `randomusstate` | `Texas` |
| `randomcellphone10` | `5551237890` |
| `randomdigits5` | `34847` |
| `randomyear_1990_2000` | `1998` |
| `randomyearpast2` | `2024` |
| `randomyearfuture2` | `2026` |
| `randomdate` | `2018-05-21` |
| `randomdate_yyyy_mm_dd_between_2020_01_01_2020_12_31` | `2020-07-15` |
| `randomdate_past_10_days` | `2025-05-27` |
| `randomdate_future_10_days` | `2025-06-16` |
| `randomtoday_yyyy-MM-dd` | `2025-07-24` |
| `randomtodayplus5_yyyy-MM-dd` | `2025-07-29` |
| `randomtodayminus5_yyyy-MM-dd` | `2025-07-19` |
| `randomtoday_yyyy-MM-dd'T'HH:mm:ss.SSSXXX@UTC` | `2025-09-02T11:09:05.352Z` |
| `randomnow@UTC` | `2025-09-02T11:09:05.352Z` |
| `randomnow_yyyy-MM-dd'T'HH:mm:ss.SSSXXX` | `2025-09-02T11:09:05.352-05:00` |
| `randomnowplus1_yyyy-MM-dd'T'HH:mm:ss.SSSXXX` | `2025-09-03T11:09:05.352-05:00` |
| `randomnowminus1_yyyy-MM-dd'T'HH:mm:ss.SSSXXX` | `2025-09-01T11:09:05.352-05:00` |
| `randomoption_red_blue_green` | `blue` |
| `randomoptionkc_AAA_BBB` | `AAA` |

### Context Variable Placeholders

Use `{{key}}` tokens in YAML to reference values stored in `TestDataContext`. Tests
can capture IDs from one API call and inject them into the next. Example:

```java
var resp = Customer_CustService.createCustomer(...);
CreateCustomerProjection proj = resp.as(CreateCustomerProjection.class);
TestDataContext.put("customerId", proj.getCustomerId());
```

```yaml
customerId: "{{customerId}}"
agreementAmountDue:
  - agreementId: "{{agreementId}}"
```

Placeholders are resolved when you call `TestDataSubstitutor.resolve()` after
populating `TestDataContext` in a setup method. For frameworks that run a
`@BeforeMethod` before each test, store the IDs there and resolve the YAML row
inside the test:

```java
@BeforeMethod(alwaysRun = true)
public void createFlowData() {
    var resp = Customer_CustService.createCustomer(
            CreateCustomerData.randomManageCustomerRequest());
    TestDataContext.put("customerId",
            resp.as(CreateCustomerProjection.class).getCustomerId());
    // store other values like agreementId here
}

@Test
public void someTest(Map<String,Object> data) {
    Map<String,Object> resolved = TestDataSubstitutor.resolve(data);
    // build DTO from 'resolved'
}
```

### Large Data Lists

When a YAML file becomes too large or you want to reuse the same schema with
records from another source, place those maps in `TestDataContext` and invoke
the `list-provider` from `DataProviderFactory`. The provider iterates for as
many elements as appear in the list.

```java
@BeforeClass
public void loadCustomers() {
    List<Map<String, Object>> rows = new ArrayList<>();
    rows.add(Map.of("firstName", "John", "lastName", "Doe", "expectedStatus", 200));
    rows.add(Map.of("firstName", "Jane", "lastName", "Smith", "expectedStatus", 200));
    rows.add(Map.of("firstName", "Bob", "lastName", "Brown", "expectedStatus", 200));

    TestDataContext.put("listData", rows);
}

@Test(dataProvider = "list-provider", dataProviderClass = DataProviderFactory.class)
public void createCustomerBulk(Map<String, Object> row) {
    Customer_CustService.createCustomer(CreateCustomerData.buildFromMap(row));
    // assertions here
}
```

This approach keeps the YAML-driven structure intact while allowing
large sets of customer data to be supplied from any source.

### Context List Placeholders

Use `<<key>>` tokens when you store a `List` in `TestDataContext`. The
`yaml-list-provider` expands the row once for each element of the list. Example:

```java
@BeforeClass
public void loadUserNames() {
    TestDataContext.put("userName", List.of(
            "user1@example.com",
            "user2@example.com",
            "user3@example.com"
    ));
}

@Test(dataProvider = "yaml-list-provider", dataProviderClass = DataProviderFactory.class)
@TestDetails(featureName = "customer_create", testCaseIds = {"TC_001"})
public void createCustomer(Map<String, Object> data) {
    // build request from data
}
```

```yaml
TC_001:
  DEFAULT:
    - username: "<<userName>>"
      password: "1Password1"
      firstName: "randomfirstname"
      lastName: "randomlastname"
      groups: [smoke]
  - username: "<<userName>>"
      password: "1Password1"
      firstName: "randomfirstname"
      lastName: "randomlastname"
      groups: [regression]
```

### Suite Vault

Sometimes multiple tests in the same execution need to share values such as
IDs or authorization tokens. Use `SuiteVault` to keep such data in memory
for the duration of the suite. Any object type can be stored:

```java
// primitives or strings
SuiteVault.put("token", authToken);

// lists and maps
SuiteVault.put("ids", List.of(1, 2, 3));

// Java 17 record types
record User(String username, String role) {}
SuiteVault.put("admin", new User("jsmith", "ADMIN"));

// retrieving values (cast to the expected type)
String token = SuiteVault.get("token");
List<Integer> ids = SuiteVault.get("ids");
User admin = SuiteVault.get("admin");
```

`BaseTest` automatically clears the vault in `@AfterSuite`, ensuring each run
starts fresh.

## Technology Stack

* **Selenium** for browser-based UI automation
* **Rest-Assured** for API interactions
* **TestNG** as the test runner
* **Allure** for beautiful test reports
* **JavaFaker** to create random data on the fly

## Running the Tests

Use Maven to execute the desired modules:

```bash
mvn clean test -pl rac_pad_ui               # run UI tests
mvn clean test -pl rac_pad_api              # run API tests
mvn clean test -pl rac_pad_api,rac_pad_ui   # run both
```

Specify `remote_chrome`, `remote_edge` or `remote_firefox` as the browser value
to run tests on the built-in Selenium Grid. Use the system property
`-Dselenium.grid.url=<url>` to point to a different Grid. Without this property,
the framework defaults to `http://10.252.41.230:4444`.

### Convenience scripts

* **Windows:** run `run_api_tests.bat` to execute the default API regression
  suite.
* **Linux/macOS:** run `./run_api_tests.sh` for the same behaviour. The script
  supports `--groups`, `--suite` and `--publish` options (or the
  `API_GROUPS`, `API_SUITE` and `API_PUBLISH` environment variables) so the
  TestNG groups, suite file and Teams notification flag can be changed without
  editing the script. Pass `--dry-run` to print the Maven command without
  executing it.

### Property Precedence

Test configuration values such as `browser`, `env` and `testType` can be
specified in several ways. The framework resolves them in the following order:

1. **System properties** passed via Maven or the command line
2. **TestNG XML parameters** when executing a suite file
3. The `local.properties` file in the project root when running a single test
   from the IDE

Local properties are loaded only if neither system properties nor XML parameters
provide a value. This lets Maven or suite files override the defaults while
keeping sensible values for individual test runs.

### Retry and Skipped Tests

Any test result marked as **skipped** is treated as a failure and will be
retried up to two additional times. If a later retry passes, the test is
reported as passed; otherwise the final attempt is recorded as failed.

### Exception Handling

Initialization steps such as database setup or WebDriver creation now catch
their own exceptions and log helpful messages. WebDriver failures are rethrown
as unchecked exceptions so the suite stops with a clear message instead of
continuing with a null driver. Unexpected values for browser, environment,
language or testType are also handled gracefully. These safeguards prevent
abrupt suite termination when configuration issues occur.

## Allure Reports

After the tests finish, run the report scripts to generate Allure HTML reports:

```bash
./generate_api-allure-report.bat
./generate_ui-allure-report.bat
```

---

This framework provides a single place to automate RacPad using API, DB and UI interactions while keeping test data in maintainable YAML files.
