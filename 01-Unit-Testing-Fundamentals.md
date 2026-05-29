# Session 1 — Unit Testing Fundamentals + xUnit

> **Duration**: ~60 min
> **Primary audience**: Developers new to unit testing
> **Format**: Hands-on with IDE open. Type the examples; don't just read.
> **Prerequisites**: None — session is self-contained. Needs .NET 8 SDK (or later) and any editor (VS Code, Visual Studio, or Rider).
> **Deliverable**: After this session, learners can create an xUnit project, write `[Fact]` and `[Theory]` tests using the AAA pattern, and run them from the CLI.

---

## Learning Objectives

By the end of this session, you can:

1. Explain in one sentence what a unit test is and what it isn't (e.g., why a test that hits SQL Server is not a unit test).
2. Create a new xUnit test project with `dotnet new xunit` and wire it to a class library with a project reference.
3. Write a passing `[Fact]` test using the Arrange-Act-Assert (AAA) pattern.
4. Convert a copy-pasted set of `[Fact]` tests into a single `[Theory]` with `[InlineData]`.
5. Name a test using the `MethodName_Scenario_ExpectedBehavior` convention and explain why naming matters.

---

## Why this matters

The most common objection to unit testing from engineers who haven't worked in a well-tested codebase is "it's extra work to write and keep up with." Here's what flips the calculation:

When you change a method six months from now, the tests are the safety net that tells you *immediately* whether you broke something. Without that net, you ship the change, the bug shows up in production three weeks later, and the root cause analysis costs ten times what the test would have. The "extra work" is actually amortized prevention.

This applies to every domain where one wrong line silently breaks a downstream workflow — desktop add-ins, installer logic, web modules, data pipelines, anything with non-trivial business rules. Tests are how you catch the breakage before it ships — not after a customer files a ticket.

This session gets you from zero to "I can write and run a test." Sessions 2 and 3 turn that into "I write tests as a design tool."

---

## Session Map

