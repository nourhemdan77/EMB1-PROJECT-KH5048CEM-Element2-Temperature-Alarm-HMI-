# Design Document: Car Temperature Alarm HMI

## 1. System Overview
This project models a car dashboard HMI that watches cabin or engine temperature and warns the driver when it moves outside a safe range.

* **Sensor Reading:** Reads the **LM35** analog sensor on `A1` (`PC1`) through the ATmega328P 10-bit ADC and calculates degrees Celsius.
* **16x2 LCD Output:** Shows live temperature (`T:xx.xC`), `LL`, `LH`, and status (`OK` or `NOT OKAY`).
* **Two Limit Buttons:** Reads the keypad shield button ladder on `A0` (`PC0`) so the `UP` button adjusts `LH` and the `DOWN` button adjusts `LL` (tap adds `1°C`, hold `0.8 s` subtracts `1°C`).
* **Alert Outputs:**
  * Inside range (`LL <= Temp <= LH`): LCD shows `OK`, Red LED (`D3`) is OFF, buzzer (`D2`) is OFF.
  * Outside range (`Temp < LL` or `Temp > LH`): LCD shows `NOT OKAY`, Red LED (`D3`) is ON, buzzer (`D2`) is ON.
* **Configured Ranges:**
  * **Final Target Range:** `LL = 25°C` and `LH = 30°C`.
  * **Bench Test Range:** `LL = 0°C` and `LH = 30°C` used during initial testing to check normal readings (`24.6°C` -> `OK`) and heated readings (`43.6°C` -> `NOT OKAY`).

---

## 2. Pin Mapping

| Part | Job | Arduino Pin | ATmega328P Pin | Mode | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Keypad Buttons** | Control `LL` and `LH` | `A0` | `PC0` (`ADC0`) | Analog Input | Resistor divider buttons on the 16x2 shield |
| **Temp Sensor** | Analog temperature signal | `A1` | `PC1` (`ADC1`) | Analog Input | **LM35** (`10 mV/°C`), wired directly without extra series resistor |
| **Buzzer** | Sound alarm | `D2` | `PD2` | Digital Output | Active 5V buzzer on breadboard |
| **Red LED** | Light alarm | `D3` | `PD3` | Digital Output | 5mm Red LED with `330 Ohm` series resistor |
| **16x2 LCD** | Display text | `D4–D9` | `PD4–PD7, PB0–PB1` | Digital Output | 4-bit parallel LCD connection (`RS=D8`, `EN=D9`, `D10` floating) |

---

## 3. Code Structure (`code/projectApp/`)
We organized the firmware into separate bare-metal C driver files:
1. **`projectApp.ino`:** Runs the non-blocking Timer1 loop (`tmr_init`, `get_ms`), checks button presses (`chk_key`, `chg_lim`), reads temperature (`rd_tmp`), drives the LED and buzzer (`chk_alm`), and updates the LCD (`draw_lcd`).
2. **`adc.h` & `adc.ino`:** Configures `ADMUX` (AVCC 5V reference) and `ADCSRA` (128 prescaler) in `adc_init()` and performs a dummy read plus conversion in `adc_rd()` across `CH_KEY` (`A0`) and `CH_SENS` (`A1`).
3. **`lcd.h` & `lcd.ino`:** Controls the 16x2 LCD in 4-bit mode (`lcd_init`, `lcd_line`) using direct port writes (`PORTB`, `PORTD` masked with `0x0F`) and debounces keypad buttons (`key_rd`).
4. **`digital_input_output.h` & `digital_input_output.ino`:** Sets `PD2` and `PD3` as outputs in `DDRD` (`io_init`) and switches them in `PORTD` (`led_on`, `led_off`, `buz_on`, `buz_off`).

*(PlantUML diagrams for the system blocks, program flowchart, and alarm states are in [design/diagrams.puml](diagrams.puml).)*

---

## 4. ADC Math & Limit Rules
* **LM35 Calculation:** The 10-bit ADC maps `0V–5V` (`VREF = 5000 mV`) to `0–1023`. Averaging 16 samples (`16384` total steps) converts the `10 mV/°C` LM35 voltage into tenths of a degree (`250` = `25.0°C`):
  $$\text{Temp\_x10} = \frac{\text{Sum\_16\_Samples} \times 5000 + 8192}{16384}$$
* **Corner Cases Handled:**
  * Equal values (`Temp == LL` or `Temp == LH`, verified at `25.0°C == LL`) stay in `OK`.
  * The button logic blocks `LL` from reaching or exceeding `LH` (`0 <= LL < LH <= 99`).
  * Non-blocking Timer1 scheduling (`10 ms` keypad poll, `100 ms` sensor poll, `200 ms` LCD refresh) with a short `20 ms` debounce prevents dropped presses.

---

## 5. Bench Troubleshooting & Calibration Findings
1. **Sensor Line Stabilization & Dummy ADC Read:** Removing an extra series resistor from the sensor line and adding a dummy ADC conversion in `adc_rd()` after switching `ADMUX` from `A0` (`5V`) to `A1` eliminated `30–40°C` voltage crosstalk fluctuations.
2. **Post-Lighter Thermal Settling:** Heating the LM35 closely with a lighter caused temporary reading fluctuations while residual heat and air currents cooled off. Once settled at ambient temperature, the third LM35 held a steady **24.6°C–25.0°C** and switched cleanly across `LL = 25°C` (`24.9°C` -> `NOT OKAY` with LED/buzzer ON; `25.0°C` -> `OK` with LED/buzzer OFF).
3. **Polling Architecture:** Inputs are checked sequentially inside the main Timer1 loop rather than via hardware interrupts, which responds smoothly with zero dropped button presses.
