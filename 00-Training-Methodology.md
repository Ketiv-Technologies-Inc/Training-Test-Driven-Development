# Unit Testing & Test-Driven Development — Beginner Training Program

> **Audience**: Developers who have never formally learned unit testing or TDD. Assumes working familiarity with C# and the .NET CLI, but no prior testing experience.
> **Format**: Self-paced or instructor-led. Conversational where appropriate; structured for retention.
> **Stack**: C# / .NET 8+, xUnit v2/v3, Moq + NSubstitute, Coverlet, dotnet CLI.
> **Total duration**: ~3 hours of focused work, plus field reinforcement between sessions.

---

## Why this program exists

Unit testing has a credibility problem with developers who have never worked in a well-tested codebase. From the outside it looks like "extra work to write and maintain." That intuition is correct *if* tests are written badly — bad tests genuinely are net-negative. But good tests pay back their cost many times over by:

1. **Letting you change code without fear.** The number one reason senior engineers hesitate to refactor is "I might break something I don't know about." A good test suite removes that hesitation.
2. **Acting as executable documentation.** Six months from now, a test named `Add_TwoNegativeNumbers_ReturnsSum` tells the next reader (probably you) what the method is supposed to do — more reliably than a comment.
3. **Forcing better design.** Code that is hard to test is almost always code that is hard to maintain. The pain of writing the test surfaces the design problem early. This is the core insight behind TDD.

This program teaches you to write tests that produce those payoffs — not tests that just exist to hit a coverage number.

---

## Session sequence and rationale

Three sessions, ~60 minutes each. Sequenced **foundation-up**, not topic-grouped:

| # | Session | Why this order |
|---|---|---|
| 1 | Unit Testing Fundamentals + xUnit | You can't evaluate TDD as a philosophy until you can actually write and run a test. Tool fluency first. |
| 2 | Test-Driven Development (Red-Green-Refactor) | Once writing tests is mechanical, the *design* shift TDD requires becomes the only new thing to learn. |
| 3 | Test Doubles, Coverage, CI, Anti-Patterns | These are the things that break a test suite over time. They make sense only after sessions 1 and 2. |

### Why foundation-up here instead of frequency-of-encounter

For operator training I'd sequence by what you do most often. For *learning a discipline*, the concepts genuinely build — you can't usefully discuss mocking until you've written tests against pure functions. The order isn't negotiable, but the depth within each session can flex.

### What's deliberately out of scope

- **Integration tests, end-to-end tests, UI automation.** Different category of testing. Unit testing first; the others get easier once the unit-testing mindset is in place.
- **Property-based testing (FsCheck, Bogus).** Excellent technique, but it's an optimization on top of unit testing fundamentals. Out of scope here.
- **Behavior-Driven Development (BDD) and SpecFlow / Reqnroll.** Useful for stakeholder-readable specs but conceptually orthogonal to the core unit-testing/TDD skill.
- **Performance and load testing.** Different tools, different mindset.
- **MSTest and NUnit deep-dives.** Mentioned for context, but xUnit is the modern .NET default per Microsoft's own guidance, so the worked examples all use xUnit.

### What you'll be able to do at the end

By the end of session 3, you can:

1. Add an xUnit test project to an existing .NET solution with the correct package references.
2. Write `[Fact]` and `[Theory]` tests using the AAA pattern and consistent naming.
3. Practice a TDD Red-Green-Refactor cycle on a small problem without skipping steps.
4. Identify when to use a fake, stub, mock, or spy — and write each with Moq or NSubstitute.
5. Collect code coverage with Coverlet and read the report intelligently (not chase 100%).
6. Wire `dotnet test` into a CI pipeline so tests fail the build.
7. Recognize the common anti-patterns — testing implementation details, brittle mocks, magic strings, multiple acts per test — when reviewing your own code or a teammate's PR.

---

## Methodology — why each session is structured the way it is

This program applies eleven well-researched learning principles. You'll see these structural elements in every session; they aren't decoration:

