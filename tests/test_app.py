from datetime import date
from app import create_app, db
from app.models import Task


def test_home_page_and_task_lifecycle():
    app = create_app({
        "TESTING": True,
        "SQLALCHEMY_DATABASE_URI": "sqlite:///:memory:",
    })
    client = app.test_client()

    response = client.get("/")
    assert response.status_code == 200
    assert b"Daily Task Planner" in response.data

    response = client.post("/tasks", data={"title": "Deploy to ECS", "task_date": date.today().isoformat()})
    assert response.status_code == 302

    with app.app_context():
        task = db.session.execute(db.select(Task)).scalar_one()
        task_id = task.id

    client.post(f"/tasks/{task_id}/toggle")
    with app.app_context():
        assert db.session.get(Task, task_id).completed is True

    client.post(f"/tasks/{task_id}/delete")
    with app.app_context():
        assert db.session.get(Task, task_id) is None


def test_health_endpoint():
    app = create_app({
        "TESTING": True,
        "SQLALCHEMY_DATABASE_URI": "sqlite:///:memory:",
    })
    response = app.test_client().get("/health")
    assert response.status_code == 200
    assert response.get_json()["status"] == "ok"
