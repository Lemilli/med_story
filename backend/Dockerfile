FROM python:3.12.13-slim-trixie

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

RUN addgroup --system --gid 10001 medstory \
    && adduser --system --uid 10001 --ingroup medstory --home /app --no-create-home medstory

COPY --chown=medstory:medstory . .

USER medstory

EXPOSE 8000

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
