local Blur = NewInstance("BlurEffect", {Name = RandomString(), Parent = Services.Lighting, Size = 4, Enabled = false})

return {
	Name = "Shader Mod",
	Commands = {
		{
			Name = "toggleshader",
			Description = "Toggles shaders."
			Function = function()
				-- code
			end
		}
	}
}
