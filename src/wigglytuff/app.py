"""Web app module."""
import subprocess  # nosec
from concurrent.futures import Future, ThreadPoolExecutor
from functools import partial

from flask import Flask, redirect, render_template, request, url_for


# WSGI entry point
def create_app():
    """Configure Flask app and return it."""

    app = Flask(__name__)
    executor = ThreadPoolExecutor(max_workers=2)
    # TODO: clean up after SIGINT SIGTERM
    futures_store: set[Future] = set()

    app.add_url_rule(
        "/",
        "home",
        partial(home_view, request=request, app=app, futures_store=futures_store),
    )
    app.add_url_rule(
        "/download_yt",
        "download_yt",
        view_func=partial(
            get_yt_video,
            request=request,
            app=app,
            executor=executor,
            futures_store=futures_store,
        ),
        methods=["POST"],
    )
    return app


# baba
def home_view(request, app, futures_store: set):
    """Render all features in the feature store."""
    return render_template("home.html", futures=futures_store)


def get_yt_video(request, app, executor, futures_store: set):
    """TODO."""
    # TODO sec risk validate form
    dl_future = executor.submit(
        subprocess.run,
        "youtube-dl --audio-format mp3 --audio-quality 9 -x".split()
        + [request.form.get("url")],
        capture_output=True,
    )
    futures_store.add(dl_future)
    _ = executor.submit(move_mp3, dl_future, "TODO")

    return redirect(url_for("home"))


# TODO
def move_mp3(blocking_future, dest_path):
    """TODO."""
    blocking_future.result()


if __name__ == "__main__":
    app = create_app()
