// temp alarm HMI - Arduino UNO
// A0: keypad | A1: LM35 | D3: LED | D2: buzzer
// UP -> LH, DOWN -> LL (tap +1C, hold 0.8s -> -1C, repeat 0.3s)

#ifndef F_CPU
#define F_CPU 16000000UL
#endif

#include <avr/io.h>
#include <stdint.h>
#include "adc.h"
#include "lcd.h"
#include "digital_input_output.h"

#define VREF 5000UL

uint8_t ll = 20;     // default lower limit (25 C)
uint8_t lh = 30;     // default higher limit (30 C)
uint16_t tmp = 0;    // tenths of C (270 = 27.0 C)

uint8_t err = 0;
uint8_t alm = 0;
uint8_t upd = 1;

uint8_t oldk = KEY_NONE;
uint8_t held = 0;

uint32_t tp = 0;
uint32_t tr = 0;
uint32_t tk = 0;
uint32_t ts = 0;
uint32_t tl = 0;

uint16_t t0 = 0;
uint16_t rem = 0;
uint32_t ms = 0;

// start Timer1 (prescaler 64 -> 4us/tick)
void tmr_init(void){
  TCCR1A = 0;
  TCCR1B = (1 << CS11) | (1 << CS10);
  TIMSK1 = 0;
  TCNT1 = 0;
  t0 = 0;
  rem = 0;
  ms = 0;
}

// elapsed ms without blocking
uint32_t get_ms(void){
  uint16_t now = TCNT1;
  uint32_t sum = (uint32_t)rem + (uint16_t)(now - t0);
  t0 = now;
  ms += sum / 250UL;
  rem = (uint16_t)(sum % 250UL);
  return ms;
}

// step LL or LH and keep LL < LH
void chg_lim(uint8_t k, int8_t d){
  int16_t nx;
  if(k == KEY_UP){
    nx = (int16_t)lh + d;
    if(nx > ll && nx <= 99){
      lh = (uint8_t)nx;
      upd = 1;
    }
  } else if(k == KEY_DOWN){
    nx = (int16_t)ll + d;
    if(nx >= 0 && nx < lh){
      ll = (uint8_t)nx;
      upd = 1;
    }
  }
}

// tap vs hold button logic
void chk_key(uint8_t k, uint32_t now){
  if(k != oldk){
    if(k == KEY_NONE && !held) chg_lim(oldk, 1);
    oldk = k;
    tp = now;
    tr = now;
    held = 0;
    return;
  }
  if(k != KEY_UP && k != KEY_DOWN) return;

  if(!held && (now - tp) >= 800UL){
    chg_lim(k, -1);
    held = 1;
    tr = now;
  } else if(held && (now - tr) >= 300UL){
    chg_lim(k, -1);
    tr = now;
  }
}

// average 16 LM35 reads
void rd_tmp(void){
  uint8_t i;
  uint16_t v;
  uint32_t s = 0;
  for(i = 0; i < 16; i++){
    v = adc_rd(CH_SENS);
    if(v > 1023){
      err = 1;
      return;
    }
    s += v;
  }
  // LM35 = 10mV/C in tenths
  tmp = (uint16_t)((s * VREF + 8192UL) / 16384UL);
  err = (tmp > 1000);
}

// update LED and buzzer outputs
void chk_alm(void){
  alm = err || (tmp < (uint16_t)ll * 10) || (tmp > (uint16_t)lh * 10);
  if(alm){
    led_on();
    buz_on();
  } else {
    led_off();
    buz_off();
  }
}

// put 2 digits in buffer
void fmt2(char *b, uint16_t v){
  b[0] = (char)('0' + (v / 10) % 10);
  b[1] = (char)('0' + (v % 10));
}

// draw both LCD lines
void draw_lcd(void){
  char r0[17] = "T:00.0C         ";
  char r1[17] = "LL:00 LH:00     ";
  const char *m = "NOT OKAY";
  uint8_t i;

  fmt2(&r1[3], ll);
  fmt2(&r1[9], lh);

  if(err){
    lcd_line(0, "CHECK SENSOR");
  } else {
    if(tmp == 1000){
      r0[2] = '1'; r0[3] = '0'; r0[4] = '0'; r0[5] = 'C'; r0[6] = ' ';
    } else {
      fmt2(&r0[2], tmp / 10);
      r0[5] = (char)('0' + (tmp % 10));
    }
    if(alm){
      for(i = 0; i < 8; i++) r0[8 + i] = m[i];
    } else {
      r0[8] = 'O';
      r0[9] = 'K';
    }
    lcd_line(0, r0);
  }
  lcd_line(1, r1);
}

// init modules and first screen
void app_init(void){
  io_init();
  adc_init();
  lcd_init();
  rd_tmp();
  chk_alm();
  draw_lcd();
  tmr_init();
}

// non-blocking control loop
void app_run(void){
  uint32_t now = get_ms();

  // poll keypad every 10ms
  if((now - tk) >= 10UL){
    uint8_t k = key_rd();
    now = get_ms();
    tk = now;
    chk_key(k, now);
  }

  // read LM35 every 100ms
  if((now - ts) >= 100UL){
    ts = now;
    rd_tmp();
  }

  chk_alm();

  // refresh LCD on change or 200ms
  if(upd || (now - tl) >= 200UL){
    draw_lcd();
    upd = 0;
    tl = now;
  }
}

#ifdef ARDUINO
void setup(void){
  app_init();
}

void loop(void){
  app_run();
}
#else
int main(void){
  app_init();
  while(1){
    app_run();
  }
  return 0;
}
#endif
