-- put former exec-once commands inside the func and former exec commands outside
hl.on("hyprland.start", function ()
    hl.exec_cmd("opencloud")
end)