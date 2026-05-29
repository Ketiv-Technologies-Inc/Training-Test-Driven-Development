# Session 3 — Test Doubles, Coverage, CI, and Anti-Patterns

> **Duration**: ~60 min
> **Primary audience**: Developers who completed Sessions 1 and 2
> **Format**: Hands-on. Learners mock a dependency, collect coverage, and wire `dotnet test` into a CI script.
> **Prerequisites**: Sessions 1 and 2 complete; both field assignments done.
> **Deliverable**: After this session, learners can isolate code from its dependencies for testing, measure coverage without becoming a slave to it, run tests in CI, and recognize the anti-patterns that quietly destroy a test suite over time.

---

## Callback (3 min — start here)

Before new content, retrieve from Sessions 1 and 2:

- What's the AAA pattern, and why is each step visually separated?
- What's the Red-Green-Refactor cycle, and what's the rule about refactoring vs. extending?
- What does the F in FIRST stand for, and what's the practical threshold?

If any felt slow, reread the relevant recap. Session 3 is the place where Sessions 1 and 2 either click into a working practice or remain isolated facts.

---

## Learning Objectives

By the end of this session, you can:

1. Distinguish between **dummies, stubs, mocks, fakes,** and **spies** — and pick the right one for a given test.
2. Write a mocked unit test using both **Moq** and **NSubstitute**, and explain why you'd choose one over the other.
3. Collect code coverage with `dotnet test --collect:"XPlat Code Coverage"` and read the Cobertura output.
4. Explain why 100% coverage is the wrong goal and what a healthy coverage range looks like.
5. Wire `dotnet test` into a CI pipeline (GitHub Actions YAML snippet) so a failed test breaks the build.
6. Identify at least five anti-patterns that silently degrade a test suite over time.

---

## Why this matters

Sessions 1 and 2 worked on pure functions — FizzBuzz, calculators, things with no dependencies. Real code isn't like that. You have services that call other services, repositories that hit databases, classes that read configuration files. To unit-test any of that, you have to *isolate the code from its collaborators*. That's what test doubles are for.

Then there's the longevity question. Even a well-designed test suite rots if no one watches it. Tests get flaky, coverage drops, slow tests get marked `[Skip]` and forgotten. This session is the operations manual: how to keep a suite healthy over years.

This is also where most engineers go wrong — they discover mocks, mock everything, and end up with tests that pass even when the code is completely broken. The discipline of this session is *what to mock and what not to mock*.

---

## Session Map

| Block | Time | Topic |
|---|---|---|
| 1 | ~15 min | Test doubles — dummies, stubs, mocks, fakes, spies |
| 2 | ~15 min | Mocking with Moq and NSubstitute (hands-on) |
| Break | ~2 min | Stretch |
| 3 | ~12 min | Code coverage with Coverlet — what to measure and what not to |
| 4 | ~13 min | CI integration and anti-patterns |
| Recap | ~5 min | Retrieval-style recap |

---

## Block 1 — Test doubles

### Content

"Test double" is the umbrella term (Gerard Meszaros, *xUnit Test Patterns*) for any stand-in object you use in a test in place of a real dependency. Five subtypes, often confused, each with a specific purpose:

| Type | Purpose | When to use | Example |
|---|---|---|---|
| **Dummy** | Fills a required parameter you don't care about. | The method needs an argument; the test never uses it. | `new User(null!, "test@x.com")` where the first param is a Logger you don't care about. |
| **Stub** | Returns canned data when called. | The code under test needs *input* from a dependency. | An `IClock` stub that returns a fixed `DateTime` so date logic is deterministic. |
| **Mock** | Verifies interactions — was this method called, with what args, how many times? | The code under test should *cause* a specific call to happen. | Verify `Logger.LogError(...)` is called when validation fails. |
| **Fake** | A simpler working implementation. | The dependency is too heavy to use real, but a real working alternative exists. | `InMemoryRepository<T>` instead of a SQL-backed repository. |
| **Spy** | A real or stub object that records the calls made on it for later assertion. | Need to verify interactions but don't want to pre-configure behavior. | A wrapper that records all `Send(...)` calls for assertions after the act. |

The two that matter most in day-to-day work are **stubs** and **mocks**. The distinction:

