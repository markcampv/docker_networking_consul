FROM python:3.11-slim
WORKDIR /app
RUN pip install flask waitress requests
COPY app.py .
ENV PORT=6060
CMD ["python","app.py"]
