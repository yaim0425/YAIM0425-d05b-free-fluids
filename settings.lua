---------------------------------------------------------------------------------------------------
---> settings-final-fixes.lua <---
---------------------------------------------------------------------------------------------------

data:extend({
	{
		type = "int-setting",
		name = "zzzYAIM0425-0500-amount",
		localised_name = { "description.amount" },
		order = "1",
		setting_type = "startup",
		minimum_value = 1000,
		maximum_value = 65000,
		default_value = 1000
	},
	{
		type = "bool-setting",
		name = "zzzYAIM0425-0500-all",
		localised_name = { "gui-blueprint-library.shelf-choice-all" },
		order = "2",
		setting_type = "startup",
		default_value = false
	}
})

---------------------------------------------------------------------------------------------------
