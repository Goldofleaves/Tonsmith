SMODS.current_mod.config_tab = function ()

    BSFX.CARDAREAS.selected = {}
    BSFX.CARDAREAS.available = {}

    BSFX.CARDAREAS.selected = CardArea(
            20, 20,
            G.CARD_W*6,G.CARD_H,
            {card_limit = 1, type = 'bsfx_list', highlight_limit = 1})

    BSFX.CARDAREAS.available = CardArea(
            20, 20,
            G.CARD_W*6,G.CARD_H,
            {card_limit = 1, type = 'bsfx_list', highlight_limit = 1})

    return {n = G.UIT.ROOT, config = {minw = 10, minh = 6 ,r = 0.1, colour = G.C.BLACK, align = "cm"}, nodes = {
        {n = G.UIT.R, config = {align = "tm"}, nodes = {{n = G.UIT.T, config = {text = "Select soundpack", scale = 0.6, colour = G.C.WHITE}}}},
        {n = G.UIT.R, config = {minh = 0.1}},

        {n = G.UIT.R, config = {align = "tm"}, nodes = {{n = G.UIT.T, config = {text = "Left less priority, right most priority", scale = 0.3, colour = G.C.WHITE}}}},
        {n = G.UIT.R, config = {minh = 0.2}},
        {n = G.UIT.R, config = {align = "tm", id = "act_text"}, nodes = {{n = G.UIT.T, config = {text = "Active soundpacks", scale = 0.3, colour = G.C.WHITE}}}},
        {n = G.UIT.R, config = {minh = 0.15}},

        {n = G.UIT.R, config = {align = "tm", colour = G.C.BLACK}, nodes = {{
            n = G.UIT.O, config = {id = "selected", object = BSFX.CARDAREAS.selected}
        }}},
        {n = G.UIT.R, config = {minh = 0.15}},
        {n = G.UIT.R, config = {align = "tm", padding = 0}, nodes = {
            {n = G.UIT.C, config = {padding = 0.2}, nodes = {
                {n = G.UIT.R, nodes = {UIBox_button{
                    label = {"Add"},
                    minw = 1.5, minh = 0.6
                }}},

                {n = G.UIT.R, nodes = {UIBox_button{
                    label = {"Remove"},
                    minw = 1.5, minh = 0.6
                }}}
            }},

            {n = G.UIT.C, config = {padding = 0.2}, nodes = {
                {n = G.UIT.R, nodes = {UIBox_button{
                    label = {"Reload"},
                    button = "BSFX_reload_lists",
                    minw = 1.5, minh = 0.6
                }}},

                {n = G.UIT.R, nodes = {UIBox_button{
                    label = {"Apply"},
                    minw = 1.5, minh = 0.6
                }}}
            }},
        }},
        {n = G.UIT.R, config = {minh = 0.15}},

        {n = G.UIT.R, config = {align = "tm"}, nodes = {{n = G.UIT.T, config = {text = "Available soundpacks", scale = 0.3, colour = G.C.WHITE}}}},
        {n = G.UIT.R, config = {minh = 0.15}},

        {n = G.UIT.R, config = {align = "tm", colour = G.C.BLACK}, nodes = {{
            n = G.UIT.O, config = {id = "available", object = BSFX.CARDAREAS.available}
        }}},
        {n = G.UIT.R, config = {minh = 0.1}},
    }}
end