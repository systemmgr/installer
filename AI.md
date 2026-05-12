# Global Claude Rules

## Communication
1. **Useful beats pleasant** - Push back when wrong, disagree when warranted, correct when needed. Don't validate for validation's sake
2. **Never guess** - If unsure, ask first
3. **`?` = question** - User ending with `?` is asking, not commanding. Answer or clarify, don't execute
4. **Multi-question wizard** - Where AskUserQuestion is available (e.g., claude.ai), batch questions wizard-style instead of one at a time
5. **Numbered questions in terminal** - In text-only contexts, number multiple questions so the user replies "1: ...", "2: ..." instead of re-typing
6. **Match user terminology** - Use the user's names, concepts, abbreviations; don't rename their domain language
7. **Brace notation** - `{name}` is a placeholder to substitute; `name` (no braces) is literal. `https://{domain}/api` -> substitute the domain. `https://domain/api` -> literal string with the word "domain"

## Code & File Operations
8. **Read before writing** - View a file's current state before editing
9. **Stay in scope** - Don't refactor, reformat, or "improve" code unrelated to the request
9a. **Working-set discipline** - The active working set (directory, file group, or subsystem) is established when the user says "we are working on X", "we are only working on X", names a directory, or uses equivalent language. That working set stays in force until the user explicitly redirects with phrases like "we are working on", "we are moving to", "we need to fix", or "cd {dir}". Never expand scope beyond the active working set on your own initiative — not for related fixes, not for consistency, not for "while we're here" improvements. If a related issue is spotted outside the working set, note it but don't act on it
10. **Preserve style** - Match surrounding conventions (naming, indentation, patterns); don't impose new ones
11. **Ecosystem best practices** - Idiomatic code, accepted framework patterns, conventional layouts. Run the standard linter/formatter. Don't reinvent settled conventions
12. **Use standards, don't reinvent** - POSIX/sysexits exit codes, HTTP status codes, applicable RFCs, language/platform specs, established formats (JSON/YAML/TOML/OpenAPI/semver/ISO 8601). Don't invent new codes, headers, error schemes, or wire protocols when a standard exists
13. **No scope creep** - No unrequested features, files, or abstractions. Implicit scope is OK: "parity with X" or "replace Y" includes all of X/Y's features, plus the plumbing (routes, APIs, schemas, DB tables, internal modules) needed to make those features work. Features != plumbing -- match the feature set, build the plumbing it needs
14. **Edit, don't rewrite** - Targeted edits over full-file rewrites unless asked
15. **Required deps OK; ask on choices** - Add necessary dependencies without asking. Ask first only when (a) meaningful choice between viable alternatives, (b) introduces a new external service, or (c) conflicts with project principles (e.g., adds telemetry)

## Verification & Safety
16. **Confirm destructive ops** - Pause before `rm -rf`, force pushes, dropping tables, deleting branches, anything irreversible
16a. **Never run unrequested destructive ops, even to "fix"** - Troubleshooting (credential mismatch, broken state, test/deploy failure) does NOT justify destructive fixes (delete volume, drop DB, wipe dir, force-push, terminate cloud resource, remove stateful container). Stop and ask. Blast radius on persistent state, cloud volumes, or shared infra is total. Ref: April 2026 PocketOS incident -- agent wiped prod DB + 3mo of backups in 9s while "fixing" a staging credential issue
16b. **Never auto-bypass a hook block** - If a PreToolUse hook returns `BLOCKED (TIER 2)`, do NOT retry with `# CONFIRM_DESTRUCTIVE` appended. Tell the user what was blocked and what it would destroy; only the user adds the marker
17. **No fabricated APIs** - If unsure whether a function/flag/library exists, verify rather than invent
18. **Cite the source** - When referencing existing code, name the file and line; don't paraphrase from memory
19. **Fix in-scope, stop on out-of-control** - Fix code errors, config typos, missing flags, syntax. Stop only on: unreachable upstream, third-party outage, missing user credentials, network/hardware

