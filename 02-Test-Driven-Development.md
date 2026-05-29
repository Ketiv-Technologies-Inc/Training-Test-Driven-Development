# Session 2 — Test-Driven Development (Red-Green-Refactor)

> **Duration**: ~60 min
> **Primary audience**: Developers who completed Session 1
> **Format**: Hands-on. Learners write a small feature using TDD, end-to-end.
> **Prerequisites**: Session 1 complete; field reinforcement done. Learners should be comfortable creating xUnit projects and writing `[Fact]`/`[Theory]` tests.
> **Deliverable**: After this session, learners have completed one full TDD cycle and can explain when TDD pays off vs. when it doesn't.

---

## Callback (3 min — start here)

Before the new content, recall from Session 1:

- What does AAA stand for, and why are the steps separated?
- What's the format of a well-named test? Give an example.
- Why is a test that reads from disk *not* a unit test?

If any of those took longer than 5 seconds to answer, reread the Session 1 recap. The spaced repetition only works if you do the retrieval — and Session 2 builds directly on Session 1 mechanics.

---

## Learning Objectives

By the end of this session, you can:

1. Describe the Red-Green-Refactor cycle and explain what happens in each step.
2. Implement a small feature (FizzBuzz or similar) using strict TDD — never writing production code before a failing test exists.
3. State the FIRST principles for good unit tests (Fast, Independent, Repeatable, Self-validating, Timely) and identify violations.
4. Distinguish between **refactoring** and **extending** — and explain why mixing them is dangerous.
5. Name two scenarios where TDD is the wrong choice and explain why.

---

## Why this matters

Session 1 taught you the mechanics: how to write a test that runs. This session changes *when* you write the test.

In traditional development, you write code, decide it works, and (maybe) write tests later. The problem: by the time you write the test, you've already made design decisions that may be hard to test. You end up either skipping the test, writing a test that hits a database to exercise the code (slow, brittle), or refactoring the code to make it testable (expensive, late).

**TDD inverts the order.** You write the test first. Because a test is small, fast, and isolated, writing it first forces your production code to be small, fast, and isolated by construction. The discipline produces better-designed code as a side effect.

Microsoft's own TDD walkthrough nails the value: *"With unit tests in place, we can happily make any change to our code and immediately know whether we have broken existing functionality."*

You'll feel resistance to writing the test first. That's normal. The first ten times feel slower. After that, it gets faster than the old way — because you spend less time debugging code you didn't need to write.

---

## Session Map

| Block | Time | Topic |
|---|---|---|
| 1 | ~10 min | The Red-Green-Refactor cycle |
| 2 | ~18 min | TDD live: build FizzBuzz from scratch |
| Break | ~2 min | Stretch |
| 3 | ~12 min | FIRST principles for good unit tests |
| 4 | ~13 min | When TDD is wrong (and what to do instead) |
| Recap | ~5 min | Retrieval-style recap |

---

## Block 1 — The Red-Green-Refactor cycle

### Content

TDD is one rule: **never write production code without a failing test that demands it.**

That rule expands into three steps, run in a tight loop:

| Step | What you do | What "done" looks like |
|---|---|---|
| 🔴 **Red** | Write a failing test that expresses the next bit of behavior you want. | The test runner shows ❌ for the expected reason (not a compile error you forgot to fix). |
| 🟢 **Green** | Write the *minimum* code needed to make the test pass. Sloppy is fine. | All tests pass, including the new one. |
| 🔵 **Refactor** | With the safety net of green tests, clean up the code. Remove duplication, improve names, extract methods. | All tests still pass; code is cleaner than at end of Green. |

Three things make this work:

1. **Each cycle is ~5-10 minutes.** If you're spending 45 minutes in Red, your step is too big. Break the test down.
2. **Refactor on green only.** Microsoft's "Day in the life of a devops developer" walkthrough states it directly: *"Every change you make while you are developing the code should be either a refactoring or an extension."* (The same principle goes back to Martin Fowler's *Refactoring*.) Mixing them — adding new behavior while restructuring — means a test failure could be either a regression or an incomplete refactor. You don't know which.
3. **Run the tests after every change.** Not after every feature. After every save. Visual Studio's Live Unit Testing does this automatically; from the CLI, run `dotnet watch test`.

### The two-things-at-once trap (productive failure setup)

