"""
Pytest configuration for odyssey_video tests.
Adds the parent directory to sys.path so modules can be imported directly.
"""
import sys
import os

# Add the odyssey_video package root to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