- **Stub** = "when you ask me X, I'll tell you Y." Tests use stubs to control *inputs* to the code under test.
- **Mock** = "when you call me with X, I'll remember it, and the test will verify the call happened." Tests use mocks to verify *outputs* (side effects) of the code under test.

A test should typically have **at most one mock** — the one verifying the interaction it's testing. Everything else should be a stub. If a test has five mocks, you're testing implementation details, not behavior. (More on this in the anti-patterns block.)

### Why this matters in C# specifically

You inject dependencies through constructor parameters. That's the seam that lets you swap real for fake in tests:

```csharp
public class OrderService
{
    private readonly IOrderRepository _repository;
    private readonly IEmailSender _emailSender;
    private readonly IClock _clock;

    public OrderService(IOrderRepository repository, IEmailSender emailSender, IClock clock)
    {
        _repository = repository;
        _emailSender = emailSender;
        _clock = clock;
    }

    public void PlaceOrder(Order order)
    {
        order.PlacedAt = _clock.Now;
        _repository.Save(order);
        _emailSender.SendConfirmation(order);
    }
}
```

In a unit test of `PlaceOrder`, you'd:

- **Stub** `IClock` to return a fixed time (so the test is repeatable).
- **Stub** `IOrderRepository.Save` to succeed silently.
- **Mock** `IEmailSender.SendConfirmation` to verify it was called with the right order.

If the class instead `new`'d its dependencies internally (`new SqlOrderRepository()`), you couldn't substitute them — the test would hit a real database. The constructor-injection pattern *enables* unit testing. This is the design pressure TDD applies that Session 2 alluded to.

### Knowledge check (verbal)

Ask yourself: *"What's the difference between a stub and a mock, in one sentence each?"*

Listening for: stub provides canned input; mock verifies interactions/calls happened. A test that uses a mock makes an assertion about the call; a test that uses a stub uses it to set up state.

---

## Block 2 — Mocking with Moq and NSubstitute (hands-on)

### Content

Both libraries solve the same problem with different ergonomics. You'll see both in real .NET codebases, so it's worth being literate in both.

**Setup**:

```bash
mkdir MockingDemo && cd MockingDemo
dotnet new sln -n MockingDemo
dotnet new classlib -n Orders
dotnet new xunit -n Orders.Tests
dotnet sln add Orders/Orders.csproj Orders.Tests/Orders.Tests.csproj
dotnet add Orders.Tests reference Orders
dotnet add Orders.Tests package Moq
dotnet add Orders.Tests package NSubstitute
```

**The system under test** (`Orders/OrderService.cs`):

```csharp
namespace Orders;

public interface IOrderRepository
{
    void Save(Order order);
}

public interface IEmailSender
{
    void SendConfirmation(Order order);
}

public interface IClock
{
    DateTime Now { get; }
}

public record Order(string Id, string CustomerEmail, decimal Total)
{
    public DateTime PlacedAt { get; set; }
}

public class OrderService(IOrderRepository repository, IEmailSender emailSender, IClock clock)
{
    public void PlaceOrder(Order order)
    {
        if (order.Total <= 0)
            throw new ArgumentException("Order total must be positive.", nameof(order));

        order.PlacedAt = clock.Now;
        repository.Save(order);
        emailSender.SendConfirmation(order);
    }
}
```

### Moq version

```csharp
using Moq;
using Orders;
using Xunit;

namespace Orders.Tests;

public class OrderServiceMoqTests
{
    [Fact]
    public void PlaceOrder_ValidOrder_SavesAndSendsConfirmation()
    {
        // Arrange
        var fixedTime = new DateTime(2026, 5, 28, 10, 0, 0);
        var repository = new Mock<IOrderRepository>();    // stub + mock
        var emailSender = new Mock<IEmailSender>();        // mock
        var clock = new Mock<IClock>();                    // stub
        clock.Setup(c => c.Now).Returns(fixedTime);

        var service = new OrderService(repository.Object, emailSender.Object, clock.Object);
        var order = new Order("ORDER-1", "customer@example.com", 99.95m);

        // Act
        service.PlaceOrder(order);

        // Assert
        Assert.Equal(fixedTime, order.PlacedAt);
        repository.Verify(r => r.Save(order), Times.Once);
        emailSender.Verify(e => e.SendConfirmation(order), Times.Once);
    }

    [Fact]
    public void PlaceOrder_ZeroTotal_ThrowsArgumentException()
    {
        // Arrange
        var service = new OrderService(
            Mock.Of<IOrderRepository>(),
            Mock.Of<IEmailSender>(),
            Mock.Of<IClock>());
        var order = new Order("ORDER-2", "customer@example.com", 0m);

        // Act + Assert
        Assert.Throws<ArgumentException>(() => service.PlaceOrder(order));
    }
}
```

