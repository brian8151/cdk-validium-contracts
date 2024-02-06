import os
import sys
import datetime

# Check if the correct number of arguments are provided
if len(sys.argv) != 3:
    print("Usage: python script.py source_file target_file")
    sys.exit(1)

source_file = sys.argv[1]
target_file = sys.argv[2]

# Get the modification time of the source file
source_mtime = os.path.getmtime(source_file)

# Set target file mtime to source file mtime
os.utime(target_file, (source_mtime, source_mtime))

# Subtract one millisecond from the source mtime
target_mtime = source_mtime - 1

# Update the target file's mtime
os.utime(target_file, (target_mtime, target_mtime))
