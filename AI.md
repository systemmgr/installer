# AI.md — HOW

This file answers **how** things are done in this project.
Rules and communication behavior: see the rules file in the repo root.
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

```
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
gitcommit {subcommand}
```

`gitcommit` signs, commits, and pushes in one shot. The wrapper deletes `COMMIT_MESS` on success.

### Subcommand reference

| Subcommand | Stages |
|---|---|
| `all` | everything (`git add -A`) |
| `bin` | `bin/` only |
| `modified` | tracked modified files |
| `new` | untracked files only |

Use `all` when changes span multiple directories. Use `bin` for script-only changes.

### Forbidden

- `git commit` (plain) — skips signing
- `git push` (plain) — use `gitcommit push` to push without committing
- `gitcommit ai` / `gitcommit random` / `gitcommit custom` — bypass the message file
- `-m`/`--message` flag — always use COMMIT_MESS

### Commit message format

```
{type}({scope}): {subject} — <=72 chars total

{body: what and why, not how}

- {path}: {one-line description of change}
```

Types: `feat` / `fix` / `docs` / `style` / `refactor` / `perf` / `test` / `chore`

One logical change per commit. Unrelated changes = separate commits. Never commit mid-task with files in an inconsistent state.

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

Scripts in `bin/` are moving to fully self-contained (no external functions file dependency). Rules for standalone scripts:

- Must inline the full `printf_color` + `printf_*` block (not sourced from `mgr-installers.bash`)
- Must define all `__` helper functions they use
- Network fetches, version checks, heavy I/O: only run inside the specific `case` branch that needs them — never unconditionally at startup
- `__sleep` must use `sleep N` — `read -t N _ </dev/null` returns immediately on EOF and is a no-op

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
1. User gives 2+ tasks -> create `TODO.AI.md` immediately
2. After each task -> move to Completed
3. All done -> empty the file (keep the file; blank = nothing outstanding)
4. Update session history in this file
5. Write `.git/COMMIT_MESS` and commit

---

## Testing

- Syntax check first: `bash -n bin/{script}`
- Run `bin/{script} --help` to confirm help output renders without errors
- Run the specific subcommand being changed in a real shell
- Incus-first for full integration testing; Docker fallback when Incus unavailable

---

## Security Additions

- No `curl | sh` patterns
- Use `sudo tee` instead of redirect for privileged writes
- Never hardcode secrets — all repos are public

---

## Session History

### Session 2025-01-24: Git Log Enhancements & AI Workflow

Established AI workflow rules; enhanced gitcommit log, gen-changelog, gitadmin.
Created AI.md master context file. Added comment-above-code standard.

### Session 2026-01-13: setupmgr Unified Installation Refactoring

Fixed `__install_from_binary` arg-passing bug. Converted act + incus tools to
unified `__install_from_archive` / `__install_from_binary` helpers (40 lines -> 3).

### Session 2026-01-14: Comprehensive Testing & Tool Removal

Tested all 95 converted setupmgr tools. Fixed zoxide strip-components bug and
tokei release fallback. Removed 6 tools with no available binaries.

### Session 2026-04-05: Fix dockermgr manifest command (Docker 25+)

Fixed platform names (x86_64 -> amd64), empty `$amend` guard, `--amend` flag
misuse, `$oci_labels` word-splitting (string -> bash array), BuildKit stdin
(`-` -> `-f - .`).

### Session 2026-04-18: UUOC elimination across all 222 scripts

Universal: `APPNAME="${0##*/}"`, `${SUDO##*/}`, `__is_an_option` with `[[ ]]`.
Script-specific: sysusage, reqpkgs, proxmox-cli, pastebin, buildx, gen-nginx,
dictionary, notifications. All 222 pass `bash -n`. Added UUOC rule to AI.md.

### Session 2026-04-19: UUOC elimination in templates/ (shebang-aware)

Applied bash-only rewrites to 23 of 37 bash templates. Skipped sh/fish/zsh.
Fixed gen-script heredoc generators so newly generated scripts start clean.

### Session 2026-04-24: Completion extensions + setupmgr installer fixes

