#!/usr/bin/env python
#
# Script to create volume-table.h at compile-time.


import math, sys


def f(x):
    return (0.24 * x * x *x + 231 * x * x + 0.24 * x + 231 - 231 * (math.exp (-0.1 * x)) - 231 * (x * x) * (math.exp(-0.1 * x))) / ((x * x) + 1)

sys.stdout.write('static const guint8 raumfeld_volume_ramp[101] = { ')
for i in range(0,101):
    sys.stdout.write('%d' % (int(round(f(i)))))
    if i < 100:
        sys.stdout.write(', ')
sys.stdout.write(" };\n")
