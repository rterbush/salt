from subprocess import Popen
from pywinauto import Desktop
from pywinauto.timings import Timings

Timings.slow()
Timings.window_find_timeout = 120

strategies = 'C:\\Users\\TS\\Framework\\ELD\\000-BOS-SMART-CODE-V1.8.ELD'

def launch_ts():
    app = Desktop(backend="uia").window(title_re="TradeStation.*")
    if not app.exists():
        Popen('C:/Program Files (x86)/TradeStation 9.5/Program/ORPlat.exe', shell=True)
        app.wait('visible')
        app.UserNameEdit.set_edit_text('{{ tsuser }}')
        app.PasswordEdit.set_edit_text('{{ tspass }}')
        app.Login.click()

        # Need to start Online this first time in Simulated mode
        if not app.RadioButton2.get_toggle_state():
            app.RadioButton2.toggle()

        app.Main.wait('visible')

    return app


if __name__ == "__main__":

    app = launch_ts()
    app.MenuBar.type_keys('%FM')                                # Open Import Dialog
    app.Dialog.ListBox.ListItem2.select()                       # Select Import ELD Option
    app.Dialog.Next.click()

    # Hardcoding this file path for now while there is just one.
    # Will need to do something more clever as we have more strategies to import
    app.Dialog.ComboBox.Edit.set_edit_text(strategies)

    # Walk through dialogs
    app.Dialog.Next.click()
    app.Dialog.Next.click()
    app.Dialog.Finish.click()
    app.Dialog.Ok.click()

    app.MenuBar.type_keys('%FX')                                # Exit TradeStation

    if not app.CheckBox.get_toggle_state():                     # Turn off backups
        app.CheckBox.toggle()

    app.Dialog.No.click()                                       # Stop upgrade nagging
    app.ExitTradeStation.click()                                # Bye bye
