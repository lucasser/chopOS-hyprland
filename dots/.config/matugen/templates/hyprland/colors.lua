hl.config({
    general = {
        col = {
            active_border   = {
                colors = {
                    "rgba({{colors.primary.default.hex_stripped}}CC)",
                    "rgba({{colors.tertiary.default.hex_stripped}}99)"
                },
                angle = 45
            },
            inactive_border = "rgba({{colors.secondary.default.hex_stripped}}33)",
        },
    },
    group = {
        col = {
            border_active   = {
                colors = {
                    "rgba({{colors.primary.default.hex_stripped}}CC)",
                    "rgba({{colors.tertiary.default.hex_stripped}}99)"
                },
                angle = 45
            },
            border_inactive = "rgba({{colors.secondary.default.hex_stripped}}33)",
        },
        groupbar = {
            text_color = "rgba({{colors.tertiary.default.hex_stripped}}FF)",
            col = {
                active   = {
                    colors = {
                        "rgba({{colors.primary.default.hex_stripped}}CC)",
                        "rgba({{colors.tertiary.default.hex_stripped}}99)"
                    },
                    angle = 45
                },
                inactive = "rgba({{colors.secondary.default.hex_stripped}}33)",
            },
        }
    },

    misc = {
        background_color = "rgba({{colors.surface.dark.hex_stripped}}FF)",
    },
})

hl.window_rule({
    match        = { pin = 1 },
    border_color = "rgba({{colors.primary.default.hex_stripped}}AA) rgba({{colors.primary.default.hex_stripped}}77)",
})

