# Element 2: Car Temperature Alarm HMI — Program Flowchart

This flowchart shows how our bare-metal C code in `projectApp.ino` runs from startup through the main loop: initializing the pins, ADC, and 16x2 LCD, reading the two limit buttons (`LL` and `LH`) on `A0`, reading the **LM35** sensor on `A1`, and switching the LCD status, Red LED (`D3`), and buzzer (`D2`).

```plantuml
@startuml
title Element 2: Car Temperature Alarm HMI Flowchart

start

:Set Up GPIO Pins\n(PD2 = Buzzer Output, PD3 = Red LED Output);
:Set Up ADC Registers\n(AVCC 5V Reference, 128 Prescaler);
:Initialize 16x2 LCD in 4-Bit Mode;
:Load Initial Limits (LL and LH);

while (Board Powered On?) is (Yes)
    :Read Keypad Ladder on A0 (ADC0);

    if (LL Button Pressed?) then (Yes)
        :Update Lower Limit LL\n(Keep LL <= LH);
        :Short Debounce (20-30 ms);
    elseif (LH Button Pressed?) then (Yes)
        :Update Higher Limit LH\n(Keep LH >= LL);
        :Short Debounce (20-30 ms);
    else (No Button)
    endif

    :Read LM35 Sensor on A1 (ADC1);
    :Convert ADC Reading to Celsius (Temp);

    if (Temp >= LL AND Temp <= LH?) then (Yes - Inside Range)
        :Set LCD Status = "OK";
        :Turn Red LED OFF (PD3 = 0);
        :Turn Buzzer OFF (PD2 = 0);
    else (No - Outside Range)
        :Set LCD Status = "NOT OKAY";
        :Turn Red LED ON (PD3 = 1);
        :Turn Buzzer ON (PD2 = 1);
    endif

    :Update 16x2 LCD Screen\n(Row 1: Temp & Status | Row 2: LL & LH);
endwhile (No)

stop
@enduml
```
