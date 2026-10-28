# Cross-platform compatibility notes

Windows PowerShell entry points supplement—not replace—the existing Fedora/Linux Bash scripts.

| Task | Windows | Fedora/Linux |
|---|---|---|
| Start backend | .\work\start-backend.ps1 | bash work/start-backend.sh |
| Start frontend | .\work\start-frontend.ps1 | bash work/start-frontend.sh |
| Check environment | .\work\check-environment.ps1 | bash work/check-environment.sh |
| Python import path | $env:PYTHONPATH = ".;backend" | export PYTHONPATH=".:backend" |
| SQLite demo URL | $env:MOBILE_PENTEST_DATABASE_URL = "sqlite:///./storage/masa.sqlite3" | export MOBILE_PENTEST_DATABASE_URL="sqlite:///./storage/masa.sqlite3" |

## Guidelines

- Prefer pathlib.Path for Python filesystem operations.
- Avoid hardcoded Linux paths, shell built-ins, and Unix-only executable assumptions in application logic.
- Configure external tools through MOBILE_PENTEST_*_PATH settings and a private .env file.
- Use Windows paths in .env where appropriate, for example C:/tools/apktool.jar.
- Preserve existing Fedora defaults and Bash scripts.
- Script availability alone does not prove all analysis features work on every host OS; test each workflow independently.

PostgreSQL is suitable for a shared/team setup. SQLite is a local single-user fallback.

## Maintainer validation checklist

- [ ] Python dependencies install on Windows and Fedora.
- [ ] Backend starts and the health endpoint responds on both.
- [ ] Frontend npm ci, npm run dev, and npm run build work on both.
- [ ] APK validation, apktool, and JADX work with configured tools.
- [ ] Storage/workspace paths are created correctly on both.
- [ ] PostgreSQL and SQLite behave as documented.
- [ ] ADB, emulator boot, logcat, and screenshots are tested on each supported host.
- [ ] Optional Ghidra analysis is tested on each supported host.
- [ ] Automated tests run on both operating systems.
- [ ] Commands in each OS-specific guide have been verified on that OS.
