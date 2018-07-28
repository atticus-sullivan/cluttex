::dummy:: --[[
@texlua "%~f0" %*
@goto :eof
]]
os.type = os.type or "windows"
if os.type == "windows" then
package.preload["texrunner.pathutil"] = function(...)
--[[
  Copyright 2016 ARATA Mizuki

  This file is part of ClutTeX.

  ClutTeX is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  ClutTeX is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with ClutTeX.  If not, see <http://www.gnu.org/licenses/>.
]]

-- pathutil module

local assert = assert
local select = select
local string = string
local string_find = string.find
local string_sub = string.sub
local string_match = string.match
local string_gsub = string.gsub
local filesys = require "lfs"

local function basename(path)
  local i = 0
  while true do
    local j = string_find(path, "[\\/]", i + 1)
    if j == nil then
      return string_sub(path, i + 1)
    elseif j == #path then
      return string_sub(path, i + 1, -2)
    end
    i = j
  end
end


local function dirname(path)
  local i = 0
  while true do
    local j = string_find(path, "[\\/]", i + 1)
    if j == nil then
      if i == 0 then
        -- No directory portion
        return "."
      elseif i == 1 then
        -- Root
        return string_sub(path, 1, 1)
      else
        -- Directory portion without trailing slash
        return string_sub(path, 1, i - 1)
      end
    end
    i = j
  end
end


local function parentdir(path)
  local i = 0
  while true do
    local j = string_find(path, "[\\/]", i + 1)
    if j == nil then
      if i == 0 then
        -- No directory portion
        return "."
      elseif i == 1 then
        -- Root
        return string_sub(path, 1, 1)
      else
        -- Directory portion without trailing slash
        return string_sub(path, 1, i - 1)
      end
    elseif j == #path then
      -- Directory portion without trailing slash
      return string_sub(path, 1, i - 1)
    end
    i = j
  end
end


local function trimext(path)
  return (string_gsub(path, "%.[^\\/%.]*$", ""))
end


local function ext(path)
  return string_match(path, "%.([^\\/%.]*)$") or ""
end


local function replaceext(path, newext)
  local newpath, n = string_gsub(path, "%.([^\\/%.]*)$", function() return "." .. newext end)
  if n == 0 then
    return newpath .. "." .. newext
  else
    return newpath
  end
end


local function joinpath2(x, y)
  local xd = x
  local last = string_sub(x, -1)
  if last ~= "/" and last ~= "\\" then
    xd = x .. "\\"
  end
  if y == "." then
    return xd
  elseif y == ".." then
    return dirname(x)
  else
    if string_match(y, "^%.[\\/]") then
      return xd .. string_sub(y, 3)
    else
      return xd .. y
    end
  end
end

local function joinpath(...)
  local n = select("#", ...)
  if n == 2 then
    return joinpath2(...)
  elseif n == 0 then
    return "."
  elseif n == 1 then
    return ...
  else
    return joinpath(joinpath2(...), select(3, ...))
  end
end


-- https://msdn.microsoft.com/en-us/library/windows/desktop/aa365247(v=vs.85).aspx
local function isabspath(path)
  local init = string_sub(path, 1, 1)
  return init == "\\" or init == "/" or string_match(path, "^%a:[/\\]")
end

local function abspath(path, cwd)
  if isabspath(path) then
    -- absolute path
    return path
  else
    -- TODO: relative path with a drive letter is not supported
    cwd = cwd or filesys.currentdir()
    return joinpath2(cwd, path)
  end
end

return {
  basename = basename,
  dirname = dirname,
  trimext = trimext,
  ext = ext,
  replaceext = replaceext,
  join = joinpath,
  abspath = abspath,
}
end
else
package.preload["texrunner.pathutil"] = function(...)
--[[
  Copyright 2016 ARATA Mizuki

  This file is part of ClutTeX.

  ClutTeX is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  ClutTeX is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with ClutTeX.  If not, see <http://www.gnu.org/licenses/>.
]]

-- pathutil module for *nix

local assert = assert
local select = select
local string = string
local string_find = string.find
local string_sub = string.sub
local string_match = string.match
local string_gsub = string.gsub
local filesys = require "lfs"

local function basename(path)
  local i = 0
  while true do
    local j = string_find(path, "/", i + 1, true)
    if j == nil then
      return string_sub(path, i + 1)
    elseif j == #path then
      return string_sub(path, i + 1, -2)
    end
    i = j
  end
end


local function dirname(path)
  local i = 0
  while true do
    local j = string_find(path, "/", i + 1, true)
    if j == nil then
      if i == 0 then
        -- No directory portion
        return "."
      elseif i == 1 then
        -- Root
        return "/"
      else
        -- Directory portion without trailing slash
        return string_sub(path, 1, i - 1)
      end
    end
    i = j
  end
end


local function parentdir(path)
  local i = 0
  while true do
    local j = string_find(path, "/", i + 1, true)
    if j == nil then
      if i == 0 then
        -- No directory portion
        return "."
      elseif i == 1 then
        -- Root
        return "/"
      else
        -- Directory portion without trailing slash
        return string_sub(path, 1, i - 1)
      end
    elseif j == #path then
      -- Directory portion without trailing slash
      return string_sub(path, 1, i - 1)
    end
    i = j
  end
end


local function trimext(path)
  return (string_gsub(path, "%.[^/%.]*$", ""))
end


local function ext(path)
  return string_match(path, "%.([^/%.]*)$") or ""
end


local function replaceext(path, newext)
  local newpath, n = string_gsub(path, "%.([^/%.]*)$", function() return "." .. newext end)
  if n == 0 then
    return newpath .. "." .. newext
  else
    return newpath
  end
end


