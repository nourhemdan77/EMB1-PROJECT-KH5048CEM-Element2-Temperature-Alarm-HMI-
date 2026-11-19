*** Settings ***
Documentation     Embedded Systems Software Integration Test Cases - Element 2 Car Temperature Alarm HMI
Library           Dialogs

*** Variables ***
${STATUS_OK}              OK
${STATUS_NOT_OKAY}        NOT OKAY
${TEST_LL}                ${0}
${TEST_LH}                ${30}
${FINAL_LL}               ${25}
${FINAL_LH}               ${30}
${OBSERVED_HIGH_TEMP}     ${43.6}

*** Keywords ***
Initialize HMI Hardware Environment
    [Arguments]    ${ll_init}    ${lh_init}
    Execute Manual Step    Confirm Arduino UNO Rev3 is powered, 16x2 LCD keypad shield is connected on A0, LM35 sensor is connected on A1, buzzer is on D2 (PD2), Red LED is on D3 (PD3), and limits are set to LL=${ll_init} C and LH=${lh_init} C.

Adjust Limit Button On Keypad
    [Arguments]    ${button_name}    ${target_value}
    Execute Manual Step    Press the ${button_name} button on the A0 keypad shield until the 16x2 LCD displays ${button_name}=${target_value} C.

Apply Sensor Temperature Stimulus
    [Arguments]    ${condition_description}
    Execute Manual Step    Set LM35 sensor thermal condition: ${condition_description}.

Verify LCD Display Status
    [Arguments]    ${expected_status}
    Execute Manual Step    Inspect 16x2 LCD and confirm live Temp, LL, LH, and status text '${expected_status}' are rendered clearly.

Verify Alert Outputs State
    [Arguments]    ${led_state}    ${buzzer_state}
    Execute Manual Step    Confirm Red LED on D3 (PD3) is ${led_state} and audible buzzer on D2 (PD2) is ${buzzer_state}.

*** Test Cases ***
#####################################################################################################################
SwIT_HMI_TempAlarm_0001
  [Tags]              MANUAL    BRINGUP    OBSERVED
  [Documentation]
  ...  Object Text: Checking that the HMI system initializes the 16x2 LCD, ADC, and GPIO pins cleanly upon power-on or reset
  ...  aTestGroup: HMI_TEMP_ALARM_CONTROL
  ...  aTestAuthor: Nour Hemdan
  ...  aReference: REQ_HMI_001, REQ_LCD_001
  ...  aTestGoal: Checking clean hardware bring-up and readable 16x2 LCD initialization

  Initialize HMI Hardware Environment    ${TEST_LL}    ${TEST_LH}
  Execute Manual Step    Press the Arduino UNO Rev3 hardware RESET button and wait for initialization to finish.
  Verify LCD Display Status    ${STATUS_OK}
#####################################################################################################################
SwIT_HMI_TempAlarm_0002
  [Tags]              MANUAL    FUNCTIONAL    OBSERVED
  [Documentation]
  ...  Object Text: Checking that the HMI displays OK and keeps Red LED and buzzer OFF when temperature is within [LL, LH]
  ...  aTestGroup: HMI_TEMP_ALARM_CONTROL
  ...  aTestAuthor: Nour Hemdan
  ...  aReference: REQ_HMI_002, REQ_ALARM_001
  ...  aTestGoal: Checking normal operating state when measured LM35 temperature is inside the inclusive range

  Initialize HMI Hardware Environment    ${TEST_LL}    ${TEST_LH}
  Apply Sensor Temperature Stimulus    Maintain LM35 reading strictly between ${TEST_LL} C and ${TEST_LH} C
  Verify LCD Display Status    ${STATUS_OK}
  Verify Alert Outputs State    OFF    SILENT
#####################################################################################################################
SwIT_HMI_TempAlarm_0003
  [Tags]              MANUAL    FUNCTIONAL    OVER_TEMP    OBSERVED
  [Documentation]
  ...  Object Text: Checking that the HMI displays NOT OKAY and activates Red LED and buzzer when temperature exceeds LH
  ...  aTestGroup: HMI_TEMP_ALARM_CONTROL
  ...  aTestAuthor: Nour Hemdan
  ...  aReference: REQ_HMI_003, REQ_ALARM_002
  ...  aTestGoal: Checking high-temperature alarm trigger when LM35 reading rises above LH (e.g., 43.6 C > 30 C)

  Initialize HMI Hardware Environment    ${TEST_LL}    ${TEST_LH}
  Apply Sensor Temperature Stimulus    Warm the LM35 sensor until displayed temperature exceeds ${TEST_LH} C (observed at ${OBSERVED_HIGH_TEMP} C)
  Verify LCD Display Status    ${STATUS_NOT_OKAY}
  Verify Alert Outputs State    ON    SOUNDING
#####################################################################################################################
SwIT_HMI_TempAlarm_0004
  [Tags]              MANUAL    FUNCTIONAL    RECOVERY    OBSERVED
  [Documentation]
  ...  Object Text: Checking that the HMI automatically clears NOT OKAY and turns off Red LED and buzzer when temperature returns inside [LL, LH]
  ...  aTestGroup: HMI_TEMP_ALARM_CONTROL
  ...  aTestAuthor: Nour Hemdan
  ...  aReference: REQ_HMI_004, REQ_ALARM_003
  ...  aTestGoal: Checking automatic alarm recovery when temperature returns inside valid limits

  Initialize HMI Hardware Environment    ${FINAL_LL}    ${FINAL_LH}
  Apply Sensor Temperature Stimulus    Observe temperature transition from 24.9 C (NOT OKAY) to 25.0 C (== LL)
  Verify LCD Display Status    ${STATUS_OK}
  Verify Alert Outputs State    OFF    SILENT
