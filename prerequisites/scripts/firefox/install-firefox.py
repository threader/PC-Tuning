import sys
import ctypes
import os
import subprocess
import json
import requests

def main() -> int:
    """program entrypoint"""

    if not ctypes.windll.shell32.IsUserAnAdmin():
        print("error: administrator privileges required")
        return 1

    print("info: checking for an internet connection")
    try:
        requests.get("https://archlinux.org", timeout=3)
    except requests.ConnectionError:
        print("error: no internet connection")
        return 1

    subprocess_null = {"stdout": subprocess.DEVNULL, "stderr": subprocess.DEVNULL}
    setup = f"{os.environ['TEMP']}\\FirefoxSetup.exe"
    download_link = "https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=en-GB"
    install_dir = "C:\\Program Files\\Mozilla Firefox"
    policies = f"{install_dir}\\distribution\\policies.json"

    response = requests.get("https://product-details.mozilla.org/1.0/firefox_versions.json", timeout=3)
    remote_version = response.json()["LATEST_FIREFOX_VERSION"]

    remove_files = [
        "crashreporter.exe",
        "crashreporter.ini",
        "defaultagent.ini",
        "defaultagent_localized.ini",
        "default-browser-agent.exe",
        "maintenanceservice.exe",
        "maintenanceservice_installer.exe",
        "pingsender.exe",
        "updater.exe",
        "updater.ini",
        "update-settings.ini"
    ]

    policies_content = {
        "policies": {
            "DisableAppUpdate": True,
            "OverrideFirstRunPage": "",
            "DisableFirefoxStudies": True,
            "DisableTelemetry": True,
            "Extensions": {
                "Install": [
                    "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi"
                ]
            },
        }
    }

    if os.path.exists(f"{install_dir}\\firefox.exe"):
        process = subprocess.run(['C:\\Program Files\\Mozilla Firefox\\firefox.exe', '--version', '|', 'more'], capture_output=True, check=False, universal_newlines=True)
        local_version = process.stdout.split()[-1]

        if all([remote_version, local_version]) and local_version == remote_version:
            print(f"info: latest version {remote_version} already installed")
            return 0

    if os.path.exists(setup):
        os.remove(setup)

    print(f"info: downloading firefox {remote_version} setup")
    with open(setup, "wb") as binary:
        binary.write(requests.get(download_link, timeout=5).content)

    if not os.path.exists(setup):
        print("error: download unsuccessful")
        return 1

    subprocess.run(["taskkill", "/F", "/IM", "Firefox.exe"], **subprocess_null, check=False)

    print("info: installing firefox")
    subprocess.run([setup, "/S", "/MaintenanceService=false"], check=False)

    os.remove(setup)

    print("info: removing bloatware")
    for file in remove_files:
        file = f"{install_dir}\\{file}"
        if os.path.exists(file):
            os.remove(file)

    print("info: importing policies")
    os.makedirs(f"{install_dir}\\distribution", exist_ok=True)

    if os.path.exists(policies):
        os.remove(policies)

    with open(policies, "a", encoding="UTF-8") as f:
        json.dump(policies_content, f, indent=4)

    print("info: done")

    return 0

if __name__ == "__main__":
    sys.exit(main())
