# MASA + DY-MASA on Windows 10/11

This guide adds Windows instructions while preserving the Fedora/Linux workflow. Use PowerShell from the repository root unless a step says otherwise.

## 1. Install prerequisites

Install Git for Windows, Python 3.11 or 3.12, Node.js LTS (includes npm), a Java JDK supported by your installed tools, Android SDK Platform Tools (ADB), apktool, and JADX. Android Emulator and Ghidra are optional; PostgreSQL is optional for local single-user use because SQLite is supported.

Verify commands:

~~~powershell
git --version
python --version
node --version
npm --version
java -version
adb version
~~~

## 2. Clone and install

~~~powershell
git clone https://github.com/nasif-xy/MASA-INSA-project.git
Set-Location MASA-INSA-project
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r backend\requirements.txt
Set-Location frontend
npm ci
Set-Location ..
~~~

If PowerShell blocks virtual-environment activation, invoke .venv\Scripts\python.exe directly rather than weakening the machine-wide execution policy.

## 3. Configure

~~~powershell
Copy-Item .env.windows.example .env
notepad .env
~~~

Set Java, apktool, JADX, Android SDK, ADB, emulator, and optional Ghidra paths to real locations. The example contains placeholders. Never commit .env because it may contain credentials.

For a local SQLite demo, put this in .env:

~~~dotenv
MOBILE_PENTEST_DATABASE_URL=sqlite:///./storage/masa.sqlite3
~~~

PostgreSQL is also supported. SQLite is intended for a local single-user demo, not a shared production deployment.

## 4. Check tools

From the repository root:

~~~powershell
.\work\check-environment.ps1
~~~

Fix missing commands and tool paths before running a full scan.

## 5. Start MASA

Open two PowerShell terminals at the repository root.

Terminal A:

~~~powershell
.\work\start-backend.ps1
~~~

Terminal B:

~~~powershell
.\work\start-frontend.ps1
~~~

Open http://127.0.0.1:5173. Backend health is at http://127.0.0.1:8000/api/health.

Manual backend startup:

~~~powershell
$env:PYTHONPATH = ".;backend"
.\.venv\Scripts\python.exe -m uvicorn app.main:app --host 127.0.0.1 --port 8000
~~~

In a second terminal:

~~~powershell
Set-Location frontend
npm run dev
~~~

## 6. Optional Android runtime validation

Install Android SDK Platform Tools and, if needed, Android Emulator through Android Studio's SDK Manager. Set ANDROID_HOME or ANDROID_SDK_ROOT and add platform-tools to PATH, or configure explicit MASA paths in .env. Confirm adb devices works. For a physical device, enable USB debugging only on a device you own or are authorized to test, then approve its RSA prompt. Ensure the configured AVD exists before emulator-based validation.

Test static analysis first; DY-MASA runtime validation is optional and must be verified separately on your host.

## 7. Tests and troubleshooting

Run the test command documented by the current project and install its test dependencies. For a pytest-based suite, the typical command is python -m pytest; this does not claim pytest or every optional dependency is installed.

- Python/npm not found: install supported versions, ensure they are on PATH, and reopen PowerShell.
- Java/JADX/apktool errors: verify JAR paths and supported Java versions.
- ADB says unauthorized: unlock the test device and accept its debugging authorization.
- Database errors: verify PostgreSQL credentials or configure the SQLite URL above.
- Missing tool paths: run the environment checker and correct .env.

Only analyze APKs you own or have permission to assess. Automated findings require manual validation; a clean scan does not prove an app is secure.
