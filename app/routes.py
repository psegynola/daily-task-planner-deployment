from datetime import date, datetime, timedelta
from flask import Blueprint, jsonify, redirect, render_template, request, url_for
from . import db
from .models import Task

main = Blueprint("main", __name__)


def week_dates(start_date):
    monday = start_date - timedelta(days=start_date.weekday())
    return [monday + timedelta(days=i) for i in range(7)]


@main.get("/")
def index():
    requested_date = request.args.get("date")
    try:
        selected = datetime.strptime(requested_date, "%Y-%m-%d").date() if requested_date else date.today()
    except ValueError:
        selected = date.today()

    days = week_dates(selected)
    tasks = Task.query.filter(Task.task_date.in_(days)).order_by(Task.created_at.asc()).all()
    grouped = {day: [] for day in days}
    for task in tasks:
        grouped[task.task_date].append(task)

    return render_template("index.html", days=days, grouped=grouped, selected=selected)


@main.post("/tasks")
def create_task():
    title = request.form.get("title", "").strip()
    task_date = request.form.get("task_date", "")

    if not title or len(title) > 200:
        return redirect(request.referrer or url_for("main.index"))

    try:
        parsed_date = datetime.strptime(task_date, "%Y-%m-%d").date()
    except ValueError:
        return redirect(request.referrer or url_for("main.index"))

    db.session.add(Task(title=title, task_date=parsed_date))
    db.session.commit()
    return redirect(request.referrer or url_for("main.index"))


@main.post("/tasks/<int:task_id>/toggle")
def toggle_task(task_id):
    task = db.get_or_404(Task, task_id)
    task.completed = not task.completed
    db.session.commit()
    return redirect(request.referrer or url_for("main.index"))


@main.post("/tasks/<int:task_id>/delete")
def delete_task(task_id):
    task = db.get_or_404(Task, task_id)
    db.session.delete(task)
    db.session.commit()
    return redirect(request.referrer or url_for("main.index"))


@main.get("/health")
def health():
    try:
        db.session.execute(db.select(Task.id).limit(1))
        return jsonify(status="ok", database="connected"), 200
    except Exception:
        return jsonify(status="error", database="unavailable"), 503
