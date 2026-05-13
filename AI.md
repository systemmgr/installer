# AI.md — HOW

This file answers **how** things are done in this project.
Rules and communication behavior: see the global user rules file.
What the project is: see `IDEA.md`.

---

## Session Startup Checklist

Every session, in order:
1. Read `IDEA.md` — understand what the project is
2. Read this file (`AI.md`) — understand how to work
3. Check `TODO.AI.md` if it exists — resume in-flight tasks
4. `git status` + `git log -5` — current working tree state

---

## AI Behavior & Autonomy

- Read files, run `bash -n`, check `git status`, run `--help` — do these without asking
- Question marks are questions. Answer or clarify; don't execute
- Don't expand scope beyond what was asked. Note related issues; don't fix them without being asked
- When 2+ tasks are given, populate `TODO.AI.md` immediately

---

## Understanding User Intent

- `{name}` in a command or path = placeholder to substitute
- `name` without braces = literal text
- "We are working on X" = sets the active working set until user redirects
- "We are moving to Y" / "we need to fix Z" = redirect

---

## Git & Commit Workflow

### The only commit path

```bash
# 1. Check what changed
git status --porcelain
git diff --stat

# 2. Write the commit message
cat > .git/COMMIT_MESS << 'EOF'
{subject line <=72 chars}

{body - what changed and why}

- {file}: {change description}
- {file}: {change description}
EOF

# 3. Commit + push
gitcommit all
```

`gitcommit` signs, commits, and pushes in one shot. The wrapper deletes
`COMMIT_MESS` on success.

**Key behavior:** when `.git/COMMIT_MESS` exists, `gitcommit` stages ALL
changed files regardless of which subcommand is passed. Use `all` as the
standard subcommand.

### Subcommand reference

| Subcommand | Effect |
|---|---|
| `all` | stage everything + commit using COMMIT_MESS |
| `push` | push without committing (no COMMIT_MESS needed) |

### Forbidden

- `git commit` (plain) — skips signing
- `git push` (plain) — use `gitcommit push` to push without committing
- `gitcommit ai` / `gitcommit random` / `gitcommit custom` — bypass the message file
- `-m`/`--message` flag — always use COMMIT_MESS

### Commit message format

```
{emoji} {subject} — <=72 chars total {emoji}

{body: what and why, not how}

- {path}: {one-line description of change}
```

Emoji map: ✨ feat · 🐛 fix · 📝 docs · 🎨 style · ♻️ refactor · ⚡ perf
           ✅ test · 🔧 chore · 🔒 security · 🗑️ remove · 🚀 deploy · 📦 deps

One logical change per commit. Unrelated changes = separate commits.
Never commit mid-task with files in an inconsistent state.

---

## Code Standards

### Naming

- Functions: `__` prefix — `__my_function`
- Variables: `{SCRIPTNAME}_` prefix in uppercase — `CAPTIVE_AUTH_TIMEOUT`
- Local variables: `local varname` inside functions

### Comments

- Always **above** the code they describe — never inline at end of line
- One line max; describe WHY not WHAT

### Versioning

- Format: `YYYYMMDDHHMM-git`
- Locations: `##@Version` header line AND `VERSION=` variable (first occurrence only)
- Bump both on every change; templates contain `GEN_SCRIPT_REPLACE_VERSION` — leave those alone

### Shellcheck disable

Single combined line, full canonical set — never split across multiple lines:

```bash
# shellcheck disable=SC1001,SC1003,SC2001,SC2003,SC2016,SC2031,SC2090,SC2115,SC2120,SC2155,SC2199,SC2229,SC2317,SC2329
```

### Control flow

- Prefer `if/else` over `&&`/`||` chains for readability
- Always add a newline at end of file

### Line length

- <= 180 characters: write on a single line, including pipelines
- > 180 characters, or contains a multi-line embedded program (awk/sed script): split

---

## Bash Performance — No UUOC, Minimize Forks

Every `$(...)`, pipe, and external command spawns a subprocess. Prefer bash builtins.

### File reading

```bash
# BAD
contents="$(cat file)"
cat file | grep pattern

# GOOD
contents="$(< file)"
grep pattern file
```

### Path manipulation

```bash
# BAD
name="$(basename -- "$path")"
dir="$(dirname -- "$path")"

# GOOD
name="${path##*/}"      # basename
dir="${path%/*}"        # dirname
stem="${name%.ext}"     # strip extension
```

### String matching

```bash
# BAD
if echo "$var" | grep -q "pattern"; then

# GOOD
if [[ "$var" == *"pattern"* ]]; then
```

### Regex

```bash
if [[ "$url" =~ ^(https?):// ]]; then
  protocol="${BASH_REMATCH[1]}"
fi
```

