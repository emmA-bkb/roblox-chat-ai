local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local SendText = ReplicatedStorage:WaitForChild("SendText")

local estaRespondendo = false
local cancelarResposta = false
local escrevendoAtual = nil
local containerEscrevendoAtual = nil
local ladoEscrevendoAtual = nil

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HudIa"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 760, 0, 540)
mainFrame.Position = UDim2.new(0.5, -380, 0.5, -270)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 18)
mainCorner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 56)
title.BackgroundTransparency = 1
title.Text = "Chati gepete"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local chatFrame = Instance.new("ScrollingFrame")
chatFrame.Size = UDim2.new(1, -24, 1, -150)
chatFrame.Position = UDim2.new(0, 12, 0, 62)
chatFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
chatFrame.BorderSizePixel = 0
chatFrame.ScrollBarThickness = 8
chatFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
chatFrame.AutomaticCanvasSize = Enum.AutomaticSize.None
chatFrame.ScrollingDirection = Enum.ScrollingDirection.Y
chatFrame.Parent = mainFrame

local chatCorner = Instance.new("UICorner")
chatCorner.CornerRadius = UDim.new(0, 14)
chatCorner.Parent = chatFrame

local chatPadding = Instance.new("UIPadding")
chatPadding.PaddingTop = UDim.new(0, 10)
chatPadding.PaddingBottom = UDim.new(0, 10)
chatPadding.Parent = chatFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = chatFrame

local inputContainer = Instance.new("Frame")
inputContainer.Size = UDim2.new(1, -24, 0, 64)
inputContainer.Position = UDim2.new(0, 12, 1, -76)
inputContainer.BackgroundTransparency = 1
inputContainer.Parent = mainFrame

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(1, -120, 1, 0)
inputBox.Position = UDim2.new(0, 0, 0, 0)
inputBox.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
inputBox.PlaceholderText = "Digite sua mensagem..."
inputBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
inputBox.Text = ""
inputBox.Font = Enum.Font.Gotham
inputBox.TextSize = 20
inputBox.TextXAlignment = Enum.TextXAlignment.Left
inputBox.ClearTextOnFocus = false
inputBox.Parent = inputContainer

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 12)
inputCorner.Parent = inputBox

local inputPadding = Instance.new("UIPadding")
inputPadding.PaddingLeft = UDim.new(0, 14)
inputPadding.PaddingRight = UDim.new(0, 14)
inputPadding.Parent = inputBox

local sendButton = Instance.new("TextButton")
sendButton.Size = UDim2.new(0, 108, 1, 0)
sendButton.Position = UDim2.new(1, -108, 0, 0)
sendButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
sendButton.Text = "Enviar"
sendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
sendButton.Font = Enum.Font.GothamBold
sendButton.TextSize = 20
sendButton.Parent = inputContainer

local sendCorner = Instance.new("UICorner")
sendCorner.CornerRadius = UDim.new(0, 12)
sendCorner.Parent = sendButton

local function atualizarBotao()
	if estaRespondendo then
		sendButton.Text = "Parar"
		sendButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
	else
		sendButton.Text = "Enviar"
		sendButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	end
end

local function atualizarScroll()
	task.wait()
	chatFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
	chatFrame.CanvasPosition = Vector2.new(0, math.max(0, layout.AbsoluteContentSize.Y))
end

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(atualizarScroll)

local function calcularAlturaTexto(texto, largura, textSize, fonte)
	local size = TextService:GetTextSize(
		texto,
		textSize,
		fonte,
		Vector2.new(largura, 100000)
	)
	return size.Y
end

local function ajustarBubble(bubble, container, isUser)
	local larguraMaxima = math.floor(chatFrame.AbsoluteSize.X * 0.68)
	local paddingHorizontal = 28
	local paddingVertical = 20

	local alturaTexto = calcularAlturaTexto(
		bubble.Text,
		larguraMaxima - paddingHorizontal,
		bubble.TextSize,
		bubble.Font
	)

	local alturaFinal = math.max(44, alturaTexto + paddingVertical)

	bubble.Size = UDim2.new(0, larguraMaxima, 0, alturaFinal)
	container.Size = UDim2.new(1, -20, 0, alturaFinal)

	if isUser then
		bubble.Position = UDim2.new(1, -10 - larguraMaxima, 0, 0)
	else
		bubble.Position = UDim2.new(0, 10, 0, 0)
	end
end

local function criarMensagem(texto, isUser)
	local container = Instance.new("Frame")
	container.BackgroundTransparency = 1
	container.Size = UDim2.new(1, -20, 0, 50)
	container.Parent = chatFrame

	local bubble = Instance.new("TextLabel")
	bubble.BackgroundColor3 = isUser and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(60, 60, 60)
	bubble.TextColor3 = Color3.fromRGB(255, 255, 255)
	bubble.TextWrapped = true
	bubble.TextXAlignment = isUser and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
	bubble.TextYAlignment = Enum.TextYAlignment.Top
	bubble.Font = Enum.Font.Gotham
	bubble.TextSize = 19
	bubble.Text = texto
	bubble.BorderSizePixel = 0
	bubble.Parent = container

	local bubbleCorner = Instance.new("UICorner")
	bubbleCorner.CornerRadius = UDim.new(0, 12)
	bubbleCorner.Parent = bubble

	local bubblePadding = Instance.new("UIPadding")
	bubblePadding.PaddingLeft = UDim.new(0, 14)
	bubblePadding.PaddingRight = UDim.new(0, 14)
	bubblePadding.PaddingTop = UDim.new(0, 10)
	bubblePadding.PaddingBottom = UDim.new(0, 10)
	bubblePadding.Parent = bubble

	ajustarBubble(bubble, container, isUser)
	atualizarScroll()

	return bubble, container, isUser
end

local function animarTexto(bubble, container, isUser, textoFinal)
	cancelarResposta = false
	estaRespondendo = true
	atualizarBotao()

	bubble.Text = ""

	for i = 1, #textoFinal do
		if cancelarResposta then
			break
		end

		bubble.Text = string.sub(textoFinal, 1, i)
		ajustarBubble(bubble, container, isUser)
		atualizarScroll()
		task.wait(0.012)
	end

	estaRespondendo = false
	atualizarBotao()
end

local function enviarMensagem()
	local msg = inputBox.Text
	if msg == "" or msg:match("^%s*$") then
		return
	end

	cancelarResposta = true

	criarMensagem(msg, true)
	inputBox.Text = ""

	escrevendoAtual, containerEscrevendoAtual, ladoEscrevendoAtual = criarMensagem("Escrevendo...", false)

	SendText:FireServer(msg)
end

sendButton.MouseButton1Click:Connect(function()
	if estaRespondendo then
		cancelarResposta = true
		estaRespondendo = false
		atualizarBotao()
	else
		enviarMensagem()
	end
end)

inputBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		if not estaRespondendo then
			enviarMensagem()
		end
	end
end)

SendText.OnClientEvent:Connect(function(resposta)
	local texto = tostring(resposta)

	if escrevendoAtual and containerEscrevendoAtual then
		animarTexto(escrevendoAtual, containerEscrevendoAtual, ladoEscrevendoAtual, texto)
		escrevendoAtual = nil
		containerEscrevendoAtual = nil
		ladoEscrevendoAtual = nil
	else
		local bubble, container, isUser = criarMensagem("", false)
		animarTexto(bubble, container, isUser, texto)
	end
end)