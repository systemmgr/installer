# AI Rules — casjay-dotfiles/scripts

**HOW things are done → `AI.md`**
**WHAT this project is → `IDEA.md`**

---

## Compact Instructions

When compacting, preserve: current task goal, files changed, commands run, failing tests + exact errors, decisions made, next action list.
Drop: old exploration paths, repeated logs, irrelevant discussion.

---

## Communication

1. **Useful beats pleasant** — Push back when wrong, disagree when warranted. Don't validate for validation's sake
2. **Never guess** — If unsure, ask first
3. **`?` = question** — User ending with `?` is asking, not commanding. Answer; don't execute
4. **Numbered questions in terminal** — Number multiple questions so the user replies "1: ..., 2: ..." instead of re-typing
5. **Match user terminology** — Use the user's names, concepts, abbreviations; don't rename their domain language
6. **Brace notation** — `{name}` is a placeholder; `name` (no braces) is literal text

---

## Code & File Operations

7. **Read before writing** — View a file's current state before editing
8. **Stay in scope** — Don't refactor, reformat, or "improve" code outside the request
9. **Working-set discipline** — Active working set is set when user says "we are working on X". Stays until user explicitly redirects. Never expand scope on your own initiative — note related issues but don't act on them
10. **Preserve style** — Match surrounding conventions; don't impose new ones
11. **Use standards, don't reinvent** — POSIX/sysexits exit codes, HTTP status codes, applicable RFCs, established formats (JSON/YAML/TOML/semver/ISO 8601)
12. **No scope creep** — No unrequested features, files, or abstractions. "Parity with X" includes all of X's features + required plumbing
13. **Edit, don't rewrite** — Targeted edits over full-file rewrites unless asked
14. **Required deps OK; ask on choices** — Add necessary dependencies without asking. Ask only when there's a meaningful choice, a new external service, or a conflict with project principles

---

## Verification & Safety

15. **Confirm destructive ops** — Pause before `rm -rf`, force pushes, dropping tables, deleting branches
16. **Never run unrequested destructive ops** — Troubleshooting does NOT justify destructive fixes. Stop and ask
17. **No fabricated APIs** — If unsure a function/flag/library exists, verify rather than invent
18. **Cite the source** — Reference code by file + line; don't paraphrase from memory
19. **Fix in-scope, stop on out-of-control** — Fix code errors, config typos, syntax. Stop on: unreachable upstream, missing credentials, hardware/network issues

---

## Self-Validation

20. **Run the code** — Don't deliver "done" without running it; run tests, hit the endpoint
21. **Iterate until passing** — Don't stop at "compiles"; keep going until success criteria are met
22. **Define success up front** — Before non-trivial work, state what "done" looks like
23. **Add tests for new behavior** — Test that fails before change, passes after; then run it
24. **Plan complex work first** — 3+ files, multi-step, or ambiguous: outline the plan first

---

## Build & Execution Environment

25. **Never run built binaries on host** — Run inside a container. Prefer Incus over Docker
26. **Cross-platform default** — Target both `linux/amd64` and `linux/arm64` unless scoped to one
27. **Reproducible builds** — Builds happen in containers with declared toolchain images

---

## Output Style

28. **No filler preamble** — Skip openers like "Great question!" or "Happy to help"
29. **No reflexive agreement** — Don't agree before actually re-examining the claim
30. **No closing recap** — Don't summarize what was just done unless asked
31. **Tight output** — Status updates: 1-3 sentences max. No headers/bullets unless required
32. **Show diffs, not retellings** — For code changes, show the actual change
33. **No emojis unless asked** — Plain text by default
34. **Don't pause for "continue?"** — If next step is clear, do it. Pause only when genuinely blocked
35. **No AI attribution** — Never add AI-tool trailers or "Generated with X" to commits or code

---

## Token & Context Discipline

36. **Explore subagent for broad searches** — Searches spanning 3+ files or unknown locations: dispatch via Explore subagent
37. **Read files narrowly** — Files >500 lines: use `offset`/`limit` or grep first. Don't load 2000 lines for 50
38. **Parallelize independent research** — Multiple independent questions: spawn agents in parallel (single message, multiple Agent calls)

---

## Spec & Workflow

39. **Spec is source of truth** — `AI.md` = HOW, `IDEA.md` = WHAT, `TODO.AI.md` = in-flight tasks. Defer to these; flag drift, don't silently follow conversational direction
40. **Drift check every turn** — Before responding to a dev request, verify it matches `AI.md`; flag divergence before acting
41. **Never build unspec'd features** — If a request isn't in spec, ask whether to update spec first
42. **Capture learnings** — After completing a task, record reusable gotchas/conventions in `AI.md` or memory

---

## Project-Critical Overrides

These override or extend the global rules above for this repo specifically.

### Commit Workflow (see AI.md for full details)

- **`gitcommit` is the ONLY commit path** — plain `git commit` and `git push` are forbidden
- **Only invocation:** write `.git/COMMIT_MESS` first, then `gitcommit {subcommand}` (e.g. `gitcommit bin`, `gitcommit all`)
- **Forbidden subcommands:** `gitcommit ai`, `gitcommit random`, `gitcommit custom` — all bypass the message file
- **No `-m`/`--message`** — always use the COMMIT_MESS file

### Code Standards (see AI.md for full details)

- Functions prefixed `__` (e.g. `__my_function`)
- Variables prefixed `{SCRIPTNAME}_` in uppercase
- Comments ABOVE code — never inline at end of line
- Version: `YYYYMMDDHHMM-git` in `##@Version` and `VERSION=` — bump on every change
- No UUOC; prefer bash builtins over forks

### Security

**Secure by design, invisible to the user.** Security lives in the code, not in
user-facing friction. Guard inside the code against: SQL injection (parameterized
queries/ORMs), enumeration (uniform error responses, constant-time comparison),
race conditions (locking, transactions, atomic ops), CSRF, XSS, SSRF, path
traversal, IDOR, ReDoS, deserialization. Don't push the cost onto users with
arbitrary password complexity rules, captcha gauntlets, or excessive re-verification.
The code defends; the user just uses the tool.

**Never hardcode secrets — every repo is public.** Never commit passwords, API keys,
tokens, certificates, OAuth client secrets, DB URIs with credentials, internal
hostnames/IPs, customer data, or tracking codes. Sensitive values live in env vars,
gitignored config files, or a secret manager. Scan for accidental leaks before commit.

**Project-specific:**
- No `curl | sh` patterns — always download then inspect/verify before running
- Use `sudo tee` instead of `sudo sh -c 'echo ... > file'` for privileged writes
