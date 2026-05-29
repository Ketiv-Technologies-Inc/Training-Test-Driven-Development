# Test-Driven Development Training

A three-session, self-paced (or instructor-led) training program covering unit testing fundamentals and Test-Driven Development for C# / .NET developers.

Designed for engineers who have never formally learned unit testing or TDD. Built on Microsoft Learn's official guidance, xUnit's documentation, and well-established learning-science principles (cognitive load theory, retrieval practice, productive failure, the 70-20-10 model).

---

## Program at a glance

| Session | File | Duration | Topic |
|---|---|---|---|
| Overview | [`00-Training-Methodology.md`](00-Training-Methodology.md) | ~10 min | Why this program exists, how it's structured, how to use it |
| 1 | [`01-Unit-Testing-Fundamentals.md`](01-Unit-Testing-Fundamentals.md) | ~60 min | What a unit test is, xUnit setup, AAA pattern, `[Fact]` vs `[Theory]` |
| 2 | [`02-Test-Driven-Development.md`](02-Test-Driven-Development.md) | ~60 min | Red-Green-Refactor, FIRST principles, when TDD is wrong |
| 3 | [`03-Test-Doubles-Coverage-CI.md`](03-Test-Doubles-Coverage-CI.md) | ~60 min | Stubs/mocks/fakes/spies, Moq + NSubstitute, Coverlet, CI, anti-patterns |

**Total time**: ~3 hours of focused work, plus field reinforcement between sessions.

---

## Prerequisites

- **.NET 8 SDK** or later — verify with `dotnet --version`
- A C# editor — VS Code, Visual Studio 2022, or Rider
- Comfort with the .NET CLI (`dotnet new`, `dotnet build`, `dotnet add`)
- No prior unit testing experience required

---

## Tooling stack

| Concern | Choice | Why |
|---|---|---|
| Test framework | **xUnit** (v2/v3) | Microsoft's recommended default; per-test instance, no `[SetUp]`/`[TearDown]` |
| Mocking | **Moq** and **NSubstitute** | Both shown side-by-side; pick whichever fits your project's conventions |
| Coverage | **Coverlet** (`coverlet.collector`) | Already wired into the `dotnet new xunit` template |
| Coverage reports | **ReportGenerator** | Converts Cobertura XML to readable HTML |
| CI | **GitHub Actions** (sample YAML in Session 3) | Easily adaptable to Azure DevOps / GitLab CI |

---

## How to use this program

### Self-paced learner

1. Read [`00-Training-Methodology.md`](00-Training-Methodology.md) first — it explains the structure and how to get the most out of it.
2. Block 60 minutes for each session. No Slack, no email, closed door.
3. Have an IDE open and **type the examples** — don't just read.
4. Do the field reinforcement assignment between sessions. The session is ~10% of the learning; the on-the-job application is the other ~90%.
5. Answer the recap questions before reading the answers. The retrieval is the encoding moment.

### Instructor running a team workshop

1. Treat each session as a ~60-minute slot. Project the code; let learners type along.
2. Pre-stage the working `Calculator`, `FizzBuzz`, and `Orders` solutions for quick recovery if a learner hits an environment issue.
3. Use the verbal knowledge checks as group questions — call on a different person each time.
4. **Do not skip the "make-it-fail" demos.** Showing a real failure on screen is the highest-retention moment of each session.
5. Use the field reinforcement as next-day asynchronous follow-up; review submissions before the next session.

---

## Learning outcomes

By the end of the program, learners can:

1. Add an xUnit test project to an existing .NET solution with correct package references
2. Write `[Fact]` and `[Theory]` tests using AAA and `MethodName_Scenario_ExpectedBehavior` naming
3. Practice a TDD Red-Green-Refactor cycle without skipping steps
4. Identify when to use a fake, stub, mock, or spy — and write each with Moq or NSubstitute
5. Collect code coverage with Coverlet and read the report intelligently (not chase 100%)
6. Wire `dotnet test` into a CI pipeline so tests fail the build
7. Recognize the common anti-patterns when reviewing code or a PR

---

## What's deliberately out of scope

- Integration, end-to-end, and UI automation testing
- Property-based testing (FsCheck, Bogus)
- BDD frameworks (SpecFlow, Reqnroll)
- Performance and load testing
- MSTest and NUnit deep-dives (mentioned for context only)

These are downstream concerns. Get the unit-testing/TDD mindset right first; the rest gets easier.

---

## Methodology

Every session is structured around eleven evidence-based learning principles (cognitive load, spaced repetition, retrieval practice, productive failure, andragogy, etc.). Each structural element — measurable objectives, time-boxed blocks, make-it-fail demos, retrieval-style recaps, field reinforcement — exists because of a specific principle. Full rationale is in [`00-Training-Methodology.md`](00-Training-Methodology.md).

---

## Sources

Every factual claim in this program is grounded in official documentation. Each session ends with a "Source Documentation References" section linking to the authoritative material:

- [Microsoft Learn — Unit testing C# with dotnet test and xUnit](https://learn.microsoft.com/dotnet/core/testing/unit-testing-csharp-with-xunit)
- [Microsoft Learn — Unit testing best practices for .NET](https://learn.microsoft.com/dotnet/core/testing/unit-testing-best-practices)
- [Microsoft Learn — Use code coverage for unit testing](https://learn.microsoft.com/dotnet/core/testing/unit-testing-code-coverage)
- [Microsoft Learn — Unit testing and mocking with the Azure SDK for .NET](https://learn.microsoft.com/dotnet/azure/sdk/unit-testing-mocking)
- [Microsoft Learn — Iteration #6: Use test-driven development (C#)](https://learn.microsoft.com/aspnet/mvc/overview/older-versions-1/contact-manager/iteration-6-use-test-driven-development-cs)
- [xUnit.net official site](https://xunit.net/)

---

## Contributing

Issues and pull requests welcome. If you spot a factual error, please open an issue citing the specific claim and the source that contradicts it. Pedagogical structure (block ordering, retrieval prompts, learning principles) is intentional — propose changes with rationale grounded in the methodology brief.

---

## License

Internal training material — Ketiv Technologies, Inc.
