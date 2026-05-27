---- ════════════════════════════════════════════════════════════════
----        Copyright © WITHVOIDWITHIN — All rights reserved.
----         https://steamcommunity.com/id/withvoidwithin/
----               https://withvoidwithin.github.io/
---- ════════════════════════════════════════════════════════════════

---- Debug
---- ================================================================================================================================

---- Numbers
---- ================================================================================================================================

--- Ограничивает число заданными границами.
--- @param number number Значение для ограничения
--- @param min? number Минимальное значение
--- @param max? number Максимальное значение
--- @return number
--- **[ Server / Client ]**
function _Clamp(number, min, max)
    if min and number < min then return min end
    if max and number > max then return max end

    return number
end

--- Генерирует случайное число с треугольным (Normal) или V-образным (Inverted) распределением.
--- @param min number
--- @param max number
--- @param bias number диапазон [0.0 - 1.0].
--- @param inverted? boolean true для V-образного распределения (провал в точке bias).
--- **[ Server / Client ]**
function _RandomDist(min, max, bias, inverted)
    local u = RandomFloat(0, 1)
    local range = max - min

    if not inverted then
        -- Triangular Distribution
        if u < bias then
            return min + range * math.sqrt(u * bias)
        else
            return max - range * math.sqrt((1.0 - u) * (1.0 - bias))
        end
    else
        -- Inverted (V-Shape) Distribution
        if u < bias then
            return min + (range * bias) * (1.0 - math.sqrt(u / bias))
        else
            return (min + range * bias) + (range * (1.0 - bias)) * math.sqrt((u - bias) / (1.0 - bias))
        end
    end
end

--- Округляет число до заданного количества знаков после запятой.
--- <br> Использует метод "Round Half Up" (округление 0.5 в большую сторону).
--- @param number number Число для округления.
--- @param decimals? number Количество знаков (по умолчанию 0).
--- @return number
--- **[ Server / Client ]**
function _Round(number, decimals)
    if not decimals or decimals == 0 then
        return math.floor(number + 0.5)
    end

    local mult = 10 ^ decimals

    return math.floor(number * mult + 0.5) / mult
end

--- @param number number
--- @param in_min number
--- @param in_max number
--- @param out_min number
--- @param out_max number
function _Remap(number, in_min, in_max, out_min, out_max)
    return Script_RemapValClamped(number, in_min, in_max, out_min, out_max)
end

---- Tables
---- ================================================================================================================================

--- Рекурсивно копирует таблицу.
--- Cсылки на Userdata (Dota Entities) сохраняются, но не клонируются.
--- @param obj any Объект для копирования.
--- @param copy_meta? boolean Скопировать ли метатаблицу (по умолчанию false).
--- @param _seen? table (Internal) Кэш для обработки циклических ссылок. Его не нужно передавать.
--- @return any
--- **[ Server / Client ]**
function _DeepCopy(obj, copy_meta, _seen)
    if type(obj) ~= "table" then return obj end

    _seen = _seen or {}

    if _seen[obj] then return _seen[obj] end

    local new_table = {}

    _seen[obj] = new_table

    for k, v in pairs(obj) do
        new_table[_DeepCopy(k, copy_meta, _seen)] = _DeepCopy(v, copy_meta, _seen)
    end

    if copy_meta then
        local mt = getmetatable(obj)
        if mt then setmetatable(new_table, mt) end
    end

    return new_table
end

--- Рекурсивно сливает содержимое table_new в table_base.
--- Модифицирует table_base на месте.
--- @param table_base table Таблица, в которую будут добавлены данные.
--- @param table_new table Таблица с новыми данными.
--- @param merge_meta? boolean Если true, сливает также метатаблицы (рекурсивно).
--- @return table
--- **[ Server / Client ]**
function _Merge(table_base, table_new, merge_meta)
    if not table_new then return table_base end

    for k, v in pairs(table_new) do
        if type(table_base[k]) == "table" and type(v) == "table" then
            _Merge(table_base[k], v, merge_meta)
        else
            table_base[k] = _DeepCopy(v, merge_meta)
        end
    end

    if merge_meta then
        local mt_new = getmetatable(table_new)

        if type(mt_new) == "table" then
            local mt_base = getmetatable(table_base)

            if type(mt_base) == "table" then
                _Merge(mt_base, mt_new, true)
            else
                setmetatable(table_base, _DeepCopy(mt_new, true))
            end
        end
    end

    return table_base
end

