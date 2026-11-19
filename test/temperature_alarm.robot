*** Settings ***
Documentation    Embedded Systems Project Test Cases - Element 2 Car Temperature Alarm HMI
Library          Dialogs

*** Variables ***
${TEMP_LL}       0
${TEMP_LH}       30
${FINAL_LL}      25
${FINAL_LH}      30

*** Keywords ***
Verify Hardware Setup
    Execute Manual Step    Confirm Arduino UNO Rev3 is powered, 16x2 LCD keypad shield is seated on A0, LM35 sensor is connected to A1, buzzer is on D2 (PD2), and Red LED is on D3 (PD3).

Set Temperature Limits Via Keypad
    [Arguments]    ${ll_value}    ${lh_value}
    Execute Manual Step    Press the LL and LH buttons on the A0 keypad shield until the 16x2 LCD displays LL=${ll_value} and LH=${lh_value}.

Verify Normal OK Outputs
    Execute Manual Step    Verify the 16x2 LCD displays 'OK', the Red LED (D3) is OFF, and the buzzer (D2) is SILENT.

Verify Alarm NOT OKAY Outputs
    Execute Manual Step    Verify the 16x2 LCD displays 'NOT OKAY', the Red LED (D3) is ON, and the buzzer (D2) is SOUNDING.

*** Test Cases ***
Test Case 1: Power-On Bringup and 16x2 LCD Initialization
    [Documentation]    Verify clean system startup and readable 16x2 LCD display layout.
    # Arrange (Set up the test environment)
    Verify Hardware Setup

    # Act (Perform the action to be tested)
    Execute Manual Step    Press the Arduino UNO hardware RESET button and allow firmware initialization to complete.

    # Assert (Verify the expected outcome)
    Execute Manual Step    Confirm both rows of the 16x2 LCD render Temp, LL, LH, and status fields clearly without corrupted characters.

Test Case 2: Within-Range Normal Operation (OK State)
    [Documentation]    Verify LCD displays OK and both alarm outputs stay off when Temp is inside the inclusive [LL, LH] range.
    # Arrange (Set up the test environment)
    Set Temperature Limits Via Keypad    ${TEMP_LL}    ${TEMP_LH}

    # Act (Perform the action to be tested)
    Execute Manual Step    Keep the LM35 temperature sensor at an ambient reading strictly between ${TEMP_LL} C and ${TEMP_LH} C.

    # Assert (Verify the expected outcome)
    Verify Normal OK Outputs

Test Case 3: Above Higher Limit Alarm Trigger (Over-Temperature)
    [Documentation]    Verify LCD displays NOT OKAY and activates Red LED and buzzer when Temp exceeds LH (e.g., 43.6 C > 30 C).
    # Arrange (Set up the test environment)
    Set Temperature Limits Via Keypad    ${TEMP_LL}    ${TEMP_LH}

    # Act (Perform the action to be tested)
    Execute Manual Step    Apply gentle heat to the LM35 sensor until the displayed temperature rises above ${TEMP_LH} C (e.g., 43.6 C).

    # Assert (Verify the expected outcome)
    Verify Alarm NOT OKAY Outputs

Test Case 4: Automatic Alarm Recovery Within Range
    [Documentation]    Verify system automatically clears NOT OKAY and turns off LED and buzzer when Temp cools back into [LL, LH].
    # Arrange (Set up the test environment)
    Execute Manual Step    Confirm system is currently in the NOT OKAY alarm state above ${TEMP_LH} C with LL=${TEMP_LL} and LH=${TEMP_LH}.

    # Act (Perform the action to be tested)
    Execute Manual Step    Remove the heat source and allow the LM35 sensor to cool back down inside [${TEMP_LL}, ${TEMP_LH}] C.

    # Assert (Verify the expected outcome)
    Verify Normal OK Outputs

Test Case 5: Below Lower Limit Alarm Trigger (Final 25-30 C Range)
    [Documentation]    Verify LCD displays NOT OKAY and activates Red LED and buzzer when Temp drops below LL using final 25-30 C range.
    # Arrange (Set up the test environment)
    Set Temperature Limits Via Keypad    ${FINAL_LL}    ${FINAL_LH}

    # Act (Perform the action to be tested)
    Execute Manual Step    Cool the LM35 sensor (or adjust limits) so the displayed temperature is strictly below ${FINAL_LL} C.

    # Assert (Verify the expected outcome)
    Verify Alarm NOT OKAY Outputs

Test Case 6: Inclusive Boundary Equality at LL and LH
    [Documentation]    Corner case: Verify Temp == LL and Temp == LH remain in the valid OK state.
    # Arrange (Set up the test environment)
    Verify Hardware Setup

    # Act (Perform the action to be tested)
    Execute Manual Step    Adjust LL equal to the live displayed Temp, observe status, then adjust LH equal to the live displayed Temp.

    # Assert (Verify the expected outcome)
    Verify Normal OK Outputs

