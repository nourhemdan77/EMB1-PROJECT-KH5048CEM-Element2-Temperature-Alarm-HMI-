# Test Results Record

We separated what we captured in our photos and test video from our earlier hardware troubleshooting notes and final checks.

---

## 1. Verified Results Shown in Our Photos & Test Video

| Test ID | Test Case | Limits Set | Hardware Input | LCD Output | Red LED (PD3) | Buzzer (PD2) | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC01** | Power on and LCD startup | `LL=0°C`, `LH=30°C` | Powered UNO Rev3 + LCD shield | Both rows readable | Checked | Checked | **PASS** |
| **TC02** | Temperature inside `[LL, LH]` | `LL=0°C`, `LH=30°C` | LM35 reading = **24.6°C** | `T:24.6C OK` | **OFF** | **OFF** | **PASS** |
| **TC03** | Temperature above `LH` | `LL=0°C`, `LH=30°C` | Heated LM35 = **43.6°C** | `T:43.6C NOT OKAY` | **ON** | **ON** | **PASS** |
| **TC04** | Automatic alarm recovery | `LL=25°C`, `LH=30°C` | Temperature rose from `24.9°C` back into `[25, 30]°C` | Switched back to `OK` | **OFF** | **OFF** | **PASS** |
| **TC05** | Temperature below `LL` (`25–30°C`) | `LL=25°C`, `LH=30°C` | LM35 reading = **24.9°C** (`< 25°C`) | `T:24.9C NOT OKAY` | **ON** | **ON (Sounding)** | **PASS** |
| **TC06** | Boundary equality (`Temp == LL`) | `LL=25°C`, `LH=30°C` | LM35 reading = **25.0°C** (`== LL`) | `T:25.0C OK` | **OFF** | **OFF** | **PASS** |
| **TC08** | Room-temperature accuracy & responsiveness | `LL=25°C`, `LH=30°C` | Ambient room temp ~**25°C** after calibration & dummy ADC read | Stable **24.6°C–25.0°C** | Matches state | Matches state | **PASS** |
| **TC13** | 3rd sensor & post-lighter thermal settling | `LL=25°C`, `LH=30°C` | Allowed residual heat and air currents from lighter test to settle | Settled cleanly at **24.6°C–25.0°C** | **ON** at `24.9°C`, **OFF** at `25.0°C` | **ON** at `24.9°C`, **OFF** at `25.0°C` | **PASS** |
| **TC14** | Dedicated LM35 ground return (star ground) | `LL=25°C`, `LH=30°C` | Isolated LM35 `GND` directly to a separate UNO `GND` pin away from shared LCD/LED/buzzer ground | Eliminated **22°C to 30°C** ground-bounce jumps; held steady room temperature | Stable | Stable | **PASS** |

---

## 2. Bench Notes & Hardware Troubleshooting (TC09 – TC12)

| Test ID / Note | What Happened | Action / Finding |
| :--- | :--- | :--- |
| **TC09 (Resistor Removal)** | Removing the extra resistor on the sensor path stopped the temperature reading from fluctuating randomly on `A1` (while keeping the series resistor on the `D3` Red LED). | Confirmed clean signal stability without the extra sensor-line resistor. |
| **TC10 (1st Sensor Burnout)** | Our first temperature sensor burned out during testing and stayed stuck at **0.5°C** on the 16x2 LCD. | Replaced the damaged sensor with a new **LM35** (`70 EGP` vs `90 EGP` at another store). |
| **TC11 (2nd Sensor Offset)** | The second **LM35** responded inside the configured low/high range, but at **22–25°C** room temperature it jumped higher than expected (**30–40°C**). | Fixed `A0` to `A1` ADC capacitor crosstalk with a dummy conversion read and isolated the LM35 `GND` to its own UNO `GND` pin (**TC14**). |
| **TC12 (Lighter Heat Fluctuation)** | Holding a lighter close to the LM35 heated the plastic package unevenly (`30°C to 40°C`) and caused temporary reading fluctuations while cooling down. | Verified in **TC13** that once residual lighter heat settled, the sensor held a steady **24.6°C–25.0°C**. |

---

## 3. Final Check to Show in Demo Video
* **TC07 (Limit Inversion Guard & Reset):** Show on video that pressing `LL` cannot push `LL` above `LH` (`LL <= LH`) and pressing Reset restarts cleanly into the default window.
