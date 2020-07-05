#!/usr/bin/env python3
# vim: syntax=python ts=4 sts=4 sw=4 expandtab



if __name__ == "__main__":
    import sys
    import fileinput
    import re

    # Read STDIN, or the file(s) specified on the command line, 
    # and create control signal, macro, and opcode objects
    for line in fileinput.input():
        line, i, i = line.partition('#') # strip comments
        line = line.rstrip()
        if not line:
            continue
        #####
        # Control signal
        m = re.match("\(([a-zA-Z/]+)\)", line)
        if m:
            m = re.match("\(([a-zA-Z/]+)\)\s+([0-9]+)\s+([0-9]+)\s+0x([0-9a-fA-F]{2})", line)
            if m:
                print("Control signal {}, default {}, ROM {}, mask {}".format(m.group(1), m.group(2), m.group(3), m.group(4)))
            else:
                print("ERROR: {} line {} looks like a control signal, but does not match regex".format(fileinput.filename(), fileinput.filelineno()))

        #####
        # Macro
        m = re.match("\{(\S+)\}", line)
        if m:
            print("Macro {}".format(m.group(1)))

        #####
        # Opcode
        m = re.match("\[(0x[0-9a-fA-F]{2})\]", line)
        if m:
            print("Opcode {}".format(m.group(1)))

