
exports['qb-target']:AddBoxZone("restaurantcooker", vector3(-1336.85, -1060.75, 7.35), 1.8, 1.8, { --, the 1.5 is the length of the boxzone and the 1.6 is the width of the boxzone, the length and width have to be float values
  name = "restaurantcooker", -- This is the name of the zone recognized by PolyZone, this has to be unique so it doesn't mess up with other zones
  heading = 35.0, -- The heading of the boxzone, this has to be a float value
  debugPoly = false, -- This is for enabling/disabling the drawing of the box, it accepts only a boolean value (true or false), when true it will draw the polyzone in green
  minZ = 5.35, -- This is the bottom of the boxzone, this can be different from the Z value in the coords, this has to be a float value
  maxZ = 8.35, -- This is the top of the boxzone, this can be different from the Z value in the coords, this has to be a float value
}, {
  options = { -- This is your options table, quiin this table all the options will be specified for the target to accept
    { -- This is the first table with options, you can make as many options inside the options table as you want
      	num = 1, -- This is the position number of your option in the list of options in the qb-target context menu (OPTIONAL)
      	type = "client", -- This specifies the type of event the target has to trigger on click, this can be "client", "server", "command" or "qbcommand", this is OPTIONAL and will only work if the event is also specified
      	event = "qb-menu:client:restaurant:cooker", -- This is the event it will trigger on click, this can be a client event, server event, command or qbcore registered command, NOTICE: Normal command can't have arguments passed through, QBCore registered ones can have arguments passed through
      	icon = 'fa-solid fa-utensils', -- This is the icon that will display next to this trigger option
      	label = 'Cuisiner', -- This is the label of this option which you would be able to click on to trigger everything, this has to be a string
      	targeticon = 'fas fa-example', -- This is the icon of the target itself, the icon changes to this when it turns blue on this specific option, this is OPTIONAL
      	-- action = function(entity) -- This is the action it has to perform, this REPLACES the event and this is OPTIONAL
		-- 	TriggerEvent('qb-menu:client:restaurant:cooker') -- Triggers a client event called testing:event and sends the argument 'test' with it
		-- end,
      	job = 'restaurant', -- This is the job, this option won't show up if the player doesn't have this job, this can also be done with multiple jobs and grades, if you want multiple jobs you always need a grade with it: job = {["police"] = 0, ["ambulance"] = 2},
      	--gang = 'ballas', -- This is the gang, this option won't show up if the player doesn't have this gang, this can also be done with multiple gangs and grades, if you want multiple gangs you always need a grade with it: gang = {["ballas"] = 0, ["thelostmc"] = 2},
      	--citizenid = 'JFD98238', -- This is the citizenid, this option won't show up if the player doesn't have this citizenid, this can also be done with multiple citizenid's, if you want multiple citizenid's there is a specific format to follow: citizenid = {["JFD98238"] = true, ["HJS29340"] = true},
      	drawDistance = 3.0, -- This is the distance for the sprite to draw if Config.DrawSprite is enabled, this is in GTA Units (OPTIONAL)
      	drawColor = {255, 0, 0, 0}, -- This is the color of the sprite if Config.DrawSprite is enabled, this will change the color for this PolyZone only, if this is not present, it will fallback to Config.DrawColor, for more information, check the comment above Config.DrawColor (OPTIONAL)
      	successDrawColor = {30, 144, 255, 255}, -- This is the color of the sprite if Config.DrawSprite is enabled, this will change the color for this PolyZone only, if this is not present, it will fallback to Config.DrawColor, for more information, check the comment above Config.DrawColor (OPTIONAL)
    }
  },
  distance = 2.5, -- This is the distance for you to be at for the target to turn blue, this is in GTA units and has to be a float value
})