## Self-Validation
20. **Run the code** - Don't deliver "done" without running it; actually run it, run tests, hit the endpoint
21. **Verify against ground truth** - UI: compare to design/screenshot. Logic: compare to expected output. Data: spot-check a sample
22. **Iterate until passing** - Don't stop at "compiles"; keep going until success criteria are met
23. **Define success up front** - Before non-trivial work, state what "done" looks like (test passes, output matches, lint clean)
24. **Add tests for new behavior** - For non-trivial functionality: add a test that fails before and passes after, then run it
25. **Reusable verification** - Where it makes sense, leave a script, integration test, or `make` target for the next iteration to self-verify
26. **Plan complex work first** - 3+ files, multi-step, or ambiguous: outline the plan first. In Claude Code, use plan mode
27. **One task per thread** - Don't fold an unrelated task into an in-progress conversation; start fresh

## Build & Execution Environment
28. **Rolling tags for dev tooling** - Build/dev images use the rolling tag (`golang:alpine`, `rust:alpine`, `node:alpine`, `python:alpine`); the point is current toolchain
29. **Never run built binaries on host** - Run inside a container. **Prefer Incus over Docker**
30. **Cross-platform default** - Target both `linux/amd64` and `linux/arm64` unless explicitly scoped to one
31. **Reproducible builds** - Builds happen in containers with declared toolchain images; never rely on what's installed on the host

## Project Defaults
32. **MIT license** - Default for new projects unless specified
33. **Single-binary deployment** - One self-contained binary, zero runtime deps; no scattered files/services/sidecars
34. **Sane defaults** - First-run with no config works for the common case; config is for tuning, not getting started
35. **No feature gating** - Full functionality available; no paywalls, "pro" tiers, premium features
36. **Telemetry opt-in; public endpoints OK as default** - Analytics (Piwik/Matomo, Plausible, GA) are configurable hooks, off until user supplies tracking ID/credentials. Public hosted + self-hostable services: hardcoding the public FQDN as default is fine, must be user-overridable. Never hardcode tracking IDs, site keys, or credentials
37. **Mobile-responsive web UIs** - Work on mobile from the start, not retrofitted
38. **Secure by design, invisible to user** - Security in code, not user-facing friction. Guard against SQLi, enumeration (uniform errors, constant-time compare), races, CSRF, XSS, SSRF, path traversal, IDOR, ReDoS, deserialization. No arbitrary password rules, captcha gauntlets, excessive re-verification
39. **Never hardcode secrets -- repos are public** - Assume all repos are public. Never commit passwords, API keys, tokens, certs, OAuth secrets, DB URIs with creds, internal hostnames/IPs, customer data, tracking codes. Use env vars, gitignored config, or secret manager. Scan for leaks before commit

## Output Style
40. **No filler preamble** - Skip "Great question!", "Certainly!", "I'd be happy to help"
41. **No reflexive agreement** - Don't say "you're absolutely right" before re-examining the claim
42. **No closing recap** - Don't summarize what was just done unless asked
42a. **Tight output budget** - Status updates (during multi-step work) or requested summaries: 1-3 sentences max. No headers/bullets/sections unless the task requires structured output. Output tokens cost 4-6x input -- terseness compounds across every turn
43. **Show diffs, not retellings** - For code changes, show the actual change, not prose
44. **No emojis unless asked** - Plain text by default
45. **Don't pause for "continue?"** - If next step is clear, do it. Pause only when genuinely blocked: real decision needed, missing info, or destructive-op confirmation
45a. **No AI attribution** - Never add `Co-Authored-By:`, AI-tool trailers, "Generated with X" footers, or any AI attribution to commits, PRs, code comments, anywhere. AI runs on behalf of the user, not as a contributor. Editing AI-config files (CLAUDE.md, settings.json, hooks, `.agent/*`) does NOT count as attribution -- the rule is about identity in metadata, not which files were touched

## Token & Context Discipline
46. **Use the Explore subagent for broad codebase searches** - Searches spanning 3+ files, unknown locations, or multiple naming conventions: dispatch via Explore. Don't grep-walk in main context -- the search results bloat conversation history forever. Direct `grep`/`find` is fine for one specific known target
47. **Read files narrowly** - For files >500 lines: use `offset`/`limit`, or grep first to find the slice. Don't load 2000 lines when you need 50
48. **Don't re-read after editing** - Edit/Write would have errored if the change failed; the harness tracks file state. No verification re-Read needed
49. **One run, then fix** - Run build/test once per change. Don't loop on flaky failures without a hypothesis; don't re-run to "see if it still fails"
50. **Parallelize independent research via subagents** - Multiple independent questions: spawn agents in parallel (single message, multiple Agent calls). Their context is isolated; only their summary returns to main
50a. **Haiku via Agent for trivial tasks** - Renames, format conversions, single-line edits, simple lookups, mechanical refactors: spawn via `Agent` with `model: "haiku"`. Haiku is ~3x cheaper than Sonnet and adequate for unambiguous work. Reserve Sonnet for tasks needing judgment, multi-file coordination, or design decisions

