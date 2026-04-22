#!/usr/bin/env python3
"""
Version Bumper for Flutter Apps

This script automates version bumping in pubspec.yaml following semantic versioning.
It updates both the version string and build number.

Usage:
    python3 scripts/bump_version.py [--bump major|minor|patch] [--build-number NUM]

Examples:
    python3 scripts/bump_version.py --bump patch
    python3 scripts/bump_version.py --bump minor
    python3 scripts/bump_version.py --bump major
    python3 scripts/bump_version.py --build-number 42
"""

import re
import argparse
import sys
from pathlib import Path
from datetime import datetime

class VersionBumper:
    def __init__(self, pubspec_path: str = "pubspec.yaml"):
        self.pubspec_path = Path(pubspec_path)
        if not self.pubspec_path.exists():
            raise FileNotFoundError(f"pubspec.yaml not found at {pubspec_path}")
        
    def read_version(self) -> tuple[str, int]:
        """Extract current version and build number from pubspec.yaml"""
        with open(self.pubspec_path, 'r') as f:
            content = f.read()
        
        # Match version: X.Y.Z+N format
        match = re.search(r'version:\s*(\d+\.\d+\.\d+)\+(\d+)', content)
        if not match:
            raise ValueError("Could not parse version from pubspec.yaml")
        
        version = match.group(1)
        build_number = int(match.group(2))
        
        return version, build_number
    
    def parse_version(self, version: str) -> tuple[int, int, int]:
        """Parse semantic version string"""
        parts = version.split('.')
        if len(parts) != 3:
            raise ValueError(f"Invalid version format: {version}")
        
        try:
            return tuple(int(p) for p in parts)
        except ValueError:
            raise ValueError(f"Version parts must be integers: {version}")
    
    def bump_version(self, version: str, bump_type: str) -> str:
        """Bump version based on type: major, minor, or patch"""
        major, minor, patch = self.parse_version(version)
        
        if bump_type == "major":
            major += 1
            minor = 0
            patch = 0
        elif bump_type == "minor":
            minor += 1
            patch = 0
        elif bump_type == "patch":
            patch += 1
        else:
            raise ValueError(f"Unknown bump type: {bump_type}")
        
        return f"{major}.{minor}.{patch}"
    
    def update_version(self, new_version: str, new_build_number: int = None) -> str:
        """Update version in pubspec.yaml"""
        with open(self.pubspec_path, 'r') as f:
            content = f.read()
        
        old_version, old_build = self.read_version()
        
        # If build number not specified, increment it
        if new_build_number is None:
            new_build_number = old_build + 1
        
        # Replace version line
        new_content = re.sub(
            r'version:\s*\d+\.\d+\.\d+\+\d+',
            f'version: {new_version}+{new_build_number}',
            content
        )
        
        if new_content == content:
            raise RuntimeError("Failed to update version in pubspec.yaml")
        
        # Write back
        with open(self.pubspec_path, 'w') as f:
            f.write(new_content)
        
        return old_version, old_build, new_version, new_build_number
    
    def print_summary(self, old_version: str, old_build: int, 
                     new_version: str, new_build: int):
        """Print version bump summary"""
        print("\n" + "="*60)
        print("  Version Bump Summary")
        print("="*60)
        print(f"  File: {self.pubspec_path}")
        print(f"  Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print()
        print(f"  Old Version: {old_version}+{old_build}")
        print(f"  New Version: {new_version}+{new_build}")
        print()
        print(f"  Version Change: {old_version} → {new_version}")
        print(f"  Build Number: {old_build} → {new_build}")
        print("="*60 + "\n")

def main():
    parser = argparse.ArgumentParser(
        description="Bump Flutter app version in pubspec.yaml"
    )
    
    parser.add_argument(
        "--bump",
        choices=["major", "minor", "patch"],
        help="Type of version bump (semantic versioning)"
    )
    parser.add_argument(
        "--build-number",
        type=int,
        help="Explicitly set build number (otherwise incremented)"
    )
    parser.add_argument(
        "--pubspec",
        default="pubspec.yaml",
        help="Path to pubspec.yaml (default: pubspec.yaml)"
    )
    
    args = parser.parse_args()
    
    try:
        bumper = VersionBumper(args.pubspec)
        current_version, current_build = bumper.read_version()
        
        # Determine new version
        if args.bump:
            new_version = bumper.bump_version(current_version, args.bump)
        else:
            new_version = current_version
        
        # Update
        old_v, old_b, new_v, new_b = bumper.update_version(
            new_version, 
            args.build_number
        )
        
        bumper.print_summary(old_v, old_b, new_v, new_b)
        
        # Output for GitHub Actions
        print("GitHub Actions Output:")
        print(f"  version_old={old_v}+{old_b}")
        print(f"  version_new={new_v}+{new_b}")
        
        return 0
        
    except Exception as e:
        print(f"❌ Error: {e}", file=sys.stderr)
        return 1

if __name__ == "__main__":
    sys.exit(main())
