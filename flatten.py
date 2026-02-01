#!/usr/bin/env python3

import argparse
import os
import re
from pathlib import Path

def flatten_scripts(project_root, build_dir):
    """Flatten GSC scripts similar to the PowerShell version"""
    
    # Paths
    out_file = Path(build_dir) / "menu_flat.gsc"
    menu_file = Path(project_root) / "zm_tomb" / "menu.gsc"
    origins_dir = Path(project_root) / "origins_menu"
    
    # Remove existing output file
    if out_file.exists():
        out_file.unlink()
    
    with open(out_file, 'w', encoding='ascii') as writer:
        # menu
        writer.write("// ===== BEGIN menu.gsc =====\n")
        if menu_file.exists():
            with open(menu_file, 'r', encoding='ascii') as f:
                for line in f:
                    # Skip includes of origins_menu files
                    if not re.match(r'^\s*#include\s+scripts\\zm\\origins_menu\\', line):
                        writer.write(line)
        
        # utility + base
        for filename in ["menu_utility.gsc", "menu_base.gsc"]:
            file_path = origins_dir / filename
            if file_path.exists():
                writer.write("\n")
                writer.write(f"// ===== BEGIN {filename} =====\n")
                with open(file_path, 'r', encoding='ascii') as f:
                    for line in f:
                        # Skip any include statements
                        if not re.match(r'^\s*#include\b', line):
                            writer.write(line)
        
        # modes (all other .gsc files)
        gsc_files = sorted([f for f in origins_dir.glob("*.gsc") 
                           if f.name not in ["menu_utility.gsc", "menu_base.gsc"]])
        
        for gsc_file in gsc_files:
            writer.write("\n")
            writer.write(f"// ===== BEGIN {gsc_file.name} =====\n")
            with open(gsc_file, 'r', encoding='ascii') as f:
                for line in f:
                    # Skip any include statements
                    if not re.match(r'^\s*#include\b', line):
                        writer.write(line)
    
    print(f"Flatten complete: {out_file}")

def main():
    parser = argparse.ArgumentParser(description='Flatten GSC scripts')
    parser.add_argument('--project-root', required=True, help='Project root directory')
    parser.add_argument('--build-dir', required=True, help='Build directory')
    
    args = parser.parse_args()
    
    try:
        flatten_scripts(args.project_root, args.build_dir)
    except Exception as e:
        print(f"ERROR: {e}")
        exit(1)

if __name__ == "__main__":
    main()