| Element | Principle | What it does for you |
|---|---|---|
| 3–5 measurable learning objectives per session | Goal-setting theory (Locke & Latham) | Specific targets produce ~15% higher performance than "do your best." You can self-check whether you hit them. |
| "Why this matters" opener | Andragogy (Knowles) | Adults learn faster when relevance is established up front. |
| Time-boxed blocks of 12–15 minutes | Microlearning / attention decay | Attention degrades sharply past ~20 minutes. Blocks let you take breaks and resume. |
| One major concept per block, ≤5 per session | Cognitive load theory (Sweller) | Working memory holds ~4 chunks. Overpacking sessions kills retention. |
| Make-it-fail demo in each session | Productive failure (Kapur) | Letting yourself hit the real error encodes the fix far better than reading about it. |
| Verbal-style retrieval questions, not summaries | Retrieval practice (Roediger & Karpicke) | Pulling info from memory is ~50% more effective than re-reading. |
| Recap as questions, not bullet lists | Ebbinghaus forgetting curve | Reverses the ~50%-in-1-hour drop. |
| Cross-session callbacks at start of sessions 2 and 3 | Spaced repetition (Cepeda) | Re-encountering concepts at expanding intervals encodes them durably. |
| Field reinforcement assignment between sessions | 70-20-10 model | ~70% of durable learning happens on the job. The session is only ~10%. |
| Real code examples, not invented ones | Dual coding (Paivio) + andragogy | Pairing verbal explanation with concrete code creates two retrieval pathways. |
| "Show → Do → Teach" in instructor notes | Surgical-training tradition | Demonstrating, then practicing, then explaining back encodes procedural knowledge. |

**Important for self-study**: when a section says "ask the room," you ask *yourself* the question, out loud or in writing, before you read on. The retrieval moment is the encoding moment — skip it and the session quietly stops working.

---

## How to use this program

**Self-paced learners:**

1. **Block 60 minutes** for each session. No Slack, no email. Closed door.
2. **Have a real IDE open** — VS Code, Visual Studio, or Rider. The hands-on blocks expect you to actually type the code, not skim it.
3. **Do the field reinforcement** between sessions. The session itself is one-tenth of the durable learning; the field assignment is the other nine-tenths. Skipping it means the content evaporates within a week.
4. **Don't speed-run the recap.** When the recap asks you a question, answer it before reading on. If you can't, go back and reread that block — that's the signal the section is doing.
5. **Stop and look up** anything unclear. The "Source Documentation References" at the end of each session is the authoritative material — Microsoft Learn, the official xUnit docs. Going there builds the habit of grounding your knowledge.

**Instructors teaching a team:**

1. Treat each session as a ~60-minute slot. Project the code and let learners type along.
2. Pre-stage the working `Calculator` / `FizzBuzz` / `Orders` solutions so you can recover quickly if a learner hits an environment issue.
3. Use the "verbal knowledge check" prompts as group questions — call on a different person each time. The retrieval moment is the encoding moment.
4. Do not skip the "make-it-fail" demos. Showing a real failure on screen is the highest-retention moment of the session.
5. Use the field reinforcement as the next-day asynchronous follow-up. Review what people produced before starting the next session.

---

## Files in this program

```
unit-testing-and-tdd-training/
├── 00-Training-Methodology.md       (this file — the "why" behind the structure)
├── 01-Unit-Testing-Fundamentals.md  (Session 1 — ~60 min)
├── 02-Test-Driven-Development.md    (Session 2 — ~60 min)
└── 03-Test-Doubles-Coverage-CI.md   (Session 3 — ~60 min)
```

Read them in order. The sessions reference each other intentionally — that's the spaced-repetition cross-link doing its job.

---

## A word on tooling choice

You asked which library you should use. Short answer: **xUnit**.

Long answer: there are three credible options for .NET — xUnit, NUnit, and MSTest. Microsoft's own .NET MAUI guidance explicitly recommends xUnit. xUnit was written by the original creators of NUnit after they learned what NUnit got wrong; it has the cleanest design, no `[SetUp]`/`[TearDown]` (which encourage bad patterns — covered in session 1), and the strongest ecosystem in modern .NET. Pick xUnit and don't relitigate it.

For mocking we'll cover both **Moq** and **NSubstitute**. Moq has been the .NET standard for a decade; NSubstitute has a friendlier API and is gaining ground. You should be able to read both — pick whichever you prefer for your own code.

---

*Document Version: 1.0 — Unit Testing & TDD self-study program*

## Source Documentation References

- Microsoft Learn — Unit testing C# with dotnet test and xUnit: https://learn.microsoft.com/dotnet/core/testing/unit-testing-csharp-with-xunit
- Microsoft Learn — Unit testing best practices for .NET: https://learn.microsoft.com/dotnet/core/testing/unit-testing-best-practices
- Microsoft Learn — Unit testing (.NET MAUI deployment, xUnit recommendation): https://learn.microsoft.com/dotnet/maui/deployment/unit-testing
- Microsoft Learn — Visual Studio unit test basics: https://learn.microsoft.com/visualstudio/test/unit-test-basics
- xUnit.net official site: https://xunit.net/
