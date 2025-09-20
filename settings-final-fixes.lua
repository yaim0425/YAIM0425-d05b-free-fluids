---------------------------------------------------------------------------
---[ settings-final-fixes.lua ]---
---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Cargar las funciones de GMOD ]---
---------------------------------------------------------------------------

require("__" .. "YAIM0425-i5MOD50-core" .. "__.settings-final-fixes")

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Contenedor de este archivo ]---
---------------------------------------------------------------------------

local This_MOD = GMOD.get_id_and_name()
if not This_MOD then return end
GMOD[This_MOD.id] = This_MOD

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Opciones ]---
---------------------------------------------------------------------------

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

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Completar las opciones ]---
---------------------------------------------------------------------------

--- Información adicional
for order, setting in pairs(This_MOD.setting) do
    setting.type = setting.type .. "-setting"
    setting.name = This_MOD.prefix .. setting.name
    setting.order = GMOD.pad_left_zeros(GMOD.digit_count(order), order)
    setting.setting_type = "startup"
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Cargar la configuración ]---
---------------------------------------------------------------------------

data:extend(This_MOD.setting)

---------------------------------------------------------------------------
