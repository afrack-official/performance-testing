# Simulating Multiple Stores for Transaction Processing and Actions in Real-Time Scenarios

## Objective:
To test the performance of the channels: FPOS, OrbisWeb, and HHT.

---

## Channels with Script Files

1. **FPOS**:  
   - `FPOS_ShellPerformance.jmx`

2. **OrbisWeb**:  
   - `OW_PerformanceTesting.jmx`

3. **HHT**:  
   - `HHT_PerformanceTesting.jmx`

---

## Verification Scripts (for new test builds in the environment)

1. **FPOS**:  
   - `FPOS_CheckingScripts.jmx`

2. **OrbisWeb**:  
   - `OW_CheckingScripts.jmx`

3. **HHT**:  
   - `HHT_CheckingScripts.jmx`

---

## Folders Overview

### Configurations Folder:
Contains test property files.

- `DryRun.properties`
- `EnduranceTest.properties`
- `LoadTest.properties`
- `Maintenance.properties`
- `SmokeTest.properties`
- `StressTest.properties`
- `Test.properties`
- `FPOS_Clear.properties`

### Cleanup Scripts Folder:
These scripts are used to clean existing data in OrbisWeb before conducting tests, particularly for certain transactions.

- `UK_CleanUp.jmx`
- `NL_CleanUp.jmx`
- `SA_CleanUp.jmx`
- `FPOS_Clear.jmx`

### TestResults Folder:
- FPOS transactions will be placed in this folder and sent to the respective stores during test execution.

### Variables Folder:
- Contains channel debug variable text files that capture the test variables used in the test scripts.

---

## Archives Folder  
Contains individual test scripts for FPOS, HHT, and OrbisWeb.
