#!/usr/bin/env python3

# /usr/local/bin/st -g100x30 -e python3 -i /home/tubbles/.install/interactive.py
# /usr/local/bin/st -g44x30 -e R -q --no-save

from fractions import Fraction  # NOQA


def frac(a, b):
    return Fraction(a, b).as_integer_ratio()


def todec():
    try:
        while True:
            print("> ", end="")
            a = input()
            try:
                print(int(a, 0))
            except ValueError as e:
                print(e)
    except (KeyboardInterrupt, EOFError):
        print("")


def tohex():
    try:
        while True:
            print("> ", end="")
            a = input()
            try:
                print(hex(int(a, 0)))
            except ValueError as e:
                print(e)
    except (KeyboardInterrupt, EOFError):
        print("")