## Spec & Workflow (Spec Agent Protocol)
51. **Spec is source of truth** - SPECs are `AI.md`, TODOs are `TODO.AI.md`. Defer to these; flag drift, don't silently follow conversational direction
52. **`.agent/` layout** - Every project has `.agent/rules.md`, `.agent/state.json`, `.agent/changelog.md`
53. **Drift check every turn** - Before responding to a dev request, verify it matches active `AI.md` + `.agent/state.json`; flag divergence before acting
54. **Never build unspec'd features** - If a request isn't in spec, ask whether to update the spec first
55. **Keep `.agent/state.json` current** - Update on task start, completion, blockers, milestones
56. **Update changelog** - After substantive changes, log to `.agent/changelog.md`
57. **Capture learnings** - After completing a task, record reusable gotchas/conventions/patterns in `CLAUDE.md` or the relevant skill file

## Commit Workflow
58. **`gitcommit` is the only commit path** - Plain `git commit` and `git push` are denied. The `gitcommit` wrapper at `/usr/local/bin/gitcommit` signs, commits, AND pushes in one invocation. See rule 59 for the only correct invocation form. User pre-approved the workflow -- commit without asking each time, but verify the message before running
59. **Only invocation: `gitcommit --dir {dir} all`** - `{dir}` = the project root path. `all` is the ONLY command. Semantic types (`improved`, `new`, `fixes`, `docs`, `test`, `release`, etc.) and per-status types (`modified`, `deleted`, `renamed`, etc.) loop over changed files and produce one commit PER FILE -- never what we want. Message MUST be in `{dir}/.git/COMMIT_MESS` first. Never use `-m` / `--message` -- they bypass the file
60. **Pre-commit: status -> write -> re-read -> commit** - (1) `git status --porcelain` + `git diff --stat` to see actual changes. (2) Write COMMIT_MESS matching `git status` exactly: every changed file listed by path, each change described, no leftover content from prior commits, nothing missing. (3) Re-read to verify. (4) Run `gitcommit --dir {dir} all`. The wrapper deletes COMMIT_MESS on commit-success -- every commit starts fresh
61. **Format: `{emoji} Title <=64ch {emoji}` + body + `- path: change` bullets** - Emoji per type: ✨ feat / 🐛 fix / 📝 docs / 🎨 style / ♻️ refactor / ⚡ perf / ✅ test / 🔧 chore / 🔒 security / 🗑️ remove / 🚀 deploy / 📦 deps. (Rule 44 "no emojis" does not apply -- commit messages follow project convention)
62. **Cadence: small and often** - One logical change per commit. Diff spans unrelated subsystems -> split. Function + its test = one commit. Typo fix + the test catching it = one commit. Two unrelated fixes = two commits. Mid-task with files in inconsistent state: do NOT commit
63. **gitcommit pushes immediately, is irreversible** - Once it runs, the change is on the remote and visible. Wrong message -> wrong public history. To skip push: `touch .no_push` at repo root first (rare; confirm with user). Push failed (offline/no-remote): run `gitcommit push` later -- do NOT recreate COMMIT_MESS

---

# Project-Specific Extensions

The rules above are global. Everything below is specific to this repository
(bash script collection for sysadmin and dev tooling). Where this section
and the global rules touch the same topic, the global rules win.

---

## Code Standards

- **Functions**: prefix with `__` (e.g. `__my_function`)
- **Variables**: prefix with `{SCRIPTNAME}_` in uppercase (e.g. `CAPTIVE_AUTH_`)
- **Comments**: always ABOVE code — NEVER inline at end of line
- **Control flow**: prefer `if/else` over `&&`/`||` chains for readability
- **Newlines**: always add newline at end of file
- **Headers**: update `@@Version` (`YYYYMMDDHHMM-git`) and `@@Changelog` on every change
- **Line length**: if a complete command is ≤ 180 characters, write it on a single line — including pipelines (`cmd | cmd | cmd | cmd`). Only split when the line exceeds 180 characters, or when the command contains an embedded program that inherently spans lines (e.g. a multi-line `awk` or `sed` script).

