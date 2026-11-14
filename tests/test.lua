local root = assert(arg[1])
local fs, writes, mkdirs = {}, {}, 0
local failSave = false
local menuCount, deleted = 0, 0
local imageSize = {w=4000,h=2000}
hs = {
  fs = {
    attributes = function(p) return fs[p] end,
    mkdir = function(p)
      if fs[p] then return false end
      fs[p]={mode="directory"}; mkdirs=mkdirs+1; return true
    end,
  },
  image = {
    getExifFromPath = function() return {PixelXDimension=4000,PixelYDimension=2000} end,
    imageFromPath = function(p)
      if p:find("broken") then return nil end
      local im={}
      function im:copy() return self end
      function im:size(s)
        if not s then return imageSize end
        self.resized=s; return self
      end
      function im:saveToFile(path, scale, format)
        if failSave then return false end
        assert(scale==true and format=="PNG")
        assert(not fs[path]);fs[path]={mode="file",size=100}
        writes[#writes+1]={path=path,size=self.resized};return true
      end
      return im
    end,
  },
  menubar = {new = function()
    menuCount=menuCount+1
    return {setTitle=function(self) return self end,setMenu=function(self) return self end,
      delete=function() deleted=deleted+1 end}
  end},
  dialog = {chooseFileOrFolder=function() return nil end,blockAlert=function() end},
}
local realOpen=io.open
io.open=function(path, mode)
  if path:match("^/[^/]+%.%w+$") and mode=="rb" then
    local w,h=4000,2000
    if path:find("huge") then w,h=12000,12000 end
    local function u32(n) return string.char((n>>24)&255,(n>>16)&255,(n>>8)&255,n&255) end
    return {read=function() return "\137PNG\13\10\26\10"..u32(13).."IHDR"..u32(w)..u32(h) end,close=function() end}
  end
  return realOpen(path, mode)
end
local spoon=dofile(root.."/Source/PlantDoctorPhotoPrep.spoon/init.lua")
local function reset()
  fs={["/output"]={mode="directory"},["/source.jpg"]={mode="file",size=1000}}
  writes={};mkdirs=0;failSave=false;imageSize={w=4000,h=2000}
end
local function reject(paths,parent)
  local result,err=spoon:exportPhotos(paths,parent or "/output")
  assert(result==nil and type(err)=="string");assert(mkdirs==0 and #writes==0)
end
reset();reject({});reject({"/a","/b","/c","/d","/e"});reject({"/missing.jpg"})
reset();reject({"/source.jpg"},"/missing")
reset();fs["/source.jpg"].size=26*1024*1024;reject({"/source.jpg"})
reset();fs["/bad.gif"]={mode="file",size=100};reject({"/bad.gif"})
reset();fs["/broken.jpg"]={mode="file",size=100};reject({"/broken.jpg"})
reset();fs["/huge.png"]={mode="file",size=100};reject({"/huge.png"})
reset();local result,err=spoon:exportPhotos({"/source.jpg"},"/output")
assert(result and not err and #result.files==1 and #result.errors==0)
assert(writes[1].size.w==2400 and writes[1].size.h==1200)
assert(fs["/source.jpg"].size==1000 and not fs["/source.jpg"].changed)
local second=assert(spoon:exportPhotos({"/source.jpg"},"/output"))
assert(result.directory~=second.directory and #writes==2)
reset();imageSize={w=200,h=100};result=assert(spoon:exportPhotos({"/source.jpg"},"/output"))
assert(writes[1].size.w<=2400 and writes[1].size.h<=2400)
reset();failSave=true;result=assert(spoon:exportPhotos({"/source.jpg"},"/output"))
assert(#result.files==0 and #result.errors==1)
reset();spoon:choosePhotos();assert(mkdirs==0)
local selections=0
hs.dialog.chooseFileOrFolder=function()
 selections=selections+1
 if selections==1 then return {["1"]="/source.jpg"} end
 return {["1"]="/output"}
end
spoon:choosePhotos();assert(#writes==1)
spoon:start():start();assert(menuCount==1);spoon:stop():stop();assert(deleted==1)
assert(spoon.homepage=="https://plantdoctor.app" and spoon.author=="Moruk LLC <hi@moruk.co>")
print("PASS: Lua safety, export, cancel and lifecycle assertions")
