--[[
  Copyright 2019 ARATA Mizuki

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

local string = string

local function dounsafechar(c)
  if c == " " then
    return "_"
  else
    return string.format("_%02x", c:byte(1))
  end
end

local function escapejobname(name)
  return (string.gsub(name, "[%s\"$%%&'();<>\\^`|]", dounsafechar))
end

local function safeinput(name)
  local escaped, n = string.gsub(name, "[%\\%%^%{%}%~%#]", "~\\%1")
  if n == 0 then
    return string.format("\\input\"%s\"", name)
  else
    return string.format("\\begingroup\\escapechar-1\\let~\\string\\edef\\x{\"%s\" }\\expandafter\\endgroup\\expandafter\\input\\x", escaped)
  end
end

return {
  escapejobname = escapejobname,
  safeinput = safeinput,
}
