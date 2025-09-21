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

    --- Obtener los elementos
    This_MOD.get_elements()

    --- Modificar los elementos
    for iKey, spaces in pairs(This_MOD.to_be_processed) do
        for jKey, space in pairs(spaces) do
            --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

            --- Marcar como procesado
            This_MOD.processed[iKey] = This_MOD.processed[iKey] or {}
            This_MOD.processed[iKey][jKey] = true

            --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

            --- Crear los elementos
            This_MOD.create_item(space)
            This_MOD.create_entity(space)
            This_MOD.create_recipe(space)

            --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        end
    end

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
    This_MOD.delete = {
        icon = data.raw["virtual-signal"]["signal-deny"].icons[1].icon,
        scale = 0.5
    }

    This_MOD.create = {
        icon = data.raw["virtual-signal"]["signal-check"].icons[1].icon,
        scale = 0.5
    }

    This_MOD.indicator = {
        icon = data.raw["virtual-signal"]["signal-star"].icons[1].icon,
        scale = 0.25,
        shift = { 0, -5 }
    }

    This_MOD.indicator_bg = {
        icon = data.raw["virtual-signal"]["signal-black"].icons[1].icon,
        scale = 0.25,
        shift = { 0, -5 }
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores de la referencia en este MOD
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Contenedor de los fluidos a afectar
    This_MOD.fluids = {}

    --- Valores de referencia
    This_MOD.entity_name = "assembling-machine-2"
    This_MOD.new_entity_name = GMOD.name .. "-free-" .. This_MOD.entity_name

    --- Acciones
    This_MOD.actions = {
        delete = "ingredients",
        create = "results"
    }

    --- Receta base
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

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Funciones locales ]---
---------------------------------------------------------------------------

function This_MOD.get_elements()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Función para analizar cada entidad
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function valide(item, entity)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Validar valores de referencia
        if GMOD.entities[This_MOD.new_entity_name] then return end
        if not entity then return end
        if not item then return end

        --- Validar si ya fue procesado
        if
            This_MOD.processed[entity.type] and
            This_MOD.processed[entity.type][item.name]
        then
            return
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Valores para el proceso
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Space = {}
        Space.item = item
        Space.entity = entity

        Space.recipe = GMOD.recipes[Space.item.name]
        Space.recipe = Space.recipe and Space.recipe[1] or nil

        Space.prefix = This_MOD.new_entity_name

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Guardar la información
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        This_MOD.to_be_processed[entity.type] = This_MOD.to_be_processed[entity.type] or {}
        This_MOD.to_be_processed[entity.type][entity.name] = Space

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Fluidos a afectar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function get_fluids(fluids)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Fluidos a afectar
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Fluids = {}
        for _, recipes in pairs(GMOD.recipes) do
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

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Fluidos que se crean sin recetas
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        for _, entity in pairs(GMOD.entities) do
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

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Cambiar los valores vacios
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        for key, value in pairs(Fluids) do
            if not GMOD.get_length(value) then
                Fluids[key] = false
            end
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Se desean todos los liquidos
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        if This_MOD.setting.all then
            for key, value in pairs(Fluids) do
                fluids[key] = value
            end
            return
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Fluidos en el ambiente
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Fluidos tomados del suelo
        for _, tile in pairs(data.raw.tile) do
            if tile.fluid then
                fluids[tile.fluid] = Fluids[tile.fluid]
            end
        end

        --- Fluidos minables
        for _, resource in pairs(data.raw.resource) do
            local results = resource.minable
            results = results and results.results
            for _, result in pairs(results or {}) do
                if result.type == "fluid" then
                    fluids[result.name] = Fluids[result.name]
                end
            end
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores a afectar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    valide(
        GMOD.items[This_MOD.entity_name],
        GMOD.entities[This_MOD.entity_name]
    )

    get_fluids(This_MOD.fluids)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------

