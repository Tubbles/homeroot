#!/usr/bin/env python3

# /usr/local/bin/st -g100x30 -e python3 -i /home/tubbles/.install/interactive.py
# /usr/local/bin/st -g44x30 -e R -q --no-save

from fractions import Fraction  # NOQA


def frac(a, b):
    return Fraction(a, b).as_integer_ratio()


def todec(number=None):
    if not number:
        try:
            while True:
                print("> ", end="")
                number = input()
                try:
                    print(int(str(number), 0))
                except ValueError as e:
                    print(e)
        except (KeyboardInterrupt, EOFError):
            print("")
    else:
        print(int(str(number), 0))


def tohex(number=None):
    if not number:
        try:
            while True:
                print("> ", end="")
                number = input()
                try:
                    print(hex(int(str(number), 0)))
                except ValueError as e:
                    print(e)
        except (KeyboardInterrupt, EOFError):
            print("")
    else:
        print(hex(int(str(number), 0)))


def tobin(number=None):
    if not number:
        try:
            while True:
                print("> ", end="")
                number = input()
                try:
                    print(bin(int(str(number), 0)))
                except ValueError as e:
                    print(e)
        except (KeyboardInterrupt, EOFError):
            print("")
    else:
        print(bin(int(str(number), 0)))


def tooct(number=None):
    if not number:
        try:
            while True:
                print("> ", end="")
                number = input()
                try:
                    print(oct(int(str(number), 0)))
                except ValueError as e:
                    print(e)
        except (KeyboardInterrupt, EOFError):
            print("")
    else:
        print(oct(int(str(number), 0)))
