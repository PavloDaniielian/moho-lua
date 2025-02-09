ScriptName = "CountTotalKeyFrames"

CountTotalKeyFrames = {}

-- Function to display script name in MOHO's Script Menu
function CountTotalKeyFrames:UILabel()
    return "Count Total Keyframes"
end

-- List of channel types to count
local channelTypes = {
    MOHO.CHANNEL_TRANSLATION_X,
    MOHO.CHANNEL_TRANSLATION_Y,
    MOHO.CHANNEL_TRANSLATION_Z,
    MOHO.CHANNEL_ROTATION_X,
    MOHO.CHANNEL_ROTATION_Y,
    MOHO.CHANNEL_ROTATION_Z,
    MOHO.CHANNEL_SCALE_X,
    MOHO.CHANNEL_SCALE_Y,
    MOHO.CHANNEL_SCALE_Z,
    MOHO.CHANNEL_OPACITY,
    MOHO.CHANNEL_SHEAR_X,
    MOHO.CHANNEL_SHEAR_Y,
    MOHO.CHANNEL_LAYER_ORDER,
    MOHO.CHANNEL_CURVATURE
}

-- Function to count keyframes in a layer
function countKeyframesInLayer(layer)
    local totalKeyframes = 0

    -- If it's a Group Layer, check sub-layers
    if layer:IsGroupType() then
        print("📂 Entering Group Layer: " .. layer:Name())

        -- Try to get sub-layers, even if CountLayers() is unavailable
        local subLayerCount = layer:CountLayers() or 0
        print("  🔍 Group contains " .. subLayerCount .. " sub-layers (if 0, checking deeper manually).")

        if subLayerCount > 0 then
            for i = 0, subLayerCount - 1 do
                local subLayer = layer:Layer(i)
                totalKeyframes = totalKeyframes + countKeyframesInLayer(subLayer)
            end
        else
            print("  ⚠️ Warning: CountLayers() failed, checking deeper manually.")
            
            -- If CountLayers() fails, check if it's a Smart Bone or other type
            if layer:LayerType() == MOHO.LT_BONE then
                totalKeyframes = totalKeyframes + countKeyframesInLayer(layer)
            end
        end

    -- Handle Bone Layers and Count Bone Animation Keyframes
    elseif layer:LayerType() == MOHO.LT_BONE then
        print("🦴 Checking Bone Layer: " .. layer:Name())

        local skeleton = layer:Skeleton()
        if skeleton then
            local boneCount = skeleton:CountBones()
            print("  🔍 Bone Layer has " .. boneCount .. " bones.")

            for i = 0, boneCount - 1 do
                local bone = skeleton:Bone(i)
                if bone then
                    local keyCount = bone:AnimationChannel(MOHO.BONE_ANIM_TRANSLATION):CountKeys() +
                                     bone:AnimationChannel(MOHO.BONE_ANIM_ANGLE):CountKeys() +
                                     bone:AnimationChannel(MOHO.BONE_ANIM_SCALE):CountKeys()
                    
                    print("  🦴 Bone " .. i .. " (" .. bone:Name() .. ") has " .. keyCount .. " keyframes")
                    totalKeyframes = totalKeyframes + keyCount
                end
            end
        else
            print("  ⚠️ Warning: No skeleton found in Bone Layer. Skipping...")
        end

    -- Handle Camera Keyframes
    elseif layer:LayerType() == MOHO.LT_CAMERA then
        print("🎥 Checking Camera Layer: " .. layer:Name())

        for _, channelType in ipairs(channelTypes) do
            local channel = layer:Channel(channelType)
            if channel then
                local keyCount = channel:CountKeys()
                print("  🎞️ Camera Channel has " .. keyCount .. " keyframes")
                totalKeyframes = totalKeyframes + keyCount
            end
        end

    -- Handle Vector, Image, and Switch Layers
    else
        local channelCount = layer:CountChannels()
        print("🎬 Checking Layer: " .. layer:Name() .. " | Channels: " .. channelCount)

        for j = 0, channelCount - 1 do
            local channel = layer:Channel(j)
            if channel ~= nil then
                local keyCount = channel:CountKeys()
                print("  🎥 Channel " .. j .. " has " .. keyCount .. " keyframes")
                totalKeyframes = totalKeyframes + keyCount
            else
                print("  ⚠️ Warning: Channel " .. j .. " is nil. Skipping...")
            end
        end
    end

    return totalKeyframes
end

-- Main function to count keyframes
function CountTotalKeyFrames:Run(moho)
    if moho == nil or moho.document == nil then
        print("❌ Error: No active document found.")
        return
    end

    print("📜 Moho Document Found! Starting keyframe count...")

    local totalKeyframes = 0
    local layers = moho.document:CountLayers()
    print("📦 Total Layers: " .. layers)

    for i = 0, layers - 1 do
        local layer = moho.document:Layer(i)
        totalKeyframes = totalKeyframes + countKeyframesInLayer(layer)
    end

    print("🎯 Total Keyframes in the Project: " .. totalKeyframes)
end