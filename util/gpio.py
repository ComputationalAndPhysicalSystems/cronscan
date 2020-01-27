#!/usr/bin/python3
#from neopixel import *
#import time

with open("/home/caps/scripts/caps_cronscan/exp/current.env") as infile:
    Exp, Cnt = map(str, infile.read().split())
Msg = "/home/caps/scripts/caps_cronscan/exp/" + Exp +"/"+ Exp +".pylog"

LEDCOUNT = 6 # int(Cnt) # Number of LEDs
GPIOPIN = 21
FREQ = 800000
DMA = 5
INVERT = False # Invert required when using inverting buffer
BRIGHTNESS = 255


#strip = Adafruit_NeoPixel(LEDCOUNT, GPIOPIN, FREQ, DMA, INVERT, BRIGHTNESS)

# Intialize the library (must be called once before other functions).
#strip.begin()

# get the last values to set the neopixels
f1 = open(Msg, "r")
Last_line = f1.readlines()[-1]
f1.close()


def split(line):
	return [char for char in line]

LED = (split(Last_line))
#print(LED)

for num, led in enumerate(LED):
#	print(led)
	val = int(led)
#	print("hi")
#	print(val)
#	dude="yes"
	if (val == 1):
		print("turning on LED"+str(num+1))
	 	val = 255
	strip.setPixelColor(num, Color(0,0,val))


