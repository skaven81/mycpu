"""
Pytest bootstrap for Odyssey ANSI Studio.

Adds the package root (odyssey_ansi_studio/) to sys.path so tests can
`from studio.model... import ...` without an install step.  Mirrors
odyssey_video/tests/conftest.py.
"""

import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
