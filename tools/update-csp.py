"""Refresh the Content-Security-Policy hashes in ScrubbyWurd.html.

The page allows only its own inline <script> and <style>, identified by their
SHA-256 hashes. Any edit to either block changes its hash, so run this after
editing:

    python tools/update-csp.py
"""
import base64
import hashlib
import pathlib
import re
import sys

PAGE = pathlib.Path(__file__).resolve().parent.parent / "ScrubbyWurd.html"
META = re.compile(r'(<meta http-equiv="Content-Security-Policy" content=")[^"]*(">)')


def sha256(block: str) -> str:
    digest = hashlib.sha256(block.encode("utf-8")).digest()
    return "'sha256-" + base64.b64encode(digest).decode() + "'"


def main() -> int:
    # newline="" keeps the file's line endings, which are part of what gets hashed.
    # .gitattributes pins this file to LF so the hash matches what GitHub Pages serves.
    with PAGE.open(encoding="utf-8", newline="") as f:
        html = f.read()
    if "\r\n" in html:
        print("ScrubbyWurd.html has CRLF line endings; the served file uses LF, so the hashes would not match")
        return 1
    # Tags must start a line, so the same words inside a comment or string aren't picked up.
    scripts = re.findall(r"^<script>(.*?)^</script>", html, re.S | re.M)
    styles = re.findall(r"^<style>(.*?)^</style>", html, re.S | re.M)
    if len(scripts) != 1 or len(styles) != 1:
        print(f"expected one <script> and one <style>, found {len(scripts)} and {len(styles)}")
        return 1
    policy = (
        "default-src 'none'; "
        f"script-src {sha256(scripts[0])}; "
        f"style-src {sha256(styles[0])}; "
        "img-src data:; "  # only the page's own built-in icon
        "base-uri 'none'; form-action 'none'"
    )
    new, n = META.subn(lambda m: m.group(1) + policy + m.group(2), html)
    if n != 1:
        print("Content-Security-Policy meta tag not found")
        return 1
    with PAGE.open("w", encoding="utf-8", newline="") as f:
        f.write(new)
    print(policy)
    return 0


if __name__ == "__main__":
    sys.exit(main())
