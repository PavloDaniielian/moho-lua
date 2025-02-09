ScriptName = "CountTotalKeyFrames"

CountTotalKeyFrames = {}

-- Function to display script name in MOHO's Script Menu
function CountTotalKeyFrames:UILabel()
    return "Count Total Keyframes"
end

-- List of all possible keyframe-supported channels
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
    MOHO.CHANNEL_CURVATURE,
    MOHO.CHANNEL_MORPH,
    MOHO.CHANNEL_SMARTBONE,
    MOHO.CHANNEL_VECTOR_X,
    MOHO.CHANNEL_VECTOR_Y
}

-- Function to count keyframes in any layer
function countKeyframesInLayer(layer)
    local totalKeyframes = 0

    -- If it's a group layer, check sub-layers (if possible)
    if layer:IsGroupType() then
        print("📂 Entering Group Layer: " .. layer:Name())

        -- Check if CountLayers() is available
        if layer.CountLayers then
            local subLayerCount = layer:CountLayers()
            print("  🔍 Group contains " .. subLayerCount .. " sub-layers.")

            for i = 0, subLayerCount - 1 do
                local subLayer = layer:Layer(i)
                totalKeyframes = totalKeyframes + countKeyframesInLayer(subLayer)
            end
        else
            print("  ⚠️ Warning: CountLayers() is unavailable for " .. layer:Name() .. ". Checking channels manually.")
            -- Even if it's a "group", count its direct channels
        end
    end

    -- Count Bone Animation Keyframes
    if layer:LayerType() == MOHO.LT_BONE then
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
    end

    -- Count Camera Keyframes
    if layer:LayerType() == MOHO.LT_CAMERA then
        print("🎥 Checking Camera Layer: " .. layer:Name())

        for _, channelType in ipairs(channelTypes) do
            local channel = layer:Channel(channelType)
            if channel then
                local keyCount = channel:CountKeys()
                print("  🎞️ Camera Channel has " .. keyCount .. " keyframes")
                totalKeyframes = totalKeyframes + keyCount
            end
        end
    end

    -- Count All Other Animation Keyframes (Even When Grouped)
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