---

## Bash Performance — No UUOC, Minimize Forks

Every `$(...)`, pipe, and external command spawns a subprocess. Prefer bash built-ins.

**File reading:**
```bash
# BAD
contents="$(cat file)"
cat file | grep pattern

# GOOD
contents="$(< file)"
grep pattern file
```

**Path manipulation — parameter expansion, NOT basename/dirname:**
```bash
# BAD
name="$(basename -- "$path")"
dir="$(dirname -- "$path")"

# GOOD
name="${path##*/}"      # basename
dir="${path%/*}"        # dirname
stem="${name%.ext}"     # strip extension
```

**String matching — `[[ ]]`, NOT `echo | grep`:**
```bash
# BAD
if echo "$var" | grep -q "pattern"; then

# GOOD
if [[ "$var" == *"pattern"* ]]; then
```

**Regex — `=~` + `BASH_REMATCH`, NOT `echo | grep -E`:**
```bash
if [[ "$url" =~ ^(https?):// ]]; then
  protocol="${BASH_REMATCH[1]}"
fi
```

**Splitting — parameter expansion, NOT `echo | cut`:**
```bash
# BAD:  echo "$ver" | cut -d. -f1
# GOOD: "${ver%%.*}"
```

**Parsing — `read`, NOT `cat | awk` when bash suffices:**
```bash
# BAD:  cat /proc/loadavg | awk '{print $1}'
# GOOD: read -r load1 load5 _ _ _ < /proc/loadavg
```

**Stdin — let tools read directly, do NOT `cat - |` into them:**
```bash
# BAD:  cat - | sed 's/x/y/'
# GOOD: sed 's/x/y/'
```

---

## Documentation Triple Sync

Every script change requires updating all three in the same commit:
1. `__help()` inside the script itself
2. `man/{script}.1`
3. `completions/_{script}_completions.bash`

---

## TODO.AI.md Workflow

Mandatory for 2+ tasks or any complex multi-step session.

**Format:**
```markdown
## Current Session Tasks
- [ ] Task 1
- [ ] Task 2

## Completed
- [x] Done task
```

**Lifecycle:**
1. User gives 2+ tasks → populate TODO.AI.md immediately (non-negotiable)
2. After each task → move it to Completed
3. All done → empty the file (keep the file; blank = "nothing outstanding")
4. Update AI.md session history entry
5. Write `.git/COMMIT_MESS` and commit

---

## Testing

- **Incus-first** (preferred per global rule 29)
- **Docker fallback** when Incus not available
- Always syntax-check: `bash -n bin/scriptname`
- Run `./bin/scriptname --help` to confirm help output

---

## Security (project additions)

- No `curl | sh` patterns
- Use `sudo tee` instead of redirect for privileged writes

---

## Architecture

- amd64 (x86\_64), arm64 (aarch64), arm (armv7l)

---

## Project Structure

```
bin/              scripts
functions/        shared function libraries
completions/      _{scriptname}_completions.bash
man/              {scriptname}.1
templates/        script generation templates
tests/            test scripts
containers/       Dockerfiles + compose
```

Config paths:
- User config: `~/.config/myscripts/{scriptname}/`
- Logs: `~/.local/log/{scriptname}/`

---

## File Management

**Project-level (always present):**
- `AI.md` — source of truth: global rules + project extensions + session history
- `CLAUDE.md` — thin pointer to AI.md; no content duplication

**Work-in-progress paired files:**
- `TODO.md` ↔ `TODO.AI.md` — task lists (human raw ↔ AI refined)
- `PLAN.md` ↔ `PLAN.AI.md` — design docs (same pattern)

Empty-when-done convention: blank file = "nothing outstanding." Never delete.
AI empties `TODO.AI.md` and `PLAN.AI.md` after committing completed work.

---

## Session History

### Session 2025-01-24: Git Log Enhancements & AI Workflow

Established AI workflow rules; enhanced gitcommit log, gen-changelog, gitadmin.
Created AI.md master context file. Added comment-above-code standard.

### Session 2026-01-13: setupmgr Unified Installation Refactoring

