local Blur = NewInstance("BlurEffect", {Name = RandomString(), Parent = Services.Lighting, Size = 4, Enabled = false})
local Depth = NewInstance("DepthOfFieldEffect", {Name = RandomString(), Parent = Services.Lighting, FarIntensity = 0.75, FocusDistance = 0.05, InFocusRadius = 10, NearIntensity = 0.75, Enabled = false})
return {
	Name = "Shader Mod",
	Commands = {
		{
			Name = "toggleshader",
			Description = "Toggles shaders.",
			Function = function()
				Blur.Enabled, Depth.Enabled = not Blur.Enabled, not Depth.Enabled
			end
		}
	}
}
