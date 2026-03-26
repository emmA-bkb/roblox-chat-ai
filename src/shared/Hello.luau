local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local SendText = ReplicatedStorage:WaitForChild("SendText")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HudIa"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 420, 0, 260)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -130)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "Chat da IA"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local chatFrame = Instance.new("ScrollingFrame")
chatFrame.Name = "ChatFrame"
chatFrame.Size = UDim2.new(1, -20, 1, -100)
chatFrame.Position = UDim2.new(0, 10, 0, 45)
chatFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
chatFrame.BorderSizePixel = 0
chatFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
chatFrame.ScrollBarThickness = 6
chatFrame.Parent = mainFrame

local chatCorner = Instance.new("UICorner")
chatCorner.CornerRadius = UDim.new(0, 10)
chatCorner.Parent = chatFrame

local chatLayout = Instance.new("UIListLayout")
chatLayout.Padding = UDim.new(0, 8)
chatLayout.Parent = chatFrame

local inputBox = Instance.new("TextBox")
inputBox.Name = "InputBox"
inputBox.Size = UDim2.new(1, -100, 0, 40)
inputBox.Position = UDim2.new(0, 10, 1, -50)
inputBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
inputBox.BorderSizePixel = 0
inputBox.PlaceholderText = "Digite sua mensagem..."
inputBox.Text = ""
inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
inputBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
inputBox.TextScaled = false
inputBox.TextSize = 18
inputBox.Font = Enum.Font.Gotham
inputBox.ClearTextOnFocus = false
inputBox.Parent = mainFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 10)
inputCorner.Parent = inputBox

local sendButton = Instance.new("TextButton")
sendButton.Name = "SendButton"
sendButton.Size = UDim2.new(0, 80, 0, 40)
sendButton.Position = UDim2.new(1, -90, 1, -50)
sendButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
sendButton.BorderSizePixel = 0
sendButton.Text = "Enviar"
sendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
sendButton.TextSize = 18
sendButton.Font = Enum.Font.GothamBold
sendButton.Parent = mainFrame

local sendCorner = Instance.new("UICorner")
sendCorner.CornerRadius = UDim.new(0, 10)
sendCorner.Parent = sendButton

local function atualizarCanvas()
	task.wait()
	chatFrame.CanvasSize = UDim2.new(0, 0, 0, chatLayout.AbsoluteContentSize.Y + 10)
	chatFrame.CanvasPosition = Vector2.new(0, math.max(0, chatLayout.AbsoluteContentSize.Y))
end

local function criarMensagem(texto, autor)
	local label = Instance.new("TextLabel")
	label.BackgroundColor3 = autor == "Você" and Color3.fromRGB(70, 130, 255) or Color3.fromRGB(70, 70, 70)
	label.BorderSizePixel = 0
	label.Size = UDim2.new(1, -10, 0, 30)
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = 18
	label.Font = Enum.Font.Gotham
	label.Text = autor .. ": " .. texto
	label.Parent = chatFrame

	local msgCorner = Instance.new("UICorner")
	msgCorner.CornerRadius = UDim.new(0, 8)
	msgCorner.Parent = label

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingBottom = UDim.new(0, 8)
	padding.Parent = label

	atualizarCanvas()
	return label
end

local esperandoResposta = false

local function enviarMensagem()
	if esperandoResposta then
		return
	end

	local mensagem = inputBox.Text
	if mensagem == "" or mensagem:match("^%s*$") then
		return
	end

	criarMensagem(mensagem, "Você")
	inputBox.Text = ""
	esperandoResposta = true

	criarMensagem("Escrevendo...", "IA")
	SendText:FireServer(mensagem)
end

sendButton.MouseButton1Click:Connect(enviarMensagem)

inputBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		enviarMensagem()
	end
end)

SendText.OnClientEvent:Connect(function(resposta)
	esperandoResposta = false

	local children = chatFrame:GetChildren()
	for i = #children, 1, -1 do
		local obj = children[i]
		if obj:IsA("TextLabel") and obj.Text == "IA: Escrevendo..." then
			obj.Text = "IA: " .. tostring(resposta)
			atualizarCanvas()
			return
		end
	end

	criarMensagem(tostring(resposta), "IA")
end)