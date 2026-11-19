#include <avr/io.h>
#include "digital_input_output.h"

#define LED PD3
#define BUZ PD2

// set PD3 and PD2 as outputs
void io_init(void){
  DDRD |= (1 << LED) | (1 << BUZ);
  PORTD &= ~((1 << LED) | (1 << BUZ));
}

// turn LED on
void led_on(void){
  PORTD |= (1 << LED);
}

// turn LED off
void led_off(void){
  PORTD &= ~(1 << LED);
}

// turn buzzer on
void buz_on(void){
  PORTD |= (1 << BUZ);
}

// turn buzzer off
void buz_off(void){
  PORTD &= ~(1 << BUZ);
}
