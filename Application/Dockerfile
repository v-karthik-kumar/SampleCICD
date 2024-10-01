# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy the current directory contents into the container at /usr/src/app
COPY . .
RUN cd ./banking-system
WORKDIR /usr/src/app/banking-system
# Install any needed packages specified in requirements.txt
RUN pwd

RUN pip install --no-cache-dir -r requirements.txt

# Make port 5000 available to the world outside this container
EXPOSE 8000

# Define environment variable to prevent Python from buffering output
ENV PYTHONUNBUFFERED=1

#CMD ["python", "main.py", "--host=0.0.0.0"]
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