--- Возвращает количество элементов в таблице (корректно работает с hash-map и смешанными таблицами).
--- Аналог table.count, так как оператор # работает только с последовательными массивами.
--- @param tbl table
--- <br> **[ Server / Client ]**
function _GetTableSize(tbl)
    if not tbl then return 0 end

    local count = 0

    for _ in pairs(tbl) do
        count = count + 1
    end

    return count
end

--- Возвращает случайный КЛЮЧ из таблицы любого типа.
--- @generic Key, Value
--- @param tbl table<Key, Value>
--- @return Key
--- <br> **[ Server / Client ]**
function _GetTableRandomKey(tbl)
    local count = 0

    for _ in pairs(tbl) do
        count = count + 1
    end

    if count == 0 then return nil end

    local target = RandomInt(1, count)
    local i = 0

    for k, _ in pairs(tbl) do
        i = i + 1

        if i == target then return k end
    end --- @diagnostic disable-line: missing-return
end

--- Возвращает случайное ЗНАЧЕНИЕ из таблицы любого типа.
--- @generic Key, Value
--- @param tbl table<Key, Value>
--- @return Value
--- <br> **[ Server / Client ]**
function _GetTableRandomValue(tbl)
    local count = 0

    for _ in pairs(tbl) do
        count = count + 1
    end

    if count == 0 then return nil end

    local target = RandomInt(1, count)
    local i = 0

    for _, v in pairs(tbl) do
        i = i + 1

        if i == target then return v end
    end --- @diagnostic disable-line: missing-return
end

---- Server Only
---- ================================================================================================================================

if not IsServer() then return end

--- Рекурсивно подготавливает данные для отправки на клиент.
--- @param obj any Данные для сериализации.
--- @param _seen? table (Internal) Кэш для защиты от циклов.
--- @return any
function _SerializeForClient(obj, _seen)
    local t = type(obj)

    -- 1. Пропускаем примитивы (number, string, boolean, nil)
    if t ~= "table" and t ~= "userdata" then
        return obj
    end

    if t == "userdata" then
        if obj.GetEntityIndex then
            if IsValidEntity(obj) then
                return obj:GetEntityIndex()
            else
                return nil -- Энтити невалидна (мертва), не отправляем мусор
            end
        else
            -- Это Vector или другой безопасный userdata (Physics object и т.д.)
            return obj
        end
    end

    -- 3. Обработка таблиц (рекурсия и защита от циклов)
    _seen = _seen or {}

    if _seen[obj] then
        return nil
    end

    _seen[obj] = true

    local new_table = {}

    for k, v in pairs(obj) do
        local key = _SerializeForClient(k, _seen)
        local val = _SerializeForClient(v, _seen)

        if key ~= nil and val ~= nil then
            new_table[key] = val
        end
    end

    return new_table
end

--- Записывает данные в CustomNetTables.
--- <br> Автоматически преобразует Entity -> EntityIndex.
--- @param nettable_name string Имя основной таблицы.
--- @param key string Ключ внутри таблицы.
--- @param data table|any Новые данные.
--- @param merge? boolean Если true, данные будут слиты с текущими, а не перезаписаны целиком.
--- **[ Server Only ]**
function _SetNetTable(nettable_name, key, data, merge)
    local safe_data = _SerializeForClient(data)

    if safe_data == nil then return end

    if merge then
        local current_data = CustomNetTables:GetTableValue(nettable_name, key)

        if current_data and type(current_data) == "table" and type(safe_data) == "table" then
            _Merge(current_data, safe_data)

            safe_data = current_data
        end
    end

    CustomNetTables:SetTableValue(nettable_name, key, safe_data)
end

--- Рекурсивно фильтрует таблицу `data`, создавая новую таблицу на основе правил из `mask`.
--- @param data any
--- @param mask table|bool
function _SerializeDataByMask(data, mask)
    if mask == true then return data end
    if type(data) ~= "table" or type(mask) ~= "table" then return nil end

    local result = {}
    local has_data = false

    for key, mask_value in pairs(mask) do
        local data_value = data[key]

        if data_value ~= nil then
            if mask_value == true then
                result[key] = data_value
                has_data = true
            else
                local sub_result = _SerializeDataByMask(data_value, mask_value)

                if sub_result then
                    result[key] = sub_result
                    has_data = true
                end
            end
        end
    end

    return has_data and result or nil
end

