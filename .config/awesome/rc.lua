-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
local home_dir = os.getenv("HOME") 
local theme_dir = os.getenv("HOME") .. "/.config/awesome/themes/"
local freedesktop = require("freedesktop")
-- awesome-wm-widgets widgets.
local battery_widget = require("awesome-wm-widgets.battery-widget.battery")
local ram_widget = require("awesome-wm-widgets.ram-widget.ram-widget")
local volume_widget = require("awesome-wm-widgets.volume-widget.volume")
local brightness_widget = require("awesome-wm-widgets.brightness-widget.brightness")
local switcher = require("awesome-switcher")
-- default xrandr config
awful.spawn.with_shell("nm-applet &")
--awful.spawn.with_shell("ulauncher --hide-window &")
awful.spawn.with_shell("compton &")
-- Themes define colours, icons, font and wallpapers.
beautiful.init(theme_dir .. "custom/theme.lua")

-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

--------------------Variables--------------------

terminal = "kitty"
browser = "firefox"
work_browser = "Chromium"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor

-- Usually, Mod4 is the key with a logo between Control and Alt.
modkey = "Mod4"


--------------------Error Handling--------------------

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end

--------------------Layouts--------------------

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    awful.layout.suit.max,
}

--------------------Menu--------------------

-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mydisplaymenu = {
   { "Single Display", function() awful.spawn.with_shell("bash ~/.screenlayout/single.sh") end},
   { "Right - Dual Display", function() awful.spawn.with_shell("bash ~/.screenlayout/rightdouble.sh") end}, 
   { "Left - Dual Display", function() awful.spawn.with_shell("bash ~/.screenlayout/leftdouble.sh") end}, 
   { "Triple Display", function() awful.spawn.with_shell("bash ~/.screenlayout/triple.sh") end},
   { "Clone Primary Display", function() awful.spawn.with_shell("bash ~/.screenlayout/cloneonce.sh") end},
}

sessionmenu = {
   { "Shutdown", function() awful.spawn.with_shell("systemctl poweroff") end},
   { "Logout", function() awesome.quit() end},
   { "Lock", function() awful.spawn.with_shell("bash betterlockscreen -l dimblur") end},
   { "Human Mode", function() awful.spawn.with_shell("notify-send \"Sorry, human mode is still in developement.\"") end},
}

mymainmenu = freedesktop.menu.build({ 
   before = { 
     { "Awesome", myawesomemenu, beautiful.awesome_icon }, 
     { "Displays", mydisplaymenu}
     },
   after = {
     { "Terminal", terminal },
     { "Session", sessionmenu}
   }
})

--------------------Menu--------------------

-- Awesome launcher widget
mylauncher = awful.widget.launcher({ image = beautiful.down_arrow,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

--------------------Tasklist--------------------

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 350, height = 0} })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

--------------------Wallpaper Management--------------------

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end


-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)


--------------------Taglist Management--------------------

    -- Each screen has its own tag table.
    awful.tag({ "  : Home " }, s, awful.layout.layouts[1])

    awful.tag.add( "  : Term ", {
      layout = awful.layout.layouts[1],
      screen = s,
    })

    awful.tag.add( "  : w.w.w ", {
      layout = awful.layout.layouts[1],
      screen = s,
    })

    awful.tag.add( "  : Edit ", {
      layout = awful.layout.layouts[3],
      screen = s,
    })

    awful.tag.add( "  : Coms ", {
      layout = awful.layout.layouts[1],
      screen = s,
    })
    
    awful.tag.add( "  : Media", {
      layout = awful.layout.layouts[1],
      screen = s,
    })

-- Taglist management over --

    -- Create a promptbox for each screen
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.noempty,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = {
        layout = wibox.layout.flex.horizontal,
        awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        style = {
          shape_border_width = 1,
          --shape  = gears.shape.rounded_bar,
        },
        layout   = {
          spacing = 0,
          spacing_widget = {
            {
                forced_width = 0,
                shape        = gears.shape.rectangle,
                widget       = wibox.widget.separator
            },
            valign = 'center',
            halign = 'center',
            widget = wibox.container.place,
          },
          layout  = wibox.layout.fixed.horizontal
        },
        widget_template = {
          {
              {
                  {
                      {
                        id     = 'icon_role',
                        widget = wibox.widget.imagebox,
                      },
                      margins = 2,
                      widget  = wibox.container.margin,
                  },
                  {
                    id     = 'text_role',
                    widget = wibox.widget.textbox,
                    forced_width = 200,
                  },
                layout = wibox.layout.fixed.horizontal,
            },
            left  = 10,
            right = 10,
            widget = wibox.container.margin
        },
        id     = 'background_role',
        widget = wibox.container.background,
      },
    }
  }

    -- Create a systray widget
    --systray = wibox.widget.systray()
    --systray:set_base_size(30)
    s.systray = wibox.widget.systray()
    s.systray.visible = false

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", height = 28, screen = s})
    s.mywibox.opacity = 1
    
    keybrd = wibox.widget.textbox()
    keybrd:set_text(" ")
    time = wibox.widget.textbox()
    time:set_text(" ")
    spacer = wibox.widget {
        widget        = wibox.widget.separator,
        shape         = gears.shape.rectangle,
        color         = beautiful.bg_normal,
        forced_width  = 5,
    }


    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            spacer,
            playerctl_widget,
            expand = "none",
            --s.mypromptbox,
        },
        
          --s.mypromptbox,
          s.mytasklist, -- Middle widget
        
        { -- Right widgets
            --s.mytasklist,
            layout = wibox.layout.fixed.horizontal, 
            time,
            mytextclock,
            ram_widget,
						keybrd,
            mykeyboardlayout,
            spacer,
						brightness_widget,
            spacer,
            volume_widget,
            spacer,
            battery_widget,
            spacer,
            s.systray, 
            spacer,
            s.mylayoutbox,
        },
    }
