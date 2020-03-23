local beautiful = require('beautiful')
local wibox = require('wibox')
local gears = require('gears')
local clickable_container = require('widgets.clickable-container')

local dpi = beautiful.xresources.apply_dpi

-- Calendar theme
local styles = {}

styles.month = { 
    padding = 5,
    bg_color = '#00000000',
}
styles.normal = {
    fg_color = '#f2f2f2',
    bg_color = '#00000000'
}
styles.focus = {
    fg_color = '#f2f2f2',
    bg_color = '#007af7',
    markup = function(t) return '<b>' .. t .. '</b>' end
}
styles.header = {
    fg_color = '#f2f2f2',
    bg_color = '#00000000',
    markup = function(t) return '<b>' .. t .. '</b>' end
}
styles.weekday = { 
    fg_color = '#ffffff',
    bg_color = '#00000000',
    markup = function(t) return '<b>' .. t .. '</b>' end
}

local function decorate_cell(widget, flag, date)
    if flag=='monthheader' and not styles.monthheader then
        flag = 'header'
    end
    local props = styles[flag] or {}
    if props.markup and widget.get_text and widget.set_markup then
        widget:set_markup(props.markup(widget:get_text()))
    end
    -- Change bg color for weekends
    local d = {year=date.year, month=(date.month or 1), day=(date.day or 1)}
    local weekday = tonumber(os.date('%w', os.time(d)))
    local default_bg = (weekday==0 or weekday==6) and '#232323' or '#383838'
    local ret = wibox.widget {
        {
            widget,
            margins = (props.padding or 2) + (props.border_width or 0),
            widget  = wibox.container.margin
        },
        shape = props.shape,
        shape_border_color = props.border_color or '#b9214f',
        shape_border_width = props.border_width or 0,
        fg = props.fg_color or '#999999',
        bg = props.bg_color or default_bg,
        widget = wibox.container.background
    }
    return ret
end

-- Calendar Widget
local cal = wibox.widget {
    {
        date = os.date('*t'),
        font = 'SF Display Regular 12',
        start_sunday = true,
        fn_embed = decorate_cell,
        spacing = dpi(10),
        long_weekdays = false,
        widget   = wibox.widget.calendar.month
    },
    margins = dpi(2),
    widget = wibox.container.margin
}

-- Time Summary
local week_day = wibox.widget {
    format = '%A',
    font = 'SF Display Bold 14',
    refresh = 1,
    widget = wibox.widget.textclock
}

local date = wibox.widget {
    format = '%B %d, %Y',
    font = 'SF Display Regular 12',
    refresh = 1,
    widget = wibox.widget.textclock
}

local widget_header = wibox.widget {
    text = 'Widgets',
    align = 'left',
    valign = 'center',
    font = 'SF Display Bold 14',
    widget = wibox.widget.textbox
}

-- Create clock box in every screen
screen.connect_signal("request::desktop_decoration", function(s)
    -- Create the box
    local width = dpi(658)
    local padding = dpi(10)
    clock_box = wibox {
        bg = '#00000000',
        visible = false,
        ontop = true,
        type = "normal",
        height = dpi(500),
        width = width,
        x = (s.geometry.width / 2) - (width / 2),
        y = dpi(26)
    }

    local separator = wibox.widget {
        orientation = 'vertical',
        forced_width = dpi(15),
        forced_height = dpi(1),
        opacity = 0.50,
        span_ratio = 0.925,
        widget = wibox.widget.separator
    }

    local top_separator = wibox.widget {
        orientation = 'vertical',
        forced_width = dpi(15),
        forced_height = dpi(10),
        opacity = 0.00,
        span_ratio = 0.925,
        widget = wibox.widget.separator
    }

    clock_box:setup {
        {
            layout = wibox.layout.fixed.vertical,
            top_separator,
            {
                expand = "none",
                layout = wibox.layout.fixed.horizontal,
                {
                    {
                        layout = wibox.layout.fixed.vertical,
                        nil,
                    },
                    left = dpi(2),
                    right = dpi(2),
                    forced_width = dpi(365),
                    widget = wibox.container.margin
                },
                {
                    layout = wibox.layout.fixed.horizontal,
                    separator,
                    {
                        layout = wibox.layout.fixed.vertical,
                        spacing = dpi(5),
                        {
                            -- top_separator,
                            widget_header,
                            nil,
                            nil,        
                            layout = wibox.layout.fixed.vertical,
                            spacing = dpi(5)
                        },
                        {
                            layout = wibox.layout.fixed.vertical,
                            week_day,
                            date,
                        },
                        cal,
                    },
                },
            }
        },
        -- The real background color
        bg = beautiful.background.bg_normal,
        -- The real, anti-aliased shape
        shape = function(cr, width, height)
            gears.shape.partially_rounded_rect( cr, width, height, false, false, true, true, beautiful.corner_radius) 
        end,
        widget = wibox.container.background()
    }
end)

local clock_widget = wibox.widget {
    {
        format = "%a %l:%M %p",
        font = 'SF Display Regular 10',
        refresh = 15,
        widget = wibox.widget.textclock
    },
    left = 7,
    right = 7,
    widget = wibox.container.margin
}

local clock_button = clickable_container(clock_widget)

return clock_button