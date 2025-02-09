--[[
    CountKeyFrames.lua
    Author: Your Name
    Description: Counts all keyframes in all layers/channels of a Moho document
]]--
ScriptName = "CountTotalKeyFrames"

CountTotalKeyFrames = {}

-- Function to display script name in MOHO's Script Menu
function CountTotalKeyFrames:UILabel()
    return "Count Total Keyframes"
end

function printOnce(str)
    print(str)
end

function CountKeyFrames(moho)
    local doc = moho.document
    if not doc then
        printOnce("No document open.")
        return
    end

    local totalKeys = 0

    local function ProcessLayer(layer, count)
        -- Ensure the layer is valid before counting keys
        if not layer then return count end
    
        printOnce("check layer: " .. layer:Name())

        local numCh = layer:CountChannels()
        printOnce("CountChannels: " .. numCh)
    
        for i = 0, numCh - 2 do
            local chInfo = MOHO.MohoLayerChannel:new_local()
            layer:GetChannelInfo(i, chInfo)
            if( chInfo.name:Buffer() == "All Channels") then
                if (chInfo.subChannelCount == 1) then
                    local ch = layer:Channel(i, 0, moho.document)
                    local countkeys = ch:CountKeys()
                    printOnce("Channel " .. i .. ": " .. chInfo.name:Buffer() .. "  Keyframes: " .. countkeys)
                    if countkeys > 1 then
                        count = count + countkeys
                    end
                else
                    printOnce("Channel " .. i .. ": " .. chInfo.name:Buffer())
                    for subID = 0, chInfo.subChannelCount - 1 do
                        local ch = layer:Channel(i, subID, moho.document)
                        local countkeys = ch:CountKeys()
                        if countkeys > 1 then
                            printOnce("Sub-channel " .. subID .. "  Keyframes: " .. countkeys)
                            count = count + countkeys
                        end
                    end
                end
            end
        end
        
        -- Recursively process sublayers if it's a group layer
        if layer:LayerType() == MOHO.LT_GROUP then
            local groupLayer = moho:LayerAsGroup(layer)
            if groupLayer then
                for i = 0, groupLayer:CountLayers()-1 do
                    local subLayer = groupLayer:Layer(i)
                    count = ProcessLayer(subLayer, count)
                end
            end
        end
        
        return count
    end

    -- Iterate through all document layers
    for i = 0, doc:CountLayers() - 1 do
        local layer = doc:Layer(i)
        printOnce("check layer: " .. layer:Name())
        totalKeys = ProcessLayer(layer, totalKeys)
    end

    -- Show result
    print("Total Keyframes: " .. totalKeys)
end

function CountTotalKeyFrames:Run(moho)
    CountKeyFrames(moho)
end