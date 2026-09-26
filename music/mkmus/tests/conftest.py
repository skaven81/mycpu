"""
Pytest configuration for music/mkmus tests.
Adds the parent directory to sys.path so modules can be imported directly.
"""
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