### Splitting

```bash
# BAD:  echo "$ver" | cut -d. -f1
# GOOD: "${ver%%.*}"
```

### Parsing

```bash
# BAD:  cat /proc/loadavg | awk '{print $1}'
# GOOD: read -r load1 _ _ _ _ < /proc/loadavg
```

### Stdin passthrough

```bash
# BAD:  cat - | sed 's/x/y/'
# GOOD: sed 's/x/y/'
```

---

## Self-Contained Scripts

Scripts in `bin/` are fully self-contained — no external functions file dependency. Rules:

- Must inline the full `printf_color` + `printf_*` block (not sourced from any lib)
- Must define all `__` helper functions they use
- Network fetches, version checks, heavy I/O: only run inside the specific `case` branch
  that needs them — never unconditionally at startup
- `__sleep` must use `sleep N` — `read -t N _ </dev/null` is a no-op on EOF

### Function inclusion rules

Only inline functions the script actually calls. Never carry over boilerplate functions
that the script does not use.

- **Sudo functions** (`requiresudo`, `__sudo`, `__sudorun`, `__sudoif`, `__can_i_sudo`,
  `__sudoask`, `__sudo_group`, `__user_is_root`, `__user_is_not_root`): include only if
  the script body actually calls them. Verify by grepping the script — do not rely on the
  `@@sudo/root` header field, which may be stale.
- **Installer/manager helpers** (`user_install`, `__options`, and similar external-lib
  entrypoints): never include — these belong to the external functions library, not to
  individual scripts.
- When migrating a script from sourced-lib to self-contained: audit every function defined
  in the script, grep for its call sites, and drop any function with zero call sites.

---

## Color & NO_COLOR

- `--no-color` flag sets `SHOW_RAW="true"` internally
- `NO_COLOR` env var is checked independently per no-color.org spec:
  `[ -n "${NO_COLOR+x}" ]` — handles set-to-empty correctly
- Colorization block: `if [ -n "${NO_COLOR+x}" ] || [ "$SHOW_RAW" = "true" ]; then`
- Early argv check (before getopt): `[ "$1" = "--no-color" ] && export SHOW_RAW="true"`

---

## Documentation Triple Sync

Every script change requires updating all three in the same commit:

1. `__help()` inside the script
2. `man/{script}.1`
3. `completions/_{script}_completions.bash`

---

## TODO.AI.md Workflow

Mandatory when 2+ tasks are given or the session is complex.

```markdown
## Current Session Tasks
- [ ] Task 1
- [ ] Task 2

## Completed
- [x] Done task
```

Lifecycle:
1. User gives 2+ tasks → create `TODO.AI.md` immediately
2. After each task → move to Completed
3. All done → empty the file (keep the file; blank = nothing outstanding)
4. Write `.git/COMMIT_MESS` and commit

---

## Testing

- Syntax check first: `bash -n bin/{script}`
- Run `bin/{script} --help` to confirm help output renders without errors
- Run the specific subcommand being changed in a real shell
- Incus-first for full integration testing; Docker fallback when Incus unavailable

---

## Security

- No `curl | sh` patterns — always download then inspect/verify before running
- Use `sudo tee` instead of redirect for privileged writes
- Never hardcode secrets — all repos are public
- No `bash -x` on code paths that build auth headers (`set -x` exposes tokens in stderr)
- No `--token`/`--api-key`/`--password` values in test commands (GitGuardian flags the pattern)

---

## Session History

Decisions and conventions established — not a work log.

- **2026-01**: Established AI workflow; `gitcommit` as sole commit path; comment-above-code standard
- **2026-01**: `__install_from_archive` / `__install_from_binary` unified helpers in setupmgr
- **2026-04**: UUOC elimination — `APPNAME="${0##*/}"`, bash builtins over forks, `[[ ]]` throughout
- **2026-04**: UUOC applied to templates/ (bash-only; sh/fish/zsh skipped)
- **2026-04**: All completions renamed to `.bash` extension
- **2026-05**: `__sleep` must use `sleep N` (read -t is a no-op on EOF)
- **2026-05**: `--raw` (color flag) renamed to `--no-color` everywhere; `NO_COLOR` env var support added
- **2026-05**: Shellcheck disable: single combined line, full canonical SC set
- **2026-05**: `gitcommit`: COMMIT_MESS presence triggers stage-all regardless of subcommand
- **2026-05**: gen-header structural update: 4 header fields restored (@@Other, @@Resource,
  @@Terminal App, @@sudo/root); boilerplate aligned to bash/system template
- **2026-05**: Self-contained migration rule: only inline functions the script calls; drop
  sudo functions when not used (verify by grep, not header); never include user_install,
  __options, or other external-lib entrypoints
