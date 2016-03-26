
-- Define some keyboard modifier variables
-- (Node: Capslock bound to cmd+alt+ctrl+shift via Seil and Karabiner)
local hyper = {"⌘", "⌥", "⌃", "⇧"}

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
  hs.notify.new({title="Hammerspoon", informativeText="Hello World"}):send()
end)

function launchApp(name)
  local r = hs.application.launchOrFocus(name)
  if not r then
    hs.notify.new({title="Hammerspoon", informativeText="Unable to launch/focus " .. name}):send()
  end
end

---------------------------------------
-- hotkey bindings for applications
hs.hotkey.bind(hyper, "u", function() launchApp("Google Chrome") end)
hs.hotkey.bind(hyper, "e", function() launchApp("Emacs") end)
hs.hotkey.bind(hyper, "f", function() launchApp("Firefox") end)
hs.hotkey.bind(hyper, "m", function() launchApp("Microsoft Outlook") end)
hs.hotkey.bind(hyper, "i", function() launchApp("/Users/outtenr/Applications/iTerm.app") end)
hs.hotkey.bind(hyper, "x", function() launchApp("Terminal") end)
hs.hotkey.bind(hyper, "o", function() launchApp("Jabber") end)
hs.hotkey.bind(hyper, "c", function() launchApp("Opera") end)
hs.hotkey.bind(hyper, "l", function() launchApp("Safari") end)
hs.hotkey.bind(hyper, "p", function() launchApp("Simplenote") end)
hs.hotkey.bind(hyper, ".", function() launchApp("Todoist") end)
hs.hotkey.bind(hyper, "y", function() launchApp("/Users/outtenr/Applications/Visual Studio Code.app") end)
hs.hotkey.bind(hyper, "8", function() launchApp("LimeChat") end)
hs.hotkey.bind(hyper, "9", function() launchApp("TiddlyDesktop") end)
hs.hotkey.bind(hyper, "b", function() hs.application.launchOrFocus("Atom") end)

function listAppTitles()
  hs.fnutils.each(hs.application.runningApplications(), function(app) print("[" .. app:title() .. "]") end)
end

function reloadConfig()
  hs.reload()
  listAppTitles()
end

---------------------------------------
-- positioning functions
function posFullHeight(percentUsed, moveRight)
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()
  local cur = screen:currentMode()

  if moveRight then
    f.x = max.x + (cur.w * (1.0 - percentUsed))
  else
    f.x = max.x
  end
  f.y = max.y
  f.w = max.w * percentUsed
  f.h = max.h
  win:setFrame(f)
end

hs.hotkey.bind(hyper, "r", function() posFullHeight(0.7, true) end)
hs.hotkey.bind(hyper, "g", function() posFullHeight(0.7, false) end)


hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", reloadConfig)
hs.notify.new({title="Hammerspoon", informativeText="Reloaded config."}):send()
