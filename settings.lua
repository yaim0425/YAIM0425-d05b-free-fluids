---------------------------------------------------------------------------------------------------
---> settings-final-fixes.lua <---
---------------------------------------------------------------------------------------------------

--- Contenedor de funciones y datos usados
--- unicamente en este archivo
local This_MOD = {}

---------------------------------------------------------------------------------------------------

--- Cargar las funciones
require("__zzzYAIM0425-0000-lib__.settings-final-fixes")

---------------------------------------------------------------------------------------------------

--- Obtener información desde el nombre de MOD
GPrefix.split_name_folder(This_MOD)

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Opciones
This_MOD.setting = {}

--- Opcion: amount
table.insert(This_MOD.setting, {
	type = "int",
	name = "amount",
	localised_name = { "description.amount" },
	minimum_value = 1000,
	maximum_value = 65000,
	default_value = 1000
})

--- Opcion: all
table.insert(This_MOD.setting, {
	type = "bool",
	name = "all",
	localised_name = { "gui-blueprint-library.shelf-choice-all" },
	default_value = false
})

---------------------------------------------------------------------------------------------------

--- Establecer el order
for order, setting in pairs(This_MOD.setting) do
	setting.type = setting.type .. "-setting"
	setting.name = This_MOD.prefix .. setting.name
	setting.order = tostring(order)
	setting.setting_type = "startup"
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Cargar la configuración
data:extend(This_MOD.setting)

---------------------------------------------------------------------------------------------------
