#!/usr/bin/python

import requests
import sys
import webbrowser


def open_module_entry(module):
    url = 'https://docs.python.org/{}/library/{}.html'.format(
            '.'.join(sys.version.split('.')[:2]),
            module
        )

    try:
        resp = requests.get(url)
        resp.raise_for_status()
    except requests.exceptions.ConnectionError as err:
        # no internet
        raise SystemExit(err)
    except requests.exceptions.HTTPError as err:
        # url, server and other errors
        raise SystemExit(err)

    webbrowser.open(url)


if len(sys.argv) != 2:
    print('Usage: open_pydoc.py module_name', file=sys.stderr)
    sys.exit(2)

open_module_entry(sys.argv[1])
