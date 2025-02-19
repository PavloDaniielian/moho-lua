-- **************************************************
-- Provide Moho with the name of this script object
-- **************************************************

ScriptName = "CountKeyFramesInThisLayer"

-- **************************************************
-- General information about this script
-- **************************************************

CountKeyFramesInThisLayer = {}

function CountKeyFramesInThisLayer:Name()
	return "CountKeyFramesInThisLayer"
end

function CountKeyFramesInThisLayer:Version()
	return "1.0"
end

function CountKeyFramesInThisLayer:UILabel()
	return("Count KeyFrames In This Layer")
end

-- **************************************************
-- The guts of this script
-- **************************************************

function printOnce(str)
    print(str)
end

function CountKeyFramesInThisLayer:Run(moho)
    if moho.layer == nil then
        return
    end

	local numCh = moho.layer:CountChannels()
	printOnce("CountChannels: " .. numCh)

    local totalKeys = 0

	for i = 0, numCh - 2 do
		local chInfo = MOHO.MohoLayerChannel:new_local()
		moho.layer:GetChannelInfo(i, chInfo)
		if not chInfo.selectionBased and chInfo.name:Buffer() ~= "All Channels" and chInfo.name:Buffer() ~= "所有轨道" then
			local uniqueKeyframes = {}
			for subID = 0, chInfo.subChannelCount-1 do
				local ch = moho.layer:Channel(i, subID, moho.document)
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
				printOnce("Channel " .. i .. ": " .. chInfo.name:Buffer() .. "  Keyframes: " .. totalUniqueKeyframes)
				totalKeys = totalKeys + totalUniqueKeyframes
			end

			-- if (chInfo.subChannelCount == 1) then
			-- 	local ch = moho.layer:Channel(i, 0, moho.document)
			-- 	local countkeys = ch:CountKeys()
			-- 	printOnce("Channel " .. i .. ": " .. chInfo.name:Buffer() .. "  Keyframes: " .. countkeys)
			-- 	if countkeys > 1 then
			-- 		totalKeys = totalKeys + countkeys
			-- 	end
			-- else
			-- 	printOnce("Channel " .. i .. ": " .. chInfo.name:Buffer())
			-- 	for subID = 0, chInfo.subChannelCount - 1 do
			-- 		local ch = moho.layer:Channel(i, subID, moho.document)
			-- 		local countkeys = ch:CountKeys()
			-- 		if countkeys > 1 then
			-- 			printOnce("Sub-channel " .. subID .. "  Keyframes: " .. countkeys)
			-- 			totalKeys = totalKeys + countkeys
			-- 		end
			-- 	end
			-- end
		end
	end
    
	print("total key frames in this layer: " .. totalKeys)
end
