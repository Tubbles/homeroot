---
name: python-uv
description: Python package management conventions using `uv` instead of `pip`. Always create a project-local venv before installing; never install system-wide. Load when working with Python code, installing or upgrading Python packages, creating virtual environments, or seeing `pyproject.toml` / `requirements.txt` / `.py` files in the task.
---

# Python

- Always use `uv` instead of `pip` or `pip3`.
- Always create a venv with `uv venv` first — never install system-wide (`--system`).
- Install packages with `uv pip install --python .venv/bin/python <package>`.
