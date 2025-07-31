# setup_uv.bat

This batch script automates the installation of the `uv` binary on Windows, with optional virtual environment creation.

- Downloads the latest `uv` binary for Windows (`x86_64-pc-windows-msvc`)
- Installs it to `%USERPROFILE%\.local\bin`
- Adds the installation path to the `PATH` environment variable (session-only)
- Optionally creates a Python virtual environment using `uv` (if `--venv` is provided)

---

## 🔧 Requirements

- Windows 10 or later
- PowerShell (included with Windows)
- Internet connection
- Python (required only for `--venv` option)

---

## 🚀 Usage

### 📦 Install `uv` Only

```cmd
setup_uv.bat
```

### 🐍 Install `uv` and Create a Virtual Environment

Creates a virtual environment named `.venv` in the current directory:

```cmd
setup_uv.bat --venv
```

---

## 📁 Installation Details

The script installs the following executables to `%USERPROFILE%\.local\bin`:

- `uv.exe`
- `uvx.exe`
- `uvw.exe`

If `%USERPROFILE%\.local\bin` is not in your `PATH`, the script will:

- Temporarily add it to your session's `PATH`, or
- Prompt you to manually add it for persistent use

---

## ✅ Post-Installation Check

Open a new terminal and run:

```cmd
uv --version
```

If a version number is displayed, the installation was successful. If not, verify that `%USERPROFILE%\.local\bin` is in your system's `PATH`.

---

## 🧼 Uninstallation

To uninstall, delete the following files:

```cmd
%USERPROFILE%\.local\bin\uv*.exe
```

Optionally, remove `%USERPROFILE%\.local\bin` from your `PATH` if it was added manually.

---

## 💬 Notes

- The script skips re-downloading if `uv.exe` already exists in `%USERPROFILE%\.local\bin`.
- It can be extended to support alternative sources (e.g., GitHub releases or Chocolatey).
- This is a lightweight, patch-safe batch script designed for quick setup or automation.

---

## 🛠️ Troubleshooting

**Q: "uv is not recognized as an internal or external command"**

A: Restart your terminal or manually add `%USERPROFILE%\.local\bin` to your user `PATH` environment variable.

**Q: Cannot write to `%USERPROFILE%\.local\bin`**

A: Ensure the directory exists and you have write permissions. Create it manually if needed:

```powershell
New-Item -ItemType Directory -Path "$env:USERPROFILE\.local\bin"
```
