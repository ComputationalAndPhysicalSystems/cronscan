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

num = args.i


strip = Adafruit_NeoPixel(LEDCOUNT, GPIOPIN, FREQ, DMA, INVERT, BRIGHTNESS)

# Intialize the library (must be called once before other functions).
strip.begin()

# get the last values to set the neopixels

print("turning on LED"+str($1))
strip.setPixelColor(num, Color(0,0,val))
strip.show()
time.sleep(2)
strip.setPixelColor(num, Color(0,0,0))
strip.show()




