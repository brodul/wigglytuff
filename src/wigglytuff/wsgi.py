"""Entrypoint for WSGI servers."""
from .app import create_app

wsgi_entrypoint = create_app()