#####################################################################################################################
SwIT_HMI_TempAlarm_0005
  [Tags]              MANUAL    FUNCTIONAL    UNDER_TEMP    OBSERVED
  [Documentation]
  ...  Object Text: Checking that the HMI displays NOT OKAY and activates Red LED and buzzer when temperature falls below LL using final 25-30 C window
  ...  aTestGroup: HMI_TEMP_ALARM_CONTROL
  ...  aTestAuthor: Nour Hemdan
  ...  aReference: REQ_HMI_005, REQ_ALARM_004
  ...  aTestGoal: Checking low-temperature alarm trigger when LM35 reading drops below LL (observed at 24.9 C < 25 C)

  Initialize HMI Hardware Environment    ${FINAL_LL}    ${FINAL_LH}
  Adjust Limit Button On Keypad    LL    ${FINAL_LL}
  Adjust Limit Button On Keypad    LH    ${FINAL_LH}
  Apply Sensor Temperature Stimulus    Maintain LM35 reading at 24.9 C (strictly below ${FINAL_LL} C)
  Verify LCD Display Status    ${STATUS_NOT_OKAY}
  Verify Alert Outputs State    ON    SOUNDING
#####################################################################################################################
SwIT_HMI_TempAlarm_0006
  [Tags]              MANUAL    CORNER_CASE    BOUNDARY    OBSERVED
  [Documentation]
  ...  Object Text: Checking that boundary equality at Temp == LL and Temp == LH evaluates as inclusive valid OK state
  ...  aTestGroup: HMI_TEMP_ALARM_CONTROL
  ...  aTestAuthor: Nour Hemdan
  ...  aReference: REQ_HMI_006, REQ_CORNER_001
  ...  aTestGoal: Checking inclusive boundary condition when live temperature equals LL (25.0 C == 25 C) or LH exactly

  Initialize HMI Hardware Environment    ${FINAL_LL}    ${FINAL_LH}
  Execute Manual Step    Observe live Temp reaching 25.0 C equal to LL=25 C and verify inclusive OK state.
  Verify LCD Display Status    ${STATUS_OK}
  Verify Alert Outputs State    OFF    SILENT
#####################################################################################################################
SwIT_HMI_TempAlarm_0007
  [Tags]              MANUAL    CORNER_CASE    SAFETY_GUARD    PENDING
  [Documentation]
  ...  Object Text: Checking that keypad limit buttons prevent invalid inverted limits where LL exceeds LH
  ...  aTestGroup: HMI_TEMP_ALARM_CONTROL
  ...  aTestAuthor: Nour Hemdan
  ...  aReference: REQ_HMI_007, REQ_SAFETY_001
  ...  aTestGoal: Checking limit boundary protection so LL cannot be incremented above LH and LH cannot be decremented below LL

  Initialize HMI Hardware Environment    ${FINAL_LL}    ${FINAL_LH}
  Execute Manual Step    Attempt to press LL button repeatedly to push LL above ${FINAL_LH} C, then press LH button to push LH below ${FINAL_LL} C.
  Execute Manual Step    Confirm firmware clamps limit values so LL <= LH is always preserved on the 16x2 LCD.
#####################################################################################################################
SwIT_HMI_TempAlarm_0008
  [Tags]              MANUAL    CORNER_CASE    TIMING_AND_ACCURACY    OBSERVED
  [Documentation]
  ...  Object Text: Checking that rapid keypad button presses register without blocking ADC updates and verifying LM35 room-temperature accuracy
  ...  aTestGroup: HMI_TEMP_ALARM_CONTROL
  ...  aTestAuthor: Nour Hemdan
  ...  aReference: REQ_HMI_008, REQ_ADC_001
  ...  aTestGoal: Checking non-blocking debounce responsiveness and verifying room-temperature calibration accuracy (~25 C)

  Initialize HMI Hardware Environment    ${FINAL_LL}    ${FINAL_LH}
  Execute Manual Step    Press LL or LH button 4 times in quick succession and compare ambient LCD temperature (24.6 C - 25.0 C) against room temperature.
  Execute Manual Step    Confirm all 4 valid presses register without freezing the display and ambient temperature matches room temperature accurately.
#####################################################################################################################
SwIT_HMI_TempAlarm_0009
  [Tags]              MANUAL    HARDWARE_DEBUG    SIGNAL_STABILITY    OBSERVED
  [Documentation]
  ...  Object Text: Checking that removing the extra resistor on the sensor path eliminates fluctuating ADC readings on A1
  ...  aTestGroup: HMI_TEMP_ALARM_CONTROL
  ...  aTestAuthor: Nour Hemdan
  ...  aReference: REQ_HW_001, REQ_ADC_002
  ...  aTestGoal: Checking signal stability after removing extra resistor causing voltage fluctuations

  Initialize HMI Hardware Environment    ${TEST_LL}    ${TEST_LH}
  Execute Manual Step    Remove the extra resistor on the LM35 sensor line while keeping the LED current-limiting resistor on D3.
  Execute Manual Step    Confirm the temperature reading on the 16x2 LCD stabilizes without random jumps.
#####################################################################################################################
SwIT_HMI_TempAlarm_0010
  [Tags]              MANUAL    FAULT_DIAGNOSIS    SENSOR_REPLACEMENT_1    OBSERVED
  [Documentation]
  ...  Object Text: Checking fault behavior when the first LM35 sensor burned out and displayed 0.5 C on the 16x2 LCD
  ...  aTestGroup: HMI_TEMP_ALARM_CONTROL
