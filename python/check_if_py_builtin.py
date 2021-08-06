#!/usr/bin/python

import pkgutil
import sys


def get_pkgs_installed():
    return [p.name for p in pkgutil.iter_modules() if p.name[0] != '_']


def pip_freeze():
    try:
        from pip._internal.operations import freeze
    except ImportError:  # for pip < 10.0
        from pip.operations import freeze

    return list(freeze.freeze())


def list_diff(l1, l2):
    difference = list(set(l1) - set(l2))
    difference.sort()
    return difference


default_python_packages = list_diff(
    get_pkgs_installed(),
    pip_freeze()
)

if len(sys.argv) != 2:
    print('Usage: check_if_py_builtin.py module_name', file=sys.stderr)
    sys.exit(2)

if sys.argv[1] in default_python_packages:
    print('yes')
else:
    print('nope')
