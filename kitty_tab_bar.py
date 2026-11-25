import os

from kitty.boss import get_boss
from kitty.fast_data_types import Screen, add_timer
from kitty.tab_bar import DrawData, ExtraData, TabBarData, draw_tab_with_powerline

SHELLS = {'bash', 'zsh', 'fish', 'sh', 'dash'}
SEPARATOR = ' │ '
HOME = os.path.expanduser('~')
_timer_started = False


def _dir_name(cwd):
    if not cwd:
        return '?'
    if cwd == HOME:
        return '~'
    return os.path.basename(cwd.rstrip('/')) or '/'


def _describe(window):
    try:
        cmdline = window.child.foreground_cmdline
        cwd = window.child.foreground_cwd
    except Exception:
        # the foreground process can exit between listing and reading /proc
        return window.title
    if not cmdline:
        return window.title
    exe = os.path.basename(cmdline[0]).lstrip('-')
    if exe in SHELLS:
        return _dir_name(cwd)
    if exe == 'claude':
        # Claude Code puts a short session topic into the window title
        title = window.title.strip()
        if title and title.lower() not in ('claude', 'claude code'):
            return title
        return exe
    arg = next((a for a in reversed(cmdline[1:]) if not a.startswith('-')), None)
    if arg:
        return f'{exe} {os.path.basename(arg.rstrip("/")) or arg}'
    return exe


def _tab_title(tab_id):
    tab = get_boss().tab_for_id(tab_id)
    if tab is None or tab.name:
        return None
    labels = []
    for window in tab:
        label = _describe(window)
        if labels and labels[-1][0] == label:
            labels[-1][1] += 1
        else:
            labels.append([label, 1])
    return SEPARATOR.join(f'{label}×{n}' if n > 1 else label for label, n in labels)


def _redraw(timer_id):
    for tm in get_boss().all_tab_managers:
        tm.mark_tab_bar_dirty()


def draw_tab(
    draw_data: DrawData, screen: Screen, tab: TabBarData,
    before: int, max_tab_length: int, index: int, is_last: bool,
    extra_data: ExtraData,
) -> int:
    global _timer_started
    if not _timer_started:
        # Titles here come from foreground processes, which kitty does not watch,
        # so without a periodic redraw the tab text goes stale after a command starts.
        add_timer(_redraw, 2.0, True)
        _timer_started = True
    title = _tab_title(tab.tab_id)
    if title:
        tab = tab._replace(title=title)
    return draw_tab_with_powerline(
        draw_data, screen, tab, before, max_tab_length, index, is_last, extra_data)
