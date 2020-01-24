#!/usr/bin/env python3

import board
import neopixel

pixel_pin = board.D21

np = neopixel.NeoPixel(pixel_pin, 6)

np[0] = (255, 0, 0)
np[1] = (0, 255, 0)

np.write()