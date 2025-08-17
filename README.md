# 🚀 Universal UV Project Bootstrapper

This is a powerful, feature-rich batch script for Windows that automates the entire setup process for a Python project using the lightning-fast `uv` tool from Astral.

It is designed to be a one-stop-shop for bootstrapping a new project, handling everything from `uv`'s installation and virtual environment creation to dependency management and Git repository initialization. It's robust, user-friendly, and built to handle common Windows environment and permission issues gracefully.

---

## ✨ Features

- **Zero-Dependency Auto-Install:** Automatically detects if `uv` is missing, installs it using PowerShell, and permanently adds it to the user `PATH`.
- **Seamless Terminal Restart:** Intelligently restarts itself in a new terminal after installation to ensure `uv` is immediately available, bypassing common PATH issues.
- **Multiple Interactive Modes:**
    - **`Auto Mode`:** A fire-and-forget setup that initializes a project, creates a venv, installs dependencies, and runs the main script.
    - **`Menu Mode`:** A guided, step-by-step menu for granular control over the setup process.
    - **`Toggle Mode`:** A power-user interface to select and run a custom sequence of tasks.
- **Intelligent Environment Handling:**
    - Detects an already-active virtual environment.
    - Automatically finds `pyproject.toml`, `requirements.lock`, or `requirements.txt`.
    - Uses the correct `uv` command (`sync` vs. `install`) based on the dependency file.
- **Configuration Persistence:** Saves and loads the chosen Python version and main script name to a local `config.json` file for consistency across sessions.
- **Robust Tooling:**
    - Uses PowerShell for reliable JSON parsing and `uv` installation.
    - Graceful error handling for failed installations or commands.
- **Developer-Friendly Extras:**
    - **Git Integration:** Initializes a Git repository and generates a comprehensive `.gitignore` file.
    - **VS Code Launch:** Instantly opens the project in Visual Studio Code.
    - **Activated Terminal:** Launches a new terminal session with the virtual environment pre-activated.

---

## 🚀 Getting Started

1.  Place `setup_uv.bat` in your new or existing project's root directory.
2.  Run the script from the command line:

```cmd
.\setup_uv.bat
```

### First-Run Experience

If `uv` is not installed, the script will automatically:
1.  Download and run the official `uv` installer.
2.  Permanently add `uv` to your user `PATH` using `setx`.
3.  Display a message and restart itself in a new terminal window.

Once `uv` is available, you will be prompted to choose an operating mode.

---

## ⚙️ Operating Modes

### 1. Auto Mode

The fastest way to get a project up and running. It performs a complete, logical setup:
- **Initializes Project:** If no dependency files or `main.py` are found, it runs `uv init` to create a default `pyproject.toml` and `.venv`.
- **Loads Config:** Applies settings from `config.json` if it exists.
- **Handles Setup:** Runs the sequence of creating a venv, installing dependencies, and selecting a main script.
- **Saves Config:** Persists the final configuration to `config.json`.
- **Runs Script:** Launches your main Python script using `uv run`.

### 2. Menu Mode

Provides a step-by-step interactive menu for full control. This is ideal for managing an existing project or for users who prefer a guided approach.

```
[1] Python Version Setup
[2] Virtual Environment
[3] Install Dependencies
[4] Select Main Script
[5] Git Initialization
[6] Print Summary
[7] VS Code Launch
[8] Activate Venv in New Terminal
[Q] Quit
```

### 3. Toggle Mode

A power-user mode that lets you select multiple actions to run in a single batch. Use the number keys to toggle an action `ON` (1) or `OFF` (0), then press `R` to run the selected tasks.

---

## 📄 Configuration File

The script uses a `config.json` file in the project root to remember your settings.

- **`python_version`:** The specific Python version you want `uv` to use (e.g., `"3.12"`).
- **`main_script`:** The entry point to your application. **You are not required to use `main.py`**. The script will prompt you to enter your desired script name (e.g., `app.py`, `src/server.py`), which is then saved here.

This file is created or updated automatically when you use the `Auto Mode` or the `Python Version Setup` and `Select Main Script` menu options.

**Example `config.json`:**
```json
{
    "python_version": "3.12",
    "main_script": "app/main.py"
}
```