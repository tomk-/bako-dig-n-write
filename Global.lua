function onLoad()
    buttonContainer = getObjectFromGUID('0f1ba4')
    buttonContainer.createButton(
        {
            click_function = 'setup',
            function_owner = Global,
            label          = 'Setup',
            position       = {
                0, 0.01, 1.5
            },
            scale = {
                2,
                2,
                2
            },
            width          = 400,
            height         = 120
        }
    )
end

function setup()
    -- Place Discovery cards
    buttonContainer.removeButton(#buttonContainer.getButtons() - 3)
    local singleCardsGUIDs = {}
    for _, aCard in ipairs(getObjects()) do
        if aCard.type == 'Card' then
            table.insert(singleCardsGUIDs, aCard.getGUID())
        end
    end
    for _, aDeck in ipairs(getObjects()) do
        if aDeck.type == 'Deck' then
            aDeck.shuffle()
            Wait.time(
                function()
                    local deckGUID = aDeck.getGUID()
                    aDeck.takeObject(
                        {
                            position = {
                                aDeck.getPosition().x,
                                aDeck.getPosition().y + 3,
                                aDeck.getPosition().z
                            },
                            smooth = true,
                            flip = true
                        }
                    )
                    Wait.time(
                        function()
                            for _, remainingCards in ipairs(getObjects()) do
                                if remainingCards.type == 'Deck' or (remainingCards.type == 'Card' and remainingCards.is_face_down) then
                                    remainingCards.destruct()
                                end
                            end
                        end,
                        0.6
                    )
                end,
                0.6
            )
        end
    end

    -- Deal Game sheets
    local drawer = getObjectFromGUID('3dcbdd')
    drawer.call('onButtonClick')
    Wait.time(
        function()
            local gameSheetsBag = getObjectFromGUID('ff8268')
            for _, playerColorName in ipairs(getSeatedPlayers()) do
                for _, hand in ipairs(Hands.getHands()) do
                    local data = hand.getData()
                    for k, v in pairs(data) do
                        if k == "ColorDiffuse" then
                            local handZoneColor = cloneWithAlpha1(v)
                            local playerColor = Color.fromString(playerColorName)
                            if handZoneColor == playerColor then
                                local newPosition = nil
                                local newRotation = nil
                                if hand.getRotation().y == 0 then
                                    newPosition = {
                                        hand.getPosition().x,
                                        hand.getPosition().y,
                                        hand.getPosition().z + 18
                                    }
                                end
                                if hand.getRotation().y == 90 then
                                    newPosition = {
                                        hand.getPosition().x + 11,
                                        hand.getPosition().y,
                                        hand.getPosition().z
                                    }
                                end
                                if hand.getRotation().y == 180 then
                                    newPosition = {
                                        hand.getPosition().x,
                                        hand.getPosition().y,
                                        hand.getPosition().z - 18
                                    }
                                end
                                if hand.getRotation().y == 270 then
                                    newPosition = {
                                        hand.getPosition().x - 11,
                                        hand.getPosition().y,
                                        hand.getPosition().z
                                    }
                                end
                                local newRotation = {hand.getRotation().x, hand.getRotation().y - 180, hand.getRotation().z}
                                gameSheetsBag.takeObject(
                                    {
                                        position = newPosition,
                                        rotation = newRotation,
                                        smooth = true,
                                        callback_function = function(takenSheet)
                                            Wait.time(
                                                function()
                                                    takenSheet.setLock(true)
                                                end,
                                                3
                                            )
                                        end
                                    }
                                )
                                break
                            end
                        end
                    end
                end
                Wait.time(
                    function()
                        drawer = getObjectFromGUID('661907')
                        drawer.call('onButtonClick')
                    end,
                    1
                )
            end
        end,
        2
    )
end

 -- alpha 1 is needed since equals() contemplated it
 function cloneWithAlpha1(color)
    local copy = color:copy()
    copy:set(copy.r, copy.g, copy.b, 1)
    return copy
end