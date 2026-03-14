if #arg < 2 then
	error("Usage: embed_stdlib.lua <root-dir> <output-header> [files...]")
end

local root = arg[1]
local output = arg[2]
local files = {}

local function is_file(path)
	local f = io.open(path, "rb")
	if f == nil then
		return false
	end
	f:close()
	return true
end

local function read_file(path)
	local f = assert(io.open(path, "rb"))
	local data = assert(f:read("*a"))
	f:close()
	return data
end

local function relpath(path)
	if path == root then
		return ""
	end
	local prefix = root .. "/"
	if path:sub(1, #prefix) == prefix then
		return path:sub(#prefix + 1)
	end
	error("input path is outside the stdlib root: " .. path)
end

local function c_string(s)
	return string.format("%q", s)
end

local function emit_bytes(out, data)
	if #data == 0 then
		out:write("  0x00\n")
		return
	end
	for i = 1, #data, 12 do
		out:write(" ")
		local line = {}
		local last = math.min(i + 11, #data)
		for j = i, last do
			line[#line + 1] = string.format("0x%02x", data:byte(j))
		end
		out:write(table.concat(line, ", "))
		out:write(",\n")
	end
end

for i = 3, #arg do
	local path = arg[i]
	if is_file(path) then
		files[#files + 1] = path
	end
end

if #files == 0 then
	local cmd = string.format("find %q -type f | sort", root)
	local p = assert(io.popen(cmd, "r"))
	for path in p:lines() do
		files[#files + 1] = path
	end
	assert(p:close())
end

table.sort(files)

local out = assert(io.open(output, "w"))
out:write("#ifndef TUP_EMBEDDED_STDLIB_DATA_H\n")
out:write("#define TUP_EMBEDDED_STDLIB_DATA_H\n\n")

for i, path in ipairs(files) do
	local data = read_file(path)
	out:write(string.format("static const unsigned char metatup_stdlib_file_%d[] = {\n", i - 1))
	emit_bytes(out, data)
	out:write("};\n\n")
end

out:write("const struct metatup_embedded_file metatup_stdlib_files[] = {\n")
for i, path in ipairs(files) do
	out:write(string.format(
		"\t{ %s, metatup_stdlib_file_%d, %d },\n",
		c_string(relpath(path)),
		i - 1,
		#read_file(path)))
end
out:write("};\n\n")
out:write(string.format("const unsigned int metatup_stdlib_files_count = %d;\n\n", #files))
out:write("#endif\n")
out:close()
