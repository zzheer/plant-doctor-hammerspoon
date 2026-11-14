--- === PlantDoctorPhotoPrep ===
--- Prepare local plant photos for identification or care discussions.
--- No uploads, diagnosis, tracking or API calls. Originals remain unchanged.
local obj = {}
obj.__index = obj
obj.name = "PlantDoctorPhotoPrep"
obj.version = "1.0.0"
obj.author = "Moruk LLC <hi@moruk.co>"
obj.homepage = "https://plantdoctor.app"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local function dimensions(size)
  return size and type(size.w) == "number" and type(size.h) == "number"
    and size.w > 0 and size.h > 0 and size.w < math.huge and size.h < math.huge
    and size.w * size.h <= 36000000
end

--- PlantDoctorPhotoPrep:exportPhotos(paths, parent) -> table or nil, error
--- Method
--- Export up to four JPEG/PNG copies to a new folder, at most 2400 pixels per edge.
--- Parameters:
---  * paths - Array of local file paths, each at most 25 MiB and 36 megapixels
---  * parent - Existing destination directory
--- Returns:
---  * Table with directory, files and errors, or nil plus a preflight error
--- Notes:
---  * Output is rasterized PNG. Partial write failures are listed in errors.
function obj:exportPhotos(paths, parent)
  if type(paths) ~= "table" or #paths < 1 or #paths > 4 then
    return nil, "Choose between one and four JPEG or PNG photos."
  end
  local dest = type(parent) == "string" and hs.fs.attributes(parent)
  if not dest or dest.mode ~= "directory" then return nil, "Choose an existing destination folder." end
  local prepared = {}
  for _, path in ipairs(paths) do
    local ext = type(path) == "string" and path:lower():match("%.([^.]+)$")
    if ext ~= "jpg" and ext ~= "jpeg" and ext ~= "png" then return nil, "Only JPEG and PNG photos are supported." end
    local attr = hs.fs.attributes(path)
    if not attr or attr.mode ~= "file" or not attr.size or attr.size > 25 * 1024 * 1024 then
      return nil, "A photo is missing, is not a regular file, or exceeds 25 MiB."
    end
    local exif = hs.image.getExifFromPath(path)
    if exif and exif.PixelXDimension and exif.PixelYDimension
      and not dimensions({w=exif.PixelXDimension, h=exif.PixelYDimension}) then
      return nil, "A photo exceeds the 36 megapixel limit or has invalid dimensions."
    end
    local image = hs.image.imageFromPath(path)
    local size = image and image:size()
    if not dimensions(size) then return nil, "A photo cannot be decoded or has unsupported dimensions." end
    local scale = math.min(1, 2400 / math.max(size.w, size.h))
    prepared[#prepared + 1] = {image=image, size={w=math.max(1, math.floor(size.w * scale)), h=math.max(1, math.floor(size.h * scale))}}
  end
  local base = parent:gsub("/+$", "") .. "/PlantDoctorPhotos-" .. os.date("%Y%m%d-%H%M%S")
  local directory
  for n=1,100 do
    local candidate = base .. (n == 1 and "" or "-" .. n)
    if not hs.fs.attributes(candidate) and hs.fs.mkdir(candidate) then directory = candidate; break end
  end
  if not directory then return nil, "Cannot create a new export folder. Check destination permissions." end
  local result = {directory=directory, files={}, errors={}}
  for i, item in ipairs(prepared) do
    local path = directory .. string.format("/plant-photo-%02d.png", i)
    local ok, saved = pcall(function()
      if hs.fs.attributes(path) then return false end
      return item.image:copy():size(item.size, true):saveToFile(path, true, "PNG")
    end)
    if ok and saved then result.files[#result.files + 1] = path
    else result.errors[#result.errors + 1] = "Photo " .. i .. " could not be saved." end
  end
  return result
end

--- PlantDoctorPhotoPrep:choosePhotos() -> self
--- Method
--- Open native photo and destination pickers, then report local export results.
--- Parameters:
---  * None
--- Returns:
---  * The Spoon object
function obj:choosePhotos()
  local paths = hs.dialog.chooseFileOrFolder("Choose up to four plant photos", "", true, false, true, {"jpg", "jpeg", "png"}, true)
  if not paths then return self end
  local folders = hs.dialog.chooseFileOrFolder("Choose where to create the new photo folder", "", false, true, false)
  if not folders then return self end
  local result, err = self:exportPhotos(paths, folders[1])
  if not result then hs.dialog.blockAlert("Photos were not exported", err, "OK")
  else
    hs.dialog.blockAlert("Plant photo export", string.format("Saved %d of %d photos in:\n%s\n%s\nOriginals remain unchanged. Review visible private details before sharing.", #result.files, #paths, result.directory, table.concat(result.errors, "\n")), "OK")
  end
  return self
end

--- PlantDoctorPhotoPrep:showChecklist() -> self
--- Method
--- Display a checklist for useful plant identification and health photos.
--- Parameters:
---  * None
--- Returns:
---  * The Spoon object
function obj:showChecklist()
  hs.dialog.blockAlert("Plant photo checklist", "Use clear, natural light. Capture the whole plant, affected leaves, leaf undersides, and soil/pot drainage. Avoid faces, addresses and documents in the frame. Photo preparation does not identify plants or diagnose problems. Plant Doctor offers photo-based identification and care guidance at plantdoctor.app.", "OK")
  return self
end

--- PlantDoctorPhotoPrep:start() -> self
--- Method
--- Add the manual photo preparation menu. Safe to call repeatedly.
--- Parameters:
---  * None
--- Returns:
---  * The Spoon object
function obj:start()
  if not self.menu then
    self.menu = hs.menubar.new()
    if self.menu then self.menu:setTitle("Plant Photos"):setMenu({
      {title="Prepare plant photos…", fn=function() self:choosePhotos() end},
      {title="Photo checklist…", fn=function() self:showChecklist() end},
    }) end
  end
  return self
end

--- PlantDoctorPhotoPrep:stop() -> self
--- Method
--- Remove this Spoon's menu.
--- Parameters:
---  * None
--- Returns:
---  * The Spoon object
function obj:stop()
  if self.menu then self.menu:delete(); self.menu = nil end
  return self
end
return obj
