local menu_entry = "Create Sample"
local menu_group = "General"

local vb = renoise.ViewBuilder()
local sample_rate     = vb:valuebox { min= 20, max= 192000, value=44100 }
local bit_depth       = vb:valuebox { min= 1,  max= 64,     value=16 }
local num_channels    = vb:valuebox { min= 1,  max= 2,      value=2 }
local num_frames      = vb:valuebox { min= 1,  max= 999999, value=44100 }

local view = vb:column {
  margin= 8, spacing= 4,
  vb:row { vb:text { width = 160, text="Sample Rate:"  }, sample_rate  },
  vb:row { vb:text { width = 160, text="Bit Depth:"    }, bit_depth    },
  vb:row { vb:text { width = 160, text="Channels:"     }, num_channels },
  vb:row { vb:text { width = 160, text="Sample Count:" }, num_frames   }
}

local function validate (sample_buffer)
  if (sample_buffer.has_sample_data) then
    local response = renoise.app():show_prompt("Warning!","Creating a new sample will overwrite the existing sample buffer.",{ "Ok", "Cancel" } )
    if response ~= "Ok" then
      return false
    end
  end
  return true
end

local function init (sample_buffer)
  sample_buffer:create_sample_data(
    sample_rate.value,
    bit_depth.value,
    num_channels.value,
    num_frames.value
  )
end

return {
  menu_entry = menu_entry,
  menu_group = menu_group,
  validate   = validate,
  init = init,
  view = view
}