local function joinpath2(x, y)
  local xd = x
  if string_sub(x, -1) ~= "/" then
    xd = x .. "/"
  end
  if y == "." then
    return xd
  elseif y == ".." then
    return dirname(x)
  else
    if string_sub(y, 1, 2) == "./" then
      return xd .. string_sub(y, 3)
    else
      return xd .. y
    end
  end
end

local function joinpath(...)
  local n = select("#", ...)
  if n == 2 then
    return joinpath2(...)
  elseif n == 0 then
    return "."
  elseif n == 1 then
    return ...
  else
    return joinpath(joinpath2(...), select(3, ...))
  end
end


local function abspath(path, cwd)
  if string_sub(path, 1, 1) == "/" then
    -- absolute path
    return path
  else
    cwd = cwd or filesys.currentdir()
    return joinpath2(cwd, path)
  end
end


return {
  basename = basename,
  dirname = dirname,
  parentdir = parentdir,
  trimext = trimext,
  ext = ext,
  replaceext = replaceext,
  join = joinpath,
  abspath = abspath,
}
end
end
if os.type == "windows" then
package.preload["texrunner.shellutil"] = function(...)
--[[
  Copyright 2016 ARATA Mizuki

  This file is part of ClutTeX.

  ClutTeX is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  ClutTeX is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with ClutTeX.  If not, see <http://www.gnu.org/licenses/>.
]]

local string_gsub = string.gsub

-- s: string
local function escape(s)
  return '"' .. string_gsub(string_gsub(s, '(\\*)"', '%1%1\\"'), '(\\+)$', '%1%1') .. '"'
end


return {
  escape = escape,
}
end
else
package.preload["texrunner.shellutil"] = function(...)
--[[
  Copyright 2016 ARATA Mizuki

  This file is part of ClutTeX.

  ClutTeX is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  ClutTeX is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with ClutTeX.  If not, see <http://www.gnu.org/licenses/>.
]]

local assert = assert
local string_match = string.match
local table = table
local table_insert = table.insert
local table_concat = table.concat

-- s: string
local function escape(s)
  local len = #s
  local result = {}
  local t,i = string_match(s, "^([^']*)()")
  assert(t)
  if t ~= "" then
    table_insert(result, "'")
    table_insert(result, t)
    table_insert(result, "'")
  end
  while i < len do
    t,i = string_match(s, "^('+)()", i)
    assert(t)
    table_insert(result, '"')
    table_insert(result, t)
    table_insert(result, '"')
    t,i = string_match(s, "^([^']*)()", i)
    assert(t)
    if t ~= "" then
      table_insert(result, "'")
      table_insert(result, t)
      table_insert(result, "'")
    end
  end
  return table_concat(result, "")
end


return {
  escape = escape,
}
end
end
package.preload["texrunner.fsutil"] = function(...)
--[[
  Copyright 2016 ARATA Mizuki

  This file is part of ClutTeX.

  ClutTeX is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  ClutTeX is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with ClutTeX.  If not, see <http://www.gnu.org/licenses/>.
]]

local assert = assert
local os = os
local os_execute = os.execute
local os_remove = os.remove
local filesys = require "lfs"
local pathutil = require "texrunner.pathutil"
local shellutil = require "texrunner.shellutil"
local escape = shellutil.escape

local copy_command
if os.type == "windows" then
  function copy_command(from, to)
    -- TODO: What if `from` begins with a slash?
    return "copy " .. escape(from) .. " " .. escape(to) .. " > NUL"
  end
else
  function copy_command(from, to)
    -- TODO: What if `from` begins with a hypen?
    return "cp " .. escape(from) .. " " .. escape(to)
  end
end

local isfile = filesys.isfile or function(path)
  return filesys.attributes(path, "mode") == "file"
end

local isdir = filesys.isdir or function(path)
  return filesys.attributes(path, "mode") == "directory"
end

local function mkdir_rec(path)
  local succ, err = filesys.mkdir(path)
  if not succ then
    succ, err = mkdir_rec(pathutil.parentdir(path))
    if succ then
      return filesys.mkdir(path)
    end
  end
  return succ, err
end

local function remove_rec(path)
  if isdir(path) then
    for file in filesys.dir(path) do
      if file ~= "." and file ~= ".." then
        local succ, err = remove_rec(pathutil.join(path, file))
        if not succ then
          return succ, err
        end
      end
    end
    return filesys.rmdir(path)
  else
    return os_remove(path)
  end
end

return {
  copy_command = copy_command,
  isfile = isfile,
  isdir = isdir,
  mkdir_rec = mkdir_rec,
  remove_rec = remove_rec,
}
end
package.preload["texrunner.option"] = function(...)
--[[
  Copyright 2016 ARATA Mizuki

  This file is part of ClutTeX.

  ClutTeX is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  ClutTeX is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with ClutTeX.  If not, see <http://www.gnu.org/licenses/>.
]]

