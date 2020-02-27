#!/usr/bin/python
from neopixel import *
import time
import argparse
import RPi.GPIO as GPIO

parser = argparse.ArgumentParser()
parser.add_argument('-c', type=int)
args = parser.parse_args()

if GPIO.RPI_REVISION == 2:
	GPIOPIN = 10

if GPIO.RPI_REVISION == 3:
	GPIOPIN = 21

LEDCOUNT = args.c # int(Cnt) # Number of LEDs
FREQ = 800000
DMA = 5
INVERT = False # Invert required when using inverting buffer
BRIGHTNESS = 255

def colorWipe(strip, color, wait_ms=50):
    """Wipe color across display a pixel at a time."""
    for i in range(strip.numPixels()):
        strip.setPixelColor(i, color)
        strip.show()
        time.sleep(wait_ms/1000.0)


strip = Adafruit_NeoPixel(LEDCOUNT, GPIOPIN, FREQ, DMA, INVERT, BRIGHTNESS)
# Intialize the library (must be called once before other functions).
strip.begin()

colorWipe(strip, Color(0,0,0), 10)
