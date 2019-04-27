from pywinauto import Desktop
from pywinauto.timings import Timings

Timings.slow()
Timings.window_find_timeout = 30

def launch_ts_setup():
    app =Desktop(backend="uia").window(title_re='TradeStation 9.5 Setup Wizard')
    if not app.exists():
        Popen('C:\Users\Administrator\Downloads\TradeStation 9.5 Setup.exe', shell=True)
        app.wait('visible')

    return app


