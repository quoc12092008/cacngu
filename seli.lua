spawn(function()
    while true do
        pcall(function()
            request({Url = "http://127.0.0.1:5555/heartbeat", Method = "GET"})
        end)
        wait(30)
    end
end)

print("[HEARTBEAT] Started")
