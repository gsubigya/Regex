# 1. Regex Basics: A Step-by-Step Guide for Beginners

## What is regex, really?

Imagine you're looking for every word in a book that starts with a capital letter. You could read every page and check each word by eye. That's slow and boring. Or you could describe the **pattern** you're looking for ("a capital letter, followed by more letters") and let a tool find every match instantly.

That description of a pattern is a **regular expression**, or **regex** for short.

A regex is just a small piece of text that describes a *shape* of text you want to find. It's not tied to any one programming language. It works in `grep`, Python, JavaScript, text editors, and almost everywhere else.

> **Simple way to think about it:** normal search finds exact words. Regex finds *shapes* of words.

## Why bother learning it?

- Search and replace across thousands of files in seconds
- Validate input (is this a valid email? a valid phone number?)
- Pull specific data out of messy text (logs, exports, scraped pages)
- Find secrets, keys, and tokens hiding in code, which is exactly what files 2 and 3 in this repo do

## How we'll practice

Throughout this file, assume you're testing patterns against this line of text:

```
Contact: subigya99, backup email: help@example.com, id: 4021
```

We'll build up from the simplest possible pattern to full expressions.

---

## Step 1: Literal characters

The simplest regex is just plain text. The pattern:

```
subigya
```

matches the exact text `subigya` wherever it appears. No magic yet, this is exactly like a normal search.

## Step 2: The dot `.` (match any character)

The dot means "any single character except a newline."

```
s.b.gya
```

This matches `subigya` because each dot stands in for one character (`u` and `i` in this case). It would also match `sabcgya`, since the dot doesn't care *which* character, only that *one* is there.

## Step 3: Character classes `[ ]`

A character class matches **one** character from a specific set you define.

```
[abc]
```

matches a single `a`, `b`, or `c`.

You can use ranges too:

```
[a-z]        any lowercase letter
[A-Z]        any uppercase letter
[0-9]        any single digit
[a-zA-Z0-9]  any letter or digit
```

Add a `^` right after the opening bracket to mean "NOT these":

```
[^0-9]    any character that is NOT a digit
```

## Step 4: Shorthand character classes

Because `[0-9]` and friends are so common, regex gives you shortcuts:

| Shortcut | Meaning | Same as |
|---|---|---|
| `\d` | a digit | `[0-9]` |
| `\D` | not a digit | `[^0-9]` |
| `\w` | a "word" character | `[a-zA-Z0-9_]` |
| `\W` | not a word character | `[^a-zA-Z0-9_]` |
| `\s` | whitespace (space, tab, newline) | none, it's its own shorthand |
| `\S` | not whitespace | none, it's its own shorthand |

So instead of `id: [0-9][0-9][0-9][0-9]`, you can write `id: \d\d\d\d`.

## Step 5: Quantifiers (how many times?)

Quantifiers say how many times the thing before them should repeat.

| Symbol | Meaning |
|---|---|
| `*` | 0 or more times |
| `+` | 1 or more times |
| `?` | 0 or 1 time (optional) |
| `{n}` | exactly n times |
| `{n,}` | n or more times |
| `{n,m}` | between n and m times |

Matching our 4-digit id cleanly:

```
\d{4}
```

matches exactly four digits in a row, like `4021`.

Matching one or more word characters (a whole "word"):

```
\w+
```

matches `subigya99` as one chunk, because `+` keeps grabbing word characters until it hits something that isn't one (like a comma).

## Step 6: Anchors (position, not characters)

Anchors don't match characters. They match a *position*.

| Symbol | Meaning |
|---|---|
| `^` | start of the line |
| `$` | end of the line |
| `\b` | a word boundary (edge of a word) |

```
^Contact
```

only matches if the line **starts** with `Contact`.

```
\d{4}$
```

only matches four digits that sit at the **very end** of the line.

`\b` is especially useful because it makes sure you match a whole word, not part of one. For example, `\bid\b` matches the standalone word `id`, but won't match `id` inside `void` or `raid`.

## Step 7: Groups `( )` and alternation `|`

Parentheses group parts of a pattern together, and let you extract just that piece later (this is called a **capture group**).

```
(\w+)@(\w+\.\w+)
```

This has two groups: the part before the `@` and the part after it. Against `help@example.com`, group 1 captures `help` and group 2 captures `example.com`.

The pipe `|` means "or":

```
(cat|dog|bird)
```

matches `cat`, `dog`, or `bird`.

## Step 8: Greedy vs. lazy matching

By default, quantifiers are **greedy**. They grab as much text as possible.

```
".*"
```

Against `"first" and "second"`, a greedy `.*` matches all the way from the first `"` to the *last* `"`, giving you `"first" and "second"` as one match, probably not what you wanted.

Add a `?` after the quantifier to make it **lazy**, so it grabs as little as possible:

```
".*?"
```

This now matches just `"first"`, stopping at the first closing quote it finds.

## Step 9: Lookarounds (matching without capturing)

Sometimes you want to match something only if it's near something else, without including that "something else" in your result.

| Pattern | Meaning |
|---|---|
| `(?=X)` | positive lookahead: must be followed by X |
| `(?!X)` | negative lookahead: must NOT be followed by X |
| `(?<=X)` | positive lookbehind: must be preceded by X |
| `(?<!X)` | negative lookbehind: must NOT be preceded by X |

Example:

```
(?<=id: )\d{4}
```

matches `4021`, but only the digits, not the `id: ` in front of it. This is extremely useful for pulling clean values out of `key: value` style text, and you'll use it a lot in files 2 and 3.

---

## Quick reference cheat sheet

| Symbol | Meaning |
|---|---|
| `.` | any character |
| `\d` `\w` `\s` | digit / word char / whitespace |
| `[abc]` | one of a, b, or c |
| `[^abc]` | anything except a, b, or c |
| `*` `+` `?` | 0+, 1+, 0-or-1 |
| `{n,m}` | between n and m times |
| `^` `$` | start / end of line |
| `\b` | word boundary |
| `( )` | capture group |
| `|` | or |
| `(?=...)` `(?<=...)` | lookahead / lookbehind |

## Practice exercises

Try writing a pattern for each of these before checking the answer.

1. **Match any 5-digit ZIP code.**
   `\b\d{5}\b`

2. **Match a word that starts with a capital letter.**
   `\b[A-Z][a-z]*\b`

3. **Match a simple email address.**
   `[\w.]+@[\w.]+\.\w+`

4. **Match a hex color code like `#A1B2C3`.**
   `#[0-9A-Fa-f]{6}`

5. **Match text between quotes, without grabbing too much.**
   `".*?"`

Once these feel natural, move on to **`02-extract-secrets-and-keys.md`** to put this to real use.
