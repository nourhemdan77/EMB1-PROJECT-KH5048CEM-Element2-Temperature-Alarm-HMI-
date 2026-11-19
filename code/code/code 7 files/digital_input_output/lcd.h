#ifndef PROJECT_LCD_KEYPAD_H
#define PROJECT_LCD_KEYPAD_H

#include <stdint.h>

#define KEY_NONE   0
#define KEY_RIGHT  1
#define KEY_UP     2
#define KEY_DOWN   3
#define KEY_LEFT   4
#define KEY_SEL    5

#define MAX_RIGHT  50
#define MAX_UP     250
#define MAX_DOWN   450
#define MAX_LEFT   650
#define MAX_SEL    850

void lcd_init(void);
void lcd_cmd(uint8_t c);
void lcd_clr(void);
void lcd_pos(uint8_t x, uint8_t y);
void lcd_chr(char c);
void lcd_str(const char *s);
void lcd_line(uint8_t y, const char *s);

uint16_t key_raw(void);
uint8_t key_rd(void);

#endif
