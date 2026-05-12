# Installer Template Standardization

Goal: match all `templates/scripts/installers/*.sh` to the shell template standard
(PRINTF_SET_* vars, __printf_color(), __printf_space(), UUOC fixes).
Preserve existing layout/formatting. dockermgr.sh (3269 lines) handled separately.

## Standard group: hakmgr, desktopmgr, devenvmgr, dfmgr, systemmgr

- [x] hakmgr.sh — add __printf_color(), fix UUOC helper functions
- [x] desktopmgr.sh — same as hakmgr
- [x] devenvmgr.sh — same + add missing "# Define custom functions" comment
- [x] dfmgr.sh — same + add comment + change default color CYAN→WHITE
- [x] systemmgr.sh — same as hakmgr

UUOC fixes to apply to all five:
- __total_memory(): drop grep | awk → awk '/[Mm]em:/{print $2; exit}'
- __get_pid(): remove redundant -F ' ' from awk
- __port_in_use(): merge two awk commands into one
- __get_user_name(): drop leading grep, pass file to awk directly
- __get_user_group(): drop leading grep, pass file to awk directly

## Small group: fontmgr, iconmgr, thememgr, wallpapermgr

- [x] fontmgr.sh — add PRINTF_SET_*, __printf_color(), __printf_space()
- [x] iconmgr.sh — same
- [x] thememgr.sh — same
- [x] wallpapermgr.sh — same

## personal.sh

- [x] personal.sh — add PRINTF_SET_*, __printf_color(), __printf_space()
                    add connect_test() + elif branch in import block
                    fix bare systemctl → \systemctl
                    fix __get_pid awk -F ' ' → awk

## Commit

- [ ] Write .git/COMMIT_MESS and run gitcommit all
