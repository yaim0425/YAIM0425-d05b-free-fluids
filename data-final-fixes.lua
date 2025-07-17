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
    This_MOD.setting_mod()

    --- Fluidos a afectar
    This_MOD.get_fluids()

    --- Crear las recetas de los fluidos
    This_MOD.create_recipes()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Valores de la referencia
function This_MOD.setting_mod()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Fluidos a duplicar
    This_MOD.fluids = {}

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores de configuración
    This_MOD.all = GPrefix.Setting[This_MOD.id]["all"]
    This_MOD.amount = GPrefix.Setting[This_MOD.id]["amount"]

    --- Indicador del MOD
    local BackColor = ""

    BackColor = data.raw["virtual-signal"]["signal-deny"].icons[1].icon
    This_MOD.delete = { icon = BackColor, scale = 0.5 }

    BackColor = data.raw["virtual-signal"]["signal-check"].icons[1].icon
    This_MOD.create = { icon = BackColor, scale = 0.5 }

    This_MOD.actions = {
        ["create"] = "results",
        ["delete"] = "ingredients"
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Receta base
    This_MOD.recipe = {
        type = "recipe",
        name = "",
        localised_name = {},
        localised_description = {},
        energy_required = 0.002,

        hide_from_player_crafting = true,
        enabled = true,
        category = "crafting-with-fluid",
        subgroup = "",
        order = "",

        ingredients = {},
        results = {}
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Fluidos a afectar
function This_MOD.get_fluids()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Se desean todos los liquidos
    if This_MOD.all then
        This_MOD.fluids = GPrefix.fluids
        return
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Fluidos tomados del suelo
    for _, tile in pairs(data.raw.tile) do
        if tile.fluid then
            This_MOD.fluids[tile.fluid] = true
        end
    end

    --- Fluidos minables
    for _, resource in pairs(data.raw.resource) do
        local results = resource.minable
        results = results and results.results
        for _, result in pairs(results or {}) do
            if result.type == "fluid" then
                This_MOD.fluids[result.name] = true
            end
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cargar los fluidos encontrados
    for name, _ in pairs(This_MOD.fluids) do
        This_MOD.fluids[name] = GPrefix.fluids[name]
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Crear las recetas de los fluidos
function This_MOD.create_recipes()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Contenedor de las nuevas recetas
    local Recipes = {}

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Recorrer los fluidos
    for action, propiety in pairs(This_MOD.actions) do
        for _, fluid in pairs(This_MOD.fluids) do
            --- Crear una copia de los datos
            local Recipe = util.copy(This_MOD.recipe)
            local Fluid = util.copy(fluid)

            --- Crear el subgroup
            local Subgroup = This_MOD.prefix .. Fluid.subgroup .. "-" .. action
            GPrefix.duplicate_subgroup(Fluid.subgroup, Subgroup)

            --- Actualizar los datos
            Recipe.name = This_MOD.prefix .. Fluid.name .. "-" .. action
            Recipe.localised_name = Fluid.localised_name
            Recipe.localised_description = Fluid.localised_description

            Recipe.subgroup = Subgroup
            Recipe.order = Fluid.order

            Recipe.icons = Fluid.icons

            --- Variaciones entre las recetas
            table.insert(Recipe.icons, This_MOD[action])
            Recipe[propiety] = { {
                type = "fluid",
                name = Fluid.name,
                amount = This_MOD.amount
            } }

            --- Crear el prototipo
            GPrefix.extend(Recipe)

            --- Guardar la nueva receta
            Recipes[action] = Recipes[action] or {}
            table.insert(Recipes[action], Recipe)
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    -- --- Ordenar las recetas
    -- for action, _ in pairs(This_MOD.actions) do
    --     GPrefix.setOrder(Recipes[action])
    -- end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
This_MOD.start()
-- ERROR()

---------------------------------------------------------------------------------------------------
