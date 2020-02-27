#!/usr/bin/python3
from neopixel import *
import time
import argparse
import RPi.GPIO as GPIO

if GPIO.RPI_REVISION == 2:
	GPIOPIN = 10

if GPIO.RPI_REVISION == 3:
	GPIOPIN = 21

exec(open('/usr/local/bin/caps_settings/config').read())
LEDCOUNT = 6 # Number of LEDs
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

