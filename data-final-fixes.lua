---------------------------------------------------------------------------------------------------
---> data-final-fixes.lua <---
---------------------------------------------------------------------------------------------------

--- Contenedor de funciones y datos usados
--- unicamente en este archivo
local ThisMOD = {}

---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
function ThisMOD.Start()
    --- Valores de la referencia
    ThisMOD.setSetting()

    --- Fluidos a afectar
    ThisMOD.getFluids()

    --- Crear las recetas de los fluidos
    ThisMOD.CreateRecipes()
end

--- Valores de la referencia
function ThisMOD.setSetting()
    --- Otros valores
    ThisMOD.Prefix   = "zzzYAIM0425-0500-"
    ThisMOD.name     = "free-fluids"
    ThisMOD.all      = GPrefix.Setting[ThisMOD.Prefix]["all"]
    ThisMOD.quantity = GPrefix.Setting[ThisMOD.Prefix]["quantity"]

    --- Indicador del MOD
    local BackColor  = ""

    BackColor        = data.raw["virtual-signal"]["signal-deny"].icon
    ThisMOD.delete   = { icon = BackColor, scale = 0.5 }

    BackColor        = data.raw["virtual-signal"]["signal-check"].icon
    ThisMOD.create   = { icon = BackColor, scale = 0.5 }

    ThisMOD.actions  = {
        ["create"] = "results",
        ["delete"] = "ingredients"
    }

    --- Receta base
    ThisMOD.Recipe   = {
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
function ThisMOD.getFluids()
    --- Fluidos a duplicar
    ThisMOD.Fluids = {}

    --- Se desean todos los liquidos
    if ThisMOD.all then
        ThisMOD.Fluids = GPrefix.Fluids
        return
    end

    --- Fluidos tomados del suelo
    for _, tile in pairs(data.raw.tile) do
        if tile.fluid then
            ThisMOD.Fluids[tile.fluid] = true
        end
    end

    --- Fluidos minables
    for _, resource in pairs(data.raw.resource) do
        local results = resource.minable
        results = results and results.results
        for _, result in pairs(results or {}) do
            if result.type == "fluid" then
                if result.name then ThisMOD.Fluids[result.name] = true end
            end
        end
    end

    --- Cargar los fluidos encontrados
    for name, _ in pairs(ThisMOD.Fluids) do
        ThisMOD.Fluids[name] = GPrefix.Fluids[name]
    end
end

--- Crear las recetas de los fluidos
function ThisMOD.CreateRecipes()
    --- Contenedor de las nuevas recetas
    local Recipes = {}

    --- Recorrer los fluidos
    for action, propiety in pairs(ThisMOD.actions) do
        for _, Fluid in pairs(ThisMOD.Fluids) do
            --- Crear una copia de los datos
            local recipe   = util.copy(ThisMOD.Recipe)
            local fluid    = util.copy(Fluid)

            --- Crear el subgroup
            local subgroup = ThisMOD.Prefix .. fluid.subgroup .. "-" .. action
            GPrefix.duplicate_subgroup(fluid.subgroup, subgroup)

            --- Actualizar los datos
            recipe.name                  = ThisMOD.Prefix .. fluid.name .. "-" .. action
            recipe.localised_name        = fluid.localised_name
            recipe.localised_description = fluid.localised_description

            recipe.subgroup              = subgroup
            recipe.order                 = fluid.order

            recipe.icons                 = fluid.icons

            --- Variaciones entre las recetas
            table.insert(recipe.icons, ThisMOD[action])
            recipe[propiety] = { {
                type = "fluid",
                name = fluid.name,
                amount = ThisMOD.quantity
            } }

            --- Crear el prototipo
            GPrefix.addDataRaw({ recipe })

            --- Guardar la nueva receta
            Recipes[action] = Recipes[action] or {}
            table.insert(Recipes[action], recipe)
        end
    end

    --- Ordenar las recetas
    for action, _ in pairs(ThisMOD.actions) do
        GPrefix.setOrder(Recipes[action])
    end
end

---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
ThisMOD.Start()

---------------------------------------------------------------------------------------------------
