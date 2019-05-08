from subprocess import Popen
from pywinauto import Desktop
from pywinauto.timings import Timings

Timings.slow()
Timings.window_find_timeout = 90

def launch_ts():
    app = Desktop(backend="uia").window(title_re="TradeStation.*")
    if not app.exists():
        Popen('C:/Program Files (x86)/TradeStation 9.5/Program/ORPlat.exe', shell=True)
        app.wait('visible')
        app.UserNameEdit.set_edit_text('{{ pillar['tsusername'] }}')
        app.PasswordEdit.set_edit_text('{{ pillar['tspassword'] }}')
        app.Login.click()
        app.Main.wait('visible')

    return app


if __name__ == "__main__":

    app = launch_ts()
    import ipdb; ipbd.set_trace()