Notes:

- `new Mock<T>()` creates a mock object; access the substitute through `.Object`.
- `Setup(...).Returns(...)` configures stub behavior.
- `Verify(...)` is the mock assertion — "was this called?"
- `Mock.Of<T>()` is a shortcut for "I need a default-behavior stub I won't configure."

### NSubstitute version

```csharp
using NSubstitute;
using Orders;
using Xunit;

namespace Orders.Tests;

public class OrderServiceNSubstituteTests
{
    [Fact]
    public void PlaceOrder_ValidOrder_SavesAndSendsConfirmation()
    {
        // Arrange
        var fixedTime = new DateTime(2026, 5, 28, 10, 0, 0);
        var repository = Substitute.For<IOrderRepository>();
        var emailSender = Substitute.For<IEmailSender>();
        var clock = Substitute.For<IClock>();
        clock.Now.Returns(fixedTime);

        var service = new OrderService(repository, emailSender, clock);
        var order = new Order("ORDER-1", "customer@example.com", 99.95m);

        // Act
        service.PlaceOrder(order);

        // Assert
        Assert.Equal(fixedTime, order.PlacedAt);
        repository.Received(1).Save(order);
        emailSender.Received(1).SendConfirmation(order);
    }
}
```

Notes:

- `Substitute.For<T>()` creates the substitute. No `.Object` indirection — the substitute *is* an `IOrderRepository`.
- `clock.Now.Returns(fixedTime)` reads more like English than the Moq equivalent.
- `Received(1)` is the call-verification syntax. Reads as "the email sender received one call to SendConfirmation."

Run `dotnet test`. Both should pass.

### Picking between them

| Factor | Moq | NSubstitute |
|---|---|---|
| Maturity / ubiquity | Older, more codebases use it | Newer, growing fast |
| API ergonomics | More verbose (`.Object`, `.Verify(..., Times.Once)`) | Cleaner (`Received(1).MethodName(...)`) |
| Strict mode by default | Loose by default (unconfigured calls return defaults) | Same |
| Async support | Good | Good |
| Verifying call arguments with predicates | `It.Is<T>(x => x.Prop == 5)` | `Arg.Is<T>(x => x.Prop == 5)` |
| Note on Moq 4.20+ | The 2023 "SponsorLink" controversy (added analyzer that emailed contributor hashes) led some teams to migrate off Moq; the dependency was removed in subsequent versions, but the reputation hit lingers — see the Moq GitHub issue history for context | No such history |

Practical guidance: if you're starting fresh, NSubstitute is the slightly easier read. If you're working in a codebase that already uses Moq, stay consistent — don't mix mocking libraries in one project.

### Don't mock value objects or simple data classes

A common mistake: mocking `Order` itself. Don't. `Order` is a data structure with no behavior; just `new` it up with the data you need. Mocks are for *collaborators with behavior* — services, repositories, gateways. If a class has no `interface` and no virtual methods, that's usually a sign you should construct it directly, not mock it.

### Knowledge check (verbal)

Ask yourself: *"In the OrderService test, why is the repository injected as an interface (`IOrderRepository`) rather than a concrete class?"*

Listening for: the interface is the seam that lets you substitute a mock/stub in tests. A concrete class with no virtual methods can't be cleanly mocked by Moq/NSubstitute — they need either an interface or virtual members to override.

---

## (Stretch break — 2 min)

---

## Block 3 — Code coverage with Coverlet

### Content

Code coverage measures what percentage of your production code is executed by your tests. It's a useful diagnostic — and a terrible target.

**The xUnit project template you've been using already includes Coverlet** by default (the `coverlet.collector` NuGet package). To collect coverage:

```bash
dotnet test --collect:"XPlat Code Coverage"
```

This outputs a `coverage.cobertura.xml` file under `TestResults/`. The file is machine-readable; to make it human-readable, install `ReportGenerator`:

```bash
dotnet tool install -g dotnet-reportgenerator-globaltool
reportgenerator -reports:"**/coverage.cobertura.xml" -targetdir:"CoverageReport" -reporttypes:Html
```

Open `CoverageReport/index.html` in a browser. You'll see line coverage, branch coverage, and a class-by-class breakdown.

### How to read coverage intelligently

Three numbers matter:

- **Line coverage**: % of lines executed at least once. The most-reported number.
- **Branch coverage**: % of `if`/`else`/`switch` branches taken at least once. *This is more useful than line coverage.* A line with `if (x) DoA(); else DoB();` is "covered" by either branch, but you want both tested.
- **Method coverage**: % of methods called at least once. Catches "this entire helper has zero tests."

### What healthy coverage looks like

There's no universal number, but rough guidelines for a typical business application:

| Coverage | Interpretation |
|---|---|
| **< 40%** | Suite is more decorative than functional. Significant code change risk. |
| **40–60%** | Probably testing the easy stuff. Likely gaps in error handling and edge cases. |
| **60–80%** | Healthy zone for most business code. Critical paths are tested. |
| **80–95%** | Good for libraries and stable code. Diminishing returns past here. |
| **> 95%** | Often means tests are written to hit lines rather than verify behavior. Suspicious. |
| **100%** | Almost always means at least some tests are testing trivial getters/setters. Bad sign. |

### Why 100% is wrong

Two failure modes:

1. **Tests written to hit lines.** A test that calls `obj.SomeProperty` to "cover" the auto-property is testing the compiler, not your code. It adds maintenance cost and catches nothing.
2. **False sense of security.** 100% line coverage doesn't mean 100% behavior coverage. You can hit every line and miss the case where `customer` is null halfway through a multi-step calculation. *Behavior* coverage is what matters; *line* coverage is a proxy.

The pragmatic move: aim for high coverage in business logic and critical paths, accept lower coverage in adapters/glue code, and watch for coverage *drops* between PRs as a signal that someone added code without tests. The trend matters more than the absolute number.

### What NOT to measure for coverage

- `Program.cs` / startup code (one-shot wiring; not really testable).
- Auto-generated code (EF migrations, Refit clients, etc.).
- DTOs and `record`s with no behavior.

Exclude these via `[ExcludeFromCodeCoverage]` attributes on the class or assembly (cleanest, works with every coverage tool), or via Coverlet's MSBuild properties (`/p:Exclude=...`) or the newer MTP integration flags. Check the [Coverlet docs](https://github.com/coverlet-coverage/coverlet) for current flag names — they've evolved across major versions.

### Knowledge check (verbal)

Ask yourself: *"Why is branch coverage more useful than line coverage, and what's the problem with chasing 100% coverage?"*

Listening for: branch coverage forces both sides of an `if` to be tested, not just one. 100% leads to tests written to hit lines rather than verify behavior, plus a false sense of security — line coverage doesn't equal behavior coverage.

---

## Block 4 — CI integration and anti-patterns

### Content

#### Wiring tests into CI

The whole point of a test suite is automatic execution. Tests that only run when someone remembers to run them locally don't catch bugs in PRs. The minimum integration is "run `dotnet test` on every PR and fail the build on red."

**GitHub Actions** (`.github/workflows/test.yml`):

```yaml
name: Tests

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '8.0.x'

      - name: Restore
        run: dotnet restore

      - name: Build
        run: dotnet build --configuration Release --no-restore

      - name: Test
        run: dotnet test --configuration Release --no-build --verbosity normal --collect:"XPlat Code Coverage"

      - name: Upload coverage
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: '**/coverage.cobertura.xml'
```

That's the minimum viable setup. Key properties:

- Runs on every push and PR.
- `--no-restore` and `--no-build` skip redundant work after the first step.
- Coverage collected automatically (the xUnit template wired Coverlet in already — Session 1).
- Coverage artifact uploaded so a reviewer can download it. Optional: integrate with Codecov / Coveralls for inline PR comments.

**Azure DevOps** has a similar pattern using the `DotNetCoreCLI@2` task with `command: test` and `arguments: '--collect "Code Coverage"'`. Same idea.

#### Anti-patterns (the things that quietly destroy suites)

These are the smells to watch for in your own code and in PR reviews:

