---------------------------------------------------------------------------------------------------
---> data-final-fixes.lua <---
---------------------------------------------------------------------------------------------------

--- Contenedor de funciones y datos usados
--- unicamente en este archivo
local This_MOD = {}

---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
function This_MOD.start()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Obtener información desde el nombre de MOD
    GPrefix.split_name_folder(This_MOD)

    --- Valores de la referencia
    This_MOD.setSetting()

    --- Fluidos a afectar
    This_MOD.getFluids()

    --- Crear las recetas de los fluidos
    This_MOD.CreateRecipes()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Valores de la referencia
function This_MOD.setSetting()
    --- Otros valores
    This_MOD.Prefix   = "zzzYAIM0425-0500-"
    This_MOD.name     = "free-fluids"
    This_MOD.all      = GPrefix.Setting[This_MOD.Prefix]["all"]
    This_MOD.quantity = GPrefix.Setting[This_MOD.Prefix]["quantity"]

    --- Indicador del MOD
    local BackColor  = ""

    BackColor        = data.raw["virtual-signal"]["signal-deny"].icon
    This_MOD.delete   = { icon = BackColor, scale = 0.5 }

    BackColor        = data.raw["virtual-signal"]["signal-check"].icon
    This_MOD.create   = { icon = BackColor, scale = 0.5 }

    This_MOD.actions  = {
        ["create"] = "results",
        ["delete"] = "ingredients"
    }

    --- Receta base
    This_MOD.Recipe   = {
        type                      = "recipe",
        name                      = "",
        localised_name            = {},
        localised_description     = {},
        energy_required           = 0.002,

        hide_from_player_crafting = true,
        enabled                   = true,
        category                  = "crafting-with-fluid",
        subgroup                  = "",
        order                     = "",

        ingredients               = {},
        results                   = {}
    }
end

---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------

--- Fluidos a afectar
function This_MOD.getFluids()
    --- Fluidos a duplicar
    This_MOD.Fluids = {}

    --- Se desean todos los liquidos
    if This_MOD.all then
        This_MOD.Fluids = GPrefix.Fluids
        return
    end

    --- Fluidos tomados del suelo
    for _, tile in pairs(data.raw.tile) do
        if tile.fluid then
            This_MOD.Fluids[tile.fluid] = true
        end
    end

    --- Fluidos minables
    for _, resource in pairs(data.raw.resource) do
        local results = resource.minable
        results = results and results.results
        for _, result in pairs(results or {}) do
            if result.type == "fluid" then
                if result.name then This_MOD.Fluids[result.name] = true end
            end
        end
    end

    --- Cargar los fluidos encontrados
    for name, _ in pairs(This_MOD.Fluids) do
        This_MOD.Fluids[name] = GPrefix.Fluids[name]
    end
end

--- Crear las recetas de los fluidos
function This_MOD.CreateRecipes()
    --- Contenedor de las nuevas recetas
    local Recipes = {}

    --- Recorrer los fluidos
    for action, propiety in pairs(This_MOD.actions) do
        for _, Fluid in pairs(This_MOD.Fluids) do
            --- Crear una copia de los datos
            local recipe   = util.copy(This_MOD.Recipe)
            local fluid    = util.copy(Fluid)

            --- Crear el subgroup
            local subgroup = This_MOD.Prefix .. fluid.subgroup .. "-" .. action
            GPrefix.duplicate_subgroup(fluid.subgroup, subgroup)

            --- Actualizar los datos
            recipe.name                  = This_MOD.Prefix .. fluid.name .. "-" .. action
            recipe.localised_name        = fluid.localised_name
            recipe.localised_description = fluid.localised_description

            recipe.subgroup              = subgroup
            recipe.order                 = fluid.order

            recipe.icons                 = fluid.icons

            --- Variaciones entre las recetas
            table.insert(recipe.icons, This_MOD[action])
            recipe[propiety] = { {
                type = "fluid",
                name = fluid.name,
                amount = This_MOD.quantity
            } }

            --- Crear el prototipo
            GPrefix.addDataRaw({ recipe })

            --- Guardar la nueva receta
            Recipes[action] = Recipes[action] or {}
            table.insert(Recipes[action], recipe)
        end
    end

    --- Ordenar las recetas
    for action, _ in pairs(This_MOD.actions) do
        GPrefix.setOrder(Recipes[action])
    end
end

---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
This_MOD.start()

---------------------------------------------------------------------------------------------------