Renamed all 242 completions to `.bash` extension. Fixed copilot (npm ->
native binary), aicli output format, openclaw added. Hardened all
`__download_*` wrappers to validate url before setting temp-file vars.

### Session 2026-04-24 (cont): 13-package test — 5 bugs found and fixed

Install/update/remove lifecycle tested on 13 packages. Fixed: ollama zstd
detection, aicli/copilot dispatcher arg-leak, output format standardisation,
ripgrep->rg name map, aicli/ollama/openclaw remove state cleanup.
Added `__remove_npm_global` helper and `__is_package_installed` map.

### Session 2026-05-01 -> 2026-05-04: Cloudflare hardening + apimgr build (v1->v18)

Cloudflare: auth/DNS bugs, timeout guards, `__cf_fqdn` wildcard fix, IPv6
reconciliation. apimgr: built from stub to 3000+ line script covering
18 providers (artifactory, bitbucket, cloudsmith, codeberg, docker, forgejo,
gitea, gitee, ghcr, github, gitlab, glcr, harbor, nexus, onedev, pagure,
quay, sourcehut). Pure env-var mapping, per-provider auth wrappers,
single `__apimgr_curl` source.

### Session 2026-05-04: buildx — silent output + Ctrl+C fix

Removed `&>/dev/null` from all 5 build pipelines; added `__trap_int`;
changed `--progress auto` -> `--progress plain`; UUOC fixes in
`__complete_url` and `__parse_dockerfile_labels`.

### Session 2026-05-04 (cont): buildx — log path + init log

Log path derived from `push_tag` via parameter expansion instead of git-dir
org. `mkdir` double-prefix fixed. Init log split to `init.log`.
UUOC fixes in `__set_variables`.

### Session 2026-05-08: pkmgr/detectostype fixes, container testing, captive-auth

- `bin/detectostype`: `VERSION_ID=` fallback for Alpine; `__detectostype_sourced`
  guard to prevent sourced script from hijacking parent args / calling exit.
- `bin/pkmgr`: sourcing guard, `__exec_unbuffered` bash -c fix for busybox script,
  `__show_info notruncate` fix, key management helpers for apk, `pip check exitCode` fix.
- `man/pkmgr.1` + `completions/_pkmgr_completions.bash`: full sync with script.
- `install.sh`: `systemctl enable --now vnstat` guarded; manager `--config` loop
  and network helpers wrapped with `timeout`.
- `containers/Dockerfile.arch`: base image `casjaysdev/archlinux`, COPY from build context.
- `containers/docker-compose.yml`: all 6 distros added, `tty: true` + `stdin_open: true`.
- `bin/captive-auth` + man page + completions: added from detecthotspot project.

### Session 2026-05-13: composemgr fixes, tmux-new PREFIX+N, printf_ inline, bug audit

- `bin/composemgr`: 10 bugs fixed (curl -O->-o, .env.sample->default.env.sample,
  empty sed pattern, invalid grep BRE, push case calling pull, etc.).
  Added init.sh execution hook after env file generation.
- `composemgr/.github/example/*`: aligned default.env.sample, app.env.sample,
  docker-compose.yaml with actual script output.
- `templates/tmux/new.conf`: fixed PREFIX+N (`--name %1` flag); replaced
  `bind-key t new-window` with `unbind-key t` (sidebar plugin owns it).
- `bin/anonymize`, `bin/gen-playlist`, `bin/update-lecerts`: inserted full
  `printf_*` inline block; self-contained scripts missing color function
  definitions caused "command not found" at runtime.
- `bin/anonymize`: `__init_versions` moved from unconditional startup into
  install-only case branches. `__monitor_connections`: fixed screen-clear
  placement, added LAN device section (`ip neigh`/`arp -n`), fixed `__sleep`
  (was a no-op via /dev/null), set 5s refresh interval.
- `bin/dotfiles`: `exit #?` -> `exit $?` (13 branches), `shist 1` -> `shift 1`.
- `bin/randomwallpaper`: `printf_head` -> `__printf_head`, removed stray
  `shift 1` inside menu loop.
- `bin/zellij-new`: removed stray trailing `'` from two comment separator lines.
- Spec restructured into three files: rules / how (AI.md) / what (IDEA.md).
