# 4. Worked Example: Pulling Specific Pieces Out of a Messy String

This file walks through a real example, step by step, using this string:

```
8299929AJJSO199018SUBIGYA70Q922NEPAL
```

The goal: pull out `SUBIGYA` and `NEPAL` from this string using regex and `grep`.

This example is useful because it shows an important limit of regex: **it matches shapes, not meaning**. Getting exactly the two pieces you want sometimes needs more than one trick.

---

## Step 1: Look at the shape of the string

Breaking the string into chunks by eye:

```
8299929   AJJSO   199018   SUBIGYA   70   Q   922   NEPAL
 digits   letters  digits   letters  digits letter digits letters
```

So the string alternates between runs of digits and runs of letters. Both `SUBIGYA` and `NEPAL` are letter runs, but so are `AJJSO` and `Q`.

## Step 2: First attempt, match any run of uppercase letters

```bash
echo "8299929AJJSO199018SUBIGYA70Q922NEPAL" | grep -oP '[A-Z]+'
```

Output:

```
AJJSO
SUBIGYA
Q
NEPAL
```

That's four matches, but only two of them are wanted.

## Step 3: Filter by length

Since `Q` is just one letter, we can require at least 4 letters in a row:

```bash
echo "8299929AJJSO199018SUBIGYA70Q922NEPAL" | grep -oP '[A-Z]{4,}'
```

Output:

```
AJJSO
SUBIGYA
NEPAL
```

That removes `Q`, but `AJJSO` is still there, and it happens to be the same length (5 letters) as `NEPAL`. This is the key lesson: length alone can't tell `AJJSO` and `NEPAL` apart. Regex only understands shape. It has no idea that "Nepal" is a country and "Ajjso" is not a real word.

To go further, we need one more idea.

## Step 4, Option A: Filter using a known word list

If you know in advance what kind of words you're hunting for (names, countries, cities), you can keep only the matches that appear in a reference list.

Create a small file `known_words.txt`:

```
SUBIGYA
NEPAL
```

(In a real project, this could be a full list of country names, or a list of employee/customer names you're allowed to search for.)

Then filter your matches against it:

```bash
echo "8299929AJJSO199018SUBIGYA70Q922NEPAL" \
  | grep -oP '[A-Z]{4,}' \
  | grep -Fxf known_words.txt
```

Output:

```
SUBIGYA
NEPAL
```

**How it works:** `grep -oP '[A-Z]{4,}'` gets all letter-runs of 4+ characters. Piping that into `grep -Fxf known_words.txt` keeps only the lines that **exactly** match (`-x`) a line from the fixed-string (`-F`) word list.

This is exactly the technique real tools use to spot names, countries, or cities inside unstructured text (it's a simplified form of what's called "dictionary-based entity extraction").

## Step 5, Option B: Use fixed positions, if the format never changes

Sometimes a string like this is actually a **fixed-format ID**, where every field always has the same length and position, like a national ID number or a product serial code. If that's true here, there's no need to guess at all. It can be extracted by position instead.

Counting the string's structure precisely:

| Characters | Position | Content |
|---|---|---|
| 1–7 | `8299929` | 7-digit block |
| 8–12 | `AJJSO` | 5-letter block |
| 13–18 | `199018` | 6-digit block |
| 19–25 | `SUBIGYA` | 7-letter block |
| 26–27 | `70` | 2-digit block |
| 28 | `Q` | 1-letter block |
| 29–31 | `922` | 3-digit block |
| 32–36 | `NEPAL` | 5-letter block |

Now we can extract each field by exact position using a lookbehind that counts characters:

```bash
STR="8299929AJJSO199018SUBIGYA70Q922NEPAL"

# Characters 19 through 25 (SUBIGYA)
echo "$STR" | grep -oP '(?<=^.{18}).{7}'

# Last 5 characters (NEPAL)
echo "$STR" | grep -oP '.{5}$'
```

Output:

```
SUBIGYA
NEPAL
```

**How it works:**
- `(?<=^.{18})` is a lookbehind meaning "only match here if exactly 18 characters came before this point, starting from the beginning of the line." Then `.{7}` grabs the next 7 characters, landing exactly on `SUBIGYA`.
- `.{5}$` simply grabs the last 5 characters of the line, using the `$` end-of-line anchor. That lands exactly on `NEPAL`.

This approach is the most **reliable** one when the format is fixed, because it doesn't depend on guessing which words are "real."

## Step 6: Which option should you use?

| Situation | Best approach |
|---|---|
| The string format is fixed and always the same length | **Option B**, extract by position |
| The format varies, but you know what words you're looking for | **Option A**, filter with a word list |
| Neither is true, the format and content are both unpredictable | You'll need something beyond plain regex, like natural-language name/place recognition tools |

## Bonus: turning this into a one-liner

If you have many strings in a file (one per line) and want to pull the last letter-block from each, following the same fixed-format idea:

```bash
grep -oP '[A-Z]{4,}$' data.txt
```

`[A-Z]{4,}$` matches a run of 4 or more uppercase letters that sits at the **very end** of the line. That's a quick way to grab a trailing "country" or "code" field from many rows at once.

---

That completes the walkthrough. You now know how to:
- Build a regex pattern step by step (file 1)
- Use it to hunt for secrets and keys (file 2)
- Use it to hunt for URLs, IPs, and emails (file 3)
- Combine length filters, word lists, and positional matching to pull exact fields out of a custom string (this file)

Go practice on `examples/sample.txt`, then try these patterns on your own files.
