## Embedded Systems Project Report: Car Temperature Alarm HMI

## 1. Introduction
We made a temperature alarm display for a car dashboard for KH5048CEM Element 2. The circuit uses an Arduino UNO Rev3, a 16x2 LCD keypad shield, an LM35 temperature sensor, an active buzzer, and a red LED.

The LM35 sensor connects to analog pin A1 and sends voltage into the ATmega328P 10-bit ADC. Our code averages 16 readings after a dummy conversion so the value stays steady, then prints the live temperature on the top row of the LCD alongside the lower limit LL and higher limit LH on the bottom row. We use the UP and DOWN buttons on pin A0 to set LL and LH inside our 25 to 30 degree target range. A quick tap adds 1 degree, while holding a button down for 0.8 seconds subtracts 1 degree. When the temperature stays between LL and LH, the screen shows OK and both the red LED on D3 and buzzer on D2 stay off. Once the reading goes above LH or drops below LL, the LCD switches to NOT OKAY and turns on both the red LED and the buzzer.

Group Members:
- Ahmed Malik - 202401540
- Ahmed Hegazy - 202201725
- Nour Hemdan - 202601953

## Who Did What
We divided the main project responsibilities evenly across our group and worked together on the final video demonstration:
- Nour Hemdan: Handled the hardware connections, breadboard wiring, sensor troubleshooting, and Robot Framework test cases.
- Ahmed Malik: Developed the bare-metal C code and drivers, and worked on the demo video recording.
- Ahmed Hegazy: Worked on the bare-metal C code, prepared the project report and design documentation, and compiled the BOM and optimized BOM.
- Collective Work: All three team members collaborated on testing the full system and producing the final demonstration video.

## 2. Project Code

**GitHub Repository:**
[EMB-PROJECT-KH5048CEM-Element2-Temperature-Alarm-HMI-](https://github.com)

We also initialized the local Git repository inside the root folder and archived the full project as Final_EMB PROJ alarm sys.7z for Moodle.

**Local Root Directory**
[code/projectApp/](./code/projectApp/)

All 7 files (projectApp.ino, adc.ino, adc.h, lcd.ino, lcd.h, digital_input_output.ino, digital_input_output.h) are written in native C. We configured the AVR registers directly (DDRD, PORTD, DDRB, PORTB, ADMUX, ADCSRA, TCCR1B) with a non-blocking Timer1 loop instead of using Arduino functions like digitalWrite, analogRead, or LiquidCrystal.

## 3. Test Cases

Test Cases are developed in **[Robot Framework](https://robotframework.org)** Test steps. We included 14 test cases covering LCD startup, OK inside range, NOT OKAY above LH at 43.6 C and below LL at 24.9 C, exact boundary equality at 25.0 C, limit button clamping, sensor line stabilization, third LM35 thermal settling at 24.6 to 25.0 C after lighter testing, and a dedicated LM35 ground connection to eliminate 22 to 30 C fluctuations:
- [temperature_alarm.robot](./test/temperature_alarm.robot)
- [TC_2026-11-18_02_05_00.robot](./test/GENIE_Output/ExecutableFormat/Robot/TC_2026-11-18_02_05_00.robot)
- [test_results.md](./test/test_results.md)

## 4. Bill of Materials (BOM)

**BOM** (Actual prototype parts matching our demo video and receipts, 714.00 EGP total)
[bom.csv](./bom/bom.csv)

**Optimized BOM** (Standalone commercial PCB redesign at 475.50 EGP estimated cost, saving 238.50 EGP)
[optimized_bom.csv](./bom/optimized_bom.csv)

## 5. Video Demonstration

[demo_video.mp4](./video/demo_video.mp4)

[video_script_and_notes.md](./video/video_script_and_notes.md)

## 6. Design
[design_document.md](./design/design_document.md)

[diagrams.puml](./design/diagrams.puml)
