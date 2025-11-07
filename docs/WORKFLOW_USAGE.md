# GitHub Workflows Usage Guide

This document explains how to use the parameterized GitHub workflows for manual test execution.

## Overview

The workflows have been updated to support **manual triggering only**, removing automatic execution on every commit. This allows for better control over when tests are executed and with what parameters.

## Available Workflows

### 1. API Regression Tests (`api-regression-tests.yml`)

**Purpose**: Execute API regression tests with customizable parameters.

**Trigger**: Manual only (via GitHub UI)

**Parameters**:
- **Groups**: TestNG groups to execute (default: `regression`)
- **Suite**: TestNG XML suite file path (default: `src/test/resources/testSuites/csm.xml`)
- **Publish**: Whether to publish Teams notifications (default: `true`)
- **Environment**: Test environment - QA, STG, or PROD (default: `QA`)

**How to run**:
1. Go to GitHub Actions in the repository
2. Select "API Regression Tests" workflow
3. Click "Run workflow"
4. Choose your branch (usually `main`)
5. Fill in the parameters as needed
6. Click "Run workflow"

### 2. RacPad CI (`racpad-ci.yml`)

**Purpose**: Execute UI and/or API tests with comprehensive parameterization.

**Trigger**: Manual only (via GitHub UI)

**Parameters**:
- **Environment**: QA, STG, or PROD (default: `QA`)
- **Groups**: Comma-separated TestNG groups (default: `smoke`)
- **TestNG XML UI**: Suite file for UI tests (default: `src/test/resources/testSuites/smoke.xml`)
- **TestNG XML API**: Suite file for API tests (default: `src/test/resources/testSuites/smoke.xml`)
- **Browser**: Browser for UI tests - chrome, firefox, or edge (default: `chrome`)
- **Publish Teams Notification**: Send Teams notifications - true or false (default: `false`)
- **Test Type**: Type of tests to run - both, ui-only, or api-only (default: `both`)

**How to run**:
1. Go to GitHub Actions in the repository
2. Select "RacPad CI" workflow
3. Click "Run workflow"
4. Choose your branch (usually `main`)
5. Fill in the parameters as needed
6. Click "Run workflow"

### 3. Scheduled Test Execution (`scheduled-tests.yml`)

**Purpose**: Optional scheduled execution that triggers other workflows.

**Trigger**: Manual only by default (schedule is commented out)

**Parameters**:
- **Enable Schedule**: Choose whether to enable scheduled execution

**How to enable scheduled execution**:
1. Edit `.github/workflows/scheduled-tests.yml`
2. Uncomment the `schedule` section
3. Commit and push the changes
4. The workflow will run automatically at the specified time

## Common Use Cases

### Running the Default API Regression Command
To execute the exact command: `./run_api_tests.sh --groups regression --suite src/test/resources/testSuites/csm.xml --publish true`

Use **API Regression Tests** workflow with default settings:
- Groups: `regression` (default)
- Suite: `src/test/resources/testSuites/csm.xml` (default)
- Publish: `true` (default)
- Environment: `QA` (default)

This will run the CSM test suite with regression groups and Teams notifications enabled.

### Running Smoke Tests on QA Environment
Use **RacPad CI** workflow with:
- Environment: `QA`
- Groups: `smoke`
- Test Type: `both`
- Browser: `chrome`

### Running Regression Tests on Staging
Use **API Regression Tests** workflow with:
- Groups: `regression`
- Environment: `STG`
- Publish: `true` (to get notifications)

### Running Only UI Tests with Firefox
Use **RacPad CI** workflow with:
- Test Type: `ui-only`
- Browser: `firefox`
- Environment: `QA`

### Running Custom Test Suite
Use either workflow with:
- Suite: Path to your custom XML file
- Groups: Your specific test groups

## Benefits of Manual Triggering

1. **Cost Control**: Tests run only when needed, reducing CI/CD costs
2. **Resource Management**: Better control over compute resource usage
3. **Targeted Testing**: Run specific test suites for specific purposes
4. **Environment Control**: Choose exactly which environment to test
5. **Flexible Scheduling**: Run tests when it makes sense for your workflow

## Migration Notes

- **Previous automatic triggers** on push/PR have been removed
- **Scheduled execution** is now optional and disabled by default
- **All existing parameterization** has been preserved and enhanced
- **New environment parameter** added for better test environment control
- **Test type selection** allows running UI-only, API-only, or both

## Support

If you need to restore automatic triggering for specific workflows, you can:
1. Add back the `push` and `pull_request` triggers in the workflow files
2. Enable the scheduled workflow by uncommenting the schedule section

For questions or issues, please contact the QA team.