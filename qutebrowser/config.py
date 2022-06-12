import os

is_work  = os.environ.get('IS_WORK') != None

config.load_autoconfig(False)

config.set('content.cookies.accept', 'all', 'chrome-devtools://*')
config.set('content.cookies.accept', 'all', 'devtools://*')
config.set('content.headers.user_agent', 'Mozilla/5.0 ({os_info}; rv:90.0) Gecko/20100101 Firefox/90.0', 'https://accounts.google.com/*')
config.set('content.headers.user_agent', 'Mozilla/5.0 ({os_info}) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99 Safari/537.36', 'https://*.slack.com/*')

custom_stylesheet = '/home/tristan/Projects/dotfiles/qutebrowser/styles.css'
config.set('content.user_stylesheets', custom_stylesheet)
c.content.blocking.method = 'both'

config.set('content.javascript.enabled', is_work)
config.set('content.javascript.enabled', True, 'chrome-devtools://*')
config.set('content.javascript.enabled', True, 'devtools://*')
config.set('content.javascript.enabled', True, 'chrome://*/*')
config.set('content.javascript.enabled', True, 'qute://*/*')

js_sites = [
    'http://miniflux.surface.local',
    'http://kiwix.surface.local',
    'https://github.com',
    'https://social.linux.pizza',
    'https://duckduckgo.com',
    'https://app.element.io',
    'https://web.archive.org',
    'https://wallabag.tristanhavelick.com',
]

for site in js_sites:
    config.set('content.javascript.enabled', True, site)

config.set('content.javascript.can_access_clipboard', True, 'https://github.com')

okay_ad_sites = []
if is_work:
    okay_ad_sites = [
        '*://optimizely.com/*',
        '*://zaius.com/*',
    	'*://mixpanel.com/*',
    	'*://*.mixpanel.com/*',
    	'*://*.mxpnl.com/*',
        '*://cdnjs.cloudflare.com/*',
    	'*://*.optimizely.com/*',
    	'*://*.zaius.com/*',
    ]

config.set('content.blocking.whitelist', okay_ad_sites)

c.hints.chars = 'arstdhneio'
c.fonts.default_size = '11pt'

search_engines = {
    'DEFAULT': 'http://bangs.surface.local/{}',
    'wb': 'https://web.archive.org/web/*/{unquoted}',
}
if is_work:
    search_engines['DEFAULT'] = 'https://lite.duckduckgo.com/lite/?q={}'
config.set('url.searchengines', search_engines)

config.set('zoom.default', '115')
config.set('spellcheck.languages', ['en-US'])

config.bind('<', 'tab-prev')
config.bind('>', 'tab-next')
config.bind('!', 'tab-focus 1')
config.bind('@', 'tab-focus 2')
config.bind('#', 'tab-focus 3')
config.bind('$', 'tab-focus 4')
config.bind('%', 'tab-focus 5')
config.bind('^', 'tab-focus 6')
config.bind('&', 'tab-focus 7')
config.bind('*', 'tab-focus 8')
config.bind('(', 'tab-focus 9')
config.bind(')', 'tab-focus 10')
config.bind(',a', f'config-cycle content.user_stylesheets {custom_stylesheet} ""')
config.bind(',M', 'hint links spawn mpv {hint-url}')
config.bind(',m', 'spawn mpv {url}')
config.bind(',r', 'spawn --userscript readability')
config.bind(',S', 'hint links userscript proxify')
config.bind(',s', 'spawn --userscript proxify')
config.bind(',w', 'spawn /home/tristan/Projects/wallabag-tiny-cli/wallabag_tiny_cli.py add "{url}"')
config.bind('yf', 'hint links yank')

c.aliases = {'w': 'session-save', 'q': 'close', 'qa': 'quit', 'wq': 'quit --save', 'wqa': 'quit --save', '1': 'scroll-to-perc 0', '%': 'scroll-to-perc 100'}
