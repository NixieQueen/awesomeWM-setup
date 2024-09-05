-- Define all system rules & notification properties here!!
-- {{{ Rules
-- Rules to apply to new clients.
ruled.client.connect_signal("request::rules", function()
    -- All clients will match this rule.
    ruled.client.append_rule {
        id         = "global",
        rule       = { },
        properties = {
            focus     = awful.client.focus.filter,
            raise     = true,
            screen    = awful.screen.preferred,
            --screen    = screen.primary,
            titlebars_enabled = false,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen
        }
    }

    -- Floating clients.
    ruled.client.append_rule {
        id       = "floating",
        rule_any = {
            instance = { "copyq", "pinentry" },
            class    = {
                "Arandr", "Blueman-manager", "Gpick", "Kruler", "Sxiv",
                "gnome-calculator", "Wpa_gui", "veromix", "xtightvncviewer",
                "qjackctl", "QjackCtl", "missioncenter"
            },
            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name    = {
                "Event Tester",  -- xev.
                "Picture-in-picture",
            },
            role    = {
                "AlarmWindow",    -- Thunderbird's calendar.
                "ConfigManager",  -- Thunderbird's about:config.
                "pop-up",         -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        properties = { floating = true }
    }

    ruled.client.append_rule {
      id = "forcedfullscreen",
      rule_any = {
        class = {
          "cool-retro-term"
        }
      },
      properties = {
        fullscreen = true,
        --screen = mouse.screen,
      }
    }

    ruled.client.append_rule {
      id = "games",
      rule_any = {
        class = {
          "steam_app_*"
        }
      },
      properties = {
        fullscreen = true,
        screen = screen.primary,
        tag = "Game",
        switch_to_tags = true,
      }
    }

    ruled.client.append_rule {
      id = "gaming",
      rule_any = {
        class = {
          "Steam",
          "steam",
          "discord"
        },
        name = {
          "Lutris"
        }
      },
      properties = {
        --screen = awful.screen.focused(),
        tag = "Game",
        switch_to_tags = true,
      }
    }

    ruled.client.append_rule {
      id = "music",
      rule_any = {
        class = {
          "org.gnome.Music",
          "lollypop",
          "amberol"
        }
      },
      properties = {
        --screen = awful.screen.focused(),
        tag = "Music",
        switch_to_tags = true,
      }
    }

    ruled.client.append_rule {
      id = "art",
      rule_any = {
        class = {
          "krita"
        }
      },
      properties = {
        tag = "Art",
        switch_to_tags = true,
      }
    }

    ruled.client.append_rule {
      id = "Code",
      rule_any = {
        class = {
          "emacs",
          "Emacs"
        }
      },
      properties = {
        tag = "Code",
        switch_to_tags = true,
      }
    }


    -- Add titlebars to normal clients and dialogs
    --ruled.client.append_rule {
    --    id         = "titlebars",
    --    rule_any   = { type = { "normal", "dialog" } },
    --    properties = { titlebars_enabled = true      }
    --}

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- ruled.client.append_rule {
    --     rule       = { class = "Firefox"     },
    --     properties = { screen = 1, tag = "2" }
    -- }
end)
-- }}}
-- {{{ Handle stuff related to notifications, basically all notifications will follow these rules
ruled.notification.connect_signal("request::rules", function()
    ruled.notification.append_rule {
      rule = {  },
      properties = {
        screen = awful.screen.preferred,
        implicit_timeout = 5,
        position = 'top_middle',
      }
    }
end)

naughty.connect_signal("request::display", function(n)
    naughty.layout.box { notification = n, type = 'notification' }
end)

-- The following will only occur when an error is thrown during startup, and this is mostly a fallback
naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        --urgency = "critical",
        title   = "Oops, an error happened"..(startup and " during startup!" or "!"),
        message = message,
        bg = beautiful.transparent,
        fg = beautiful.system_red_dark,
        timeout = 30,
        position = 'top_middle'
    }
end)
-- }}}
