# ScrubbyWurd

A text redactor: swap real names and other details in text for placeholders like `[full name]` or for made-up stand-ins. It's a single HTML file: download [`ScrubbyWurd.html`](ScrubbyWurd.html), double-click it, and it opens in your browser. Nothing to install, it works offline, and nothing you paste in is sent anywhere.

**Use it online:** https://fourier18.github.io/ScrubbyWurd/ — the page runs entirely in your browser there too; the text you paste never goes to a server.

> **Working with sensitive or work data? Use the download, not the online link.** Even though nothing you paste is sent anywhere, the online version is still a page loaded from the internet, and many workplaces don't allow confidential data in internet-connected tools. Download `ScrubbyWurd.html` and open it from your own computer, where it never connects to anything. When the task is done, delete any results you saved, and clear your clipboard history if you use one (Windows: Win+V).

## Install it as an app (Windows)

To get ScrubbyWurd in its own window, with its own icon, in the Start menu and pinnable to the taskbar, download the repository (**Code → Download ZIP**), unzip it, and in that folder run:

```
powershell -ExecutionPolicy Bypass -File tools\install-windows-app.ps1
```

Nothing is installed as a program. It copies `ScrubbyWurd.html` and its icon to `%LOCALAPPDATA%\Programs\ScrubbyWurd` and adds **ScrubbyWurd** shortcuts to the Start menu and Desktop. Right-click either one and choose **Pin to taskbar**. The shortcut opens the page in Microsoft Edge's app mode (no address bar or tabs) using a separate Edge profile with extensions and sync turned off, so no browser extension can see what you paste. Run the script again after updating to install the new version. To remove it, delete the two shortcuts and that folder.

## Using it

1. **Build your list.** In the left panel, type what to find and what to replace it with, one pair per row. A new empty row appears as you fill the last one.
2. **Paste your text** into the middle panel, or open or drop a text file.
3. **Check the result** on the right. Every replacement is highlighted; hover one to see what it replaced. The **Hits** column shows how often each item was found, with a zero shown in orange.
4. **Copy** or **Save** the result.

To add something you spot while reading, select it in the input or the result and click **+ Add selection**. It goes into a new row, ready for you to type its replacement.

## Options

- **Ignore case**: `john smith` also finds `John Smith` and `JOHN SMITH`.
- **Whole words only**: `Ann` doesn't change `Annual`.
- **Theme**: Light, Dark, Forest Green, Azure Night, Desert Sunset, Arctic Dawn or Plum Midnight.

Longer items are always replaced first, so `John Smith` isn't split by a separate `John` entry. Each piece of text is replaced once; a replacement is never changed again by another item. If two items overlap, like `Jo Ann` and `Ann Lee` in "Jo Ann Lee", the whole stretch is replaced and flagged with ⚠, so no part of either name is left behind.

## What it catches

Each item is matched as you typed it, and also where the same text is written in other common ways:

- with extra spaces, tabs, `_`, or one line break between words, or with `\n`, `\t`, `%20`, `+` or `&nbsp;` written in their place in logs, JSON, URLs and web pages;
- with invisible characters inside it (zero-width spaces, soft hyphens, direction marks), which text copied from web pages often has;
- with a curly apostrophe (`O’Brien` for `O'Brien`) or an escaped one (`&#39;`, `\u0027`, `%27`, `\'`), and `&` written as `&amp;`;
- with accented letters stored either way, or written as `\u00e9`, `&#233;`, `&eacute;` or `%C3%A9`;
- in Chinese, Japanese, Korean and Thai text, where words aren't separated by spaces.

Your text is otherwise left exactly as it is: only the matched stretches change.

It does **not** guess other formats. `555-201-8876` won't match `(555) 201-8876`, and `Mary-Jane` won't match `Mary Jane`. Add each form you expect as its own item, and check the result before you share it.

## Saving and sharing your list

Your list and settings are kept in your browser, so they're there next time you open the file on the same computer and browser. The text you paste is never saved. The page blocks all outside connections itself (a Content-Security-Policy), so nothing you paste can be sent anywhere.

To move a list to another computer or browser, or share it, use **Export** and **Import**:

- **Text file (.txt)**: one item per line, with a Tab between the find text and the replacement.
- **Spreadsheet (.csv)**: find in column A, replacement in column B. Opens in Excel or Google Sheets.

The Import window shows a preview of the list before anything changes. An exported list contains the original names you're hiding, so keep the file private.

## License

MIT — see [LICENSE](LICENSE).
