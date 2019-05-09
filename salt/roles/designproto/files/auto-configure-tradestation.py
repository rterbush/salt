from subprocess import Popen
from pywinauto import Desktop
from pywinauto.timings import Timings

Timings.slow()
Timings.window_find_timeout = 120

def launch_ts():
    app = Desktop(backend="uia").window(title_re="TradeStation.*")
    if not app.exists():
        Popen('C:/Program Files (x86)/TradeStation 9.5/Program/ORPlat.exe', shell=True)
        app.wait('visible')
        app.UserNameEdit.set_edit_text('{{ tsuser }}')
        app.PasswordEdit.set_edit_text('{{ tspass }}')
        app.Login.click()

        if not app.RadioButton2.get_toggle_state():
            app.RadioButton2.toggle()

        app.Main.wait('visible')

    return app


if __name__ == "__main__":

    app = launch_ts()
    app.FileMenuItem.select()
    import ipdb; ipbd.set_trace()