--[[
	ShopService.luau
	Loja da van (Scooby Snacks) e aplicação dos "grants" declarados em
	Definitions.Shop.

	Itens são comprados com a moeda do jogo e aplicados no perfil:
		consumíveis (snacks, kit de armadilha) entram no inventário;
		melhorias (detector, megafone, van) viram flags no personagem.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Definitions = require(Shared.Data.Definitions)
local Net = require(Shared.Net)

local ProfileService = require(script.Parent.ProfileService)

local ShopService = {}

function ShopService.buy(player, itemId)
	local item = Definitions.getItem(itemId)
	if not item then
		return false, "item inexistente"
	end

	local profile = ProfileService.get(player)
	if not profile then
		return false, "perfil não carregado"
	end

	-- itens únicos não podem ser comprados duas vezes
	if item.unique and ProfileService.hasItem(player, itemId) then
		return false, "você já tem esse item"
	end

	-- desconto de sócio (van_upgrade comprado)
	local price = item.price
	if ProfileService.hasItem(player, "scooby_badge") then
		price = math.floor(price * 0.9)
	end

	local paid = ProfileService.spendSnacks(player, price)
	if not paid then
		return false, "Scooby Snacks insuficientes (precisa de " .. price .. ")"
	end

	ProfileService.giveItem(player, itemId, item.consumable and (item.amount or 1) or 1)

	-- aplica os efeitos declarados
	local grant = item.grant or {}
	if grant.snacks then
		ProfileService.addSnacks(player, grant.snacks, "item")
	end
	if grant.speedBonus then
		player:SetAttribute("SpeedBonus", (player:GetAttribute("SpeedBonus") or 0) + grant.speedBonus)
	end
	if grant.luckBonus then
		player:SetAttribute("LuckBonus", (player:GetAttribute("LuckBonus") or 0) + grant.luckBonus)
	end
	if grant.tag then
		player:SetAttribute("Tag_" .. grant.tag, true)
	end
	if grant.extraTrapPart then
		player:SetAttribute("ExtraTrapPart", true)
	end
	if grant.revive then
		player:SetAttribute("ReviveCharges", (player:GetAttribute("ReviveCharges") or 0) + grant.revive)
	end
	if grant.skin then
		profile.skin = grant.skin
	end

	Net.fireClient(player, "ClientUnlock", {
		kind = "shop",
		id = itemId,
		name = item.name,
		description = item.description,
		price = price,
		reward = item.snacks,
	})

	Net.fireClient(player, "ClientNotify", {
		title = "Compra concluída",
		text = ("%s por %d Scooby Snacks."):format(item.name, price),
		kind = "success",
		sound = "Pop",
	})

	Net.fireClient(player, "ClientLobby", { refresh = true })
	return true, item
end

function ShopService.catalog()
	local list = {}
	for _, item in ipairs(Definitions.Shop) do
		table.insert(list, {
			id = item.id,
			name = item.name,
			description = item.description,
			price = item.price,
			category = item.category,
			unique = item.unique,
			consumable = item.consumable,
		})
	end
	return list
end

function ShopService.start()
	Net.Event("LobbyBuyItem").OnServerEvent:Connect(function(player, itemId)
		if type(itemId) ~= "string" then
			return
		end
		ShopService.buy(player, itemId)
	end)

	-- O catálogo entra no lobbyState pela PartyService (evita dois handlers no
	-- mesmo RemoteFunction). Registramos só o fornecedor do catálogo.
end

return ShopService
