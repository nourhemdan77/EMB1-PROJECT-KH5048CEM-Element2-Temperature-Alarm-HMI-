#include <avr/io.h>
#include <stdint.h>
#include "adc.h"

// setup 10-bit ADC on AVCC 5V ref
void adc_init(void){
  PRR &= ~(1 << PRADC);
  DDRC &= ~((1 << PC0) | (1 << PC1));
  PORTC &= ~((1 << PC0) | (1 << PC1));
  ADMUX = (1 << REFS0);
  ADCSRA = (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0);
}

// read channel with dummy read to clear MUX charge
uint16_t adc_rd(uint8_t ch){
  uint16_t t = 0;
  if(ch > 7) return ADC_ERR;

  ADMUX = (ADMUX & 0xF0) | (ch & 0x0F);

  // dummy conversion after switching A0 -> A1
  ADCSRA |= (1 << ADSC);
  while((ADCSRA & (1 << ADSC)) && t < 50000U) t++;

  // real conversion
  t = 0;
  ADCSRA |= (1 << ADSC);
  while((ADCSRA & (1 << ADSC)) && t < 50000U) t++;

  if(t >= 50000U) return ADC_ERR;
  return ADC;
}