Test Case 7: Invalid Limit Inversion Prevention (LL > LH Guard)
    [Documentation]    Corner case: Verify keypad buttons cannot set LL higher than LH or LH lower than LL.
    # Arrange (Set up the test environment)
    Set Temperature Limits Via Keypad    ${FINAL_LL}    ${FINAL_LH}

    # Act (Perform the action to be tested)
    Execute Manual Step    Repeatedly press the LL button to push LL past ${FINAL_LH} C, then press the LH button to push LH below ${FINAL_LL} C.

    # Assert (Verify the expected outcome)
    Execute Manual Step    Confirm the firmware clamps the thresholds so LL never exceeds LH.

Test Case 8: Rapid Button Press Responsiveness and Calibration Check
    [Documentation]    Verify short debounce registers consecutive button presses without dropping inputs and check room-temperature accuracy.
    # Arrange (Set up the test environment)
    Verify Hardware Setup

    # Act (Perform the action to be tested)
    Execute Manual Step    Press the LL or LH button 4 times in quick succession and compare the displayed ambient temperature against a reference thermometer.

    # Assert (Verify the expected outcome)
    Execute Manual Step    Confirm all 4 valid presses register on the LCD without freezing and ambient temperature matches room temperature accurately.

Test Case 9: Removing Extra Resistor to Stop Signal Fluctuations
    [Documentation]    Hardware debug: Verify removing the extra resistor on the sensor path stops reading fluctuations on A1.
    # Arrange (Set up the test environment)
    Verify Hardware Setup

    # Act (Perform the action to be tested)
    Execute Manual Step    Remove the extra resistor causing analog voltage fluctuations on the sensor line while keeping the LED resistor on D3.

    # Assert (Verify the expected outcome)
    Execute Manual Step    Observe the 16x2 LCD reading and confirm the temperature value stops jumping randomly.

Test Case 10: Damaged First LM35 Sensor Failure Diagnosis (0.5 C Output)
    [Documentation]    Fault observation: Document behavior when the first LM35 sensor burned out and output 0.5 C on the LCD.
    # Arrange (Set up the test environment)
    Verify Hardware Setup

    # Act (Perform the action to be tested)
    Execute Manual Step    Power the circuit with the damaged first LM35 sensor connected to A1.

    # Assert (Verify the expected outcome)
    Execute Manual Step    Confirm the LCD displays a stuck low fault value of 0.5 C, proving the first sensor failed and required replacement.

Test Case 11: Second LM35 Replacement High Ambient Offset Check (25 C vs 30-40 C)
    [Documentation]    Sensor swap #2: Verify second LM35 responds within limits while noting elevated 30-40 C reading at 25 C room temperature.
    # Arrange (Set up the test environment)
    Set Temperature Limits Via Keypad    ${TEMP_LL}    ${TEMP_LH}

    # Act (Perform the action to be tested)
    Execute Manual Step    Install the second replacement LM35 on A1 at 25 C room temperature and observe the displayed reading.

    # Assert (Verify the expected outcome)
    Execute Manual Step    Record that the sensor responds to range changes, though ambient reading sits higher than expected at 30-40 C instead of 25 C.

Test Case 12: Lighter Thermal Stimulus Response Test (30 C to 40 C)
    [Documentation]    Thermal response test: Bring a lighter flame close to the LM35 to verify upward temperature tracking.
    # Arrange (Set up the test environment)
    Verify Hardware Setup

    # Act (Perform the action to be tested)
    Execute Manual Step    Hold a lighter carefully near the LM35 package without melting it and monitor the LCD temperature rise.

    # Assert (Verify the expected outcome)
    Execute Manual Step    Record that the displayed temperature increases from 30 C up to 40 C (showing a slower/smaller rise than expected before the third sensor swap).

Test Case 13: Third LM35 Replacement and Post-Lighter Thermal Settling Check
    [Documentation]    Verify the third LM35 reads accurate ~25 C room temperature once residual heat and air currents from the lighter test settle, and confirm OK / NOT OKAY switching across LL=25 C.
    # Arrange (Set up the test environment)
    Set Temperature Limits Via Keypad    ${FINAL_LL}    ${FINAL_LH}

    # Act (Perform the action to be tested)
    Execute Manual Step    Allow residual heat and convection from the lighter stimulus to dissipate until the third LM35 settles at room temperature (24.6 C - 25.0 C).

    # Assert (Verify the expected outcome)
    Execute Manual Step    Confirm the reading stabilizes around 25 C without fluctuations, displays NOT OKAY with Red LED and buzzer ON at 24.9 C (< 25 C), and switches to OK at 25.0 C (== LL).
Test Case 14: Dedicated Star Ground for LM35 to Eliminate Ground-Bounce Fluctuations
    [Documentation]    Verify connecting the LM35 ground pin directly to its own dedicated UNO GND pin eliminates 22 C to 30 C fluctuations caused by shared LCD/LED/buzzer return currents.
    # Arrange (Set up the test environment)
    Set Temperature Limits Via Keypad    ${FINAL_LL}    ${FINAL_LH}

    # Act (Perform the action to be tested)
    Execute Manual Step    Connect the LM35 GND pin directly to a dedicated Arduino UNO GND pin instead of sharing the breadboard ground rail with the LCD, buzzer, and LED.

    # Assert (Verify the expected outcome)
    Execute Manual Step    Confirm the displayed room temperature stabilizes at ~22 C - 25 C without jumping to 30 C when the LCD backlight, LED, or buzzer switches.
