FROM --platform=linux/amd64 python:3.11.3-slim

WORKDIR /app
COPY . .
RUN pip install --no-cache-dir .

# Create a non-root user to run the app
RUN useradd -m flaskuser 
RUN chown -R flaskuser:flaskuser /app
USER flaskuser

ENV FLASK_APP=hello

EXPOSE 5000

CMD ["flask", "run", "--host=0.0.0.0"]
