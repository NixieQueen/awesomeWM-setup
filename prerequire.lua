-- This file serves as a simple function to see if a module can be imported.
-- If not it will simply return nil
local function prerequire(m)
  local status, m = pcall(require, m)
  if not status then
    return nil
  end
  return m
end


return prerequire
