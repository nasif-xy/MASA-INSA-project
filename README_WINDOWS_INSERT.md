## Windows quick start

Windows 10/11 is supported as a development target alongside Fedora/Linux. The Windows PowerShell scripts supplement the existing Bash scripts; they do not replace them.

Read [Windows setup](docs/WINDOWS_SETUP.md) for prerequisites, virtual-environment setup, APK tool configuration, Android SDK configuration, and troubleshooting.

From the repository root, use two PowerShell terminals:

~~~powershell
.\work\check-environment.ps1
.\work\start-backend.ps1
~~~

In the second terminal:

~~~powershell
.\work\start-frontend.ps1
~~~

Then open http://127.0.0.1:5173. Configure your own local .env from .env.windows.example before running a full APK analysis. Review [cross-platform compatibility notes](docs/CROSS_PLATFORM_COMPATIBILITY.md). Windows support has not been fully validated merely by adding these launchers; test the backend, APK tooling, Android runtime, and automated tests on the target machine.