| Anti-pattern | What it looks like | Why it's bad | Fix |
|---|---|---|---|
| **Testing implementation, not behavior** | Test breaks when you refactor without changing behavior | Tests should change only when behavior changes; otherwise they're brittle | Assert on outcomes (returned value, observable state, interactions with collaborators), not internal mechanics |
| **Mock everything** | 6 mocks, 0 stubs, complex `Setup` chains | You're testing the test, not the code; passes even when behavior is broken | One mock per test max — the dependency whose interaction you're verifying. Everything else is a stub. |
| **Shared mutable state** | `private static` fields, `[Collection]` abuse | Tests pass alone, fail in the suite, or vice versa | xUnit's per-test instance creation eliminates this. Don't fight it. |
| **Magic strings/numbers** | `Assert.Equal(1001, total)` with no explanation of why 1001 | Reader has to reverse-engineer intent | Extract to a named constant: `const decimal MaxTotal = 1001m;` |
| **Multiple Act per test** | Three method calls, three asserts, all in one test body | First failure stops subsequent asserts; you don't know if everything else also broke | Split into separate tests, or use `[Theory]` if the structure is identical |
| **Logic in tests** | `if`, `for`, `while` inside test methods | Tests can have their own bugs. Now you're debugging the test instead of the code | Use `[Theory]` for parameterization. If the test needs branching, you're testing too much. |
| **Tests that don't actually test anything** | `Assert.True(true)`, missing `await`, swallowed exceptions | Green bar, zero protection | Code review. CI mutation testing (Stryker.NET) catches these. |
| **Tests that depend on `DateTime.Now`** | Passes today, fails tomorrow | Not Repeatable (the R in FIRST) | Inject an `IClock`; stub it. |
| **Slow tests in the unit suite** | Suite takes 5 minutes; nobody runs it locally | Slow suites stop being run, then stop catching bugs | Move slow ones to integration test project. Keep unit suite under 30 seconds. |
| **Skipped tests** | `[Fact(Skip = "broken")]` everywhere | Skipped tests are dead tests; the bug they protected against has returned | Fix them or delete them. No middle ground. |
| **Tests testing the framework** | Tests for auto-properties, simple constructors, getters/setters | No value; just maintenance burden | Delete. Test behavior, not boilerplate. |

#### The single most important anti-pattern

**Tests that don't fail when they should.** A test that passes when the code is broken is worse than no test — it gives false confidence. The way to check is exactly what you did in the make-it-fail demo in Sessions 1 and 2: deliberately break the production code and confirm the test catches it. Do this when you write the test. If it doesn't fail for the broken code, the test is testing the wrong thing.

#### Make-it-fail demo (productive failure)

Open the `OrderService` test from Block 2. In `OrderService.cs`, comment out the `emailSender.SendConfirmation(order);` line. Don't change the test.

Run `dotnet test`. Expected output:

```
Failed PlaceOrder_ValidOrder_SavesAndSendsConfirmation
  Expected to receive a call matching:
    SendConfirmation(*)
  Actually received no matching calls.
```

That's the mock doing its job — verifying the *interaction* that should have happened. Without that `Verify`/`Received` line, the test would have passed silently, and a real customer would never have gotten a confirmation email.

Hold the failure for 30 seconds. Note that the failure message points directly at the missing interaction. Restore the line, confirm tests pass, move on.

### Knowledge check (verbal)

Ask yourself: *"What's the difference between a test failing because the behavior is broken and a test failing because you refactored internals — and which kind of failure is good?"*

Listening for: behavior-broken failure is good — the safety net is working. Refactor-only failure is bad — the test is brittle, assertions are on implementation details. Tests should change only when behavior changes.

---

## Recap (5 min)

Answer these out loud or in writing **before** scrolling.

1. What's the difference between a stub and a mock, and which one should you have at most one of per test?
2. Why is branch coverage more useful than line coverage?
3. What's a healthy code-coverage range for a typical business application, and why is 100% suspicious?
4. Name three anti-patterns that quietly degrade a test suite over time.
5. *Synthesis*: You're reviewing a PR. The diff adds a new method to `OrderService`, adds zero tests, and the CI coverage drops from 78% to 72%. What do you say?

---

### Answers (don't read until you've answered)

