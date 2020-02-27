#!/usr/bin/python
from neopixel import *
import time
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-p', type=int)
parser.add_argument('-c', type=int)

LEDCOUNT = args.c # int(Cnt) # Number of LEDs
GPIOPIN = args.p  # GPIO pin to use for output. Read from config file
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
