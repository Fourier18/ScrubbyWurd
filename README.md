# Redactor

A find-and-replace tool for cleaning names and other details out of text. It's a single HTML file: download `redactor.html`, double-click it, and it opens in your browser. Nothing to install, and nothing you paste in is sent anywhere.

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

Longer items are always replaced first, so `John Smith` isn't split by a separate `John` entry. Each piece of text is replaced once; a replacement is never changed again by another item.

## Saving and sharing your list

Your list and settings are kept in your browser, so they're there next time you open the file on the same computer and browser. The text you paste is never saved.

To move a list to another computer or browser, or share it, use **Export** and **Import**:

- **Text file (.txt)**: one item per line, with a Tab between the find text and the replacement.
- **Spreadsheet (.csv)**: find in column A, replacement in column B. Opens in Excel or Google Sheets.

The Import window shows a preview of the list before anything changes. An exported list contains the original names you're hiding, so keep the file private.
