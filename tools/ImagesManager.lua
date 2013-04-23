-----------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------

local images = {}

-----------------------------------------------------------------------------------------

function fetchImage( url, next, fileName )
    if(fileName == nil) then 
    	fileName = utils.imageName(url)
    end
    
	local imageReceived = function(event) return storeImage(fileName, event.target, next)  end
	display.loadRemoteImage( url, "GET", imageReceived, fileName, system.TemporaryDirectory )
end

function storeImage( name, image, next)
	image.alpha = 0;
	images[name] = image
	next();
end

------------------------------------------------------------

function drawImage( group, url, x, y, positionFrom, scale )

    local name = utils.imageName(url)
	local image = display.newImage( group, name, system.TemporaryDirectory)
	image.xScale = scale
	image.yScale = scale

	if(positionFrom == IMAGE_TOP_LEFT) then
		image.x = x + image.width*scale/2 
		image.y = y + image.height*scale/2
	else 
		image.x = x
		image.y = y
	end

	image.alpha = 0
	transition.to( image, { alpha = 1.0 } )
	
	return image;
end

function hideImage( image )
	transition.to( image, { alpha = 0, time = 400, transition = easing.outQuad } )
end