function This_MOD.create_item(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.item then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Item = GMOD.copy(space.item)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Item.name = space.prefix

    Item.localised_name = GMOD.copy(space.entity.localised_name)

    local Order = tonumber(Item.order) + 1
    Item.order = GMOD.pad_left_zeros(#Item.order, Order)

    table.insert(Item.icons, This_MOD.indicator_bg)
    table.insert(Item.icons, This_MOD.indicator)

    Item.place_result = Item.name

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Item)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_entity(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.entity then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Agregar las recetas a la entidad existente
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if space.entity[This_MOD.new_entity_name] then
        local Entity = space.entity[This_MOD.new_entity_name]
        for action, _ in pairs(This_MOD.actions) do
            table.insert(
                Entity.crafting_categories,
                This_MOD.prefix .. action
            )

            GMOD.extend({
                type = "recipe-category",
                name = This_MOD.prefix .. action
            })
        end
        return
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Entity = GMOD.copy(space.entity)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Entity.name = space.prefix

    Entity.minable.results = { {
        type = "item",
        name = Entity.name,
        amount = 1
    } }

    Entity.fast_replaceable_group = nil
    Entity.next_upgrade = nil

    Entity.energy_source = { type = "void" }

    Entity.crafting_categories = {}
    for action, _ in pairs(This_MOD.actions) do
        table.insert(
            Entity.crafting_categories,
            This_MOD.prefix .. action
        )

        GMOD.extend({
            type = "recipe-category",
            name = This_MOD.prefix .. action
        })
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Agregar los indicadores del mod
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Entity.icons = GMOD.copy(space.item.icons)
    table.insert(Entity.icons, This_MOD.indicator_bg)
    table.insert(Entity.icons, This_MOD.indicator)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Entity)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_recipe(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.recipe then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Receta para la entidad
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function entity()
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Duplicar el elemento
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Recipe = GMOD.copy(space.recipe)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Cambiar algunas propiedades
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        Recipe.name = space.prefix

        Recipe.main_product = nil
        Recipe.maximum_productivity = 1000000
        Recipe.enabled = true

        Recipe.icons = GMOD.copy(space.item.icons)
        table.insert(Recipe.icons, This_MOD.indicator_bg)
        table.insert(Recipe.icons, This_MOD.indicator)

        local Order = tonumber(Recipe.order) + 1
        Recipe.order = GMOD.pad_left_zeros(#Recipe.order, Order)

        Recipe.ingredients = {}

        Recipe.results = { {
            type = "item",
            name = Recipe.name,
            amount = 1
        } }

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        ---- Crear el prototipo
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        GMOD.extend(Recipe)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Recetas de los fluidos
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function fluids()
        for fluid, temperatures in pairs(This_MOD.fluids) do
            for temperature, _ in pairs(temperatures or { [false] = true }) do
                for action, propiety in pairs(This_MOD.actions) do
                    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
                    --- Valores a usar
                    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

                    local Flag = propiety == This_MOD.actions.create and temperature
                    local Recipe = GMOD.copy(This_MOD.recipe_base)
                    local Fluid = GMOD.copy(GMOD.fluids[fluid])

                    --- --- --- --- --- --- --- --- --- --- --- --- --- ---





                    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
                    --- Crear el subgroup
                    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

                    local Subgroup = This_MOD.prefix .. Fluid.subgroup .. "-" .. action
                    GMOD.duplicate_subgroup(Fluid.subgroup, Subgroup)

                    --- --- --- --- --- --- --- --- --- --- --- --- --- ---





                    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
                    --- Actualizar los datos
                    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

                    Recipe.name = This_MOD.prefix .. action .. "-" .. This_MOD.setting.amount .. "u-" .. Fluid.name ..
                        (Flag and "-t" .. math.floor(temperature or 0) or "")
                    Recipe.localised_description = Fluid.localised_description
                    Recipe.localised_name = Fluid.localised_name

                    Recipe.subgroup = Subgroup
                    Recipe.order = Fluid.order

                    Recipe.icons = Fluid.icons

                    Recipe.category = This_MOD.prefix .. action

                    --- --- --- --- --- --- --- --- --- --- --- --- --- ---





                    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
                    --- Variaciones entre las recetas
                    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

                    table.insert(Recipe.icons, This_MOD[action])
                    Recipe[propiety] = { {
                        type = "fluid",
                        name = Fluid.name,
                        amount = This_MOD.setting.amount,
                        temperature = Flag and temperature or nil,
                        ignored_by_stats = This_MOD.setting.amount
                    } }

                    --- --- --- --- --- --- --- --- --- --- --- --- --- ---





                    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
                    --- Guardar la recetas creadas
                    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

                    This_MOD.processed.fluids = This_MOD.processed.fluids or {}
                    This_MOD.processed.fluids[Fluid.name] = true

                    --- --- --- --- --- --- --- --- --- --- --- --- --- ---





                    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
                    --- Crear el prototipo
                    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

                    GMOD.extend(Recipe)

                    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
                end
            end
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear las recetas
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    entity()
    fluids()

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Iniciar el MOD ]---
---------------------------------------------------------------------------

This_MOD.start()

---------------------------------------------------------------------------