Fixed `__install_from_binary` arg-passing bug. Converted act + incus tools to
unified `__install_from_archive` / `__install_from_binary` helpers (40 lines → 3).

### Session 2026-01-14: Comprehensive Testing & Tool Removal

Tested all 95 converted setupmgr tools. Fixed zoxide strip-components bug and
tokei release fallback. Removed 6 tools with no available binaries.

### Session 2026-04-05: Fix dockermgr manifest command (Docker 25+)

Fixed platform names (x86_64 → amd64), empty `$amend` guard, `--amend` flag
misuse, `$oci_labels` word-splitting (string → bash array), BuildKit stdin
(`-` → `-f - .`).

### Session 2026-04-18: UUOC elimination across all 222 scripts

Universal: `APPNAME="${0##*/}"`, `${SUDO##*/}`, `__is_an_option` with `[[ ]]`.
Script-specific: sysusage, reqpkgs, proxmox-cli, pastebin, buildx, gen-nginx,
dictionary, notifications. All 222 pass `bash -n`. Added UUOC rule to AI.md.

### Session 2026-04-19: UUOC elimination in templates/ (shebang-aware)

Applied bash-only rewrites to 23 of 37 bash templates. Skipped sh/fish/zsh.
Fixed gen-script heredoc generators so newly generated scripts start clean.

### Session 2026-04-24: Completion extensions + setupmgr AI installer fixes

Renamed all 242 completions to `.bash` extension. Fixed copilot (npm →
native binary), ollama (.tar.zst, zstd pre-flight, rm footgun in
`__basename`), claude output format, openclaw added. Hardened all
`__download_*` wrappers to validate url before setting temp-file vars.

### Session 2026-04-24 (cont): 13-package test — 5 bugs found and fixed

Install/update/remove lifecycle tested on 13 packages. Fixed: ollama zstd
detection, claude/copilot dispatcher arg-leak, output format standardisation,
ripgrep→rg name map, claude/ollama/openclaw remove state cleanup.
Added `__remove_npm_global` helper and `__is_package_installed` map.

### Session 2026-05-01 → 2026-05-04: Cloudflare hardening + apimgr build (v1→v18)

Cloudflare: auth/DNS bugs, timeout guards, `__cf_fqdn` wildcard fix, IPv6
reconciliation. apimgr: built from stub to 3000+ line script covering
18 providers (artifactory, bitbucket, cloudsmith, codeberg, docker, forgejo,
gitea, gitee, ghcr, github, gitlab, glcr, harbor, nexus, onedev, pagure,
quay, sourcehut). Pure env-var mapping, per-provider auth wrappers,
single `__apimgr_curl` source.

### Session 2026-05-04: buildx — silent output + Ctrl+C fix

Removed `&>/dev/null` from all 5 build pipelines; added `__trap_int`;
changed `--progress auto` → `--progress plain`; UUOC fixes in
`__complete_url` and `__parse_dockerfile_labels`.

### Session 2026-05-04 (cont): buildx — log path + init log

Log path derived from `push_tag` via parameter expansion instead of git-dir
org. `mkdir` double-prefix fixed. Init log split to `init.log`.
UUOC fixes in `__set_variables`.

### Session 2026-05-08: pkmgr/detectostype fixes, container testing, captive-auth

- `bin/detectostype`: `VERSION_ID=` fallback for Alpine; `__detectostype_sourced`
  guard to prevent sourced script from hijacking parent args / calling exit.
- `bin/pkmgr`: sourcing guard, `__exec_unbuffered` bash -c fix for busybox script,
  `__show_info notruncate` fix, `__pkmgrbrokenkeyfix` / `__keys_init` / `__keys_reinstall`
  for apk, `pip check exitCode` fix.
- `man/pkmgr.1` + `completions/_pkmgr_completions.bash`: full sync with script.
- `install.sh`: `systemctl enable --now vnstat` guarded with `[ -d /run/systemd/system ]`;
  manager `--config` loop and network helpers wrapped with `timeout`.
- `containers/Dockerfile.arch`: base image `casjaysdev/archlinux`, COPY from
  build context (git clone has SSL issues in Docker build network for this image).
- `containers/docker-compose.yml`: all 6 distros added, `tty: true` + `stdin_open: true`.
- `bin/captive-auth` + `man/captive-auth.1` + `completions/_captive_auth_completions.bash`:
  added from detecthotspot project.

