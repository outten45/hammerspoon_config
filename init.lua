
-- Define some keyboard modifier variables
-- (Node: Capslock bound to cmd+alt+ctrl+shift via Seil and Karabiner)
local hyper = {"⌘", "⌥", "⌃", "⇧"}

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

---------------------------------------
-- hotkey bindings for applications
hs.hotkey.bind(hyper, "u", function() launchApp("Google Chrome") end)
hs.hotkey.bind(hyper, "e", function() launchApp("Emacs") end)
hs.hotkey.bind(hyper, "f", function() launchApp("Firefox") end)
hs.hotkey.bind(hyper, "m", function() launchApp("Microsoft Outlook") end)
hs.hotkey.bind(hyper, "i", function() launchApp("iTerm2") end)
hs.hotkey.bind(hyper, "x", function() launchApp("Terminal", {launch = true}) end)
hs.hotkey.bind(hyper, "o", function() launchApp("Jabber") end)
-- hs.hotkey.bind(hyper, "c", function() launchApp("Opera") end)
hs.hotkey.bind(hyper, "l", function() launchApp("Safari") end)
hs.hotkey.bind(hyper, "p", function() launchApp("Simplenote") end)
hs.hotkey.bind(hyper, ".", function() launchApp("Todoist", {launch = true}) end)
hs.hotkey.bind(hyper, "y", function() launchApp("Code") end)
hs.hotkey.bind(hyper, "8", function() launchApp("LimeChat") end)
hs.hotkey.bind(hyper, "9", function() launchApp("TiddlyDesktop") end)
hs.hotkey.bind(hyper, "b", function() launchApp("Atom") end)

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
hs.hotkey.bind(hyper, "g", function() posFullHeight(0.7, false) end)
-- right most
hs.hotkey.bind(hyper, "r", function() posFullHeight(0.7, true) end)

-- left half
hs.hotkey.bind(hyper, "t", function() posFullHeight(0.5, false) end)
-- full screen
hs.hotkey.bind(hyper, "n", function() posFullHeight(1.0, false) end)
-- right half
hs.hotkey.bind(hyper, "s", function() posFullHeight(0.5, true) end)

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
hs.hotkey.bind(hyper, 'd', mouseHighlight)

hs.hotkey.bind(hyper, '1', function()
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

hs.hotkey.bind(hyper, '2', toggleJabberMeetingStatus)
