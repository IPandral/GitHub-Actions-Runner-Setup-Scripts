# GitHub Actions Runner Setup Scripts

This repository contains two scripts to help you set up and manage GitHub Actions runners on your Linux machine. These scripts automate the process of creating, configuring, and starting GitHub Actions runners as systemd services.

## Features

- **Setup GitHub Runners**: Automates the setup of a new GitHub Actions runner, including downloading the appropriate binaries, configuring the runner, and setting it up as a `systemd` service.
- **Auto-Start Existing Runners**: Automatically sets up `systemd` services for existing GitHub Actions runners in the current directory.
- Supports multiple runners on the same machine, ensuring no conflicts.

## Scripts

### 1. `setup_github_runner.sh`

This script is for setting up a new GitHub Actions runner. It downloads the required binaries, configures the runner for a specified repository, and creates a `systemd` service to manage the runner.

#### **Usage**

1. **Make the script executable:**
   ```bash
   chmod +x setup_github_runner.sh
   ```

2. **Run the script:**
   ```bash
   ./setup_github_runner.sh
   ```

3. **Follow the prompts:**
   - Enter the GitHub repository URL (e.g., `https://github.com/owner/repo`).
   - Enter the GitHub Actions Runner token.

4. **Repeat for additional runners:**
   Run the script again for each new runner you want to set up.

#### **How It Works**

- Automatically detects the system architecture (`x64`, `arm64`, or `arm`).
- Ensures unique directories for each runner by appending `_1`, `_2`, etc., to the repository name if needed.
- Configures and starts the runner as a `systemd` service.

### 2. `auto_start_github_runners.sh`

This script is for users who have already set up runners and just want to ensure they are configured as `systemd` services for auto-start.

#### **Usage**

1. **Make the script executable:**
   ```bash
   chmod +x auto_start_github_runners.sh
   ```

2. **Run the script:**
   ```bash
   ./auto_start_github_runners.sh
   ```

3. **What It Does:**
   - Iterates over all subdirectories in the current directory.
   - Checks if each directory contains a `run.sh` file (indicating a valid GitHub Actions runner).
   - Creates or updates a `systemd` service for each runner.
   - Enables and starts the services.

## Directory Structure

After running the scripts, the directory will look like this:

```
github-runners/
├── setup_github_runner.sh  # Script to set up new runners
├── auto_start_github_runners.sh  # Script to auto-start existing runners
├── repo1/                   # Runner for repo1
│   ├── run.sh
│   ├── config.sh
│   └── ...
├── repo1_1/                 # Another runner for repo1
│   ├── run.sh
│   ├── config.sh
│   └── ...
└── repo2/                   # Runner for repo2
    ├── run.sh
    ├── config.sh
    └── ...
```

## Prerequisites

1. A Linux-based system with `bash` installed.
2. `curl`, `shasum`, and `tar` must be available (usually pre-installed on most Linux distributions).
3. A valid GitHub Actions token for the repository or organization where the runner will be used.

## License

This project is licensed under the MIT License. See the full license below.

---

## MIT License

```
MIT License

Copyright (c) 2025 Matthew Revill

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## Contributions

Contributions are welcome! Feel free to fork this repository and submit a pull request with your improvements.

## Support

If you encounter any issues or have questions about the scripts, please open an issue in this repository.
