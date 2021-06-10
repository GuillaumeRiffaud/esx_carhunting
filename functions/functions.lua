function getHashColorGroupLabel(hash)
    for key,value in pairs(Config.Colors) do
        for k,v in pairs(value.colorHashes) do
            if v == hash then
                return value.label
            end
        end
    end
    return "unidentified"
end

function capitalizeFirstLetter(word)
    local firstLetter = string.sub(word, 1, 1)
    local restOfTheWord = string.sub(word, 2)
    return (string.upper(firstLetter) .. string.lower(restOfTheWord))
end