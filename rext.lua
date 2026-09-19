#!/usr/bin/env lua
-- ==============================================================================
-- Rext v0.6.0 [Lua Engine] - Raccoon Enhanced X-platform Text Editor
-- Pure Lua | Zero Dependencies | Ultra Light | Fast
-- ==============================================================================

local utf8 = require("utf8")

local file_path = arg[1]
if not file_path then
    io.write("\27[1;31m[!] Error:\27[0m No file specified.\nUsage: rext <filename>\n")
    os.exit(1)
end

-- Global Durum Değişkenleri
local lines = {}
local current_row = 1
local current_col = 1
local start_row = 1
local user_name = os.getenv("USER") or "user"

-- Dosyayı Oku
local f = io.open(file_path, "r")
if f then
    for line in f:lines() do
        table.insert(lines, line)
    end
    f:close()
end
if #lines == 0 then lines = {""} end

-- Terminal Raw Modu Ayarları (stty ile)
local old_stty = io.popen("stty -g"):read("*a")
local function set_raw_mode(enable)
    if enable then
        os.execute("stty raw -echo -ixon -ixoff")
    else
        os.execute("stty " .. old_stty)
        io.write("\27[?25h\27[2J\27[H")
    end
end

-- UTF-8 Yardımcı Fonksiyonları
local function utf8_len(s)
    return utf8.len(s) or #s
end

local function utf8_sub(s, i, j)
    j = j or utf8_len(s)
    if i > j then return "" end
    local start_byte = utf8.offset(s, i) or 1
    local end_byte = utf8.offset(s, j + 1)
    if end_byte then
        end_byte = end_byte - 1
    else
        end_byte = #s
    end
    return s:sub(start_byte, end_byte)
end

-- Karakter Sayısı Hesaplama
local function count_chars()
    local total = 0
    for _, line in ipairs(lines) do
        total = total + utf8_len(line) + 1
    end
    return math.max(0, total - 1)
end

-- Terminal Boyutlarını Alma
local function get_term_size()
    local h = tonumber(io.popen("tput lines"):read("*a")) or 24
    local w = tonumber(io.popen("tput cols"):read("*a")) or 80
    return h, w
end

-- Alt Barda Girdi İsteme (Prompt)
local function prompt_bar(label, default_val)
    local term_h, _ = get_term_size()
    set_raw_mode(false)
    io.write(string.format("\27[%d;1H\27[K\27[1;7m %s \27[0m %s", term_h, label, default_val or ""))
    io.flush()
    
    local input = io.read()
    set_raw_mode(true)
    return input ~= "" and input or default_val
end

