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

    This_MOD.create_entity()
    This_MOD.create_item()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Valores de la referencia
function This_MOD.setting_mod()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores a duplicar
    This_MOD.fluids = {}
    This_MOD.entity = GPrefix.entities["assembling-machine-2"]
    This_MOD.item = GPrefix.get_item_create_entity(This_MOD.entity)
    This_MOD.recipes = GPrefix.recipes[This_MOD.item.name]

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

    --- Indicador de mod
    This_MOD.indicator = {
        icon = GPrefix.fluids["sulfuric-acid"].icons[1].icon,
        shift = { 0, -5 },
        scale = 0.25
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
        category = "",
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

--- Crear las recetas
function This_MOD.create_recipes()
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
            Recipe.category = This_MOD.prefix .. action

            --- Variaciones entre las recetas
            table.insert(Recipe.icons, This_MOD[action])
            Recipe[propiety] = { {
                type = "fluid",
                name = Fluid.name,
                amount = This_MOD.amount
            } }

            --- Crear el prototipo
            GPrefix.extend(Recipe)
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Crear las entidades
function This_MOD.create_entity()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Duplicar la entidad
    local Entity = util.copy(This_MOD.entity)

    --- Nombre de la entidad
    Entity.name = This_MOD.prefix .. Entity.name

    --- Anular los variables
    Entity.fast_replaceable_group = nil
    Entity.next_upgrade = nil

    --- Cambiar las propiedades
    Entity.energy_source = { type = "void" }
    table.insert(Entity.icons, This_MOD.indicator)
    Entity.minable.results = { {
        type = "item",
        name = This_MOD.prefix .. This_MOD.item.name,
        amount = 1
    } }

    --- Recetas validas
    Entity.crafting_categories = {}
    for action, _ in pairs(This_MOD.actions) do
        --- Agregar la categoria
        table.insert(
            Entity.crafting_categories,
            This_MOD.prefix .. action
        )

        --- Crear las categorias
        GPrefix.extend({
            type = "recipe-category",
            name = This_MOD.prefix .. action
        })
    end

    --- Crear la entiadad
    GPrefix.extend(Entity)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Crear los objetos
function This_MOD.create_item()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Duplicar la entidad
    local Item = util.copy(This_MOD.item)

    --- Nombre de la entidad
    Item.name = This_MOD.prefix .. Item.name

    --- Cambiar las propiedades
    Item.place_result = This_MOD.prefix .. Item.place_result
    table.insert(Item.icons, This_MOD.indicator)

    --- Crear item
    GPrefix.extend(Item)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
This_MOD.start()

---------------------------------------------------------------------------------------------------
