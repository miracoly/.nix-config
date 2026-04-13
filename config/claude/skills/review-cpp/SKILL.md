# Skill: C++ Code Review (`/review-cpp`)

Perform a thorough, pedantic C++23 code review. Be a perfectionist. Do not give the benefit of the doubt.

---

## Invocation & Argument Handling

The skill is invoked as `/review-cpp [path]`.

| Invocation | Behaviour |
|---|---|
| `/review-cpp` (no argument) | **Git diff mode** — review all changes on the current branch vs. `origin/<current-branch>` |
| `/review-cpp path/to/file.cpp` | **File mode** — review the specified file |
| `/review-cpp path/to/dir/` | **Directory mode** — review all C++ files under that path, recursively |

---

## Step 1 — Collect Files to Review

### Git diff mode (no argument)
1. Run `git rev-parse --abbrev-ref HEAD` to get `<branch>`.
2. Collect the **union** of all C++ files changed across:
   - `git diff --name-only origin/<branch>..HEAD` (committed)
   - `git diff --name-only --staged` (staged)
   - `git diff --name-only` (unstaged)
3. Filter to C++ files: `.cpp`, `.cxx`, `.cc`, `.c`, `.h`, `.hpp`, `.hxx`, `.inl`, `.tpp`.
4. For each changed file, obtain:
   - The **full file content** (not just the diff hunk) — full context is required for pattern detection.
   - The **full diff** (`git diff origin/<branch> -- <file>` combined with staged/unstaged diff) so you know which lines changed.

### File mode
Read the specified file in full.

### Directory mode
Recursively find and read all `.cpp`, `.cxx`, `.cc`, `.c`, `.h`, `.hpp`, `.hxx`, `.inl`, `.tpp` files under the given path.

---

## Step 2 — Build Full Context

Before reviewing any file, build complete context:

1. **Follow `#include` directives** — for every file under review, read all headers it includes that exist in the repository. Repeat transitively until no new in-repo headers are found.
2. **Read build configuration** — look for `CMakeLists.txt`, `meson.build`, `vcpkg.json`, `conanfile.txt`, or `.clang-tidy` in the repo root and build directories. Note the C++ standard, compiler flags, enabled warnings, and dependencies.
3. **Read related translation units** — if reviewing a `.hpp`, also read the corresponding `.cpp` if it exists, and vice-versa.
4. **Note**: Microsoft GSL (`https://github.com/microsoft/GSL`) is **always available** in the project. Use `gsl::owner<>`, `gsl::not_null<>`, `gsl::span<>`, `gsl::narrow<>`, `gsl::narrow_cast<>`, `gsl::czstring`, `gsl::zstring`, and `GSL_SUPPRESS` freely in fix examples.

---

## Step 3 — C++ Core Guidelines Review

Read the full guidelines reference at `~/.claude/skills/review-cpp/references/CppCoreGuidelines.md`.

Go through **every chapter and every rule** listed below. Do **not** skip rules. Do **not** batch rules. Check each rule individually against the code under review. For rules marked `Enforcement: not enforceable` or `???`, apply manual judgement — do not skip them.

Only **report** rules that are violated or meaningfully relevant to the code. Do not report rules that are entirely inapplicable (e.g., concurrency rules when there is zero concurrency in the reviewed code).

### Chapters to review (in order)

| ID | Chapter |
|----|---------|
| P | Philosophy |
| I | Interfaces |
| F | Functions |
| C | Classes and class hierarchies |
| Enum | Enumerations |
| R | Resource management |
| ES | Expressions and statements |
| Per | Performance |
| CP | Concurrency and parallelism |
| E | Error handling |
| Con | Constants and immutability |
| T | Templates and generic programming |
| CPL | C-style programming |
| SF | Source files |
| SL | The Standard Library |
| NL | Naming and layout |
| Pro | Profiles |
| A | Architectural ideas |

### Severity Classification

Derive severity from the language of the violated guideline:

| Severity | Criteria |
|----------|----------|
| **Error** | Guideline uses "must", "shall", "never", "always"; violation causes undefined behaviour, resource leaks, safety issues, or correctness bugs |
| **Warning** | Guideline uses "should", "avoid", "prefer"; violation is a significant quality, maintainability, or performance issue |
| **Suggestion** | Guideline uses "may", "consider", or covers style, naming, or minor improvements |

---

## Step 4 — Design Pattern Analysis

Check the code against every GoF pattern listed below. These are the **only** GoF patterns still relevant for modern C++23; obsolete ones (Iterator replaced by ranges, Interpreter, Prototype replaced by copy/move) are excluded.

For each pattern, determine:
- **Incorrect / partial implementation** → report as a violation (Error or Warning depending on severity of the flaw)
- **Could benefit from introduction** → report as a Recommendation (Suggestion)
- **Correctly implemented** → no finding needed

Scope the pattern analysis to the reviewed path plus all context gathered in Step 2.

### Creational Patterns

| Pattern | What to look for |
|---------|-----------------|
| **Abstract Factory** | Families of related objects; check for correct interface segregation, no concrete class leaking across factory boundaries |
| **Builder** | Telescoping constructors (>3 params or complex init sequences) are a smell; recommend Builder. Verify existing builders use method chaining and produce valid objects only on `build()` |
| **Factory Method** | Raw `new` / `make_unique` scattered across business logic suggests factory extraction; subclass instantiation should be deferred |
| **Singleton** | Flag any Singleton as a likely anti-pattern. Recommend dependency injection or `static`-local (Meyers Singleton) only when global access is genuinely required; check for thread-safety (C++11 `static` local is safe) |

