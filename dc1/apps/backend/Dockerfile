FROM python:3.11-slim
WORKDIR /app
RUN pip install flask waitress
COPY app.py .
ENV PORT=7000
ENV VERSION=v1
CMD ["python","app.py"]
