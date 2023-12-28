#!/usr/bin/env python

from fastapi import FastAPI

app = FastAPI()

msg = """
Hello, python_template!

This is a template for python projects.

Try opening localhost:3000/docs in your browser.
"""
msg = msg.strip()


@app.get("/hello")
def hello():
    """Returns a hello message."""
    return {"message": msg}