Here's the failure mode that bites every TDD beginner: you're in Refactor, you spot a "while I'm in here, let me also add..." Don't. Finish the refactor, get back to green, *then* start a new Red cycle for the new feature.

If you skip this discipline and a test fails, you can't tell whether your refactor broke something or your new code is wrong. You'll spend twenty minutes bisecting your own change. The discipline of one-thing-at-a-time is what makes TDD fast.

### Knowledge check (verbal)

Ask yourself: *"During the Refactor step, am I allowed to add a new feature? Why or why not?"*

Listening for: no. Refactor changes the structure of the code without changing its behavior. New features go through their own Red-Green cycle. Mixing the two destroys your ability to attribute failures.

---

## Block 2 — TDD live: build FizzBuzz from scratch

### Content

We'll build the FizzBuzz function using strict TDD. The rules of FizzBuzz:

- For numbers 1 to N, return the number as a string.
- If divisible by 3, return "Fizz" instead.
- If divisible by 5, return "Buzz" instead.
- If divisible by both 3 and 5, return "FizzBuzz".

The trap: it's tempting to write the whole function in 5 lines and *then* write tests. Don't. We're learning the discipline, and FizzBuzz is small enough that the discipline pays off visibly.

**Setup:**

```bash
mkdir FizzBuzzTdd && cd FizzBuzzTdd
dotnet new sln -n FizzBuzzTdd
dotnet new classlib -n FizzBuzz
dotnet new xunit -n FizzBuzz.Tests
dotnet sln add FizzBuzz/FizzBuzz.csproj FizzBuzz.Tests/FizzBuzz.Tests.csproj
dotnet add FizzBuzz.Tests reference FizzBuzz
```

