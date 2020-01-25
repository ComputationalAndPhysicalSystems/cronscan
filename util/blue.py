#!/usr/bin/python3
from neopixel import *
import time
LEDCOUNT = 6 # Number of LEDs
GPIOPIN = 21
FREQ = 800000
DMA = 5
INVERT = False # Invert required when using inverting buffer
BRIGHTNESS = 255


strip = Adafruit_NeoPixel(LEDCOUNT, GPIOPIN, FREQ, DMA, INVERT, BRIGHTNESS)
# Intialize the library (must be called once before other functions).
strip.begin()

strip.setPixelColor(0, Color(0,0,255))
strip.setPixelColor(1, Color(0,0,255))
strip.setPixelColor(2, Color(0,0,255))
strip.setPixelColor(3, Color(0,0,255))
strip.setPixelColor(4, Color(0,0,255))
strip.setPixelColor(5, Color(0,0,255))								
strip.show()