### Structural Patterns

| Pattern | What to look for |
|---------|-----------------|
| **Adapter** | Wrapper classes bridging incompatible interfaces; check for unnecessary copying, missing `noexcept`, missing `[[nodiscard]]` |
| **Bridge / Pimpl** | Classes with large private sections or that expose implementation details in headers; recommend Pimpl for ABI stability and compile-time firewall |
| **Composite** | Tree structures; verify uniform interface, correct ownership (prefer `std::unique_ptr` over raw owning pointers) |
| **Decorator** | Inheritance chains used solely to add behaviour; recommend Decorator. Verify existing decorators preserve the wrapped object's interface fully |
| **Facade** | Subsystems exposing too many types/functions to callers; recommend Facade for simplification |
| **Flyweight** | Redundant copies of immutable or shared data (e.g., repeated strings, config objects); recommend shared state via `std::shared_ptr` or interning |
| **Proxy** | Lazy initialisation, access control, smart-pointer wrappers; check that `std::unique_ptr` / `std::shared_ptr` are used instead of raw owning pointers |

### Behavioral Patterns

| Pattern | What to look for |
|---------|-----------------|
| **Chain of Responsibility** | Long `if-else` or `switch` chains dispatching to handlers; recommend CoR. Verify chains have a clear termination condition |
| **Command** | Encapsulation of requests as objects needed for undo/redo, queuing, or logging; for simple dispatch prefer `std::function` / lambdas over a full Command class hierarchy |
| **Mediator** | Many-to-many object communication that causes tight coupling; recommend Mediator to centralise coordination |
| **Memento** | State snapshot/restore requirements; verify encapsulation (Originator should not expose internals via Memento) |
| **Observer** | Notification/event systems; check for raw function pointers (→ use `std::function`), manual observer lists (→ consider range-based notification), and missing unsubscription logic causing dangling references |
| **State** | Large `switch` / `if-else` blocks that branch on an enum representing state; recommend State pattern or `std::variant` + `std::visit` |
| **Strategy** | Runtime-switchable algorithms; in C++23 prefer `std::function` or concepts + templates over a Strategy class hierarchy unless the algorithm set is open-ended |
| **Template Method** | Base classes with non-virtual steps calling virtual hooks; in C++23 prefer CRTP or *deducing `this`* to avoid vtable overhead when the hierarchy is closed |
| **Visitor** | Double-dispatch on a type hierarchy; in C++23 prefer `std::variant` + `std::visit` over classic Visitor unless the element hierarchy is open-ended |

---

## Step 5 — C++23 Modernisation

Beyond the guidelines, flag any code that should be updated to modern C++23:

- `std::expected<T, E>` instead of out-params, error codes, or exception abuse for recoverable errors
- `std::flat_map` / `std::flat_set` for ordered containers with cache-friendly access
- **Deducing `this`** (explicit object parameter) instead of CRTP boilerplate
- `std::ranges` / views instead of raw iterator loops
- `std::mdspan` for multi-dimensional array views
- `std::print` / `std::println` instead of `printf` / `std::cout <<`
- `std::string_view` / `std::span` for non-owning parameters (flag `const std::string&` for read-only string params)
- `[[nodiscard]]`, `[[likely]]`, `[[unlikely]]`, `[[assume(expr)]]` where missing
- `if consteval` / `constexpr if` / `consteval` where applicable
- `std::stacktrace` in diagnostic/error contexts
- Structured bindings, `std::tie`, and `auto` returns where they reduce noise
- `std::to_underlying()` instead of explicit enum casts

---

## Step 6 — Output Format

### Per-file findings

Group all findings **by file**, then within each file by **severity** (Errors first, then Warnings, then Suggestions), and within each severity group in **ascending line number** order.

Use the following format for each finding:

```
## <relative/path/to/file.cpp>

### [Error | Warning | Suggestion] — Line <N>: <Rule ID> — <Short Title>

**Rule**: <e.g., R.11 — Avoid calling `new` and `delete` explicitly>
**Issue**: <Concise description of what is wrong or what opportunity exists>

**Fix**:
```cpp
- // before (offending code, minimal excerpt)
+ // after (corrected code)
```
```

If a fix requires showing more context (e.g., a class restructure), use a longer diff block. Never show the entire file.

### Summary table

After all per-file findings, output:

```
## Review Summary

| File | Errors | Warnings | Suggestions |
|------|--------|----------|-------------|
| foo.cpp | N | N | N |
| bar.hpp | N | N | N |
| **Total** | **N** | **N** | **N** |
```

### Pattern recommendations section

After the summary table, output a dedicated section:

```
## Pattern Recommendations

### <Pattern Name> — <file(s) affected>
**Rationale**: <why this pattern would benefit this specific code>
**Sketch**:
```cpp
// minimal illustrative example of the pattern applied to this code
```
```

---

## Hard Constraints

- **Never modify any file.** All fixes are illustrative only, shown in diff-style code blocks.
- Be pedantic. Check every rule. Every deviation matters.
- Apply **C++23** as the baseline standard. Flag anything using pre-C++11 style when a modern equivalent exists.
- GSL is available — prefer `gsl::not_null<>`, `gsl::owner<>`, `gsl::span<>`, `gsl::narrow<>` in fix examples over raw pointer or unchecked casts.
- If context is needed to make a judgement (e.g., a base class, a related header), **fetch it before reporting** — do not flag something you cannot confirm.
- In git diff mode: flag violations in changed lines as **primary findings**; flag violations in unchanged context lines as **secondary findings** (prefix the title with `[Context]`). Both are reported.