Delete the auto-generated `Class1.cs` from `FizzBuzz` (we'll create files via TDD).

### Cycle 1 — Red

In `FizzBuzz.Tests/UnitTest1.cs`, replace with:

```csharp
using Xunit;
using FizzBuzz;

namespace FizzBuzz.Tests;

public class FizzBuzzServiceTests
{
    [Fact]
    public void Convert_NumberOne_ReturnsOne()
    {
        var service = new FizzBuzzService();
        var result = service.Convert(1);
        Assert.Equal("1", result);
    }
}
```

Run `dotnet test`. It won't compile — `FizzBuzzService` doesn't exist. **This counts as Red.** A compile failure is a form of failing test in the TDD loop; you're not allowed to skip writing the production code stub.

### Cycle 1 — Green

In `FizzBuzz/`, create `FizzBuzzService.cs`:

```csharp
namespace FizzBuzz;

public class FizzBuzzService
{
    public string Convert(int number) => "1";  // Yes. Hard-coded. On purpose.
}
```

Run `dotnet test`. ✅ Passes.

Resist the urge to "improve" this. The hard-coded "1" is correct minimum code. The next test will force you to generalize.

### Cycle 2 — Red

Add another test:

```csharp
[Fact]
public void Convert_NumberTwo_ReturnsTwo()
{
    var service = new FizzBuzzService();
    var result = service.Convert(2);
    Assert.Equal("2", result);
}
```

Run. ❌ Fails (returns "1", expected "2").

### Cycle 2 — Green

Update the production code, minimum change:

```csharp
public string Convert(int number) => number.ToString();
```

Run. ✅ Both tests pass.

### Cycle 2 — Refactor

Look at the test code. Two tests, both creating `new FizzBuzzService()`. That's duplication. Extract a field initialized in the constructor (which xUnit calls per test — fresh instance each time, so no state pollution):

```csharp
public class FizzBuzzServiceTests
{
    private readonly FizzBuzzService _service = new();

    [Fact]
    public void Convert_NumberOne_ReturnsOne()
    {
        var result = _service.Convert(1);
        Assert.Equal("1", result);
    }

    [Fact]
    public void Convert_NumberTwo_ReturnsTwo()
    {
        var result = _service.Convert(2);
        Assert.Equal("2", result);
    }
}
```

Run. ✅ Still passes. This is what a clean Refactor step looks like: smaller, no behavior change.

### Cycle 3 — Red (introduce Fizz)

```csharp
[Fact]
public void Convert_NumberThree_ReturnsFizz()
{
    var result = _service.Convert(3);
    Assert.Equal("Fizz", result);
}
```

Run. ❌ Fails (returns "3").

### Cycle 3 — Green

```csharp
public string Convert(int number)
{
    if (number % 3 == 0) return "Fizz";
    return number.ToString();
}
```

Run. ✅ All three tests pass.

### Cycles 4 and 5 — Buzz and FizzBuzz

On your own, add:

- `Convert_NumberFive_ReturnsBuzz`
- `Convert_NumberFifteen_ReturnsFizzBuzz`

After each Red, add minimum Green. After both pass, look at `Convert`:

```csharp
public string Convert(int number)
{
    if (number % 15 == 0) return "FizzBuzz";
    if (number % 3 == 0) return "Fizz";
    if (number % 5 == 0) return "Buzz";
    return number.ToString();
}
```

### Refactor pass: collapse the tests with `[Theory]`

Notice that `Convert_NumberThree_ReturnsFizz`, `Convert_NumberFive_ReturnsBuzz`, and `Convert_NumberFifteen_ReturnsFizzBuzz` all have identical bodies modulo input/expected. That's exactly the smell from Session 1.

```csharp
[Theory]
[InlineData(1, "1")]
[InlineData(2, "2")]
[InlineData(3, "Fizz")]
[InlineData(5, "Buzz")]
[InlineData(15, "FizzBuzz")]
[InlineData(30, "FizzBuzz")]
public void Convert_Number_ReturnsExpected(int input, string expected)
{
    var result = _service.Convert(input);
    Assert.Equal(expected, result);
}
```

Six tests, one method body. Test suite now reads as a specification of FizzBuzz behavior.

### Self-study moment

Look at the production code. It's tiny. It's correct. Every branch was demanded by a test. There is zero speculative code.

That last property is the underrated win of TDD. In a normal flow, you might have added "what if number is negative?" or "what if number is 0?" speculatively. With TDD, you don't — because no test demanded it. The code is exactly what the specification requires, no more.

If negative numbers matter in your domain, *write a test for them*, then add the behavior. That's how requirements get encoded.

### Knowledge check (verbal)

Ask yourself: *"Why does the first Green step hard-code `return \"1\"` instead of writing the full logic?"*

Listening for: TDD's minimum-code-to-pass rule. The hard-coded value is correct for the test that exists. The next test (return "2") will force the generalization. Writing more than needed is speculative code — and any speculation can be wrong in a way no test catches.

---

## (Stretch break — 2 min)

---

## Block 3 — FIRST principles for good unit tests

### Content

You now know *how* to do TDD. The FIRST mnemonic tells you whether your tests are *good*. It's the rubric you apply during the Refactor step:

| Letter | Stands for | What it means | Violation looks like |
|---|---|---|---|
| **F** | Fast | Sub-millisecond ideal; under 100ms per test always. | Tests touch DB, filesystem, network, clock. Suite runs in minutes. |
| **I** | Independent (also called "Isolated") | Tests don't depend on each other or on run order. | Test B fails when run alone but passes after Test A. Hidden shared state. |
| **R** | Repeatable | Same input → same output. Every run. Every machine. | Test uses `DateTime.Now`, random values, or live network. Flaky in CI. |
| **S** | Self-validating (also called "Self-Checking") | Pass/fail with no human interpretation. | Test writes to console; you have to read output and decide if it's right. |
| **T** | Timely | Written close to the production code — ideally first, per TDD. | Tests written months later by a different person, mostly testing the code that already exists rather than what should exist. |

> **Naming note**: The FIRST mnemonic comes from Robert C. Martin / Roy Osherove and uses "Independent" + "Self-validating." Microsoft's [Unit testing best practices](https://learn.microsoft.com/dotnet/core/testing/unit-testing-best-practices) page uses "Isolated" + "Self-Checking" for the same concepts. Same five characteristics, slightly different labels — don't get tripped up if you see one variant in a doc and the other in a book.

The two that bite most in real codebases:

**Independent**. In xUnit specifically, each test runs in a **fresh instance of the test class** — the constructor runs per test, so field initializers and the constructor act as Arrange for every test. This is intentional. Tests cannot share state through fields, which means they cannot accidentally depend on run order. xUnit's "no `[SetUp]` / `[TearDown]`" design is *because of this principle* — the older `[SetUp]` model encouraged shared setup that quietly created dependencies between tests.

(If you've used NUnit or MSTest, this is the biggest behavioral difference. Take it as a feature, not a quirk.)

**Repeatable**. The most common violation: `DateTime.Now`. A test that creates "today's invoice" and checks for "today's date" passes on Monday and fails on Tuesday around midnight UTC. Same with `Random`, network calls, file paths. The fix is dependency injection — pass a clock, a random source, or an HTTP client as a parameter, and inject a fake in tests. (Covered in Session 3.)

### Independence demo

Open `FizzBuzzServiceTests.cs`. Imagine you changed `_service` from `readonly` to a mutable static:

```csharp
private static FizzBuzzService _service = new();  // DON'T do this
```

Now suppose one test calls `_service.Configure(...)` to change behavior. Subsequent tests inherit that configuration. Run them in order: pass. Run one alone (or in a different order): fail. Run two in parallel: race condition.

xUnit makes the right choice the default — fresh instance per test — but you can fight it by introducing statics or by writing setup logic outside the constructor. Don't.

### Knowledge check (verbal)

Ask yourself: *"What does the I in FIRST stand for, and how does xUnit help you obey it by default?"*

Listening for: Independent. xUnit creates a new instance of the test class for every test method, so fields and constructor logic act as fresh Arrange for each test — no shared mutable state between tests by default.

---

## Block 4 — When TDD is wrong (and what to do instead)

### Content

TDD isn't a religion. It works extraordinarily well in some places and is a poor fit in others. Knowing which is which keeps you from forcing the wrong tool.

**TDD is the right call when:**

- Pure logic. Calculators, validators, parsers, business rules, mathematical transformations. The FizzBuzz pattern.
- Bug fixes. Write a failing test that reproduces the bug, fix until it passes. The test stays as a regression guard.
- Public API design. Writing the test first forces you to use the API before you build it. If the test is awkward, the API is awkward.
- Refactoring complex code. The test suite is your safety net; you can't refactor confidently without it.

**TDD is the wrong call (or at least a hard sell) when:**

- **Exploratory / spike code.** You're learning a library, trying out approaches, or building a throwaway proof-of-concept. Writing tests for code you're about to delete is waste. Spike, learn what you need, then *delete the spike* and rebuild with TDD.
- **UI layout and visual design.** "Did the button move 4 pixels to the left?" is not a question a unit test should answer. Use visual regression tools (e.g., Percy, Chromatic) or manual inspection. The behavior *behind* the button (click handlers, state changes) is still testable — separate the concerns.
- **Heavy I/O glue code.** The wrapper that pipes data from one database to another, with no transformation logic, is mostly integration concerns. Test the integration end-to-end; don't pretend the wrapper has interesting unit behavior.
- **Code with no clear contract yet.** If you don't know what the function should do, you can't write a test for it. Talk to the stakeholder, write the contract down, *then* TDD it.
- **Legacy code without seams.** A 2000-line method with no abstractions cannot be unit-tested as-is. Michael Feathers' *Working Effectively with Legacy Code* is the canonical reference; the pattern is "characterization tests" — pin down current behavior with high-level tests, then refactor with safety, then TDD the new parts.

### A senior-engineer nuance

Many strong engineers don't do strict Red-Green-Refactor in production code. What they *do* do is test-first thinking — they think about how they'd test the function before they write it, and that shapes the API. They may then write tests and code in tandem rather than strict alternation.

Both work. The strict cycle is the training wheels. Once you've internalized the design pressure that comes from "this needs to be testable," you can flex the discipline without losing the benefit.

What does *not* work: writing all the production code first and then writing tests against it. That produces tests that verify what the code does, not what it *should* do — and you almost never catch the design problems you would have caught earlier.

### Make-it-fail demo (productive failure)

Pick this one to feel it:

In `FizzBuzz.cs`, change line 5 from `if (number % 15 == 0)` to `if (number % 10 == 0)`. Don't change the tests.

Run `dotnet test`. You'll get something like:

```
Failed Convert_Number_ReturnsExpected(input: 15, expected: "FizzBuzz")
  Expected: FizzBuzz
  Actual:   Fizz
Failed Convert_Number_ReturnsExpected(input: 30, expected: "FizzBuzz")
  Expected: FizzBuzz
  Actual:   Fizz
```

Hold that output for 30 seconds. Notice:

1. **The test names tell you the exact failing scenarios** — input 15 and input 30.
2. **You didn't open a debugger.** The failure points you at the bug.
3. **Untested numbers (1, 2, 3, 5) still pass**, so you know the regression is scoped to the FizzBuzz case.

That's the safety net you're building with TDD. Every time you change code, the suite tells you what broke and what didn't. Without it, you'd ship the change, get a bug report a week later, and have no way to know if anything else was also wrong.

Restore line 5 to `% 15` before continuing.

### Knowledge check (verbal)

Ask yourself: *"Why is TDD a poor fit for a spike or proof-of-concept?"*

Listening for: spikes exist to learn; you don't know yet what the right design is, and writing tests against code you'll delete is waste. The right move is to spike (no tests), throw it away, then rebuild with TDD using what you learned.

---

## Recap (5 min)

Answer these out loud or in writing **before** scrolling on.

1. What are the three steps of the TDD cycle, in order?
2. During the Green step, why do you write the minimum code possible?
3. What's the difference between refactoring and extending — and why does it matter to keep them separate?
4. What does the F in FIRST stand for, and what's the practical threshold for a "fast" test?
5. *Synthesis*: You're building a function that talks to a Postgres database. Should you TDD it? If yes, how? If no, why not?

---

### Answers (don't read until you've answered)

1. **R**ed (write a failing test), **G**reen (minimum code to pass), **R**efactor (clean up while keeping tests green).
2. Speculation is risk. Code beyond what the current test demands is code you haven't proven correct. The next test forces the generalization; until then, hard-coded is fine. Also, minimum code stays in the Refactor step's bounds.
3. Refactoring changes structure without changing behavior; extending adds new behavior. If you do both at once and a test fails, you can't tell which change broke it. Strict separation = fast failure diagnosis.
4. Fast. Practical threshold: sub-100ms per test, ideally sub-millisecond. Whole suite should run in seconds, not minutes.
5. Don't TDD the database call itself — that's integration territory. But TDD the *logic surrounding* the call: separate the query construction, result mapping, and business rules into pure functions, and TDD those. The database call becomes a thin adapter (testable separately via integration tests). This is the architecture pressure TDD applies; it forces you to extract pure logic from I/O. (Covered concretely in Session 3.)

---

## Field Reinforcement (do before Session 3)

Pick something small from a real codebase you work in — a parser, a validator, a domain rule, anything pure-ish:

1. Pick a small feature you'd otherwise just write. Estimate ~30 minutes of work.
2. Implement it strictly TDD. Don't write a single line of production code without a failing test first.
3. **Time yourself.** It will feel slow. Note how long.
4. Note in a journal entry: where did TDD reveal a design problem you wouldn't have spotted otherwise? Where did it feel like overhead?
5. Bring the journal entry into Session 3 — it informs the anti-patterns discussion.

Optional stretch: do FizzBuzz in your second-favorite language. The discipline is language-agnostic; doing it twice is the fastest way to encode it.

---

## Common Pitfalls & Troubleshooting

| Pitfall | Why it happens | What to do |
|---|---|---|
| Spending 30+ minutes in Red | Step is too big — you're trying to test five behaviors at once | Break the test into the smallest behavior change. One test = one fact. |
| Refactoring on a red bar | "I'll fix it while I'm here" | Stop. Revert if needed. Get back to green, *then* refactor. |
| Writing tests after the code | Old habit; "I'll add tests later" | Tests added later test what the code does, not what it should do. The design-pressure benefit is gone. Use TDD for new code; characterization tests for legacy. |
| All tests share a stateful field | Carried over from old setup/teardown habits | Use xUnit's per-test instance creation. Field initializers and constructor act as Arrange for each test. No `[BeforeEach]`-style global state. |
| Test names describe code, not behavior | Author named tests after methods, not scenarios | Rename to `MethodName_Scenario_ExpectedBehavior`. "Test should describe what the system does, not how." |

---

## Source Documentation References

- Microsoft Learn — Iteration #6: Use test-driven development (C#): https://learn.microsoft.com/aspnet/mvc/overview/older-versions-1/contact-manager/iteration-6-use-test-driven-development-cs
- Microsoft Learn — Day in the life of a devops developer (Red-Green-Refactor in practice): https://learn.microsoft.com/azure/devops/repos/tfvc/day-life-alm-developer-write-new-code-user-story
- Microsoft Learn — Walkthrough: Test driven development with Test Explorer: https://learn.microsoft.com/visualstudio/test/quick-start-test-driven-development-with-test-explorer
- Microsoft Learn — Unit testing best practices for .NET: https://learn.microsoft.com/dotnet/core/testing/unit-testing-best-practices

---

*Document Version: 1.0 — Session 2 of Unit Testing & TDD self-study program*
