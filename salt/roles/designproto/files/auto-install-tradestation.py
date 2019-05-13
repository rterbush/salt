
from subprocess import Popen
from pywinauto import Desktop
from pywinauto.timings import Timings

Timings.slow()
Timings.window_find_timeout = 90

def launch_ts_setup():
    app = Desktop(backend="uia").window(title_re="TradeStation.*")
    if not app.exists():
        Popen('C:/temp/TradeStation 9.5 Setup.exe', shell=True)
        app.wait('visible')

    return app


if __name__ == "__main__":

    app = launch_ts_setup()
    app.Next.click()                # Begin installation
    app.Next.click()                # Accept install location

    if not app.CheckBox1.get_toggle_state():
        app.CheckBox1.toggle()      # Add shortcut to Desktop

    if not app.CheckBox2.get_toggle_state():
        app.CheckBox2.toggle()      # Add shortcut to Quicklaunch

    if not app.CheckBox3.get_toggle_state():
        app.CheckBox3.toggle()      # Set TradeStation background image

    app.Next.click()                # Start install process

    app.Continue.click()            # Begin update install process

    app.Finish.wait('visible')      # Wait for dialog to "Finish"

    if app.CheckBox.get_toggle_state():
        app.CheckBox.toggle()       # Uncheck start TradeStation

    app.Finish.click()              # Finished