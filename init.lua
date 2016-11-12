
-- Define some keyboard modifier variables
-- (Node: Capslock bound to cmd+alt+ctrl+shift via Seil and Karabiner)
local hyper = {"⌘", "⌥", "⌃", "⇧"}

-- **************************************************
-- A hack to get the hyper key to work on sierra
--   https://github.com/lodestone/hyper-hacks
--   http://brettterpstra.com/2016/09/29/a-better-hyper-key-hack-for-sierra/
-- A global variable for the Hyper Mode
k = hs.hotkey.modal.new({}, "F17")

-- Enter Hyper Mode when F18 (Hyper/Capslock) is pressed
pressedF18 = function()
   k.triggered = false
   k:enter()
end

-- Leave Hyper Mode when F18 (Hyper/Capslock) is pressed,
--   send ESCAPE if no other keys are pressed.
releasedF18 = function()
   k:exit()
   if not k.triggered then
      hs.eventtap.keyStroke({}, 'ESCAPE')
   end
end

-- Bind the Hyper key
f18 = hs.hotkey.bind({}, 'F18', pressedF18, releasedF18)
-- **************************************************


hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
  hs.notify.new({title="Hammerspoon", informativeText="Hello World"}):send()
end)

function setContains(set, key)
   return set[key] ~= nil
end

function launchApp(name, opts)
  local doLaunch = false
  if opts and opts.launch then
    doLaunch = opts.launch
  end
  if doLaunch then
    local r = hs.application.launchOrFocus(name)
    if not r then
      hs.notify.new({title="Hammerspoon", informativeText="Unable to launch/focus " .. name}):send()
    end
  else
    local app = hs.application.find(name)
    if app and app:mainWindow() then
      app:mainWindow():focus()
    else
      hs.notify.new({title="Hammerspoon", informativeText="Unable to focus " .. name .. " - maybe it isn't running."}):send()
    end
  end
end

-- local safariBrowser = "Safari"
local safariBrowser = "Safari Technology Preview"

---------------------------------------
-- bindings for applications
k:bind({}, "u", function() launchApp("Google Chrome") end)
k:bind({}, "e", function() launchApp("Emacs") end)
k:bind({}, "f", function() launchApp("Firefox") end)
k:bind({}, "m", function() launchApp("Microsoft Outlook") end)
k:bind({}, "i", function() launchApp("iTerm2") end)
k:bind({}, "x", function() launchApp("Terminal", {launch = true}) end)
k:bind({}, "o", function() launchApp("Jabber") end)
k:bind({}, "c", function() launchApp("Opera") end)
k:bind({}, "l", function() launchApp(safariBrowser) end)
k:bind({}, ".", function() launchApp("Todoist", {launch = true}) end)
k:bind({}, "y", function() launchApp("Code") end)
k:bind({}, "8", function() launchApp("LimeChat") end)
k:bind({}, "9", function() launchApp("TiddlyDesktop") end)
k:bind({}, "b", function() launchApp("Atom") end)
-- k:bind({}, "p", function() launchApp("Simplenote") end)
k:bind({}, "p", function() launchApp("Microsoft OneNote", {launch = true}) end)
k:bind({}, "3", function() launchApp("Vivaldi") end)

function listAppTitles()
  hs.fnutils.each(hs.application.runningApplications(), function(app) print("[" .. app:title() .. "]") end)
end

function reloadConfig()
  hs.reload()
  listAppTitles()
end

---------------------------------------
-- posFullHeight
--   Position window the full hight of the screen.
--   ratioUsed: ratio between 0 - 1.0
--   moveRight: move window to the right of screen
function posFullHeight(ratioUsed, moveRight)
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()
  local cur = screen:currentMode()

  if moveRight then
    f.x = max.x + (cur.w * (1.0 - ratioUsed))
  else
    f.x = max.x
  end
  f.y = max.y
  f.w = max.w * ratioUsed
  f.h = max.h
  win:setFrame(f)
end

-- left most
k:bind({}, "g", function() posFullHeight(0.7, false) end)
-- right most
k:bind({}, "r", function() posFullHeight(0.7, true) end)

-- left half
k:bind({}, "t", function() posFullHeight(0.5, false) end)
-- full screen
k:bind({}, "n", function() posFullHeight(1.0, false) end)
-- right half
k:bind({}, "s", function() posFullHeight(0.5, true) end)

-- bind right:ctrl;shift push right bar-resize:screenSizeX/3
-- bind left:ctrl;shift  push left  bar-resize:screenSizeX/3

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
k:bind({}, 'd', mouseHighlight)

k:bind({}, '1', function()
                 hs.alert.show(os.date("%x %X"))
                 -- local p = hs.geometry.point(100,100)
                 -- local r = hs.geometry.rect(100, 100, 300, 300)
                 -- d = hs.drawing.text(r, "date:" .. os.date("%x %X"))
                 -- d:setBehaviorByLabels({"canJoinAllSpaces", "stationary"}):setTextSize(11):sendToBack():show(0.5)
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", reloadConfig)
hs.notify.new({title="Hammerspoon", informativeText="Reloaded config."}):send()

----------------------------------------
-- toggel status in Cisco Jabber between Available and in a meeting
function toggleJabberMeetingStatus()
  local app = hs.application.find("Jabber")
  if not app then
    hs.notify.new({title="Hammerspoon", informativeText="Unable to find Cisco Jabber"}):send()
    return
  end

  local availableMenuStr =  {"File", "Status", "Available"}
  local meetingMenuStr =   {"File", "Status", "in a meeting"}

  local availableMenu = app:findMenuItem(availableMenuStr)
  local availableChecked = false

  if (availableMenu and availableMenu["ticked"]) then
    print("available checked")
    availableChecked = true
  else
    print("available not checked")
    print(availableMenu)
  end

  if availableChecked then
    app:selectMenuItem(meetingMenuStr)
    hs.notify.new({title="Status", informativeText="in a meeting"}):send()
  else
    app:selectMenuItem(availableMenuStr)
    hs.notify.new({title="Status", informativeText="Available"}):send()
  end
end

k:bind({}, '2', toggleJabberMeetingStatus)

----------------------------------------
-- screen saver to lock screen
hs.hotkey.bind({"cmd","alt","ctrl"}, "L", hs.caffeinate.startScreensaver)
