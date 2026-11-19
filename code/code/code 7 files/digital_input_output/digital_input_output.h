#ifndef DIGITAL_INPUT_OUTPUT_H
#define DIGITAL_INPUT_OUTPUT_H

#include <avr/io.h>

void io_init(void);
void led_on(void);
void led_off(void);
void buz_on(void);
void buz_off(void);

#endif
