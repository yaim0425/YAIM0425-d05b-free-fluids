---------------------------------------------------------------------------
---[ data-final-fixes.lua ]---
---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Información del MOD ]---
---------------------------------------------------------------------------

local This_MOD = GMOD.get_id_and_name()
if not This_MOD then return end
GMOD[This_MOD.id] = This_MOD

---------------------------------------------------------------------------

function This_MOD.start()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores de la referencia
    This_MOD.setting_mod()

    --- Obtener los elementos
    This_MOD.get_elements()

    --- Modificar los elementos
    for _, spaces in pairs(This_MOD.to_be_processed) do
        for _, space in pairs(spaces) do
            --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

            --- Crear los elementos
            This_MOD.create_item(space)
            This_MOD.create_entity(space)
            This_MOD.create_recipe(space)

            --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        end
    end

    --- Crear las recetas para los fluidos
    This_MOD.create_recipe___free()

    --- Ejecutar otro MOD
    if GMOD.d01b then GMOD.d01b.start() end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.setting_mod()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validar si se cargó antes
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Contenedor de los elementos que el MOD modoficará
    This_MOD.to_be_processed = {}

    --- Validar si se cargó antes
    if This_MOD.setting then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores de la referencia en todos los MODs
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cargar la configuración
    This_MOD.setting = GMOD.setting[This_MOD.id] or {}

    --- Indicador del mod
    This_MOD.delete = { icon = GMOD.signal.deny, scale = 0.5 }
    This_MOD.create = { icon = GMOD.signal.check, scale = 0.5 }

    This_MOD.indicator = { icon = GMOD.signal.star, scale = 0.25, shift = { 0, -5 } }
    This_MOD.indicator_bg = { icon = GMOD.signal.black, scale = 0.25, shift = { 0, -5 } }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores de la referencia en este MOD
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores de referencia
    This_MOD.old_entity_name = "assembling-machine-2"
    This_MOD.new_entity_name = GMOD.name .. "-A00A-market"
    This_MOD.new_localised_name = { "", { "entity-name.market" } }

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
        subgroup = "",
        order = "",

        ingredients = {},
        results = {}
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Cambios del MOD ]---
---------------------------------------------------------------------------

