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

    local totalLayers = 0

    local function ProcessLayer(layer, layername)
        -- Ensure the layer is valid before counting keys
        if not layer then return 0 end

        totalLayers = totalLayers + 1
    
        local layer_Type = layer:LayerType()
        
        local cur_keynum = 0
        local numCh = layer:CountChannels()
        for i = 0, numCh - 2 do
            local chInfo = MOHO.MohoLayerChannel:new_local()
            layer:GetChannelInfo(i, chInfo)
            if not chInfo.selectionBased and chInfo.name:Buffer() ~= "All Channels" then
                local uniqueKeyframes = {}
                for subID = 0, chInfo.subChannelCount-1 do
                    local ch = layer:Channel(i, subID, moho.document)
                    for k = 0, ch:CountKeys()-1 do
                        local keyFrameID = ch:GetKeyWhen(k)
                        uniqueKeyframes[keyFrameID] = true
                    end
                end
                local totalUniqueKeyframes = 0
                for _ in pairs(uniqueKeyframes) do
                    totalUniqueKeyframes = totalUniqueKeyframes + 1
                end
                if totalUniqueKeyframes > 1 then
                    printOnce( "layer(" .. layername .. ")(" .. layer_Type .. "): Channel " .. i .. "(" .. chInfo.name:Buffer() .. ") :  Keyframes: " .. totalUniqueKeyframes)
                    cur_keynum = cur_keynum + totalUniqueKeyframes
                end
            end
        end

        -- layer:ClearLayerKeyCount()
        -- local countKeys = layer:CountLayerKeys() - 1
        -- if (countKeys==1) then countKeys = 0 end
        -- printOnce("number of keyframes of layer(" .. layername .. ")(" .. layer_Type .. "): " .. countKeys)
        -- count = count + countKeys

        -- local numCh = layer:CountChannels()
        -- printOnce("CountChannels: " .. numCh)
        -- for i = 0, numCh - 2 do
        --     local chInfo = MOHO.MohoLayerChannel:new_local()
        --     layer:GetChannelInfo(i, chInfo)
        --     if( chInfo.name:Buffer() == "All Channels") then
        --         if (chInfo.subChannelCount == 1) then
        --             local ch = layer:Channel(i, 0, moho.document)
        --             local countkeys = ch:CountKeys()
        --             printOnce("Channel " .. i .. ": " .. chInfo.name:Buffer() .. "  Keyframes: " .. countkeys)
        --             if countkeys > 1 then
        --                 count = count + countkeys
        --             end
        --         else
        --             printOnce("Channel " .. i .. ": " .. chInfo.name:Buffer())
        --             for subID = 0, chInfo.subChannelCount - 1 do
        --                 local ch = layer:Channel(i, subID, moho.document)
        --                 local countkeys = ch:CountKeys()
        --                 if countkeys > 1 then
        --                     printOnce("Sub-channel " .. subID .. "  Keyframes: " .. countkeys)
        --                     count = count + countkeys
        --                 end
        --             end
        --         end
        --     end
        -- end

        -- Recursively process sublayers if it's a group or bone layer
        if layer_Type == MOHO.LT_BONE or layer_Type == MOHO.LT_GROUP then
            local groupLayer = moho:LayerAsGroup(layer)
            if groupLayer and groupLayer:CountLayers() > 0 then
                for i = 0, groupLayer:CountLayers()-1 do
                    local subLayer = groupLayer:Layer(i)
                    local s = layername .. "=>" .. subLayer:Name()
                    cur_keynum = cur_keynum + ProcessLayer(subLayer, s)
                end
            else
                print("This is not group layer")
            end
        end
        
        return cur_keynum
    end

    -- Iterate through all document layers
    local totalKeys = 0
    for i = 0, doc:CountLayers() - 1 do
        local layer = doc:Layer(i)
        printOnce("check layer: " .. layer:Name())
        totalKeys = totalKeys + ProcessLayer(layer, layer:Name() )
    end

    -- Show result
    print("Total Layer: " .. totalLayers .. ", Total Keyframes: " .. totalKeys)
end

function CountTotalKeyFrames:Run(moho)
    CountKeyFrames(moho)
end