// UNO R3 16x2 LCD keypad shield driver
// RS=D8 (PB0), EN=D9 (PB1), D4-D7=PD4-PD7, Keys=A0

#define F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>
#include "adc.h"
#include "lcd.h"

uint8_t k_cur = KEY_NONE;

// send 4-bit nibble on D4-D7
void lcd_nib(uint8_t v){
  PORTD = (PORTD & 0x0F) | ((v & 0x0F) << 4);
  _delay_us(1);
  PORTB |= (1 << PB1);
  _delay_us(1);
  PORTB &= ~(1 << PB1);
  _delay_us(1);
}

// send byte as cmd or char
void lcd_byt(uint8_t v, uint8_t d){
  if(d) PORTB |= (1 << PB0);
  else PORTB &= ~(1 << PB0);

  lcd_nib(v >> 4);
  lcd_nib(v);
  _delay_us(60);

  if(!d && (v == 0x01 || v == 0x02)) _delay_ms(2);
}

void lcd_cmd(uint8_t c){
  lcd_byt(c, 0);
}

// init LCD in 4-bit mode
void lcd_init(void){
  PORTB &= ~((1 << PB0) | (1 << PB1));
  DDRB |= (1 << PB0) | (1 << PB1);
  DDRD |= 0xF0;

  // keep D10 backlight pin floating
  DDRB &= ~(1 << PB2);
  PORTB &= ~(1 << PB2);

  _delay_ms(50);
  lcd_nib(0x03); _delay_ms(5);
  lcd_nib(0x03); _delay_us(150);
  lcd_nib(0x03); _delay_us(150);
  lcd_nib(0x02); _delay_us(150);

  lcd_cmd(0x28);
  lcd_cmd(0x08);
  lcd_cmd(0x01);
  lcd_cmd(0x06);
  lcd_cmd(0x0C);
  k_cur = KEY_NONE;
}

void lcd_clr(void){
  lcd_cmd(0x01);
}

void lcd_pos(uint8_t x, uint8_t y){
  if(x > 15 || y > 1) return;
  lcd_cmd(0x80 | (y ? 0x40 : 0x00) | x);
}

void lcd_chr(char c){
  lcd_byt((uint8_t)c, 1);
}

void lcd_str(const char *s){
  if(!s) return;
  while(*s) lcd_chr(*s++);
}

// print 16-char padded row
void lcd_line(uint8_t y, const char *s){
  uint8_t i;
  uint8_t end = (s == 0);
  if(y > 1) return;

  lcd_pos(0, y);
  for(i = 0; i < 16; i++){
    char c = ' ';
    if(!end){
      if(*s == '\0') end = 1;
      else c = *s++;
    }
    lcd_chr(c);
  }
}

uint16_t key_raw(void){
  return adc_rd(CH_KEY);
}

// map A0 ADC reading to button ID
uint8_t key_dec(uint16_t v){
  if(v == ADC_ERR) return KEY_NONE;
  if(v < MAX_RIGHT) return KEY_RIGHT;
  if(v < MAX_UP) return KEY_UP;
  if(v < MAX_DOWN) return KEY_DOWN;
  if(v < MAX_LEFT) return KEY_LEFT;
  if(v < MAX_SEL) return KEY_SEL;
  return KEY_NONE;
}

// debounce keypad reading
uint8_t key_rd(void){
  uint8_t c = key_dec(key_raw());
  if(c != k_cur){
    _delay_ms(20);
    if(key_dec(key_raw()) == c) k_cur = c;
  }
  return k_cur;
}
