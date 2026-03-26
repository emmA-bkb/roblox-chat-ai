local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SendText = ReplicatedStorage:FindFirstChild("SendText")

if not SendText then
	SendText = Instance.new("RemoteEvent")
	SendText.Name = "SendText"
	SendText.Parent = ReplicatedStorage
end

local CHAT_API_URL = "http://127.0.0.1:5000/api/chat"

local function enviarMensagemParaIA(player, mensagem)
	local response

	local ok, err = pcall(function()
		response = HttpService:PostAsync(
			CHAT_API_URL,
			HttpService:JSONEncode({ message = mensagem }),
			Enum.HttpContentType.ApplicationJson
		)
	end)

	if ok and response then
		local data = HttpService:JSONDecode(response)
		SendText:FireClient(player, data.response or "Sem resposta.")
	else
		warn("Erro ao se comunicar com a IA:", err)
		SendText:FireClient(player, "Erro ao se comunicar com a IA.")
	end
end

SendText.OnServerEvent:Connect(function(player, mensagem)
	enviarMensagemParaIA(player, mensagem)
end)