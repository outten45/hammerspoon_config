
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

-- left most
hs.hotkey.bind(hyper, "g", function() posFullHeight(0.7, false) end)
-- right most
hs.hotkey.bind(hyper, "r", function() posFullHeight(0.7, true) end)

-- left half
hs.hotkey.bind(hyper, "t", function() posFullHeight(0.5, false) end)
-- full screen
hs.hotkey.bind(hyper, "n", function() posFullHeight(1.0, false) end)
-- right half
hs.hotkey.bind(hyper, "s", function() posFullHeight(0.5, true) end)


---------------------------------------
-- from https://github.com/cmsj/hammerspoon-config/blob/master/init.lua
-- I always end up losing my mouse pointer, particularly if it's on a monitor full of terminals.
-- This draws a bright red circle around the pointer for a few seconds
function mouseHighlight()
    if mouseCircle then
        mouseCircle:delete()
        if mouseCircleTimer then
            mouseCircleTimer:stop()
        end
    end
    mousepoint = hs.mouse.getAbsolutePosition()
    mouseCircle = hs.drawing.circle(hs.geometry.rect(mousepoint.x-40, mousepoint.y-40, 80, 80))
    mouseCircle:setStrokeColor({["red"]=1,["blue"]=0,["green"]=0,["alpha"]=1})
    mouseCircle:setFill(false)
    mouseCircle:setStrokeWidth(5)
    mouseCircle:bringToFront(true)
    mouseCircle:show(0.5)

    mouseCircleTimer = hs.timer.doAfter(3, function()
        mouseCircle:hide(0.5)
        hs.timer.doAfter(0.6, function() mouseCircle:delete() end)
    end)
end
hs.hotkey.bind(hyper, 'd', mouseHighlight)


hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", reloadConfig)
hs.notify.new({title="Hammerspoon", informativeText="Reloaded config."}):send()