end)

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(


    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,     }, "Tab",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),

    awful.key({ "Mod1",           }, "Tab",
      function ()
          switcher.switch( 1, "Mod1", "Alt_L", "Shift", "Tab")
      end),
   
    awful.key({ "Mod1",           }, "s",
      function ()
        awful.screen.focused().systray.visible = not awful.screen.focused().systray.visible
      end,
              {description = "Toggle systray", group = "awesome"}
      ),

    awful.key({ "Mod1", "Shift"   }, "Tab",
      function ()
          switcher.switch(-1, "Mod1", "Alt_L", "Shift", "Tab")
      end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Rofi Launcher
    awful.key({ modkey,           }, "d", function () awful.spawn.with_shell('rofi -show drun -theme ' .. home_dir .. '/.config/awesome/config/appmenu/drun.rasi') end,
              {description = "Launch Rofi start menu", group = "awesome"}),

    awful.key({modkey,            }, ".", function () awful.spawn.with_shell("bash $HOME/bin/scripts/volume.sh up") end,
              {description = "Volume Up", group = "Audio"}),

    awful.key({modkey,            }, ",", function () awful.spawn.with_shell("bash $HOME/bin/scripts/volume.sh down") end,
              {description = "Volume Down", group = "Audio"}),

    awful.key({}, "XF86AudioRaiseVolume", function () awful.spawn.with_shell("bash $HOME/bin/scripts/volume.sh up") end,
              {description = "Volume Up", group = "Audio"}),

    awful.key({}, "XF86AudioLowerVolume", function () awful.spawn.with_shell("bash $HOME/bin/scripts/volume.sh down") end,
              {description = "Volume Down", group = "Audio"}),

    awful.key({ }, "XF86AudioMute", function () awful.util.spawn("amixer set Master toggle") end,
              {description = "Mute Audio", group = "Audio"}),

    awful.key({ }, "XF86AudioNext", function () awful.util.spawn("playerctl next") end,
              {description = "Play Next Song", group = "Audio"}),

    awful.key({ }, "XF86AudioPrev", function () awful.util.spawn("playerctl previous") end,
              {description = "Play Previous Song", group = "Audio"}),

    awful.key({}, "XF86AudioPlay", function () 
        awful.spawn.with_shell("source $HOME/.scripts/togglePause.sh") 
     end,
              {description = "Pause/Play Media", group = "awesome"}),

    awful.key({modkey,            }, "/", function () awful.spawn.with_shell("bash $HOME/bin/scripts/toggle_pause.sh") end,
              {description = "Pause/Play Audio", group = "awesome"}),

    awful.key({}, "#164", function () awful.spawn.with_shell("bash $HOME/bin/scripts/toggle_pause.sh") end,
              {description = "Pause/Play Audio", group = "awesome"}),


    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "Tab", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey, "Shift"   }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),

              -- Screenshot to Clipboard
    awful.key({}, "Print", function () awful.spawn.with_shell("maim -s | xclip -selection clipboard -t image/png") end,
              {description = "Screenshot selected window/area", group = "launcher"}),
    
    -- Brightness Control
     awful.key({}, "XF86MonBrightnessUp", function () awful.spawn.with_shell("light -A 5") end,
              {description = "Increase screen brightness", group = "launcher"}),    
     awful.key({}, "XF86MonBrightnessDown", function () awful.spawn.with_shell("light -U 5") end,
              {description = "Decrease screen brightness", group = "launcher"}),    

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "Escape", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "q",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"}),

    awful.key({ modkey }, "x" , function() awful.spawn.with_shell("gdmflexiserver -l") end )
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}
-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     --keys = keys.clientkeys,
                     buttons = clientbuttons,
                     --buttons = keys.clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Ulauncher",
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule = {}, 
      except_any = { class = {"conky", "Nautilus", "Toolbox" }},
      properties = { titlebars_enabled = true }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    { rule = { class = "kitty" },
      properties = { tag = awful.screen.focused().tags[2] } 
    },
    { rule = { class = "jetbrains-idea" },
      properties = { tag = awful.screen.focused().tags[4] } 
    },   
    { rule = { class = "chromium-browser" },
      properties = { tag = awful.screen.focused().tags[3] } 
    },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )


    awful.titlebar(c, {
      size = 28,
    }) : setup {
        { -- Left
            awful.titlebar.widget.closebutton    (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.minimizebutton (c),
            awful.titlebar.widget.stickybutton   (c),
            layout = wibox.layout.fixed.horizontal()
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c),
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal,
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
