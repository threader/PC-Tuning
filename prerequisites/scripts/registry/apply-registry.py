import sys
import os
import subprocess
import argparse


def main():
    """CLI Entrypoint"""

    parser = argparse.ArgumentParser()

    # these currently do not do anything, they are here for the future so that user experience is unaffected
    parser.add_argument("--win7", action="store_true", help="enables windows 7 support")
    parser.add_argument("--win8", action="store_true", help="enables windows 8 support")
    parser.add_argument("--win10", action="store_true", help="enables windows 10 support")

    args = parser.parse_args()

    registry_dir = "C:\\prerequisites\\scripts\\registry"

    if args.win7 and args.win10:
        print("error: registry file can only be applied for one windows version")
        return 1

    if not (args.win7 or args.win10):
        print("error: must specify windows version to apply registry files for")
        return 1

    nsudo_path = "C:\\prerequisites\\nsudo\\NSudo.exe"
    if not os.path.exists(nsudo_path):
        print(f"error: {nsudo_path} not exists")
        return 1

    # if not all(os.path.exists(f"{registry_dir}\\{x}.reg") for x in ["registry", "W7", "W10"]):
    #     print("error: registry files not found")
    #     return 1

    if not os.path.exists(f"{registry_dir}\\registry.reg"):
        print("error: registry files not found")
        return 1

    nsudo_args = [nsudo_path, "-U:T", "-P:E", "-Wait"]

    subprocess.run(["regedit.exe", "/s", f"{registry_dir}\\registry.reg"], check=False)
    subprocess.run([*nsudo_args, "regedit.exe", "/s", f"{registry_dir}\\registry.reg"], check=False)

    # if args.win7:
    #     subprocess.run(["regedit.exe", "/s", f"{registry_dir}\\W10.reg"], check=False)
    #     subprocess.run([*nsudo_args, "regedit.exe", "/s", f"{registry_dir}\\registry\\W10.reg"], check=False)
    # elif args.win10:
    #     subprocess.run(["regedit.exe", "/s", f"{registry_dir}\\W10.reg"], check=False)
    #     subprocess.run([*nsudo_args, "regedit.exe", "/s", f"{registry_dir}\\W7.reg"], check=False)

    return 0


if __name__ == "__main__":
    sys.exit(main())
