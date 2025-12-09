#!/usr/bin/env python3

# /usr/local/bin/st -g100x30 -e python3 -i /home/tubbles/.install/interactive.py
# /usr/local/bin/st -g44x30 -e R -q --no-save

from math import log2  # NOQA useful for interactive use
from math import sqrt  # NOQA useful for interavtive use
from math import floor  # NOQA useful for interavtive use
from math import log10  # NOQA useful for interavtive use


def frac(a, b):
    from fractions import Fraction

    return Fraction(a, b).as_integer_ratio()


def eng(n, precision=2):
    """Formats a number in engineering notation (E3, E6, E-3, etc.)"""
    if n == 0:
        return "0"

    exponent = int(floor(log10(abs(n)) / 3) * 3)
    mantissa = n / (10**exponent)

    return f"{mantissa:.{precision}f}E{exponent}"


def _pretty_print_timedelta(td):
    # Print as Y years D days H hours M minutes S seconds MS milliseconds US microseconds
    # Omit any fields that are zero, and stop at the first non-zero field
    # If all fields are zero, print "0 seconds"
    # If the timedelta is negative, print "negative " before the result
    string = ""
    # Check if td is negative
    if td.days < 0:
        string += "negative "
        td = -td

    years = td.days // 365
    days = td.days
    hours, remainder = divmod(td.seconds, 3600)
    minutes, seconds = divmod(remainder, 60)
    milliseconds = td.microseconds // 1000
    microseconds = td.microseconds % 1000

    if years:
        if len(string) and string != "negative ":
            string += ", "
        string += f"{years} y"
    if days:
        if len(string) and string != "negative ":
            string += ", "
        string += f"{days} d"
    if hours:
        if len(string) and string != "negative ":
            string += ", "
        string += f"{hours} h"
    if minutes:
        if len(string) and string != "negative ":
            string += ", "
        string += f"{minutes} min"
    if seconds:
        if len(string) and string != "negative ":
            string += ", "
        string += f"{seconds} s"
    if milliseconds:
        if len(string) and string != "negative ":
            string += ", "
        string += f"{milliseconds} ms"
    if microseconds:
        if len(string) and string != "negative ":
            string += ", "
        string += f"{microseconds} µs"
    if not any((days, hours, minutes, seconds, milliseconds, microseconds)):
        if len(string) and string != "negative ":
            string += ", "
        string += "0 seconds"

    splits = string.split(", ")
    if len(splits) > 1:
        string = ", ".join(splits[:-1]) + ", and " + splits[-1]

    print(string)


def s(dur):
    from datetime import timedelta

    _pretty_print_timedelta(timedelta(seconds=dur))


def ms(dur):
    from datetime import timedelta

    _pretty_print_timedelta(timedelta(milliseconds=dur))


def us(dur):
    from datetime import timedelta

    _pretty_print_timedelta(timedelta(microseconds=dur))


def todec(number=None):
    def fun(number):
        print(int(str(number), 0))

    if not number:
        try:
            while True:
                print("> ", end="")
                number = input()
                try:
                    fun(number)
                except ValueError as e:
                    print(e)
        except (KeyboardInterrupt, EOFError):
            print("")
    else:
        fun(number)


def tohex(number=None):
    def fun(number):
        print(hex(int(str(number), 0)))

    if not number:
        try:
            while True:
                print("> ", end="")
                number = input()
                try:
                    fun(number)
                except ValueError as e:
                    print(e)
        except (KeyboardInterrupt, EOFError):
            print("")
    else:
        fun(number)


def tobin(number=None):
    def fun(number):
        print(bin(int(str(number), 0)))

    if not number:
        try:
            while True:
                print("> ", end="")
                number = input()
                try:
                    fun(number)
                except ValueError as e:
                    print(e)
        except (KeyboardInterrupt, EOFError):
            print("")
    else:
        fun(number)


def tooct(number=None):
    def fun(number):
        print(oct(int(str(number), 0)))

    if not number:
        try:
            while True:
                print("> ", end="")
                number = input()
                try:
                    fun(number)
                except ValueError as e:
                    print(e)
        except (KeyboardInterrupt, EOFError):
            print("")
    else:
        fun(number)


def bits(number=None):
    def fun(number):
        print([x for x, y in enumerate(bin(int(number))[2:][::-1]) if y != "0"])

    if not number:
        try:
            while True:
                print("> ", end="")
                number = input()
                try:
                    fun(number)
                except ValueError as e:
                    print(e)
        except (KeyboardInterrupt, EOFError):
            print("")
    else:
        fun(number)