exports['qb-target']:AddBoxZone("restaurantstash", vector3(-1343.40, -1060.80, 7.35), 1.8, 1.8, { --, the 1.5 is the length of the boxzone and the 1.6 is the width of the boxzone, the length and width have to be float values
  name = "restaurantstash", -- This is the name of the zone recognized by PolyZone, this has to be unique so it doesn't mess up with other zones
  heading = 35.0, -- The heading of the boxzone, this has to be a float value
  debugPoly = false, -- This is for enabling/disabling the drawing of the box, it accepts only a boolean value (true or false), when true it will draw the polyzone in green
  minZ = 5.35, -- This is the bottom of the boxzone, this can be different from the Z value in the coords, this has to be a float value
  maxZ = 8.35, -- This is the top of the boxzone, this can be different from the Z value in the coords, this has to be a float value
}, {
  options = { -- This is your options table, quiin this table all the options will be specified for the target to accept
    { -- This is the first table with options, you can make as many options inside the options table as you want
      	num = 1, -- This is the position number of your option in the list of options in the qb-target context menu (OPTIONAL)
      	type = "client", -- This specifies the type of event the target has to trigger on click, this can be "client", "server", "command" or "qbcommand", this is OPTIONAL and will only work if the event is also specified
      	event = "qb-restaurant:client:openstash", -- This is the event it will trigger on click, this can be a client event, server event, command or qbcore registered command, NOTICE: Normal command can't have arguments passed through, QBCore registered ones can have arguments passed through
      	icon = 'fa-solid fa-box-archive', -- This is the icon that will display next to this trigger option
      	label = 'Ouvrir le coffre', -- This is the label of this option which you would be able to click on to trigger everything, this has to be a string
      	targeticon = 'fas fa-example', -- This is the icon of the target itself, the icon changes to this when it turns blue on this specific option, this is OPTIONAL
      	job = 'restaurant', -- This is the job, this option won't show up if the player doesn't have this job, this can also be done with multiple jobs and grades, if you want multiple jobs you always need a grade with it: job = {["police"] = 0, ["ambulance"] = 2},
      	--gang = 'ballas', -- This is the gang, this option won't show up if the player doesn't have this gang, this can also be done with multiple gangs and grades, if you want multiple gangs you always need a grade with it: gang = {["ballas"] = 0, ["thelostmc"] = 2},
      	--citizenid = 'JFD98238', -- This is the citizenid, this option won't show up if the player doesn't have this citizenid, this can also be done with multiple citizenid's, if you want multiple citizenid's there is a specific format to follow: citizenid = {["JFD98238"] = true, ["HJS29340"] = true},
      	drawDistance = 3.0, -- This is the distance for the sprite to draw if Config.DrawSprite is enabled, this is in GTA Units (OPTIONAL)
      	drawColor = {255, 0, 0, 0}, -- This is the color of the sprite if Config.DrawSprite is enabled, this will change the color for this PolyZone only, if this is not present, it will fallback to Config.DrawColor, for more information, check the comment above Config.DrawColor (OPTIONAL)
      	successDrawColor = {30, 144, 255, 255}, -- This is the color of the sprite if Config.DrawSprite is enabled, this will change the color for this PolyZone only, if this is not present, it will fallback to Config.DrawColor, for more information, check the comment above Config.DrawColor (OPTIONAL)
    }
  },
  distance = 2.5, -- This is the distance for you to be at for the target to turn blue, this is in GTA units and has to be a float value
})


local modelcow = {
	a_c_cow = 'a_c_cow',
}

exports['qb-target']:AddTargetModel(modelcow, { -- This defines the models, can be a string or a table
options = { 
    {
    num = 1, -- This is the position number of your option in the list of options in the qb-target context menu (OPTIONAL)
    type = "client", -- This specifies the type of event the target has to trigger on click, this can be "client", "server", "command" or "qbcommand", this is OPTIONAL and will only work if the event is also specified
    --event = "qb-restaurant-client-traire", -- This is the event it will trigger on click, this can be a client event, server event, command or qbcore registered command, NOTICE: Normal command can't have arguments passed through, QBCore registered ones can have arguments passed through
    --icon = 'fa-solid fa-cow', -- This is the icon that will display next to this trigger option
    label = 'Traire', -- This is the label of this option which you would be able to click on to trigger everything, this has to be a string
    targeticon = 'fa-solid fa-cow', -- This is the icon of the target itself, the icon changes to this when it turns blue on this specific option, this is OPTIONAL
    --item = 'handcuffs', -- This is the item it has to check for, this option will only show up if the player has this item, this is OPTIONAL
    action = function(entity) -- This is the action it has to perform, this REPLACES the event and this is OPTIONAL
        if IsPedAPlayer(entity) then return false end -- This will return false if the entity interacted with is a player and otherwise returns true
    
		TriggerEvent('qb-restaurant-client-traire',source, entity)
    end,
    -- canInteract = function(entity, distance, data) -- This will check if you can interact with it, this won't show up if it returns false, this is OPTIONAL
    --     if IsPedAPlayer(entity) then return false end -- This will return false if the entity interacted with is a player and otherwise returns true
    --     return true
    -- end,
    job = 'restaurant', -- This is the job, this option won't show up if the player doesn't have this job, this can also be done with multiple jobs and grades, if you want multiple jobs you always need a grade with it: job = {["police"] = 0, ["ambulance"] = 2},
    }
},
distance = 3.5, -- This is the distance for you to be at for the target to turn blue, this is in GTA units and has to be a float value
})


