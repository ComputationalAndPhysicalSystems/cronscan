#!/usr/bin/env python3

import machine
import neopixel

np = neopixel.NeoPixel(machine.Pin(21), 6)

np[0] = (255, 0, 0)
np[1] = (0, 255, 0)

np.write()