-- Ekranı Çizme
local function draw_screen()
    local term_h, term_w = get_term_size()
    local edit_rows = math.max(1, term_h - 6)

    if current_row < start_row then
        start_row = current_row
    elseif current_row >= start_row + edit_rows then
        start_row = current_row - edit_rows + 1
    end

    io.write("\27[?25l\27[H")

    local progress = #lines > 1 and math.floor((current_row / #lines) * 100) or 100
    local left_str = string.format("Rext v0.6.0 [Lua]        %d%%", progress)
    local right_str = string.format("%s | %s | %d chars", file_path, user_name, count_chars())
    local spaces = math.max(1, term_w - utf8_len(left_str) - utf8_len(right_str))
    
    io.write(string.format("\27[1;7m%s%s%s\27[0m\r\n", left_str, string.rep(" ", spaces), right_str))
    io.write(string.rep("-", term_w) .. "\r\n")

    for i = 1, edit_rows do
        local file_row = start_row + i - 1
        io.write(string.format("\27[%d;1H\27[K", i + 2))
        if file_row <= #lines then
            io.write(string.format("\27[1;30m%4d │ \27[0m%s", file_row, lines[file_row]))
        end
    end

    local line1 = term_h - 2
    local line2 = term_h - 1
    line_3 = term_h

    io.write(string.format("\27[%d;1H\27[K%s\r\n", line1, string.rep("-", term_w)))
    io.write(string.format("\27[%d;1H\27[K \27[1;7mCtrl+S/F2\27[0m Save  \27[1;7mCtrl+Q/F10\27[0m Exit  \27[1;7mCtrl+F\27[0m Search  \27[1;7mCtrl+K\27[0m Cut Line\r\n", line2))
    io.write(string.format("\27[%d;1H\27[K \27[1;7mLine:\27[0m %d/%d  \27[1;7mCol:\27[0m %d\r", line_3, current_row, #lines, current_col))

    local cursor_r = current_row - start_row + 3
    local cursor_c = current_col + 7
    io.write(string.format("\27[%d;%dH\27[?25h", cursor_r, cursor_c))
    io.flush()
end

-- Dosyayı Kaydetme
local function save_file()
    local new_name = prompt_bar("File Name to Write:", file_path)
    if new_name then file_path = new_name end
    local out = io.open(file_path, "w")
    if out then
        for _, line in ipairs(lines) do
            out:write(line .. "\n")
        end
        out:close()
    end
end

-- Çok Baytlı (UTF-8) Karakter Okuma
local function read_utf8_char(first_byte)
    local b = string.byte(first_byte)
    local len = 1
    if b >= 0xC0 and b <= 0xDF then len = 2
    elseif b >= 0xE0 and b <= 0xEF then len = 3
    elseif b >= 0xF0 and b <= 0xF7 then len = 4 end

    if len == 1 then return first_byte end
    local rest = io.read(len - 1)
    return first_byte .. rest
end

-- Klavye Okuma ve Döngü
set_raw_mode(true)

while true do
    draw_screen()
    local char = io.read(1)
    if not char then break end

    -- KISAYOL KOMBİNASYONLARI
    if char == "\17" then -- Ctrl+Q (Çıkış)
        break
    elseif char == "\19" or char == "\23" then -- Ctrl+S veya Ctrl+W (Kaydet)
        save_file()
    elseif char == "\06" or char == "\14" then -- Ctrl+F veya Ctrl+N (Arama)
        local term = prompt_bar("Search Term:", "")
        if term and term ~= "" then
            for idx, line in ipairs(lines) do
                if line:find(term, 1, true) then
                    current_row = idx
                    current_col = 1
                    break
                end
            end
        end
    elseif char == "\01" then -- Ctrl+A (Satır Başı)
        current_col = 1
    elseif char == "\05" then -- Ctrl+E (Satır Sonu)
        current_col = utf8_len(lines[current_row]) + 1
    elseif char == "\11" then -- Ctrl+K (Satırı Sil / Kestir)
        if #lines > 1 then
            table.remove(lines, current_row)
            if current_row > #lines then current_row = #lines end
            current_col = math.min(current_col, utf8_len(lines[current_row]) + 1)
        else
            lines = {""}
            current_col = 1
        end
    elseif char == "\r" or char == "\n" then -- Enter
        local line = lines[current_row]
        local left = utf8_sub(line, 1, current_col - 1)
        local right = utf8_sub(line, current_col)
        lines[current_row] = left
        table.insert(lines, current_row + 1, right)
        current_row = current_row + 1
        current_col = 1
    elseif char == "\127" or char == "\008" then -- Backspace
        if current_col > 1 then
            local line = lines[current_row]
            lines[current_row] = utf8_sub(line, 1, current_col - 2) .. utf8_sub(line, current_col)
            current_col = current_col - 1
        elseif current_row > 1 then
            local prev_len = utf8_len(lines[current_row - 1])
            lines[current_row - 1] = lines[current_row - 1] .. lines[current_row]
            table.remove(lines, current_row)
            current_row = current_row - 1
            current_col = prev_len + 1
        end
    elseif char == "\27" then -- Kaçış Dizileri (Yön Tuşları, Home, End, PageUp/Down, Delete)
        local seq1 = io.read(1)
        if seq1 == "[" then
            local seq2 = io.read(1)
            if seq2 == "A" then -- Yukarı Ok
                if current_row > 1 then
                    current_row = current_row - 1
                    current_col = math.min(current_col, utf8_len(lines[current_row]) + 1)
                end
            elseif seq2 == "B" then -- Aşağı Ok
                if current_row < #lines then
                    current_row = current_row + 1
                    current_col = math.min(current_col, utf8_len(lines[current_row]) + 1)
                end
            elseif seq2 == "C" then -- Sağ Ok
                if current_col <= utf8_len(lines[current_row]) then
                    current_col = current_col + 1
                elseif current_row < #lines then
                    current_row = current_row + 1
                    current_col = 1
                end
            elseif seq2 == "D" then -- Sol Ok
                if current_col > 1 then
                    current_col = current_col - 1
                elseif current_row > 1 then
                    current_row = current_row - 1
                    current_col = utf8_len(lines[current_row]) + 1
                end
            elseif seq2 == "H" then -- Home
                current_col = 1
            elseif seq2 == "F" then -- End
                current_col = utf8_len(lines[current_row]) + 1
            elseif seq2 == "3" then -- Delete Tuşu
                local seq3 = io.read(1)
                if seq3 == "~" then
                    local line = lines[current_row]
                    if current_col <= utf8_len(line) then
                        lines[current_row] = utf8_sub(line, 1, current_col - 1) .. utf8_sub(line, current_col + 1)
                    elseif current_row < #lines then
                        lines[current_row] = line .. lines[current_row + 1]
                        table.remove(lines, current_row + 1)
                    end
                end
            elseif seq2 == "5" then -- PageUp
                local seq3 = io.read(1)
                if seq3 == "~" then
                    local term_h, _ = get_term_size()
                    current_row = math.max(1, current_row - (term_h - 6))
                    current_col = math.min(current_col, utf8_len(lines[current_row]) + 1)
                end
            elseif seq2 == "6" then -- PageDown
                local seq3 = io.read(1)
                if seq3 == "~" then
                    local term_h, _ = get_term_size()
                    current_row = math.min(#lines, current_row + (term_h - 6))
                    current_col = math.min(current_col, utf8_len(lines[current_row]) + 1)
                end
            end
        elseif seq1 == "O" then
            local seq2 = io.read(1)
            if seq2 == "Q" then save_file() end -- F2
        end
    else
        local full_char = read_utf8_char(char)
        local line = lines[current_row]
        lines[current_row] = utf8_sub(line, 1, current_col - 1) .. full_char .. utf8_sub(line, current_col)
        current_col = current_col + 1
    end
end

set_raw_mode(false)
