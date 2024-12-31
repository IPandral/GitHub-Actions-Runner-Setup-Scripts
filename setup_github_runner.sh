#!/bin/bash

# Detect architecture
detect_architecture() {
	arch=$(uname -m)
	case $arch in
	"x86_64") echo "x64" ;;
	"aarch64") echo "arm64" ;;
	"armv7l" | "armhf") echo "arm" ;;
	*)
		echo "Unsupported architecture: $arch"
		exit 1
		;;
	esac
}

# Generate a unique directory name based on the repository name
generate_unique_dir() {
	local repo_name=$1
	local base_dir=$2
	local counter=1
	local unique_dir="$base_dir/$repo_name"

	# Check if directory exists; append _1, _2, etc., until unique
	while [ -d "$unique_dir" ]; do
		unique_dir="$base_dir/${repo_name}_$counter"
		counter=$((counter + 1))
	done

	echo "$unique_dir"
}

# Download the runner
download_runner() {
	local dir=$1
	local arch=$2
	local version="2.321.0"
	local url=""
	local checksum=""

	case $arch in
	"x64")
		url="https://github.com/actions/runner/releases/download/v$version/actions-runner-linux-x64-$version.tar.gz"
		checksum="ba46ba7ce3a4d7236b16fbe44419fb453bc08f866b24f04d549ec89f1722a29e"
		;;
	"arm64")
		url="https://github.com/actions/runner/releases/download/v$version/actions-runner-linux-arm64-$version.tar.gz"
		checksum="62cc5735d63057d8d07441507c3d6974e90c1854bdb33e9c8b26c0da086336e1"
		;;
	"arm")
		url="https://github.com/actions/runner/releases/download/v$version/actions-runner-linux-arm-$version.tar.gz"
		checksum="2b96a4991ebf2b2076908a527a1a13db590217f9375267b5dd95f0300dde432b"
		;;
	esac

	mkdir -p "$dir"
	cd "$dir" || exit
	curl -o "runner.tar.gz" -L "$url"
	echo "$checksum  runner.tar.gz" | shasum -a 256 -c || {
		echo "Checksum validation failed!"
		exit 1
	}
	tar xzf "runner.tar.gz"
	echo "Runner downloaded and extracted in $dir."
}

# Configure the runner
configure_runner() {
	local dir=$1
	local url=$2
	local token=$3
	cd "$dir" || exit
	./config.sh --url "$url" --token "$token" || {
		echo "Runner configuration failed!"
		exit 1
	}
	echo "Runner configured successfully in $dir."
}

# Set up the runner as a systemd service
setup_service() {
	local dir=$1
	local runner_name
	runner_name=$(basename "$dir")

	echo "Creating systemd service for $runner_name..."
	sudo bash -c "cat > /etc/systemd/system/$runner_name.service" <<EOL
[Unit]
Description=GitHub Actions Runner - $runner_name
After=network.target

[Service]
ExecStart=$dir/run.sh
WorkingDirectory=$dir
Restart=always
User=$(whoami)
Group=$(whoami)

[Install]
WantedBy=multi-user.target
EOL

	# Enable and start the service
	sudo systemctl daemon-reload
	sudo systemctl enable "$runner_name.service"
	sudo systemctl start "$runner_name.service"
	echo "Systemd service for $runner_name created and started."
}

# Main script logic
base_dir=$(pwd)
arch=$(detect_architecture)

# Ask for repository details
echo "Enter the GitHub repository URL (e.g., https://github.com/owner/repo):"
read -r repo_url
echo "Enter the GitHub Actions Runner Token:"
read -r token

# Extract repository name from the URL
repo_name=$(basename "$repo_url")
unique_dir=$(generate_unique_dir "$repo_name" "$base_dir")

# Download, configure, and set up the runner
download_runner "$unique_dir" "$arch"
configure_runner "$unique_dir" "$repo_url" "$token"
setup_service "$unique_dir"

echo "Runner setup completed for $repo_name!"
