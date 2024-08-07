--- @module 'dialog-controller'
local DialogController = {}

local function showDialog(self)
  Uci.SetSharedLayerVisibility(self.LayerName, true, self.Transition)
end

local function hideDialog(self)
  Uci.SetSharedLayerVisibility(self.LayerName, false, self.Transition)
end

---Hide the dialog layer and initialize event handlers.
---@param self table The dialog controller table
local function initialize(self)
  hideDialog(self)

  self.Timer.EventHandler = function()
    if self.Handler then
      self.Handler(0)
    end
    self.Timer:Stop()
    hideDialog(self)
  end

  if self.Controls.Buttons and #self.Controls.Buttons > 0 then
    for i, btn in ipairs(self.Controls.Buttons) do
      btn.EventHandler = function()
        self.Timer:Stop()
        if self.Handler then
          self.Handler(i) -- Unlike the zero-based Q-Sys Dialog Handler, this is one-based
        end
        hideDialog(self)
      end
    end
  else
    print("[DialogController] Initialize: WARN: Controls.Buttons is nil or empty")
  end
end

---Create a new dialog controller instance.
---@param layerName string Name of the UCI shared layer used as a dialog
---@param buttonCtrls table List of button controls used as the dialog's options
---@param titleCtrl table? Optional text control used to display the dialog title
---@param messageCtrl table? Optional text control used to display the dialog message
---@return table # A new dialog controller instance
function DialogController:New(layerName, buttonCtrls, titleCtrl, messageCtrl)
  local obj = {
    Transition = "fade",
    LayerName = layerName,
    Controls = {
      Title = titleCtrl,
      Message = messageCtrl,
      Buttons = buttonCtrls,
    },
    Handler = nil,
    Timer = Timer.New(),
  }
  initialize(obj)
  self.__index = self
  return setmetatable(obj, self)
end

---Display a dialog using a shared layer in a UCI that contains an optional title, message, and custom buttons.
---@param dialogTable table A table consisting of `Buttons` (list of strings used as button legends), and optional
---fields: `Title` string, `Message` string, `Handler` (the dialog event handler function, one-based), `Timeout`
---(the time in seconds before automatically closing the dialog) and `Styles` (list of css classes used for dynamic)
---button styling). If the timeout is reached, then the event handler will be passed 0.
function DialogController:ShowDialog(dialogTable)
  if self.Controls.Title ~= nil and dialogTable.Title ~= nil then
    self.Controls.Title.String = dialogTable.Title
  end

  self.Timer:Stop()

  if self.Controls.Message ~= nil and dialogTable.Message ~= nil then
    self.Controls.Message.String = dialogTable.Message
  end

  self.Handler = dialogTable.Handler

  if self.Controls.Buttons ~= nil and dialogTable.Buttons ~= nil then
    if #self.Controls.Buttons < #dialogTable.Buttons then
      print(string.format(
        "[DialogController] ShowDialog: WARN: More button legends provided (%n) than available (%n)",
        #dialogTable.Buttons, #self.Controls.Buttons))
    end

    for i, btn in ipairs(self.Controls.Buttons) do
      if dialogTable.Buttons[i] and dialogTable.Buttons[i] ~= '' then
        btn.Legend = dialogTable.Buttons[i]
        btn.IsInvisible = false
        if dialogTable.Styles and dialogTable.Styles[i] then
          btn.CssClass = dialogTable.Styles[i]
        else
          btn.CssClass = ""
        end
      else
        btn.IsInvisible = true
      end
    end

    showDialog(self)

    if dialogTable.Timeout and dialogTable.Timeout > 0 then
      self.Timer:Start(dialogTable.Timeout)
    end
  else
    print("[DialogController] ShowDialog: WARN: No button legends provided or available, aborting dialog")
  end
end

return DialogController
