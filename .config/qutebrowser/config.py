# Autogenerated config.py
# Documentation:
#   qute://help/configuring.html
#   qute://help/settings.html

# Uncomment this to still load settings configured via autoconfig.yml
config.load_autoconfig()

# Aliases for commands. The keys of the given dictionary are the
# aliases, while the values are the commands they map to.
# Type: Dict
c.aliases = {'q': 'quit', 'w': 'session-save', 'wq': 'quit --save'}
c.content.host_blocking.whitelist = ['piwik.org']
# c.url.searchengines = { 'DEFAULT': 'http://localhost:8888/?q={}', 'google': 'http://localhost:8888/?q={}', 'github': 'https://github.com/search?q={}', 'searx': 'https://searx.me/?q={}'}
c.url.searchengines = { 'DEFAULT': 'https://google.com/search?q={}', 'google': 'https://google.com/search?q={}', 'github': 'https://github.com/search?q={}', 'searx': 'https://searx.me/?q={}'}
c.tabs.last_close = 'close'


# import glob

# c.content.user_stylesheets = glob.glob('/home/amos/css/*.user.css')
c.hints.next_regexes.insert(0, r'»')
c.hints.prev_regexes.insert(0, r'«')
c.hints.next_regexes.append(r'下一页')
c.hints.prev_regexes.append(r'上一页')
c.hints.next_regexes.append(r'>>')
c.hints.prev_regexes.append(r'<<')


# Bindings for normal mode
config.bind('<Escape>', c.bindings.default['normal']['<Escape>'] + ';; fake-key <Escape> ;; jseval --quiet document.getSelection().empty()')
config.bind('<Ctrl-Space>', 'spawn i3-msg focus right')
config.bind('<Space>', 'fake-key <Space>')
config.bind('<Ctrl-b>', 'navigate prev')
config.bind('<Ctrl-f>', 'navigate next')
config.bind('<Ctrl-i>', 'forward')
config.bind('<Ctrl-o>', 'back')
config.bind('<Ctrl-r>', 'undo')
config.bind('<Ctrl-u>', 'spawn --userscript pbpst')
config.bind('<alt+a>', 'fake-key <Ctrl+a>')
config.bind('I', 'tab-close')
config.bind('p', 'open -t -- {clipboard}')
config.bind('<Shift-Insert>', 'open -t -- {clipboard}')
config.bind('u', 'scroll-page 0 -0.5')
config.bind('d', 'scroll-page 0 0.5')
config.bind('k', 'scroll-page 0 -0.1')
config.bind('j', 'scroll-page 0 0.1')
config.bind('y', 'yank')
config.bind('co', 'download-open')
config.bind('O', 'spawn fcitx-remote -c ;; set-cmd-text :open {url:pretty}')
config.bind('T', 'spawn fcitx-remote -c ;; set-cmd-text :open -t -r {url:pretty}')
config.bind('t', 'spawn fcitx-remote -c ;; set-cmd-text -s :open -t')
config.bind('s', 'spawn fcitx-remote -c ;; set-cmd-text -s :open -t google ')
config.bind('gs', 'spawn fcitx-remote -c ;; set-cmd-text -s :open -t github ')

# Bindings for command mode
config.bind('<Ctrl-D>', 'rl-delete-char', mode='command')
config.bind('<Ctrl-i>', 'completion-item-focus next', mode='command')
config.bind('<Ctrl-J>', 'completion-item-focus next', mode='command')
config.bind('<Ctrl-K>', 'completion-item-focus prev', mode='command')
config.bind('<Ctrl-O>', 'rl-kill-line', mode='command')

# Bindings for prompt mode
config.bind('<Ctrl-D>', 'rl-delete-char', mode='prompt')
config.bind('<Ctrl-J>', 'prompt-item-focus next', mode='prompt')
config.bind('<Ctrl-K>', 'prompt-item-focus prev', mode='prompt')
config.bind('<Ctrl-O>', 'rl-kill-line', mode='prompt')

config.bind('<Escape>', 'leave-mode ;; fake-key <Escape>', mode='insert')
config.bind('<Enter>', 'fake-key <Return>', mode='insert')
config.bind('<ctrl+a>', 'fake-key <Home>', mode='insert')
config.bind('<ctrl+e>', 'fake-key <End>', mode='insert')
config.bind('<alt+a>', 'fake-key <Ctrl+a>', mode='insert')
config.bind('<alt+b>', 'fake-key <Ctrl+Left>', mode='insert')
config.bind('<alt+f>', 'fake-key <Ctrl+Right>', mode='insert')
config.bind('<alt+d>', 'fake-key <Ctrl+Delete>', mode='insert')
config.bind('<alt+backspace>', 'fake-key <Ctrl+Left>;; fake-key <Ctrl+Delete>', mode='insert')
config.bind('<ctrl+w>', 'fake-key <Ctrl+Left>;; fake-key <Ctrl+Delete>', mode='insert')
config.bind('<ctrl+d>', 'fake-key <Delete>', mode='insert')
config.bind('<ctrl+b>', 'fake-key <Left>', mode='insert')
config.bind('<ctrl+f>', 'fake-key <Right>', mode='insert')
config.bind('<ctrl+j>', 'fake-key <Down>', mode='insert')
config.bind('<ctrl+k>', 'fake-key <Up>', mode='insert')
config.bind('<ctrl+i>', 'fake-key <Tab>', mode='insert')
config.bind('<ctrl+u>', 'fake-key <Shift+Home>;; fake-key <BackSpace>', mode='insert')
config.bind('<ctrl+o>', 'fake-key <Shift+End>;; fake-key <Delete>', mode='insert')

config.bind('<ctrl+q>', ':jseval --quiet --file ./ctrlu.js', mode='insert')
config.bind('<ctrl+x>', ':jseval --quiet --file ./ctrlk.js', mode='insert')
