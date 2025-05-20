#!/bin/bash
set -ex

# Check if an input file was provided
if [ -z "$1" ]; then
  echo "Error: No input PDF file provided."
  echo "Usage: docker run ... gitahievans/audiveris:latest /input/yourfile.pdf"
  exit 1
fi

# Extract filename without path and extension
INPUT_FILE=$(basename "$1")
FILE_BASE="${INPUT_FILE%.*}"

# Check if the input file exists in /input
if [ ! -f "$1" ]; then
  echo "Error: Input file $1 not found."
  echo "Contents of /input directory:"
  ls -la /input
  exit 1
fi

# Debug: Check file permissions and details
echo "Processing file: $1"
ls -la "$1"

# Debug: Verify Tesseract installation
echo "Tesseract version:"
tesseract --version || { echo "Tesseract failed to run"; exit 1; }

# Debug: Check Java version
echo "Java version:"
java -version 2>&1

# Run Audiveris with classpath including all JARs in /app/
echo "Running Audiveris on $1..."
java -cp "/app/*" Audiveris -batch -output /output -export "$1" 2>&1 | tee /output/audiveris.log

# Check the exit status of the Java command
JAVA_EXIT=$?
if [ $JAVA_EXIT -ne 0 ]; then
  echo "Audiveris Java command failed with exit code $JAVA_EXIT"
  cat /output/audiveris.log
  ls -la /output
  exit 1
fi

# List output directory contents
echo "Output directory contents:"
ls -la /output

echo "Conversion complete."