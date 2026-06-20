#!/usr/bin/env python3
"""
CODEX PACKER v2.0 (Staff-Refactor)
----------------------------------
Consolidates codebase into a single Markdown context file.
Focus: Safety, Configurability, and Performance.

Architecture:
- Config: Singleton configuration via argparse.
- Core: Generator-based file walker (Lazy evaluation).
- Utils: Robust binary heuristics and Token estimation.
- Output: Buffered writing.

Author: Vaylour
"""

import os
import sys
import fnmatch
import datetime
import argparse
import mimetypes
import logging
from pathlib import Path
from typing import List, Set, Generator, Tuple

# --- CONSTANTS & DEFAULTS ---
DEFAULT_IGNORE_DIRS = {
    '.git', 'node_modules', '__pycache__', 'venv', '.venv', 'env', 
    '.idea', '.vscode', 'build', 'dist', 'target', '.next', 'bin', 'obj'
}
DEFAULT_IGNORE_FILES = {
    '.DS_Store', 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'mix.lock'
}
# Skip files larger than 1MB by default to prevent token context explosion
DEFAULT_MAX_FILE_SIZE = 1_024 * 1_024 

# --- SETUP LOGGING ---
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    datefmt='%H:%M:%S'
)
logger = logging.getLogger("CodexPacker")

class PackConfig:
    """Immutable configuration state."""
    def __init__(self, args):
        self.root: Path = Path(args.root).resolve()
        self.output: Path = Path(args.output) if args.output else self._generate_output_name()
        self.max_size: int = args.max_size
        self.ignore_dirs: Set[str] = DEFAULT_IGNORE_DIRS.union(set(args.ignore_dirs or []))
        self.ignore_files: Set[str] = DEFAULT_IGNORE_FILES.union(set(args.ignore_files or []))
        self.exclude_patterns: List[str] = args.exclude or []

        # Add the output filename to ignore list to prevent self-consumption
        self.ignore_files.add(self.output.name)
        self.ignore_files.add(Path(__file__).name)

    def _generate_output_name(self) -> Path:
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        return Path(f"CODEBASE_DUMP_{timestamp}.md")

class FileUtils:
    """Static utilities for file analysis."""
    
    @staticmethod
    def is_binary(path: Path) -> bool:
        """
        Multi-stage binary detection:
        1. Check Mime Type.
        2. Check for null bytes in first 1KB.
        """
        # Stage 1: MimeType
        mime_type, _ = mimetypes.guess_type(path)
        if mime_type and not mime_type.startswith(('text/', 'application/json', 'application/javascript', 'application/xml')):
            # Allow common code formats that might get misclassified
            # If it's explicitly image/audio/video, reject.
            if mime_type.startswith(('image/', 'audio/', 'video/', 'application/octet-stream')):
                return True

        # Stage 2: Byte Analysis
        try:
            with path.open('rb') as f:
                chunk = f.read(1024)
                if b'\0' in chunk:
                    return True
        except Exception:
            return True # Unreadable = unsafe
        
        return False

    @staticmethod
    def estimate_tokens(text: str) -> int:
        """Rough estimation: 1 token ~= 4 chars."""
        return len(text) // 4

class CodebaseWalker:
    """Handles directory traversal and filtering logic."""
    
    def __init__(self, config: PackConfig):
        self.config = config

    def should_ignore(self, path: Path) -> bool:
        # Check explicit ignores
        if path.name in self.config.ignore_files:
            return True
        if path.is_dir() and path.name in self.config.ignore_dirs:
            return True
            
        # Check patterns (globs)
        for pattern in self.config.exclude_patterns:
            if fnmatch.fnmatch(path.name, pattern):
                return True
                
        return False

    def walk(self) -> Generator[Path, None, None]:
        """Lazy generator yields valid files."""
        if not self.config.root.exists():
            logger.error(f"Root path does not exist: {self.config.root}")
            sys.exit(1)

        for root, dirs, files in os.walk(self.config.root):
            # Modify dirs in-place to prevent traversing ignored directories
            dirs[:] = [d for d in dirs if d not in self.config.ignore_dirs]
            
            # Sort for deterministic output
            dirs.sort()
            files.sort()

            for fname in files:
                fpath = Path(root) / fname
                
                if self.should_ignore(fpath):
                    continue
                    
                yield fpath

    def generate_tree(self) -> str:
        """Generates a visual tree structure."""
        tree_lines = []
        start_path = self.config.root
        
        for root, dirs, files in os.walk(start_path):
            dirs[:] = [d for d in dirs if d not in self.config.ignore_dirs]
            dirs.sort()
            files.sort()
            
            level = root.replace(str(start_path), '').count(os.sep)
            indent = ' ' * 4 * level
            tree_lines.append(f"{indent}{os.path.basename(root)}/")
            
            subindent = ' ' * 4 * (level + 1)
            for f in files:
                if f not in self.config.ignore_files and not any(fnmatch.fnmatch(f, p) for p in self.config.exclude_patterns):
                    tree_lines.append(f"{subindent}{f}")
                    
        return "```text\n" + "\n".join(tree_lines) + "\n```"

