import os
from flask import Flask
from flask_sqlalchemy import SQLAlchemy


db = SQLAlchemy()


def create_app(test_config=None):
    app = Flask(__name__)

    database_url = os.getenv("DATABASE_URL", "sqlite:////data/tasks.db")
    if database_url.startswith("postgres://"):
        database_url = database_url.replace("postgres://", "postgresql://", 1)

    app.config.from_mapping(
        SECRET_KEY=os.getenv("SECRET_KEY", "dev-change-me"),
        SQLALCHEMY_DATABASE_URI=database_url,
        SQLALCHEMY_TRACK_MODIFICATIONS=False,
    )

    if test_config:
        app.config.update(test_config)

    db.init_app(app)

    from datetime import timedelta
    app.jinja_env.globals["timedelta"] = timedelta

    from .routes import main
    app.register_blueprint(main)

    with app.app_context():
        db.create_all()

    return app
