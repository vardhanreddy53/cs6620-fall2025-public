# Use an official slim Python base image
FROM python:3.11-slim

# Cleaner Python output / no .pyc bytecode in container
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Working directory inside the container
WORKDIR /app

# Install system deps — ffmpeg is required by pydub (used in app.py)
RUN apt-get update && apt-get install -y --no-install-recommends \
        ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Install Python deps first so this layer caches when only app code changes
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .

# app.py hardcodes port=3000; assignment requires 5000
RUN sed -i 's/port=3000/port=5000/' app.py

# Document the port the container listens on
EXPOSE 5000

# Start the Flask app
CMD ["python", "app.py"]