-- options_and_params, i = parseoption(arg, options)
-- options[i] = {short = "o", long = "option" [, param = true] [, boolean = true]}
-- arg[i], arg[i + 1], ..., arg[#arg] are non-options
local function parseoption(arg, options)
  local i = 1
  local option_and_params = {}
  while i <= #arg do
    if arg[i] == "--" then
      -- Stop handling options
      i = i + 1
      break
    elseif arg[i]:sub(1,2) == "--" then
      -- Long option
      local name,param = arg[i]:match("^([^=]+)=(.*)$", 3)
      name = name or arg[i]:sub(3)
      local opt = nil
      for _,o in ipairs(options) do
        if o.long then
          if o.long == name then
            if o.param then
              if param then
                -- --option=param
              else
                -- --option param
                assert(i + 1 <= #arg, "argument missing after " .. arg[i] .. " option")
                param = arg[i + 1]
                i = i + 1
              end
            else
              -- --option
              param = true
            end
            opt = o
            break
          elseif o.boolean and name == "no-" .. o.long then
            -- --no-option
            opt = o
            break
          end
        end
      end
      if opt then
        table.insert(option_and_params, {opt.long, param})
      else
        -- Unknown long option
        error("unknown long option: " .. arg[i])
      end
    elseif arg[i]:sub(1,1) == "-" then
      -- Short option
      local name = arg[i]:sub(2,2)
      local param
      local opt
      for _,o in ipairs(options) do
        if o.short then
          if o.short == name then
            if o.param then
              if #arg[i] > 2 then
                -- -oparam
                param = arg[i]:sub(3)
              else
                -- -o param
                assert(i + 1 <= #arg, "argument missing after " .. arg[i] .. " option")
                param = arg[i + 1]
                i = i + 1
              end
            else
              -- -o
              assert(#arg[i] == 2, "combining multiple short options like -abc is not supported")
              param = true
            end
            opt = o
            break
          end
        end
      end
      if opt then
        table.insert(option_and_params, {opt.long or opt.short, param})
      else
        error("unknown short option: " .. arg[i])
      end
    else
      -- arg[i] is not an option
      break
    end
    i = i + 1
  end
  return option_and_params, i
end

return {
  parseoption = parseoption;
}
end
package.preload["texrunner.tex_engine"] = function(...)
--[[
  Copyright 2016 ARATA Mizuki

  This file is part of ClutTeX.

  ClutTeX is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  ClutTeX is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with ClutTeX.  If not, see <http://www.gnu.org/licenses/>.
]]

local table = table
local setmetatable = setmetatable
local ipairs = ipairs

local shellutil = require "texrunner.shellutil"

--[[
engine.name: string
engine.type = "onePass" or "twoPass"
engine:build_command(inputfile, options)
  options:
    halt_on_error: boolean
    interaction: string
    file_line_error: boolean
    synctex: string
    shell_escape: boolean
    shell_restricted: boolean
    jobname: string
    output_directory: string
    extraoptions: a list of strings
    output_format: "pdf" or "dvi"
    draftmode: boolean
engine.executable: string
engine.supports_pdf_generation: boolean
engine.dvi_extension: string
]]

local engine_meta = {}
engine_meta.__index = engine_meta
engine_meta.dvi_extension = "dvi"
function engine_meta:build_command(inputfile, options)
  local command = {self.executable, "-recorder"}
  if options.halt_on_error then
    table.insert(command, "-halt-on-error")
  end
  if options.interaction then
    table.insert(command, "-interaction=" .. options.interaction)
  end
  if options.file_line_error then
    table.insert(command, "-file-line-error")
  end
  if options.synctex then
    table.insert(command, "-synctex=" .. shellutil.escape(options.synctex))
  end
  if options.shell_escape == false then
    table.insert(command, "-no-shell-escape")
  elseif options.shell_restricted == true then
    table.insert(command, "-shell-restricted")
  elseif options.shell_escape == true then
    table.insert(command, "-shell-escape")
  end
  if options.jobname then
    table.insert(command, "-jobname=" .. shellutil.escape(options.jobname))
  end
  if options.output_directory then
    table.insert(command, "-output-directory=" .. shellutil.escape(options.output_directory))
  end
  if self.handle_additional_options then
    self:handle_additional_options(command, options)
  end
  if options.extraoptions then
    for _,v in ipairs(options.extraoptions) do
      table.insert(command, v)
    end
  end
  table.insert(command, shellutil.escape(inputfile))
  return table.concat(command, " ")
end

local function engine(name, supports_pdf_generation, handle_additional_options)
  return setmetatable({
    name = name,
    executable = name,
    supports_pdf_generation = supports_pdf_generation,
    handle_additional_options = handle_additional_options,
  }, engine_meta)
end

local function handle_pdftex_options(self, args, options)
  if options.draftmode then
    table.insert(args, "-draftmode")
  elseif options.output_format == "dvi" then
    table.insert(args, "-output-format=dvi")
  end
end

local function handle_xetex_options(self, args, options)
  if options.output_format == "dvi" or options.draftmode then
    table.insert(args, "-no-pdf")
  end
end

local function handle_luatex_options(self, args, options)
  if options.lua_initialization_script then
    table.insert(args, "--lua="..options.lua_initialization_script)
  end
  handle_pdftex_options(self, args, options)
end

local KnownEngines = {
  ["pdftex"]   = engine("pdftex", true, handle_pdftex_options),
  ["pdflatex"] = engine("pdflatex", true, handle_pdftex_options),
  ["luatex"]   = engine("luatex", true, handle_luatex_options),
  ["lualatex"] = engine("lualatex", true, handle_luatex_options),
  ["xetex"]    = engine("xetex", true, handle_xetex_options),
  ["xelatex"]  = engine("xelatex", true, handle_xetex_options),
  ["tex"]      = engine("tex", false),
  ["etex"]     = engine("etex", false),
  ["latex"]    = engine("latex", false),
  ["ptex"]     = engine("ptex", false),
  ["eptex"]    = engine("eptex", false),
  ["platex"]   = engine("platex", false),
  ["uptex"]    = engine("uptex", false),
  ["euptex"]   = engine("euptex", false),
  ["uplatex"]  = engine("uplatex", false),
}

KnownEngines["xetex"].dvi_extension = "xdv"
KnownEngines["xelatex"].dvi_extension = "xdv"

return KnownEngines
end
package.preload["texrunner.reruncheck"] = function(...)
--[[
  Copyright 2016,2018 ARATA Mizuki

  This file is part of ClutTeX.

  ClutTeX is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  ClutTeX is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with ClutTeX.  If not, see <http://www.gnu.org/licenses/>.
]]

local io = io
local assert = assert
local filesys = require "lfs"
local md5 = require "md5"
local fsutil = require "texrunner.fsutil"
local pathutil = require "texrunner.pathutil"

local function md5sum_file(path)
  local f = assert(io.open(path, "rb"))
  local contents = f:read("*a")
  f:close()
  return md5.sum(contents)
end

-- filelist = parse_recorder_file("jobname.fls")
-- filelist[i] = {path = "...", abspath = "...", kind = "input" or "output" or "auxiliary"}
local function parse_recorder_file(file)
  local filelist = {}
  local filemap = {}
  for l in io.lines(file) do
    local t,path = l:match("^(%w+) (.*)$")
    if t == "PWD" then
      -- Ignore

    elseif t == "INPUT" then
      local abspath = pathutil.abspath(path)
      local fileinfo = filemap[abspath]
      if not fileinfo then
        if fsutil.isfile(path) then
          local kind = "input"
          local ext = pathutil.ext(path)
          if ext == "ltjruby" then -- .ltjruby (generated by luatexja-ruby)
            kind = "auxiliary"
          elseif string.find(path,"luatexja",1,true) and string.match(path, "%.lu[abc]$") then
            -- LuaTeX-ja cache (see save_cache(_luc) in ltj-base.lua)
            kind = "auxiliary"
          end
          fileinfo = {path = path, abspath = abspath, kind = kind}
          table.insert(filelist, fileinfo)
          filemap[abspath] = fileinfo
        else
          -- Maybe a command execution
        end
      else
        if #path < #fileinfo.path then
          fileinfo.path = path
        end
        if fileinfo.kind == "output" then
          -- The files listed in both INPUT and OUTPUT are considered to be auxiliary files.
          fileinfo.kind = "auxiliary"
        end
      end

    elseif t == "OUTPUT" then
      local abspath = pathutil.abspath(path)
      local fileinfo = filemap[abspath]
      if not fileinfo then
        fileinfo = {path = path, abspath = abspath, kind = "output"}
        table.insert(filelist, fileinfo)
        filemap[abspath] = fileinfo
      else
        if #path < #fileinfo.path then
          fileinfo.path = path
        end
        if fileinfo.kind == "input" then
          -- The files listed in both INPUT and OUTPUT are considered to be auxiliary files.
          fileinfo.kind = "auxiliary"
        end
      end

    else
      io.stderr:write("cluttex warning: Unrecognized line in recorder file '", file, "': ", l, "\n")
    end
  end
  return filelist
end

-- auxstatus = collectfileinfo(filelist [, auxstatus])
local function collectfileinfo(filelist, auxstatus)
  auxstatus = auxstatus or {}
  for i,fileinfo in ipairs(filelist) do
    local path = fileinfo.abspath
    if fsutil.isfile(path) then
      local status = auxstatus[path] or {}
      auxstatus[path] = status
      if fileinfo.kind == "input" then
        status.mtime = status.mtime or filesys.attributes(path, "modification")
      elseif fileinfo.kind == "auxiliary" then
        status.size = status.size or filesys.attributes(path, "size")
        status.md5sum = status.md5sum or md5sum_file(path)
      end
    end
  end
  return auxstatus
end

-- should_rerun, newauxstatus = comparefileinfo(auxfiles, auxstatus)
local function comparefileinfo(filelist, auxstatus)
  local should_rerun = false
  local newauxstatus = {}
  for i,fileinfo in ipairs(filelist) do
    local path = fileinfo.abspath
    if fsutil.isfile(path) then
      if fileinfo.kind == "input" then
        -- Input file: User might have modified while running TeX.
        local mtime = filesys.attributes(path, "modification")
        if auxstatus[path] and auxstatus[path].mtime then
          if auxstatus[path].mtime < mtime then
            -- Input file was updated during execution
            if CLUTTEX_VERBOSITY >= 1 then
              io.stderr:write("cluttex: File '", fileinfo.path, "' was modified by user.\n")
            end
            newauxstatus[path] = {mtime = mtime}
            return true, newauxstatus
          end
        else
          -- New input file
        end

      elseif fileinfo.kind == "auxiliary" then
        -- Auxiliary file: Compare file contents.
        if auxstatus[path] then
          -- File was touched during execution
          local really_modified = false
          local size = filesys.attributes(path, "size")
          if auxstatus[path].size ~= size then
            really_modified = true
            newauxstatus[path] = {size = size}
          else
            local md5sum = md5sum_file(path)
            if auxstatus[path].md5sum ~= md5sum then
              really_modified = true
            end
            newauxstatus[path] = {size = size, md5sum = md5sum}
          end
          if really_modified then
            if CLUTTEX_VERBOSITY >= 1 then
              io.stderr:write("cluttex: File '", fileinfo.path, "' was modified.\n")
            end
            should_rerun = true
          else
            if CLUTTEX_VERBOSITY >= 1 then
              io.stderr:write("cluttex: File '", fileinfo.path, "' unmodified (size and md5sum).\n")
            end
          end
        else
          -- New file
          if path:sub(-4) == ".aux" then
            local size = filesys.attributes(path, "size")
            if size == 8 then
              local auxfile = io.open(path, "rb")
              local contents = auxfile:read("*a")
              auxfile:close()
              if contents == "\\relax \n" then
                -- The .aux file is new, but it is almost empty
              else
                should_rerun = true
              end
              newauxstatus[path] = {size = size, md5sum = md5.sum(contents)}
            else
              should_rerun = true
              newauxstatus[path] = {size = size}
            end
          else
            should_rerun = true
          end
          if CLUTTEX_VERBOSITY >= 1 then
            if should_rerun then
              io.stderr:write("cluttex: New input file '", fileinfo.path, "'.\n")
            else
              io.stderr:write("cluttex: New input file '", fileinfo.path, "'. (not modified)\n")
            end
          end
        end
        if should_rerun then
          break
        end
      end
    else
      -- Auxiliary file is not really a file???
    end
  end
  return should_rerun, newauxstatus
end

return {
  parse_recorder_file = parse_recorder_file;
  collectfileinfo = collectfileinfo;
  comparefileinfo = comparefileinfo;
}
end
package.preload["texrunner.auxfile"] = function(...)
--[[
  Copyright 2016 ARATA Mizuki

  This file is part of ClutTeX.

  ClutTeX is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  ClutTeX is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with ClutTeX.  If not, see <http://www.gnu.org/licenses/>.
]]

local string_match = string.match
local pathutil = require "texrunner.pathutil"
local filesys = require "lfs"
local fsutil = require "texrunner.fsutil"

-- for LaTeX
local function parse_aux_file(auxfile, outdir, report, seen)
  report = report or {}
  seen = seen or {}
  seen[auxfile] = true
  for l in io.lines(auxfile) do
    local subauxfile = string_match(l, "\\@input{(.+)}")
    if subauxfile then
      if fsutil.isfile(subauxfile) then
        parse_aux_file(pathutil.join(outdir, subauxfile), outdir, report, seen)
      else
        local dir = pathutil.join(outdir, pathutil.dirname(subauxfile))
        if not fsutil.isdir(dir) then
          assert(fsutil.mkdir_rec(dir))
          report.made_new_directory = true
        end
      end
    end
  end
  return report
end

return {
  parse_aux_file = parse_aux_file,
}
end
package.preload["texrunner.luatexinit"] = function(...)
local function create_initialization_script(filename, options)
  local initscript = assert(io.open(filename,"w"))
  if type(options.file_line_error) == "boolean" then
    initscript:write(string.format("texconfig.file_line_error = %s\n", options.file_line_error))
  end
  if type(options.halt_on_error) == "boolean" then
    initscript:write(string.format("texconfig.halt_on_error = %s\n", options.halt_on_error))
  end
  initscript:write(string.format("local output_directory = %q\n", options.output_directory))
  initscript:write([==[
local print = print
local io_open = io.open
local io_write = io.write
local texio_write = texio.write
local texio_write_nl = texio.write_nl
local function start_file_cb(category, filename)
  if category == 1 then -- a normal data file, like a TeX source
    texio_write_nl("log", "("..filename)
  elseif category == 2 then -- a font map coupling font names to resources
    texio_write("log", "{"..filename)
  elseif category == 3 then -- an image file (png, pdf, etc)
    texio_write("<"..filename)
  elseif category == 4 then -- an embedded font subset
    texio_write("<"..filename)
  elseif category == 5 then -- a fully embedded font
    texio_write("<<"..filename)
  else
    print("start_file: unknown category", category, filename)
  end
end
callback.register("start_file", start_file_cb)
local function stop_file_cb(category)
  if category == 1 then
    texio_write("log", ")")
  elseif category == 2 then
    texio_write("log", "}")
  elseif category == 3 then
    texio_write(">")
  elseif category == 4 then
    texio_write(">")
  elseif category == 5 then
    texio_write(">>")
  else
    print("stop_file: unknown category", category)
  end
end
callback.register("stop_file", stop_file_cb)
texio.write = function(...)
  if select("#",...) == 1 then
    -- Suppress luaotfload's message (See src/fontloader/runtime/fontload-reference.lua)
    if string.match(...,"^%(using cache: ") then
      return
    elseif string.match(...,"^%(using write cache: ") then
      return
    elseif string.match(...,"^%(using read cache: ") then
      return
    elseif string.match(...,"^%(load luc: ") then
      return
    elseif string.match(...,"^%(load cache: ") then
      return
    end
  end
  return texio_write(...)
end
io.open = function(...)
  local fname, mode = ...
  -- luatexja-ruby
  if mode == "w" and fname == tex.jobname .. ".ltjruby" then
    return io_open(output_directory .. "/" .. fname, "w")
  else
    return io_open(...)
  end
end
]==])
  initscript:close()
end

return {
  create_initialization_script = create_initialization_script
}
end
--[[
  Copyright 2016,2018 ARATA Mizuki

  This file is part of ClutTeX.

  ClutTeX is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  ClutTeX is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with ClutTeX.  If not, see <http://www.gnu.org/licenses/>.
]]

-- Standard libraries
local table = table
local os = os
local io = io
local string = string
local ipairs = ipairs
local coroutine = coroutine
local tostring = tostring

-- External libraries (included in texlua)
local filesys = require "lfs"
local md5     = require "md5"
-- local kpse = require "kpse"

-- My own modules
local pathutil    = require "texrunner.pathutil"
local fsutil      = require "texrunner.fsutil"
local shellutil   = require "texrunner.shellutil"
local reruncheck  = require "texrunner.reruncheck"
local parseoption = require "texrunner.option".parseoption
local parse_aux_file = require "texrunner.auxfile".parse_aux_file
local KnownEngines = require "texrunner.tex_engine"
local luatexinit  = require "texrunner.luatexinit"

-- arguments: input file name, jobname, etc...
local function genOutputDirectory(...)
  -- The name of the temporary directory is based on the path of input file.
  local message = table.concat({...}, "\0")
  local hash = md5.sumhexa(message)
  local tmpdir = os.getenv("TMPDIR") or os.getenv("TMP") or os.getenv("TEMP")
  if tmpdir == nil then
    local home = os.getenv("HOME") or os.getenv("USERPROFILE") or error("environment variable 'TMPDIR' not set!")
    tmpdir = pathutil.join(home, ".latex-build-temp")
  end
  return pathutil.join(tmpdir, 'latex-build-' .. hash)
end

local COPYRIGHT_NOTICE = [[
Copyright (C) 2016,2018  ARATA Mizuki

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]

local function usage()
  io.write(string.format([[
ClutTeX: Process TeX files without cluttering your working directory

Usage:
  %s [options] [--] FILE.tex

Options:
  -e, --engine=ENGINE          Specify which TeX engine to use.
                                 ENGINE is one of the following:
                                     pdflatex, pdftex, lualatex, luatex,
                                     xelatex, xetex, latex, etex, tex,
                                     platex, eptex, ptex,
                                     uplatex, euptex, uptex,
  -o, --output=FILE            The name of output file.
                                 [default: JOBNAME.pdf or JOBNAME.dvi]
      --fresh                  Clean intermediate files before running TeX.
                                 Cannot be used with --output-directory.
      --max-iterations=N       Maximum number of re-running TeX to resolve
                                 cross-references.  [default: 5]
      --[no-]change-directory  Change directory before running TeX.
      --watch                  Watch input files for change.  Requires fswatch
                                 program to be installed.
      --tex-option=OPTION      Pass OPTION to TeX as a single option.
      --tex-options=OPTIONs    Pass OPTIONs to TeX as multiple options.
      --dvipdfmx-option[s]=OPTION[s]  Same for dvipdfmx.
  -h, --help                   Print this message and exit.
  -v, --version                Print version information and exit.
  -V, --verbose                Be more verbose.

      --[no-]shell-escape
      --shell-restricted
      --synctex=NUMBER
      --[no-]file-line-error   [default: yes]
      --[no-]halt-on-error     [default: yes]
      --interaction=STRING     [default: nonstopmode]
      --jobname=STRING
      --output-directory=DIR   [default: somewhere in the temporary directory]
      --output-format=FORMAT   FORMAT is `pdf' or `dvi'.  [default: pdf]

%s
]], arg[0] or 'texlua cluttex.lua', COPYRIGHT_NOTICE))
end

-- Parse options
local option_and_params, non_option_index = parseoption(arg, {
  -- Options for this script
  {
    short = "e",
    long = "engine",
    param = true,
  },
  {
    short = "o",
    long = "output",
    param = true,
  },
  {
    long = "fresh",
  },
  {
    long = "max-iterations",
    param = true,
  },
  {
    long = "change-directory",
    boolean = true,
  },
  {
    long = "watch",
  },
  {
    short = "h",
    long = "help",
  },
  {
    short = "v",
    long = "version",
  },
  {
    short = "V",
    long = "verbose",
  },
  -- Options for TeX
  {
    long = "synctex",
    param = true,
  },
  {
    long = "file-line-error",
    boolean = true,
  },
  {
    long = "interaction",
    param = true,
  },
  {
    long = "halt-on-error",
    boolean = true,
  },
  {
    long = "shell-escape",
    boolean = true,
  },
  {
    long = "shell-restricted",
  },
  {
    long = "jobname",
    param = true,
  },
  {
    long = "output-directory",
    param = true,
  },
  {
    long = "output-format",
    param = true,
  },
  {
    long = "tex-option",
    param = true,
  },
  {
    long = "tex-options",
    param = true,
  },
  {
    long = "dvipdfmx-option",
    param = true,
  },
  {
    long = "dvipdfmx-options",
    param = true,
  },
})

-- Handle options
local options = {}
local tex_extraoptions = {}
local dvipdfmx_extraoptions = {}
CLUTTEX_VERBOSITY = 0
for _,option in ipairs(option_and_params) do
  local name = option[1]
  local param = option[2]

  if name == "engine" then
    assert(options.engine == nil, "multiple --engine options")
    options.engine = param

  elseif name == "output" then
    assert(options.output == nil, "multiple --output options")
    options.output = param

  elseif name == "fresh" then
    assert(options.fresh == nil, "multiple --fresh options")
    options.fresh = true

  elseif name == "max-iterations" then
    assert(options.max_iterations == nil, "multiple --max-iterations options")
    options.max_iterations = assert(tonumber(param), "invalid value for --max-iterations option")

  elseif name == "watch" then
    assert(options.watch == nil, "multiple --watch options")
    options.watch = true

  elseif name == "help" then
    usage()
    os.exit(0)

  elseif name == "version" then
    io.stderr:write("cluttex (prerelease)\n")
    os.exit(0)

  elseif name == "verbose" then
    CLUTTEX_VERBOSITY = CLUTTEX_VERBOSITY + 1

  elseif name == "change-directory" then
    assert(options.change_directory == nil, "multiple --change-directory options")
    options.change_directory = param

  -- Options for TeX
  elseif name == "synctex" then
    assert(options.synctex == nil, "multiple --synctex options")
    options.synctex = param

  elseif name == "file-line-error" then
    options.file_line_error = param

  elseif name == "interaction" then
    assert(options.interaction == nil, "multiple --interaction options")
    assert(param == "batchmode" or param == "nonstopmode" or param == "scrollmode" or param == "errorstopmode", "invalid argument for --interaction")
    options.interaction = param

  elseif name == "halt-on-error" then
    options.halt_on_error = param

  elseif name == "shell-escape" then
    assert(options.shell_escape == nil and options.shell_restricted == nil, "multiple --(no-)shell-escape or --shell-restricted options")
    options.shell_escape = param

  elseif name == "shell-restricted" then
    assert(options.shell_escape == nil and options.shell_restricted == nil, "multiple --(no-)shell-escape or --shell-restricted options")
    options.shell_restricted = true

  elseif name == "jobname" then
    assert(options.jobname == nil, "multiple --jobname options")
    options.jobname = param

  elseif name == "output-directory" then
    assert(options.output_directory == nil, "multiple --output-directory options")
    options.output_directory = param

  elseif name == "output-format" then
    assert(options.output_format == nil, "multiple --output-format options")
    assert(param == "pdf" or param == "dvi", "invalid argument for --output-format")
    options.output_format = param

  elseif name == "tex-option" then
    table.insert(tex_extraoptions, shellutil.escape(param))

  elseif name == "tex-options" then
    table.insert(tex_extraoptions, param)

  elseif name == "dvipdfmx-option" then
    table.insert(dvipdfmx_extraoptions, shellutil.escape(param))

  elseif name == "dvipdfmx-options" then
    table.insert(dvipdfmx_extraoptions, param)

  end
end

-- Handle non-options (i.e. input file)
if non_option_index > #arg then
  -- No input file given
  usage()
  os.exit(1)
elseif non_option_index < #arg then
  io.stderr("cluttex: Multiple input files are not supported.\n")
  os.exit(1)
end
local inputfile = arg[non_option_index]

if options.engine == nil then
  io.stderr:write("cluttex: Engine not specified.\n")
  os.exit(1)
end
local engine = KnownEngines[options.engine]
if not engine then
  io.stderr:write("cluttex: Unknown engine name '", options.engine, "'.\n")
  os.exit(1)
end

-- Default values for options
if options.max_iterations == nil then
  options.max_iterations = 5
end

if options.interaction == nil then
  options.interaction = "nonstopmode"
end

if options.file_line_error == nil then
  options.file_line_error = true
end

if options.halt_on_error == nil then
  options.halt_on_error = true
end

local jobname = options.jobname or pathutil.basename(pathutil.trimext(inputfile))
assert(jobname ~= "", "jobname cannot be empty")

if options.output_format == nil then
  options.output_format = "pdf"
end
local output_extension
if options.output_format == "dvi" then
  output_extension = engine.dvi_extension or "dvi"
else
  output_extension = "pdf"
end

if options.output == nil then
  options.output = jobname .. "." .. output_extension
end

-- Prepare output directory
if options.output_directory == nil then
  local inputfile_abs = pathutil.abspath(inputfile)
  options.output_directory = genOutputDirectory(inputfile_abs, jobname, options.engine)

  if not fsutil.isdir(options.output_directory) then
    assert(fsutil.mkdir_rec(options.output_directory))

  elseif options.fresh then
    -- The output directory exists and --fresh is given:
    -- Remove all files in the output directory
    if CLUTTEX_VERBOSITY >= 1 then
      io.stderr:write("cluttex: Cleaning '", options.output_directory, "'...\n")
    end
    assert(fsutil.remove_rec(options.output_directory))
    assert(filesys.mkdir(options.output_directory))
  end

elseif options.fresh then
  io.stderr:write("cluttex: --fresh and --output-directory cannot be used together.\n")
  os.exit(1)
end

local original_wd = filesys.currentdir()
if options.change_directory then
  local TEXINPUTS = os.getenv("TEXINPUTS") or ""
  filesys.chdir(options.output_directory)
  options.output = pathutil.abspath(options.output, original_wd)
  os.setenv("TEXINPUTS", original_wd .. ":" .. TEXINPUTS)
end

-- Set `max_print_line' environment variable if not already set.
if os.getenv("max_print_line") == nil then
  os.setenv("max_print_line", "65536")
end
-- TODO: error_line, half_error_line
--[[
  According to texmf.cnf:
    45 < error_line < 255,
    30 < half_error_line < error_line - 15,
    60 <= max_print_line.
]]

local function path_in_output_directory(ext)
  return pathutil.join(options.output_directory, jobname .. "." .. ext)
end

local recorderfile = path_in_output_directory("fls")

local tex_options = {
  interaction = options.interaction,
  file_line_error = options.file_line_error,
  halt_on_error = options.halt_on_error,
  synctex = options.synctex,
  output_directory = options.output_directory,
  shell_escape = options.shell_escape,
  shell_restricted = options.shell_restricted,
  jobname = options.jobname,
  extraoptions = tex_extraoptions,
}
if options.output_format ~= "pdf" and engine.supports_pdf_generation then
  tex_options.output_format = options.output_format
end

-- Setup LuaTeX initialization script
if options.engine == "luatex" or options.engine == "lualatex" then
  local initscriptfile = path_in_output_directory("cluttexinit.lua")
  luatexinit.create_initialization_script(initscriptfile, tex_options)
  tex_options.lua_initialization_script = initscriptfile
end

local command = engine:build_command(inputfile, tex_options)

local function create_missing_directories(execlog)
  if string.find(execlog, "I can't write on file", 1, true) then
    -- There is a possibility that there are some subfiles under subdirectories.
    -- Directories for sub-auxfiles are not created automatically, so we need to provide them.
    local report = parse_aux_file(path_in_output_directory("aux"), options.output_directory)
    if report.made_new_directory then
      if CLUTTEX_VERBOSITY >= 1 then
        io.stderr:write("cluttex: Created missing directories.\n")
      end
      return true
    end
  end
  return false
end

local function run_epstopdf(execlog)
  local run = false
  if options.shell_escape ~= false then -- (possibly restricted) \write18 enabled
    for outfile, infile in string.gmatch(execlog, "%(epstopdf%)%s*Command: <r?epstopdf %-%-outfile=([%w%-/]+%.pdf) ([%w%-/]+%.eps)>") do
      local infile_abs = pathutil.abspath(infile, original_wd)
      if fsutil.isfile(infile_abs) then -- input file exists
        local outfile_abs = pathutil.abspath(outfile, options.output_directory)
        if CLUTTEX_VERBOSITY >= 1 then
          io.stderr:write("cluttex: Running epstopdf on ", infile, ".\n")
        end
        local outdir = pathutil.dirname(outfile_abs)
        if not fsutil.isdir(outdir) then
          assert(fsutil.mkdir_rec(outdir))
        end
        local command = string.format("epstopdf --outfile=%s %s", shellutil.escape(outfile_abs), shellutil.escape(infile_abs))
        io.stderr:write("EXEC ", command, "\n")
        local success = os.execute(command)
        if type(success) == "number" then -- Lua 5.1 or LuaTeX
          success = success == 0
        end
        run = run or success
      end
    end
  end
  return run
end

-- Run TeX command (*tex, *latex)
-- should_rerun, newauxstatus = single_run([auxstatus])
local function single_run(auxstatus)
  if fsutil.isfile(recorderfile) then
    -- Recorder file already exists
    local filelist = reruncheck.parse_recorder_file(recorderfile)
    auxstatus = reruncheck.collectfileinfo(filelist, auxstatus)
  else
    -- This is the first execution
    if auxstatus ~= nil then
      io.stderr:write("cluttex: Recorder file was not generated during the execution!\n")
      os.exit(1)
    end
    auxstatus = {}
  end
  --local timestamp = os.time()

  local recovered = false
  local function recover()
    -- Check log file
    local logfile = assert(io.open(path_in_output_directory("log")))
    local execlog = logfile:read("*a")
    logfile:close()
    recovered = create_missing_directories(execlog)
    recovered = run_epstopdf(execlog) or recovered
    return recovered
  end
  coroutine.yield(command, recover) -- Execute the command
  if recovered then
    return true, {}
  end

  local filelist = reruncheck.parse_recorder_file(recorderfile)
  return reruncheck.comparefileinfo(filelist, auxstatus)
end

-- Run (La)TeX (possibly multiple times) and produce a PDF file.
-- This function should be run in a coroutine.
local function do_typeset_c()
  local iteration = 0
  local should_rerun, auxstatus
  repeat
    iteration = iteration + 1
    should_rerun, auxstatus = single_run(auxstatus)
  until not should_rerun or iteration > options.max_iterations

  if should_rerun then
    io.stderr:write("cluttex warning: LaTeX should be run once more.\n")
  end

  -- Successful
  if options.output_format == "dvi" or engine.supports_pdf_generation then
    -- Output file (DVI/PDF) is generated in the output directory
    local outfile = path_in_output_directory(output_extension)
    coroutine.yield(fsutil.copy_command(outfile, options.output))
    if #dvipdfmx_extraoptions > 0 then
      io.stderr:write("cluttex warning: --dvipdfmx-option[s] are ignored.\n")
    end

  else
    -- DVI file is generated
    local dvifile = path_in_output_directory("dvi")
    local dvipdfmx_command = {"dvipdfmx", "-o", shellutil.escape(options.output)}
    for _,v in ipairs(dvipdfmx_extraoptions) do
      table.insert(dvipdfmx_command, v)
    end
    table.insert(dvipdfmx_command, shellutil.escape(dvifile))
    coroutine.yield(table.concat(dvipdfmx_command, " "))
  end
end

local function do_typeset()
  -- Execute the command string yielded by do_typeset_c
  for command, recover in coroutine.wrap(do_typeset_c) do
    io.stderr:write("EXEC ", command, "\n")
    local success, termination, status_or_signal = os.execute(command)
    if type(success) == "number" then -- Lua 5.1 or LuaTeX
      local code = success
      success = code == 0
      termination = nil
      status_or_signal = code
    end
    if not success and not (recover and recover()) then
      if termination == "exit" then
        io.stderr:write("cluttex: Command exited abnormally: exit status ", tostring(status_or_signal), "\n")
      elseif termination == "signal" then
        io.stderr:write("cluttex: Command exited abnormally: signal ", tostring(status_or_signal), "\n")
      else
        io.stderr:write("cluttex: Command exited abnormally: ", tostring(status_or_signal), "\n")
      end
      return false, termination, status_or_signal
    end
  end
  -- Successful
  if CLUTTEX_VERBOSITY >= 1 then
    io.stderr:write("cluttex: Command exited successfully\n")
  end
  return true
end

if options.watch then
  -- Watch mode
  local success, status = do_typeset()
  local filelist = reruncheck.parse_recorder_file(recorderfile)
  local input_files_to_watch = {}
  for _,fileinfo in ipairs(filelist) do
    if fileinfo.kind == "input" then
      table.insert(input_files_to_watch, fileinfo.abspath)
    end
  end
  local fswatch_command = {"fswatch", "--event=Updated", "--"}
  for _,path in ipairs(input_files_to_watch) do
    table.insert(fswatch_command, shellutil.escape(path))
  end
  if CLUTTEX_VERBOSITY >= 1 then
    io.stderr:write("EXEC ", table.concat(fswatch_command, " "), "\n")
  end
  local fswatch = assert(io.popen(table.concat(fswatch_command, " "), "r"))
  for l in fswatch:lines() do
    local found = false
    for _,path in ipairs(input_files_to_watch) do
      if l == path then
        found = true
        break
      end
    end
    if found then
      local success, status = do_typeset()
      if not success then
        -- Not successful
      end
    end
  end

else
  -- Not in watch mode
  local success, status = do_typeset()
  if not success then
    os.exit(1)
  end
end
