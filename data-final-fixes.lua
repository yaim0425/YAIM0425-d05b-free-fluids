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

    --- Crear entidad y relacionado
    This_MOD.create_entity()
    This_MOD.create_item()
    This_MOD.create_recipe()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Valores de la referencia
function This_MOD.setting_mod()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Valores a duplicar
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    This_MOD.fluids = {}
    This_MOD.entity = GPrefix.entities["assembling-machine-2"]
    This_MOD.item = GPrefix.get_item_create_entity(This_MOD.entity)
    This_MOD.recipe = GPrefix.recipes[This_MOD.item.name][1]

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Valores de configuración
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    This_MOD.all = GPrefix.Setting[This_MOD.id]["all"]
    This_MOD.amount = GPrefix.Setting[This_MOD.id]["amount"]

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Indicador del MOD
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local BackColor = ""

    BackColor = data.raw["virtual-signal"]["signal-deny"].icons[1].icon
    This_MOD.delete = { icon = BackColor, scale = 0.5 }

    BackColor = data.raw["virtual-signal"]["signal-check"].icons[1].icon
    This_MOD.create = { icon = BackColor, scale = 0.5 }

    BackColor = data.raw.fluid["sulfuric-acid"].icons[1].icon
    This_MOD.indicator = { icon = BackColor, scale = 0.25, shift = { 0, -5 } }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Acciones
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    This_MOD.actions = {}
    This_MOD.actions.create = "results"
    This_MOD.actions.delete = "ingredients"

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Receta base
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    This_MOD.recipe_base = {
        type = "recipe",
        name = "",
        localised_name = {},
        localised_description = {},
        energy_required = 0.002,

        hide_from_player_crafting = true,
        category = "crafting-with-fluid",
        subgroup = "",
        order = "",

        ingredients = {},
        results = {},
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
            local Recipe = util.copy(This_MOD.recipe_base)
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
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Crear las entidades
function This_MOD.create_entity()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Validar
    local Name = GPrefix.name .. "-free-" .. This_MOD.entity.name
    if GPrefix.entities[Name] then
        --- Modificar las recetas
        for action, _ in pairs(This_MOD.actions) do
            for _, fluid in pairs(This_MOD.fluids) do
                local Recipe = data.raw.recipe[This_MOD.prefix .. fluid.name .. "-" .. action]
                Recipe.category = GPrefix.name .. "-free-" .. action
            end
        end
        return
    end

    --- Duplicar la entidad
    local Entity = util.copy(This_MOD.entity)

    --- Nombre de la entidad
    Entity.name = Name

    --- Anular los variables
    Entity.fast_replaceable_group = nil
    Entity.next_upgrade = nil

    --- Cambiar las propiedades
    Entity.energy_source = { type = "void" }
    table.insert(Entity.icons, This_MOD.indicator)
    Entity.minable.results = { {
        type = "item",
        name = GPrefix.name .. "-free-" .. This_MOD.item.name,
        amount = 1
    } }

    --- Recetas validas
    Entity.crafting_categories = {}
    for action, _ in pairs(This_MOD.actions) do
        --- Agregar la categoria
        table.insert(
            Entity.crafting_categories,
            GPrefix.name .. "-free-" .. action
        )

        --- Crear las categorias
        GPrefix.extend({
            type = "recipe-category",
            name = GPrefix.name .. "-free-" .. action
        })

        --- Modificar las recetas
        for _, fluid in pairs(This_MOD.fluids) do
            local Recipe = data.raw.recipe[This_MOD.prefix .. fluid.name .. "-" .. action]
            Recipe.category = GPrefix.name .. "-free-" .. action
        end
    end

    --- Crear la entiadad
    GPrefix.extend(Entity)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Crear los objetos
function This_MOD.create_item()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Validar
    local Name = GPrefix.name .. "-free-" .. This_MOD.item.name
    if GPrefix.items[Name] then return end

    --- Duplicar la entidad
    local Item = util.copy(This_MOD.item)

    --- Nombre de la entidad
    Item.name = Name

    --- Cambiar las propiedades
    Item.place_result = GPrefix.name .. "-free-" .. This_MOD.entity.name
    table.insert(Item.icons, This_MOD.indicator)

    --- Crear item
    GPrefix.extend(Item)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Crear la receta
function This_MOD.create_recipe()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Validar
    local Name = GPrefix.name .. "-free-" .. This_MOD.recipe.name
    if data.raw.recipe[Name] then return end

    --- Duplicar la receta
    local Recipe = util.copy(This_MOD.recipe)

    --- Cambiar los valores
    Recipe.name = Name
    Recipe.ingredients = {}
    Recipe.results = { {
        type = "item",
        name = GPrefix.name .. "-free-" .. This_MOD.item.name,
        amount = 1
    } }

    --- Crear la receta
    GPrefix.extend(Recipe)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
This_MOD.start()

---------------------------------------------------------------------------------------------------