1. Stub provides canned input; mock verifies interactions occurred. A test should have at most one mock — the dependency whose call you're verifying. Everything else is a stub.
2. Line coverage marks a line "covered" if either branch of an `if` runs. Branch coverage requires both sides to be exercised. Branch coverage exposes untested error paths that line coverage misses.
3. 60–80% is healthy for most business code. 100% is suspicious because it almost always means tests are written to hit lines (auto-properties, trivial constructors) rather than verify behavior, *and* line coverage doesn't equal behavior coverage anyway.
4. Any three: testing implementation not behavior, over-mocking, shared mutable state, magic strings, multiple acts per test, logic in tests, dependence on `DateTime.Now`, slow tests in the unit suite, skipped tests left in place, tests for boilerplate.
5. The behavior coverage gap matters more than the percentage. Concretely: "The PR adds untested behavior. Please add tests that fail when the new method is broken — a behavior assertion, not a line-coverage assertion. If the new method calls a dependency, mock it and verify the interaction. The 6-point drop tells me roughly how much new code was added without tests; the *real* question is whether the critical paths in the new method are covered."

---

## Field Reinforcement (do tomorrow)

You've now completed the formal program. The 70-20-10 principle says ~70% of durable learning happens on the job. Here's how to make that real:

1. **Open the most recent PR you submitted that didn't have tests.** Add tests retroactively for the most critical behavior. Note where TDD would have caught a design issue.
2. **Add `dotnet test` to the team's CI pipeline** if it isn't already there. Failing the build on red tests is the structural change that makes the whole practice stick.
3. **Establish a personal rule**: no new business logic merged without a test. Track for two weeks. Note where you broke the rule and why.
4. **Read** *The Art of Unit Testing* by Roy Osherove (current 3rd edition is the best practical .NET-focused book in print) and *Working Effectively with Legacy Code* by Michael Feathers (the canonical text for retrofitting tests onto untested code).
5. **Optional**: try mutation testing with Stryker.NET on a small project. It mutates your production code and verifies that your tests catch the mutation. It's the rigorous version of the make-it-fail demos in this program.

---

## Common Pitfalls & Troubleshooting

| Pitfall | Why it happens | What to do |
|---|---|---|
| Mock setup is so complex the test is unreadable | Class under test has too many dependencies | The pain of mocking is the signal. Refactor the class — extract a smaller service, or pass a value object instead of three primitives. |
| Test passes with no Asserts | Forgot to assert, exception swallowed, `async` forgotten | Code review. Stryker.NET mutation testing surfaces these. |
| Coverage report shows 0% for tested classes | `dotnet test` ran without `--collect`, or wrong report format | Use `dotnet test --collect:"XPlat Code Coverage"`. Output is at `TestResults/<guid>/coverage.cobertura.xml`. |
| Different coverage numbers from different tools | Coverlet, MS Code Coverage, JetBrains dotCover all calculate slightly differently | Pick one, use it consistently, don't compare absolute numbers across tools. Watch the trend within one tool. |
| CI is green locally, red in pipeline | Environment-specific behavior — culture, timezone, path separators, file-locking | The pipeline is right; your local machine is hiding a bug. Reproduce locally by setting `CultureInfo.InvariantCulture` or `TZ=UTC`. |

---

## Source Documentation References

- Microsoft Learn — Unit testing and mocking with the Azure SDK for .NET (Moq + NSubstitute examples): https://learn.microsoft.com/dotnet/azure/sdk/unit-testing-mocking
- Microsoft Learn — Use code coverage for unit testing (Coverlet workflow): https://learn.microsoft.com/dotnet/core/testing/unit-testing-code-coverage
- Microsoft Learn — Microsoft Testing Platform code coverage (newer MTP integration): https://learn.microsoft.com/dotnet/core/testing/microsoft-testing-platform-code-coverage
- Microsoft Learn — Selective unit tests (xUnit filtering): https://learn.microsoft.com/dotnet/core/testing/selective-unit-tests
- Microsoft Learn — Build, test, and deploy .NET Core projects (CI integration): https://learn.microsoft.com/azure/devops/pipelines/ecosystems/dotnet-core
- Coverlet on GitHub: https://github.com/coverlet-coverage/coverlet
- Stryker.NET (mutation testing): https://stryker-mutator.io/docs/stryker-net/introduction/

---

*Document Version: 1.0 — Session 3 of Unit Testing & TDD self-study program*
