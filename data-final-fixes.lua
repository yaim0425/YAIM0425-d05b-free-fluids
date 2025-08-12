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

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

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
    This_MOD.recipes = { create = {}, delete = {} }
    This_MOD.entity = GPrefix.entities["assembling-machine-2"]
    This_MOD.item = GPrefix.get_item_create_entity(This_MOD.entity)
    This_MOD.recipe = GPrefix.recipes[This_MOD.item.name][1]

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Valores de configuración
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    This_MOD.all = GPrefix.setting[This_MOD.id]["all"]
    This_MOD.amount = GPrefix.setting[This_MOD.id]["amount"]

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Indicador del MOD
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Signal = ""

    Signal = data.raw["virtual-signal"]["signal-deny"].icons[1].icon
    This_MOD.delete = { icon = Signal, scale = 0.5 }

    Signal = data.raw["virtual-signal"]["signal-check"].icons[1].icon
    This_MOD.create = { icon = Signal, scale = 0.5 }

    Signal = data.raw["virtual-signal"]["signal-star"].icons[1].icon
    This_MOD.indicator = { icon = Signal, scale = 0.25, shift = { 0, -5 } }

    Signal = data.raw["virtual-signal"]["signal-black"].icons[1].icon
    This_MOD.indicator_bg = { icon = Signal, scale = 0.25, shift = { 0, -5 } }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Acciones
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    This_MOD.actions = {
        delete = "ingredients",
        create = "results"
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Receta base
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    This_MOD.recipe_base = {
        type = "recipe",
        name = "",
        localised_name = {},
        localised_description = {},
        energy_required = 1,

        hide_from_player_crafting = true,
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

    --- Fluidos a afectar
    local Fluids = {}
    for _, recipes in pairs(GPrefix.recipes) do
        for _, recipe in pairs(recipes) do
            for _, elements in pairs({ recipe.ingredients, recipe.results }) do
                for _, element in pairs(elements) do
                    if element.type == "fluid" then
                        local Temperatures = Fluids[element.name] or {}
                        Fluids[element.name] = Temperatures

                        if element.maximum_temperature then
                            Temperatures[element.maximum_temperature] = true
                        elseif element.temperature then
                            Temperatures[element.temperature] = true
                        end
                    end
                end
            end
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Fluidos que se crean sin recetas
    for _, entity in pairs(GPrefix.entities) do
        repeat
            --- Validación
            if not entity.output_fluid_box then break end
            if entity.output_fluid_box.pipe_connections == 0 then break end
            if not entity.output_fluid_box.filter then break end
            if not entity.target_temperature then break end

            --- Renombrar variable
            local Name = entity.output_fluid_box.filter

            --- Guardar la temperatura
            local Temperatures = Fluids[Name] or {}
            Fluids[Name] = Temperatures
            Temperatures[entity.target_temperature] = true
        until true
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cambiar los valores vacios
    for key, value in pairs(Fluids) do
        if not GPrefix.get_length(value) then
            Fluids[key] = false
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Se desean todos los liquidos
    if This_MOD.all then
        This_MOD.fluids = Fluids
        return
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Fluidos tomados del suelo
    for _, tile in pairs(data.raw.tile) do
        if tile.fluid then
            This_MOD.fluids[tile.fluid] = Fluids[tile.fluid]
        end
    end

    --- Fluidos minables
    for _, resource in pairs(data.raw.resource) do
        local results = resource.minable
        results = results and results.results
        for _, result in pairs(results or {}) do
            if result.type == "fluid" then
                This_MOD.fluids[result.name] = Fluids[result.name]
            end
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Crear las recetas
function This_MOD.create_recipes()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Recorrer los fluidos
    for fluid, temperatures in pairs(This_MOD.fluids) do
        for temperature, _ in pairs(temperatures or { [false] = true }) do
            for action, propiety in pairs(This_MOD.actions) do
                local Flag = propiety == This_MOD.actions.create and temperature

                --- Crear una copia de los datos
                local Recipe = util.copy(This_MOD.recipe_base)
                local Fluid = GPrefix.fluids[fluid]

                --- Crear el subgroup
                local Subgroup = This_MOD.prefix .. Fluid.subgroup .. "-" .. action
                GPrefix.duplicate_subgroup(Fluid.subgroup, Subgroup)

                --- Actualizar los datos
                Recipe.name = This_MOD.prefix .. action .. "-" .. This_MOD.amount .. "-" .. Fluid.name .. "-" ..
                    (Flag and temperature or Fluid.default_temperature)
                Recipe.localised_description = Fluid.localised_description
                Recipe.localised_name = Fluid.localised_name

                Recipe.subgroup = Subgroup
                Recipe.order = Fluid.order

                Recipe.icons = util.copy(Fluid.icons)

                --- Variaciones entre las recetas
                table.insert(Recipe.icons, This_MOD[action])
                Recipe[propiety] = { {
                    type = "fluid",
                    name = Fluid.name,
                    amount = This_MOD.amount,
                    temperature = Flag and temperature or nil,
                    ignored_by_stats = This_MOD.amount
                } }

                --- Guardar la recetas creadas
                table.insert(This_MOD.recipes[action], Recipe.name)

                --- Crear el prototipo
                GPrefix.extend(Recipe)
            end
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
    table.insert(Entity.icons, This_MOD.indicator_bg)
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
        for _, name in pairs(This_MOD.recipes[action]) do
            local Recipe = data.raw.recipe[name]
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
    table.insert(Item.icons, This_MOD.indicator_bg)
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
