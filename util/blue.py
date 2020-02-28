#!/usr/bin/python3
from neopixel import *
import time
import argparse
import numpy as np
import RPi.GPIO as GPIO

parser = argparse.ArgumentParser()
parser.add_argument('-c', type=int)
args = parser.parse_args()

if GPIO.RPI_REVISION == 2:
	GPIOPIN = 10

if GPIO.RPI_REVISION == 3:
	GPIOPIN = 21

exec(open('/usr/local/bin/caps_settings/config').read())
LEDCOUNT = args.c # Number of LEDs
FREQ = 800000
DMA = 5
INVERT = False # Invert required when using inverting buffer
BRIGHTNESS = 255


strip = Adafruit_NeoPixel(LEDCOUNT, GPIOPIN, FREQ, DMA, INVERT, BRIGHTNESS)
# Intialize the library (must be called once before other functions).
strip.begin()

for x in np.nditer(LED):
		x=x+0  #! for some reason i have to add zero to this to get it to work
		strip.setPixelColor(x, Color(0,0,255))
	strip.show()								
strip.show()