#!/usr/bin/env python3

# /usr/local/bin/st -g100x30 -e python3 -i /home/tubbles/.install/interactive.py
# /usr/local/bin/st -g44x30 -e R -q --no-save

from datetime import timedelta
from math import floor  # pyright: ignore[reportUnusedImport] useful for interactive use
from math import log2  # pyright: ignore[reportUnusedImport] useful for interactive use
from math import sqrt  # pyright: ignore[reportUnusedImport] useful for interactive use
from math import log10  # pyright: ignore[reportUnusedImport] useful for interactive use
from math import log1p as ln  # pyright: ignore[reportUnusedImport] useful for interactive use


def frac(a: int, b: int) -> tuple[int, int]:
    from fractions import Fraction

    return Fraction(a, b).as_integer_ratio()


def eng(n: float, precision: int = 2) -> str:
    """Formats a number in engineering notation (E3, E6, E-3, etc.)"""
    if n == 0:
        return "0"

    exponent = int(floor(log10(abs(n)) / 3) * 3)
    mantissa = n / (10**exponent)

    return f"{mantissa:.{precision}f}E{exponent}"


def _pretty_print_timedelta(td: timedelta) -> None:
    string = ""
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


def s(dur: float) -> None:
    _pretty_print_timedelta(timedelta(seconds=dur))


def ms(dur: float) -> None:
    _pretty_print_timedelta(timedelta(milliseconds=dur))


def us(dur: float) -> None:
    _pretty_print_timedelta(timedelta(microseconds=dur))


def todec(number: str | int | None = None) -> None:
    def fun(number: str | int) -> None:
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


def tohex(number: str | int | None = None) -> None:
    def fun(number: str | int) -> None:
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


def tobin(number: str | int | None = None) -> None:
    def fun(number: str | int) -> None:
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


def tooct(number: str | int | None = None) -> None:
    def fun(number: str | int) -> None:
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


def bits(number: str | int | None = None) -> None:
    def fun(number: str | int) -> None:
        print([x for x, y in enumerate(bin(int(str(number)))[2:][::-1]) if y != "0"])

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


def unit(value: float, unit_str: str) -> None:
    import pint
    from collections import defaultdict

    ureg = pint.UnitRegistry()
    try:
        qty = ureg.Quantity(value, unit_str)
        base_dim = qty.dimensionality
    except Exception:
        return
    sys_mapping: dict[str, str] = {}
    for g_name, group in ureg._groups.items():
        for member in group.members:
            sys_mapping[member] = g_name
    conversions: defaultdict[str, set[str]] = defaultdict(set)
    for u_name in dir(ureg):
        if "Δ" in u_name or u_name.startswith("_"):
            continue
        try:
            u_obj = getattr(ureg, u_name)
            if not isinstance(u_obj, ureg.Unit) or u_obj.dimensionality != base_dim:
                continue
            res = qty.to(u_obj)
            root_name = str(ureg.get_name(u_name))
            system = sys_mapping.get(u_name, sys_mapping.get(root_name, "other"))
            conversions[system].add(f"{res.magnitude} {u_name}")
        except Exception:
            continue
    for sys in sorted(conversions.keys()):
        print(f"= {sys}")
        for line in sorted(conversions[sys]):
            print(line)