--- Разбивает строку на отдельные значения, используя указанный разделитель, и возвращает их в виде таблицы.
--- @param str string Строка, которую нужно разбить на значения.
--- @param devider? string Разделитель, по которому производится разделение строки (по умолчанию — пробел).
--- **[ Server / Client ]**
function _ParseStringToValues(str, devider)
    local values = {}

    devider = devider or " "

    for value in str:gmatch("[^" .. devider .. "]+") do
        table.insert(values, value)
    end

    return values
end

--- Возвращает рандомный ключ с учётом весов (больше вес — выше шанс).
--- @generic Key
--- @param Table table<Key, number|string>
--- @return Key
function _GetTableRandomKeyByWeight(Table)
    local TotalWeight = 0
    local Weights = {}

    for Key, Weight in pairs(Table) do
        local Num = tonumber(Weight)
        if Num and Num > 0 then
            TotalWeight = TotalWeight + Num
            table.insert(Weights, { Key = Key, Weight = Num })
        end
    end

    local Pick = RandomFloat(0, TotalWeight)
    local Accum = 0

    for _, Entry in ipairs(Weights) do
        Accum = Accum + Entry.Weight
        if Pick <= Accum then
            return Entry.Key
        end
    end

    return nil -- fallback
end

--- Возвращает рандомный ключ с учётом обратных весов (меньше вес — выше шанс).
--- @generic Key
--- @param Table table<Key, number|string>
--- @return Key
function _GetTableRandomKeyByWeightInverted(Table)
    local InvertedWeights = {}
    local TotalWeight = 0

    for Key, Weight in pairs(Table) do
        local Num = tonumber(Weight)
        if Num and Num > 0 then
            local Inv = 1 / Num
            TotalWeight = TotalWeight + Inv
            table.insert(InvertedWeights, { Key = Key, Weight = Inv })
        end
    end

    local Pick = RandomFloat(0, TotalWeight)
    local Accum = 0

    for _, Entry in ipairs(InvertedWeights) do
        Accum = Accum + Entry.Weight
        if Pick <= Accum then
            return Entry.Key
        end
    end

    return nil -- fallback
end

---- Vectors
---- ================================================================================================================================

--- Возвращает случайную точку с равномерным распределением внутри квадрата.
--- @param pos Vector Центр квадрата. Z-координата будет сохранена в итоговой точке.
--- @param radius number Радиус вписаной окружности квадрата.
--- @return Vector Случайная точка внутри квадрата.
--- **[ Server / Client ]**
function _GetRandomPosInSquare(pos, radius)
    local rnd = Vector(RandomFloat(-radius, radius), RandomFloat(-radius, radius), 0)

    return pos + rnd
end

--- Возвращает случайную точку с равномерным распределением внутри окружности.
--- @param pos Vector Центр окружности. Z-координата будет сохранена в итоговой точке.
--- @param radius number Радиус окружности.
--- @return Vector Point Случайная точка внутри окружности.
--- **[ Server / Client ]**
function _GetRandomPosInRadius(pos, radius)
    local theta = RandomFloat(0, 2 * math.pi)
    local r = radius * math.sqrt(math.random()) -- sqrt для равномерного распределения
    local x = pos.x + r * math.cos(theta)
    local y = pos.y + r * math.sin(theta)

    return Vector(x, y, pos.z)
end

---- Deebug
---- ================================================================================================================================

function _GetAllNPCUnitsKV()
    local fields = {}

    for unit_name, unit_data in pairs(LoadKeyValues("scripts/npc/npc_units.txt")) do
        if type(unit_data) == "table" then
            for key, value in pairs(unit_data) do
                fields[key] = value
            end
        end
    end

    return fields
end

---- Server Only
---- ================================================================================================================================

--- Прекеш таблицы игровых ресурсов.
--- @param context CScriptPrecacheContext
--- @param res _PrecacheTable
--- <br> **[ Server Only ]**
function _Precache(context, res)
    for type, files in pairs(res or {}) do
        for _, File in pairs(files or {}) do
            PrecacheResource(type, File, context)
        end
    end
end

--- Возвращает таблицу всех ID игроков определенной команды.
--- @param team_id int
--- @return [table<int, true>]
function _GetTeamPlayers(team_id)
    local players = {}

    for i = 0, DOTA_MAX_TEAM_PLAYERS do
        if PlayerResource:IsValidPlayerID(i) and PlayerResource:GetCustomTeamAssignment(i) == team_id then
            players[i] = true
        end
    end

    return players
end