function This_MOD.get_elements()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Función para analizar cada entidad
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function valide_entity(item, entity)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Validar valores de referencia
        if GMOD.entities[This_MOD.new_entity_name] then return end

        --- Validar la entity
        if not entity then return end

        --- Validar el item
        if not item then return end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Valores para el proceso
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Space = {}
        Space.item = item
        Space.entity = entity

        Space.recipe = GMOD.recipes[Space.item.name]
        Space.recipe = Space.recipe and Space.recipe[1] or nil

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

    --- Entidad que se va a duplicar
    valide_entity(
        GMOD.items[This_MOD.old_entity_name],
        GMOD.entities[This_MOD.old_entity_name]
    )

    --- Fluidos a afectar
    This_MOD.fluids = {}
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

    --- Nombre
    Item.name = This_MOD.new_entity_name

    --- Apodo
    Item.localised_name = This_MOD.new_localised_name

    --- Actualizar el order
    local Order = tonumber(Item.order) + 1
    Item.order = GMOD.pad_left_zeros(#Item.order, Order)

    --- Agregar indicador del MOD
    table.insert(Item.icons, This_MOD.indicator_bg)
    table.insert(Item.icons, This_MOD.indicator)

    --- Entidad a crear
    Item.place_result = This_MOD.new_entity_name

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
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Entity = GMOD.copy(space.entity)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nombre
    Entity.name = This_MOD.new_entity_name

    --- Apodo
    Entity.localised_name = This_MOD.new_localised_name

    --- Objeto a minar
    Entity.minable.results = { {
        type = "item",
        name = This_MOD.new_entity_name,
        amount = 1
    } }

    --- Elimnar propiedades inecesarias
    Entity.fast_replaceable_group = nil
    Entity.next_upgrade = nil

    --- No usa energía
    Entity.energy_source = { type = "void" }

    --- Categoria de fabricación
    Entity.crafting_categories = {}

    --- Agregar indicador del MOD
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
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Recipe = GMOD.copy(space.recipe)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nombre
    Recipe.name = This_MOD.new_entity_name

    --- Apodo y descripción
    Recipe.localised_name = This_MOD.new_localised_name

    --- Elimnar propiedades inecesarias
    Recipe.main_product = nil

    --- Productividad
    Recipe.allow_productivity = true
    Recipe.maximum_productivity = 1000000

    --- Receta desbloqueada por tecnología
    Recipe.enabled = true

    --- Agregar indicador del MOD
    Recipe.icons = GMOD.copy(space.item.icons)
    table.insert(Recipe.icons, This_MOD.indicator_bg)
    table.insert(Recipe.icons, This_MOD.indicator)

    --- Actualizar el order
    local Order = tonumber(Recipe.order) + 1
    Recipe.order = GMOD.pad_left_zeros(#Recipe.order, Order)

    --- Ingredientes
    Recipe.ingredients = {}

    --- Resultados
    Recipe.results = { {
        type = "item",
        name = This_MOD.new_entity_name,
        amount = 1
    } }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Recipe)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------

function This_MOD.create_recipe___free()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Procesar cada liquido
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function validate_fluid(action, propiety, temperature, fluid)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Valores a usar
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Bandera de usar la temperatura
        local Flag = propiety == This_MOD.actions.create and temperature

        --- Nombre de la receta
        local Name =
            This_MOD.prefix ..
            action .. "-" ..
            This_MOD.setting.amount .. "u-" ..
            fluid.name ..
            (Flag and "-t" .. math.floor(temperature) or "")

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        if data.raw.recipe[Name] then return end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Crear el subgroup
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Subgroup = This_MOD.prefix .. fluid.subgroup .. "-" .. action
        GMOD.duplicate_subgroup(fluid.subgroup, Subgroup)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Duplicar el elemento
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Recipe = GMOD.copy(This_MOD.recipe_base)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Cambiar algunas propiedades
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Nombre
        Recipe.name = Name

        --- Apodo y descripción
        Recipe.localised_name = GMOD.copy(fluid.localised_name)
        Recipe.localised_description = GMOD.copy(fluid.localised_description)

        --- Subgrupo y Order
        Recipe.subgroup = Subgroup
        Recipe.order = fluid.order

        --- Agregar indicador del MOD
        Recipe.icons = GMOD.copy(fluid.icons)

        --- Categoria de fabricación
        Recipe.category = This_MOD.prefix .. action

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Variaciones entre las recetas
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        table.insert(Recipe.icons, This_MOD[action])
        Recipe[propiety] = { {
            type = "fluid",
            name = fluid.name,
            amount = This_MOD.setting.amount,
            temperature = Flag and temperature or nil,
            ignored_by_stats = This_MOD.setting.amount
        } }

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Crear el prototipo
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        GMOD.extend(Recipe)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Recorrer cada fluidos
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    for fluid, temperatures in pairs(This_MOD.fluids) do
        for temperature, _ in pairs(temperatures or { [false] = true }) do
            for action, propiety in pairs(This_MOD.actions) do
                local Fluid = GMOD.copy(GMOD.fluids[fluid])
                validate_fluid(action, propiety, temperature, Fluid)
            end
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear categoria y agrega a la maquita
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Category = GMOD.entities[This_MOD.new_entity_name].crafting_categories
    for action, _ in pairs(This_MOD.actions) do
        local Name = This_MOD.prefix .. action
        if GMOD.get_key(Category, Name) then break end
        GMOD.extend({ type = "recipe-category", name = Name })
        table.insert(Category, Name)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Iniciar el MOD ]---
---------------------------------------------------------------------------

This_MOD.start()

---------------------------------------------------------------------------
