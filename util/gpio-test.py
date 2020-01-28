#!/usr/bin/python3
from neopixel import *
import time
import argparse
import Numpy as np

parser = argparse.ArgumentParser()
parser.add_argument('-c', type=int)
parser.add_argument('-i', type=int)
args = parser.parse_args()


if args.i == 0:
	LED = np.arange(args.c)
else:
	LED = np.arange(args.i)


LEDCOUNT = args.c # int(Cnt) # Number of LEDs
GPIOPIN = 21
FREQ = 800000
DMA = 5
INVERT = False # Invert required when using inverting buffer
BRIGHTNESS = 255

num = args.i-1


strip = Adafruit_NeoPixel(LEDCOUNT, GPIOPIN, FREQ, DMA, INVERT, BRIGHTNESS)

# Intialize the library (must be called once before other functions).
strip.begin()

# get the last values to set the neopixels

print("flashing LED"+str(args.i))

for _ in range(5):
	for x in np.nditer(LED):
		strip.setPixelColor(x, Color(0,0,255))
	strip.show()
	time.sleep(1)
	for x in np.nditer(LED):
		strip.setPixelColor(x, Color(0,0,0))
	strip.show()
	time.sleep(.2)
