defmodule KV.Run do

    def run() do
        import KV.Sip
        parse "INVITE\nContent-Type: application/json"
    end

end