def main():
    parser = argparse.ArgumentParser(description="Pack codebase into a single Markdown file for LLM context.")
    parser.add_argument("--root", default=".", help="Root directory to scan")
    parser.add_argument("--output", help="Output filename")
    parser.add_argument("--max-size", type=int, default=DEFAULT_MAX_FILE_SIZE, help="Max file size in bytes to include (default: 1MB)")
    parser.add_argument("--exclude", action='append', help="Additional glob patterns to exclude (e.g. *.log)")
    parser.add_argument("--ignore-dirs", action='append', help="Additional directories to ignore")
    parser.add_argument("--ignore-files", action='append', help="Additional filenames to ignore")
    
    args = parser.parse_args()
    config = PackConfig(args)
    walker = CodebaseWalker(config)
    
    logger.info(f"Scanning Root: {config.root}")
    logger.info(f"Max File Size: {config.max_size / 1024:.2f} KB")

    stats = {
        'processed': 0,
        'skipped_binary': 0,
        'skipped_size': 0,
        'errors': 0,
        'token_est': 0
    }

    try:
        with open(config.output, 'w', encoding='utf-8') as outfile:
            # 1. Header
            outfile.write(f"# Codebase Dump\n")
            outfile.write(f"> Generated: {datetime.datetime.now()}\n")
            outfile.write(f"> Source: `{config.root.absolute()}`\n\n")
            
            # 2. Tree
            logger.info("Generating file tree...")
            outfile.write("## Project Structure\n\n")
            outfile.write(walker.generate_tree())
            outfile.write("\n\n---\n\n")

            # 3. Content Loop
            for file_path in walker.walk():
                rel_path = file_path.relative_to(config.root)
                
                # Size Check
                if file_path.stat().st_size > config.max_size:
                    stats['skipped_size'] += 1
                    logger.warning(f"Skipping large file: {rel_path}")
                    continue

                # Binary Check
                if FileUtils.is_binary(file_path):
                    stats['skipped_binary'] += 1
                    continue

                try:
                    content = file_path.read_text(encoding='utf-8', errors='ignore')
                    
                    # Formatting
                    outfile.write(f"## File: `{rel_path}`\n\n")
                    ext = file_path.suffix.lstrip('.') or 'txt'
                    outfile.write(f"```{ext}\n")
                    outfile.write(content)
                    if not content.endswith('\n'):
                        outfile.write('\n')
                    outfile.write("```\n\n")
                    
                    stats['processed'] += 1
                    stats['token_est'] += FileUtils.estimate_tokens(content)
                    
                    # Simple progress indicator
                    sys.stdout.write(f"\rProcessed: {stats['processed']} files | Tokens: ~{stats['token_est']}")
                    sys.stdout.flush()

                except Exception as e:
                    stats['errors'] += 1
                    logger.error(f"Failed to read {rel_path}: {e}")

    except IOError as e:
        logger.critical(f"Write permission denied: {e}")
        sys.exit(1)

    print("\n" + "="*40)
    logger.info(f"Dump Complete: {config.output}")
    logger.info(f"Files Packed: {stats['processed']}")
    logger.info(f"Skipped (Binary): {stats['skipped_binary']}")
    logger.info(f"Skipped (Size): {stats['skipped_size']}")
    logger.info(f"Estimated Tokens: {stats['token_est']}")

if __name__ == "__main__":
    main()
