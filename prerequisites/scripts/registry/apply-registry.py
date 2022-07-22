import sys
import os
import subprocess
import argparse

nsudo_path = "C:\\prerequisites\\nsudo\\NSudo.exe"
nsudo_args = [nsudo_path, "-U:T", "-P:E", "-Wait"]


def apply_registry(file_path: str) -> None:
    """Function to merge registry files"""
    subprocess.run(["regedit.exe", "/s", file_path], check=False)
    subprocess.run([*nsudo_args, "regedit.exe", "/s", file_path], check=False)


def main():
    """CLI Entrypoint"""

    supported_winvers = [7, 8, 10]
    registry_dir = "C:\\prerequisites\\scripts\\registry"
    registry_files = ["registry.reg"]

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--winver",
        choices=supported_winvers,
        help="specify windows version to be configured",
        required=True,
        type=int,
        metavar="<winver>"
    )
    args = parser.parse_args()

    if not os.path.exists(nsudo_path):
        print(f"error: {nsudo_path} not exists")
        return 1

    if not all(os.path.exists(f"{registry_dir}\\{x}") for x in registry_files):
        print("error: registry files not found")
        return 1

    apply_registry(f"{registry_dir}\\registry.reg")

    print(f"info: applying registry file for {args.winver}")

    if args.winver == 7:
        pass
    elif args.winver == 8:
        apply_registry(f"{registry_dir}\\windows8.reg")
    elif args.winver == 10:
        apply_registry(f"{registry_dir}\\windows10+.reg")

    print("info: done")

    return 0


if __name__ == "__main__":
    sys.exit(main())
