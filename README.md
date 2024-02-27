# Q-Sys Dialog Controller Module

Q-Sys module to create a custom dialog by utilizing a UCI shared layer.

[![Luacheck](https://github.com/scsole/q-sys-module-dialog-controller/actions/workflows/luacheck.yml/badge.svg)](https://github.com/scsole/q-sys-module-dialog-controller/actions/workflows/luacheck.yml)

## Quick start

1. Clone or download this repository to the Modules directory: `git clone https://github.com/scsole/q-sys-module-dialog-controller.git dialog-controller`
2. Add the module to the project using Design Resources
3. Use the module **inside a UCI Script**

## Usage Example

Create a new dialog controller then call `ShowDialog` as required. `ShowDialog` operates very similarly to the
`Uci.ShowDialog` function (see the
[Uci](https://q-syshelp.qsc.com/Index.htm#Control_Scripting/Using_Lua_in_Q-Sys/Uci.htm) docs for details).

```lua
local DialogController = require('dialog-controller')

-- Create a new Dialog Controller instance

local sharedLayerName = "Dialog"
local buttonCtrls = {
    -- Trigger buttons
    Controls.Dialog_Btn_0,
    Controls.Dialog_Btn_1,
    Controls.Dialog_Btn_2,
    -- Add as required
}
local titleCtrl = Controls.Dialog_Title -- set to nil if unused, else use a UCI trigger button
local messageCtrl = Controls.Dialog_Message -- set to nil if unused, else use a UCI trigger button

local CustomDialog = DialogController:New(sharedLayerName, btnCtrls, titleCtrl, messageCtrl)

-- Show a dialog (Modified from Uci.ShowDialog docs)

ButtonText = {
  "Button 1 was pushed",
  "Button 2 was pushed",
  "Button 3 was pushed",
}

function UCIDialogHandler(choiceInt)
  print(choiceInt, ButtonText[choiceInt + 1])
  Controls.WhichButton.String = ButtonText[choiceInt + 1]
end

function ShowDialog()
  CustomDialog:ShowDialog(
    {
      Title = "UCI Dialog Titlebar",
      Message = "Which button would you like to push?",
      Buttons = {
        "Button 1",
        nil, -- nil or "" will hide the associated button
        "Button 3",
      },
      Handler = UCIDialogHandler,
    }
  )
end

Controls.ShowDialog.EventHandler = ShowDialog
```
