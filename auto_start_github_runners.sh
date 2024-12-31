#!/bin/bash

# This script sets up GitHub Actions runners as systemd services.
# It iterates over all subdirectories in the current directory,
# checks if they contain a valid GitHub runner (identified by the presence of 'run.sh'),
# and creates or updates a corresponding systemd service file for each runner.
# The script then enables and starts the service for each runner.

# Steps:
# 1. Get the current directory where the script is executed.
# 2. Get the current user and group.
# 3. Iterate over all subdirectories in the current directory.
# 4. For each subdirectory, check if it contains a 'run.sh' file.
# 5. If 'run.sh' is found, create or update a systemd service file for the runner.
# 6. Enable and start the systemd service for the runner.
# 7. Print messages indicating the progress and status of the setup process.

# Get the current directory (where the script is executed)
PARENT_DIR=$(pwd)

# Current user and group
USER=$(whoami)

echo "Starting GitHub runner service setup in: $PARENT_DIR"

# Iterate over all subdirectories
for runner_dir in "$PARENT_DIR"/*/; do
	# Extract the directory name (e.g., runner1, runner2)
	runner_name=$(basename "$runner_dir")
	service_file="/etc/systemd/system/$runner_name.service"

	# Check if the directory contains a valid runner
	if [ ! -f "$runner_dir/run.sh" ]; then
		echo "Skipping $runner_name: No 'run.sh' found."
		continue
	fi

	# Create the systemd service file
	echo "Creating or updating systemd service for $runner_name..."
	sudo bash -c "cat > $service_file" <<EOL
[Unit]
Description=GitHub Actions Runner - $runner_name
After=network.target

[Service]
ExecStart=$runner_dir/run.sh
WorkingDirectory=$runner_dir
Restart=always
User=$USER
Group=$USER

[Install]
WantedBy=multi-user.target
EOL

	# Enable and start the service
	echo "Enabling and starting the service for $runner_name..."
	sudo systemctl daemon-reload
	sudo systemctl enable "$runner_name.service"
	sudo systemctl start "$runner_name.service"

	echo "Service for $runner_name created and started successfully!"
done

echo "All runners in $PARENT_DIR have been processed!"