exports['qb-target']:AddBoxZone("restaurantsell", vector3(-1339.41, -1058.95, 7.35), 1.8, 1.8, { 
  name = "restaurantsell",
  heading = 35.0, 
  debugPoly = false, 
  minZ = 6.35,
  maxZ = 9.35,
}, {
  options = { 
    { 
      	num = 1, 
      	type = "client", 
      	event = "qb-restaurant:client:takeorder", 
      	icon = 'fa-solid fa-dolly', 
      	label = 'Prendre la commande', 
      	targeticon = 'fas fa-example',
      	job = 'restaurant', 
      	drawDistance = 3.0, 
      	drawColor = {255, 0, 0, 0}, 
      	successDrawColor = {30, 144, 255, 255}, 

    },
	{ 
	  	num = 2, 
	  	type = "client", 
	  	event = "qb-restaurant:client:payorder", 
	  	icon = 'fa-solid fa-right-from-bracket', 
	  	label = 'Sortir de son service', 
	   targeticon = 'fa-solid fa-money-bill-wave',
	   job = 'restaurant', 
	   drawDistance = 3.0, 
	   drawColor = {255, 0, 0, 0}, 
	   successDrawColor = {30, 144, 255, 255}, 

	}
  },
  distance = 2.5,
})


exports['qb-target']:AddTargetModel('h4_prop_h4_box_delivery_01a', { -- This defines the models, can be a string or a table
options = { 
    {
    num = 1, -- This is the position number of your option in the list of options in the qb-target context menu (OPTIONAL)
    type = "client", -- This specifies the type of event the target has to trigger on click, this can be "client", "server", "command" or "qbcommand", this is OPTIONAL and will only work if the event is also specified
    --event = "qb-restaurant-client-traire", -- This is the event it will trigger on click, this can be a client event, server event, command or qbcore registered command, NOTICE: Normal command can't have arguments passed through, QBCore registered ones can have arguments passed through
    --icon = 'fa-solid fa-cow', -- This is the icon that will display next to this trigger option
    label = 'Ranger les pizzas', -- This is the label of this option which you would be able to click on to trigger everything, this has to be a string
    targeticon = 'fa-solid fa-pizza-slice', -- This is the icon of the target itself, the icon changes to this when it turns blue on this specific option, this is OPTIONAL
    --item = 'handcuffs', -- This is the item it has to check for, this option will only show up if the player has this item, this is OPTIONAL
    action = function(entity) -- This is the action it has to perform, this REPLACES the event and this is OPTIONAL
      if IsPedAPlayer(entity) then return false end -- This will return false if the entity interacted with is a player and otherwise returns true
      if not pizzaonbox then
		    TriggerEvent('qb-restaurant:client:storepizza')
      elseif ontakepizza then
        TriggerEvent('qb-restaurant:client:storepizza')
      else
        exports['PipouUI']:Notify("Il y a déjà des pizzas dans la boîte", "error")
      end
    end,
    job = 'restaurant', -- This is the job, this option won't show up if the player doesn't have this job, this can also be done with multiple jobs and grades, if you want multiple jobs you always need a grade with it: job = {["police"] = 0, ["ambulance"] = 2},
    },
    {
      num = 2, -- This is the position number of your option in the list of options in the qb-target context menu (OPTIONAL)
      type = "client", -- This specifies the type of event the target has to trigger on click, this can be "client", "server", "command" or "qbcommand", this is OPTIONAL and will only work if the event is also specified
      --event = "qb-restaurant-client-traire", -- This is the event it will trigger on click, this can be a client event, server event, command or qbcore registered command, NOTICE: Normal command can't have arguments passed through, QBCore registered ones can have arguments passed through
      --icon = 'fa-solid fa-cow', -- This is the icon that will display next to this trigger option
      label = 'Sortir une pizza', -- This is the label of this option which you would be able to click on to trigger everything, this has to be a string
      targeticon = 'fa-solid fa-pizza-slice', -- This is the icon of the target itself, the icon changes to this when it turns blue on this specific option, this is OPTIONAL
      --item = 'handcuffs', -- This is the item it has to check for, this option will only show up if the player has this item, this is OPTIONAL
      action = function(entity) -- This is the action it has to perform, this REPLACES the event and this is OPTIONAL
        if IsPedAPlayer(entity) then return false end -- This will return false if the entity interacted with is a player and otherwise returns true
        if not ontakepizza then
          if pizzaonbox then
            TriggerEvent('qb-restaurant:client:getpizza')
          else
            exports['PipouUI']:Notify("Pas de pizzas au chaud ! Retourne en chercher", "error")
            TriggerEvent('qb-restaurant:client:backtorestaurant')
          end
        else
          exports['PipouUI']:Notify("Tu as déjà une pizza dans les mains !", "error")
        end
      end,
      job = 'restaurant', -- This is the job, this option won't show up if the player doesn't have this job, this can also be done with multiple jobs and grades, if you want multiple jobs you always need a grade with it: job = {["police"] = 0, ["ambulance"] = 2},
    },
  },
distance = 3.5, -- This is the distance for you to be at for the target to turn blue, this is in GTA units and has to be a float value
})
