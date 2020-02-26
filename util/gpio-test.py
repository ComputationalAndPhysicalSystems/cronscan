#!/usr/bin/python
from neopixel import *
import time
import argparse
import numpy as np

parser = argparse.ArgumentParser()
parser.add_argument('-c', type=int)
parser.add_argument('-i', type=int)
args = parser.parse_args()

num = args.i-1

if args.i == 0:
	LED = np.arange(args.c)
else:
	LED = (num)


LEDCOUNT = args.c # int(Cnt) # Number of LEDs
GPIOPIN = 10
FREQ = 800000
DMA = 5
INVERT = False # Invert required when using inverting buffer
BRIGHTNESS = 255

strip = Adafruit_NeoPixel(LEDCOUNT, GPIOPIN, FREQ, DMA, INVERT, BRIGHTNESS)

# Intialize the library (must be called once before other functions).
strip.begin()

# get the last values to set the neopixels

print("flashing LED"+str(args.i))

for _ in range(6):
	for x in np.nditer(LED):
		x=x+0  #! for some reason i have to add zero to this to get it to work
		strip.setPixelColor(x, Color(0,0,255))
	strip.show()
	time.sleep(.8)
	for x in np.nditer(LED):
		x=x+0
		strip.setPixelColor(x, Color(0,0,0))
	strip.show()
	time.sleep(.05)
