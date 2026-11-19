#ifndef PROJECT_ADC_H
#define PROJECT_ADC_H

#include <stdint.h>

#define CH_KEY  0
#define CH_SENS 1
#define ADC_ERR 0xFFFFU

void adc_init(void);
uint16_t adc_rd(uint8_t ch);

#endif
