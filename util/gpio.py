#!/usr/bin/python3
from neopixel import *
import time
import argparse
import numpy as np
import RPi.GPIO as GPIO

parser = argparse.ArgumentParser()
parser.add_argument('-e', type=str)
parser.add_argument('-c', type=int)
parser.add_argument('-v', type=str)
args = parser.parse_args()

if GPIO.RPI_REVISION == 2:
	GPIOPIN = 18

if GPIO.RPI_REVISION == 3:
	GPIOPIN = 21


Msg = "/usr/local/bin/cronscan/exp/" + args.e +"/.track/pylog"

LEDCOUNT = args.c # int(Cnt) # Number of LEDs
FREQ = 800000
DMA = 5
INVERT = False # Invert required when using inverting buffer
BRIGHTNESS = 255


strip = Adafruit_NeoPixel(LEDCOUNT, GPIOPIN, FREQ, DMA, INVERT, BRIGHTNESS)

# Intialize the library (must be called once before other functions).
strip.begin()

# get the last values to set the neopixels
f1 = open(Msg, "r")
Last_line = f1.readlines()[-1]
f1.close()


def split(line):
	return [char for char in line]

LED = (split(Last_line))
#print(LED)

for num, led in enumerate(LED):
	val = int(led)
	if (val == 1):
		if(args.v == "on"):
			print("LED"+str(num+1)+" ON")
		val = 255
	else:
		if(args.v == "on"):
			print("LED"+str(num+1)+" OFF")
	strip.setPixelColor(num, Color(0,0,val))

strip.show()