| Block | Time | Topic |
|---|---|---|
| 1 | ~12 min | What a unit test actually is (and isn't) |
| 2 | ~15 min | Setting up xUnit and writing your first test |
| 3 | ~13 min | The AAA pattern and naming conventions |
| Break | ~2 min | Stretch / refill coffee |
| 4 | ~13 min | Theories — data-driven tests with `[InlineData]` |
| Recap | ~5 min | Retrieval-style recap |

---

## Block 1 — What a unit test actually is

### Content

A **unit test** is a small, fast, automated check that one isolated piece of code (typically one method, sometimes one class) behaves correctly for a specific input scenario.

The keywords carry the weight:

- **Small**: tests one concern. Not "tests the whole sign-up flow." Tests *one* behavior of *one* method.
- **Fast**: milliseconds. If a single test takes more than ~100ms, something is wrong — usually a hidden I/O dependency.
- **Automated**: runs without human intervention. You don't read output and judge; the test passes or fails on its own.
- **Isolated**: doesn't touch the database, the filesystem, the network, the clock, the user's environment. If it does, it's an *integration test* — also valuable, but in a different category.

Microsoft's framing is similar (from the Visual Studio unit test basics page): *"A unit test takes a small unit of an app, typically a method, isolates it from the remainder of the code, and verifies that it behaves as expected."*

Concrete examples:

| Test | Unit test? | Why |
|---|---|---|
| Verify `Calculator.Add(2, 3) == 5` | ✅ | Pure function, no I/O, single concern. |
| Verify `UserService.SignUp("user@example.com")` writes to SQL Server | ❌ | Touches the database — integration test. |
| Verify `OrderValidator.Validate(order)` returns expected errors | ✅ | Pure logic, no I/O. |
| Verify the login button navigates to the dashboard | ❌ | UI / end-to-end. |
| Verify `PriceCalculator.Apply(coupon)` reduces total by 10% | ✅ | Pure function over input. |

The line "is this a unit test?" matters because **mixing categories degrades the suite**. A unit suite that runs in 2 seconds is a tool you actually use. A suite that's secretly hitting the database and takes 5 minutes is a tool you avoid running, so it stops catching bugs.

### Self-study note (Show)

Open a terminal. Don't write code yet — just run `dotnet --version`. Confirm you're on .NET 8 SDK or later. If not, install it before continuing — the rest of the session assumes it's there.

### Knowledge check (verbal — answer out loud)

Ask yourself: *"If I write a test that reads a file from disk, what category of test is that, and why isn't it a unit test?"*

You're listening for: "it's an integration test, because it touches the filesystem, which means it's slow, environment-dependent, and not isolated."

---

## Block 2 — Setting up xUnit and writing your first test

### Content

Three real commands. Type each one; don't just read.

**Step 1 — Create a solution and a class library to test.**

```bash
mkdir UnitTestingDemo && cd UnitTestingDemo
dotnet new sln -n UnitTestingDemo
dotnet new classlib -n Calculator
dotnet sln add Calculator/Calculator.csproj
```

Open `Calculator/Class1.cs`, rename it `Calculator.cs`, and replace its contents with:

```csharp
namespace Calculator;

public class Calculator
{
    public int Add(int a, int b) => a + b;
}
```

**Step 2 — Create the xUnit test project.**

```bash
dotnet new xunit -n Calculator.Tests
dotnet sln add Calculator.Tests/Calculator.Tests.csproj
dotnet add Calculator.Tests/Calculator.Tests.csproj reference Calculator/Calculator.csproj
```

The `dotnet new xunit` template gives you a project pre-wired with the xUnit NuGet packages and the test runner integration. Look in `Calculator.Tests.csproj` — you'll see references to `xunit`, `xunit.runner.visualstudio`, `Microsoft.NET.Test.Sdk`, and `coverlet.collector`. **That last one matters for session 3** — coverage is already wired in by default.

**Step 3 — Write your first test.**

Open `Calculator.Tests/UnitTest1.cs`, rename it `CalculatorTests.cs`, and replace its contents with:

```csharp
using Xunit;

namespace Calculator.Tests;

public class CalculatorTests
{
    [Fact]
    public void Add_TwoPositiveNumbers_ReturnsSum()
    {
        // Arrange
        var calculator = new Calculator();

        // Act
        var result = calculator.Add(2, 3);

        // Assert
        Assert.Equal(5, result);
    }
}
```

**Step 4 — Run it.**

```bash
dotnet test
```

You should see `Passed: 1`. That's it. You wrote and ran a unit test.

### Self-study note (Do)

Don't move on until that command prints `Passed: 1` on your machine. If it doesn't, stop and debug. Common stumbles:

- Forgot the project reference. Run `dotnet add ... reference ...` again.
- Namespace collision between the class and the namespace (`Calculator.Calculator`). Either rename the class or alias it. The example above lives with the collision deliberately because you'll meet this in real code.

### Knowledge check (verbal)

Ask yourself: *"What does `[Fact]` mean and how is it different from just being a `public void` method?"*

Listening for: "`[Fact]` is the xUnit attribute that tells the test runner this method is a test. Without the attribute, the test runner skips it — it's just a regular method to the compiler."

---

## Block 3 — The AAA pattern and naming conventions

### Content

You already wrote AAA in Block 2; this block makes it deliberate.

**Arrange-Act-Assert** is the structural pattern for every unit test. Microsoft calls this out explicitly in their best-practices guidance:

| Step | What it does |
|---|---|
| **Arrange** | Create objects, set up state, prepare inputs. |
| **Act** | Invoke the method under test. Exactly one call. |
| **Assert** | Verify the result is what you expected. |

Looks trivial. The discipline is in keeping the three sections strictly separated:

```csharp
[Fact]
public void Add_TwoPositiveNumbers_ReturnsSum()
{
    // Arrange
    var calculator = new Calculator();
    var a = 2;
    var b = 3;

    // Act
    var result = calculator.Add(a, b);

    // Assert
    Assert.Equal(5, result);
}
```

**Why this matters**: when a test fails, the AAA structure tells you instantly where to look. If the failure is in Assert, the logic is wrong. If the failure is a setup exception in Arrange, your test fixture is broken. Without AAA, you stare at a flat blob of code trying to figure out what the test was even trying to do.

**Anti-pattern**: combining steps to "save space."

```csharp
// DON'T do this.
[Fact]
public void Add_EmptyString_ReturnsZero()
{
    var stringCalculator = new StringCalculator();
    Assert.Equal(0, stringCalculator.Add(""));  // Act and Assert smashed together
}
```

Microsoft's own guidance flags this exact pattern as the wrong version. Keep the three steps visually separate.

**Naming convention**: `MethodName_Scenario_ExpectedBehavior`.

| Bad | Good | Why |
|---|---|---|
| `Test1` | `Add_TwoPositiveNumbers_ReturnsSum` | Tells you what failed without opening the file. |
| `TestAdd` | `Add_NullInput_ThrowsArgumentNullException` | Documents the contract. |
| `ItWorks` | `Validate_EmptyEmail_ReturnsValidationError` | Self-explanatory in test runner output. |

The win: when your CI pipeline shows `Add_NullInput_ThrowsArgumentNullException: FAILED`, you know exactly what broke without reading any source code. That's tests-as-documentation in action.

**One assertion per test (usually).** Each test should verify one behavior. If you find yourself writing two unrelated `Assert.Equal` calls in the same test, split the test. Related assertions on the same result (e.g., `Assert.NotNull(result); Assert.Equal(5, result.Value);`) are fine — they're verifying one outcome from two angles.

### Self-study note (Teach)

Open `CalculatorTests.cs`. Add two more tests for `Add`: one for two negative numbers, one for adding zero. Name them with the `MethodName_Scenario_ExpectedBehavior` convention. Run them. Confirm three tests pass.

Then ask yourself: if you put those three tests in one method with three `Assert.Equal` calls, what do you lose? (Answer: a single failure stops the others from running, so you don't know if the bug affects negatives or just positives — and the test name has to be generic like `Add_VariousInputs_ReturnsCorrectSum`, which tells the reader nothing.)

### Knowledge check (verbal)

Ask yourself: *"Why is the test name `Add_TwoNegativeNumbers_ReturnsSum` better than `TestAddNegatives`?"*

Listening for: documents intent, lists scenario explicitly, surfaces the expected behavior, and reads well in CI output when it fails.

---

## (Stretch break — 2 min)

Get up, walk away from the keyboard. Don't skip this — attention degrades sharply past 25 minutes of focus.

---

## Block 4 — Theories and data-driven tests

### Content

You probably noticed in Block 3 that writing `Add_TwoPositiveNumbers`, `Add_TwoNegativeNumbers`, and `Add_Zero` all looked nearly identical — same Arrange, same Act, same Assert, different numbers. That's a smell. Three copy-pasted tests with one variable change is exactly what `[Theory]` is for.

xUnit has two test types:

| Attribute | Use when |
|---|---|
| `[Fact]` | Test is true for one specific scenario. "Adding 2 and 3 returns 5." |
| `[Theory]` | Test is true for a class of scenarios with varying input. "Adding any two positive numbers returns their sum." |

`[Theory]` is paired with one or more `[InlineData(...)]` attributes that supply the inputs.

**Convert the three tests into one theory:**

```csharp
[Theory]
[InlineData(2, 3, 5)]
[InlineData(-2, -3, -5)]
[InlineData(0, 0, 0)]
[InlineData(int.MaxValue, 0, int.MaxValue)]
public void Add_VariousNumbers_ReturnsSum(int a, int b, int expected)
{
    // Arrange
    var calculator = new Calculator();

    // Act
    var result = calculator.Add(a, b);

    // Assert
    Assert.Equal(expected, result);
}
```

Run `dotnet test`. You see four passing tests from one method body. Each `[InlineData]` row generates its own test entry in the runner output, so you still get per-scenario pass/fail granularity.

**When NOT to use `[Theory]`:**

- The scenarios aren't really the same test. Adding "what happens with `null`" to a numeric `[Theory]` is forcing dissimilar cases into one shape. Make it a separate `[Fact]`.
- The data is complex (objects, collections). `[InlineData]` only supports compile-time constants. For complex test data use `[MemberData]` or `[ClassData]` — out of scope for this session, but worth knowing the names so you can look them up.

**Test the unhappy path.** A common beginner mistake is writing only "happy" tests. Always test the failures too:

```csharp
[Fact]
public void Divide_ByZero_ThrowsDivideByZeroException()
{
    // Arrange
    var calculator = new Calculator();

    // Act + Assert (combined because Throws takes the action as a lambda)
    Assert.Throws<DivideByZeroException>(() => calculator.Divide(10, 0));
}
```

`Assert.Throws<TException>` is xUnit's idiomatic way to verify "this should throw." If the action doesn't throw, or throws the wrong type, the test fails.

### Make-it-fail demo (productive failure)

This is the most important moment in this session. Do not skip it.

Edit `Calculator.cs` and break the `Add` method on purpose:

```csharp
public int Add(int a, int b) => a - b;  // Deliberate bug
```

Run `dotnet test` again.

You'll see something like:

```
Failed Calculator.Tests.CalculatorTests.Add_VariousNumbers_ReturnsSum(a: 2, b: 3, expected: 5)
  Expected: 5
  Actual:   -1
```

**Sit with that output for 30 seconds.** Read it. Note three things:

1. The test name told you which scenario failed (`a: 2, b: 3`).
2. The runner showed expected vs. actual — no debugger needed.
3. You found a bug in one second instead of one production cycle.

This is the value proposition. Every time you ship code with a test suite, you get this kind of feedback the moment the bug is introduced. Without tests, that feedback might come from a customer six months later.

Restore `Add` to `a + b` before continuing.

### Knowledge check (verbal)

Ask yourself: *"When should I reach for `[Theory]` instead of `[Fact]`?"*

Listening for: when the test body is identical and only input/expected values vary; the scenarios are conceptually the same test with different data.

---

## Recap (5 min)

Answer these out loud or in writing **before** scrolling on to read the answers. The retrieval is the point.

1. What makes something a unit test rather than an integration test?
2. What does AAA stand for and why are the three sections visually separated?
3. What's the format of a well-named unit test?
4. When should I use `[Theory]` and `[InlineData]` instead of multiple `[Fact]` methods?
5. *Synthesis*: If a test takes 3 seconds to run and reads from disk, what are at least two things wrong with it?

---

### Answers (don't read these until you've answered yourself)

1. A unit test is small, fast, isolated, and automated. It exercises one method without touching the database, filesystem, network, or clock. Anything that does is an integration test.
2. **A**rrange-**A**ct-**A**ssert. Separation makes failure attribution obvious: Arrange failure = test fixture problem; Act failure = bug in the code; Assert failure = bug in the code or wrong expectation.
3. `MethodName_Scenario_ExpectedBehavior`. E.g., `Add_TwoNegativeNumbers_ReturnsSum` or `Validate_EmptyEmail_ThrowsArgumentException`.
4. When you find yourself copying a test, changing only the input values. The body becomes one method; each `[InlineData]` row becomes a separate runnable scenario.
5. (a) It's not a unit test — it's an integration test sneaking into the unit suite, which means the unit suite is slower than it needs to be. (b) It's environment-dependent — passes on your machine, fails in CI if the file isn't there. (c) It's brittle — a file format change breaks it for the wrong reason.

---

## Field Reinforcement (do before Session 2)

Do this on a real project — your own repo, a sample, anything that compiles. Don't use the throwaway `Calculator` from this session.

1. Pick one small, pure method in your existing codebase (no I/O, no DB, no UI dependencies). If you don't have one, write one — `StringExtensions.Capitalize(string s)` or similar.
2. Create a new xUnit test project alongside it: `dotnet new xunit -n YourProject.Tests`.
3. Wire the project reference: `dotnet add YourProject.Tests reference YourProject`.
4. Write **three** tests for that method: one happy path, one edge case (empty / null / boundary), one failure mode (`Assert.Throws`).
5. Run `dotnet test`. Commit the test project to source control.

If you finish in under 20 minutes, you've encoded the mechanics. If you struggle past 30, redo Block 2 of this session before moving on — the basics need to be muscle memory before TDD makes sense.

---

## Common Pitfalls & Troubleshooting

| Pitfall | Why it happens | What to do |
|---|---|---|
| Tests pass on machine, fail in CI | Hidden environment dependency (file path, timezone, culture) | Search the test for file I/O, `DateTime.Now`, `CultureInfo.CurrentCulture`. Mock them out (covered Session 3). |
| `dotnet test` finds 0 tests | Forgot `[Fact]` attribute, or method isn't `public` | Add `[Fact]` and make method `public`. xUnit only discovers attributed public methods. |
| `Assert.Equal(actual, expected)` looks backward | Comparing to expected works but message is misleading | xUnit signature is `Assert.Equal(expected, actual)` — expected first. Output "Expected 5, got 3" reads correctly. |
| Test names like `Test1`, `Test2` | Inherited bad habit from older tutorials | Adopt `MethodName_Scenario_ExpectedBehavior` and never look back. |
| One test asserts five things | Author wanted to "be efficient" | Split into five tests, or use `[Theory]` if the structure is identical. |

---

## Source Documentation References

- Microsoft Learn — Unit testing C# with dotnet test and xUnit: https://learn.microsoft.com/dotnet/core/testing/unit-testing-csharp-with-xunit
- Microsoft Learn — Unit testing best practices for .NET (AAA, naming, single Act, minimally passing): https://learn.microsoft.com/dotnet/core/testing/unit-testing-best-practices
- Microsoft Learn — Unit testing (.NET MAUI): https://learn.microsoft.com/dotnet/maui/deployment/unit-testing
- xUnit.net official documentation: https://xunit.net/docs/comparisons

---

*Document Version: 1.0 — Session 1 of Unit Testing & TDD self-study program*
