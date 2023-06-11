#!/usr/bin/env python3
# vim: syntax=python ts=4 sts=4 sw=4 expandtab

import pprint

results = dict()
#for xtal_khz in (4000, 4096, 6000, 8000, 10000, 11059.2, 12000, 16000,):
for xtal_khz in (10000,):
    results[xtal_khz] = dict()
    for baud in (300, 600, 1200, 2400, 4800, 9600, 19200, 38400, 57600, 115200):
        target_frequency_khz = 16 * (baud / 1000)
        results[xtal_khz][baud] = [ ]
        for prescaler in (1, 3, 4, 5,):
            for divisor in ('2', '3', '16/3', '8', '32/3', '16', '58/3', '22','32', '64', '128', '192', '256', '288', '352', '512', '768', '1',):
                divisor_num = eval(divisor)
                output_frequency_khz = xtal_khz / prescaler / divisor_num
                frequency_diff = abs(output_frequency_khz - target_frequency_khz)
                error_pct = frequency_diff / target_frequency_khz * 100
                if error_pct < 5:
                    results[xtal_khz][baud].append( (prescaler, divisor, error_pct) )

pprint.pprint(results)

# The xtal_khz list is the crystal frequencies I happen to have readily available.
# Of those, the 10MHz crystal appears to be the best option:
#  10000: {2400: [(1, '256', 1.7252604166666705), (4, '64', 1.7252604166666705)],
#          4800: [(1, '128', 1.7252604166666705), (4, '32', 1.7252604166666705)],
#          9600: [(1, '64', 1.7252604166666705),  (3, '22', 1.3573232323232192),  (4, '16', 1.7252604166666705)],
#         19200: [(1, '32', 1.7252604166666705),  (3, '32/3', 1.725260416666689), (4, '8', 1.7252604166666705)],
#         38400: [(1, '16', 1.7252604166666705),  (3, '16/3', 1.725260416666689)],
#        115200: [(1, '16/3', 1.725260416666664)]},
#
# All of the useful baud rates are availble with just 1.73% error.
# 9600 baud does even better with an option that gets us to 1.36% error.
