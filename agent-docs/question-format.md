# Question format

Every decision an agent puts to the user in chat uses this format, unprompted,
as text in the reply rather than question-tool cards, which cut the detail a
choice turns on. The answer is then short: `Q1 B`, or `Q3 A, C` for a question
that takes several picks. A skill whose steps name its own way to ask, such as
one confirmation card, keeps its own way.

```
❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs>

- A. <option>
- B. <option>

➡️ <the pick, then one clause of why>
```

Write each question to these rules:

- **One decision per question.** Split compound questions.
- **End the body in a question**, not a topic label.
- **State options in parallel form**: identical phrasing except the dimension that differs. No incidental variation.
- **One option per line**, lettered A, B, C. Options run together in a paragraph are read as one blur. When the options choose between things the screen already labels, letter them with those labels: mock-up variants opened with `?variant=C` and `?variant=D` become options C and D, not A and B.
- **One action per option.** When several actions can each be taken, letter each one, say "pick any" in the body, and recommend the set you would take.
- **Put the discriminating detail at the end** of the sentence.
- **No forward references.** Each question must stand alone.
- **Cut hedges**: "probably", "it depends", "we could consider". If it depends, say what it depends on; that's the real question.

The user reads each question **cold**: without the code, the ticket comments,
or the chat above it. Write the body for that reader:

- **Start from today.** Open with what the system does now, then what the change does.
- **Use the project's glossary words, or plain words.** Define any other term (a vendor's term, an abbreviation, a name coined in this session) in the sentence where it first appears.
- **Write each option as an outcome**: what the end user or the user sees or does after the pick. Add the mechanism after the outcome only when the pick turns on it.
- **Show a wording change as text**: what the document says now and what you propose, then one confirmation for the set. Letters are for real alternatives.
- **Cite each fact the body rests on**: the file, doc, or probe that shows it. Find an unchecked fact before you ask.
- **Describe an earlier question by what it decided** ("since sign-in now sends a one-time code"), not by its number.
- **Follow [communication.md](communication.md).**

```
❓ **Q3** - **Signed-out visitor, bad document link**: Today a signed-out
visitor who opens `/documents/<id>` for a document that does not exist goes
to the sign-in page, and sees "Page not found" only after signing in
(`src/lib/auth-paths.ts`). What should that visitor see first?

- A. "Page not found", without signing in
- B. The sign-in page, then "Page not found" after signing in

➡️ A: there is nothing to sign in for, and B confirms to a stranger that the URL pattern is real.
```

A grilling question carries a tag after its title, as
[Sorting in design-tree.md](design-tree.md#sorting) defines.

In chat, number questions from Q1 and count up across the whole conversation,
so a number means one question.
