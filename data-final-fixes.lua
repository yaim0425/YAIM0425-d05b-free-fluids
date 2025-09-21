---------------------------------------------------------------------------
---[ data-final-fixes.lua ]---
---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Contenedor de este archivo ]---
---------------------------------------------------------------------------

local This_MOD = GMOD.get_id_and_name()
if not This_MOD then return end
GMOD[This_MOD.id] = This_MOD

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Inicio del MOD ]---
---------------------------------------------------------------------------

function This_MOD.start()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores de la referencia
    This_MOD.setting_mod()

    -- --- Obtener los elementos
    -- This_MOD.get_elements()

    -- --- Modificar los elementos
    -- for iKey, spaces in pairs(This_MOD.to_be_processed) do
    --     for jKey, space in pairs(spaces) do
    --         --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --         --- Marcar como procesado
    --         This_MOD.processed[iKey] = This_MOD.processed[iKey] or {}
    --         This_MOD.processed[iKey][jKey] = true

    --         --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --         --- Crear los elementos
    --         This_MOD.create_item(space)
    --         This_MOD.create_entity(space)
    --         This_MOD.create_recipe(space)
    --         This_MOD.create_tech(space)

    --         --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --     end
    -- end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Valores de la referencia ]---
---------------------------------------------------------------------------

function This_MOD.setting_mod()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validar si se cargó antes
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    This_MOD.to_be_processed = {}
    if This_MOD.processed then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores de la referencia en todos los MODs
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Contenedor de los elementos que el MOD modoficó o modificará
    This_MOD.processed = {}

    --- Cargar la configuración
    This_MOD.setting = GMOD.setting[This_MOD.id]

    --- Indicador del mod
    This_MOD.indicator = {
        icon = GMOD.entities["assembling-machine-2"].icons[1].icon,
        icon_size = 64,
        scale = 0.25,
        shift = { 12, -12 }
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores de la referencia en este MOD
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores de referencia
    This_MOD.type = "assembling-machine"
    This_MOD.entity_name = This_MOD.type .. "-2"
    This_MOD.new_entity_name = GMOD.name .. "-free-" .. This_MOD.entity_name

    --- Prototipos de referencia
    This_MOD.entity = GMOD.entities[This_MOD.entity_name]
    This_MOD.item = GMOD.items[This_MOD.entity_name]

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Funciones locales ]---
---------------------------------------------------------------------------

function This_MOD.get_elements()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Renombrar
    local entity = This_MOD.entity
    local item = This_MOD.item

    --- Validar valores de referencia
    if GMOD.entities[This_MOD.new_entity_name] then return end
    if entity then return end
    if item then return end

    --- Validar si ya fue procesado
    if
        This_MOD.processed[entity.type] and
        This_MOD.processed[entity.type][item.name]
    then
        return
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores para el proceso
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Space = {}
    Space.item = item
    Space.entity = entity

    Space.recipe = GMOD.recipes[Space.item.name]
    Space.recipe = Space.recipe and Space.recipe[1] or nil

    Space.prefix = This_MOD.new_entity_name

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Guardar la información
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    This_MOD.to_be_processed[entity.type] = This_MOD.to_be_processed[entity.type] or {}
    This_MOD.to_be_processed[entity.type][entity.name] = Space

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Iniciar el MOD ]---
---------------------------------------------------------------------------

This_MOD.start()

---------------------------------------------------------------------------
