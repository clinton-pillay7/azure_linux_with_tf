# Use the official Python image from the Docker Hub
FROM python:3.9-slim

# Copy the requirements file into the container
COPY requirements.txt requirements.txt

# Install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container
COPY . .

# Expose the port that the Flask app will run on
EXPOSE 5000

# Run the Flask app
CMD ["python", "flaskapp.py"]