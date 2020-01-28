#!/usr/bin/python3
from neopixel import *
import time
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-c', type=int)
parser.add_argument('-i', type=int)
args = parser.parse_args()



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
	strip.setPixelColor(num, Color(0,0,255))
	strip.show()
	time.sleep(1)
	strip.setPixelColor(num, Color(0,0,0))
	strip.show()
	time.sleep(.2)
