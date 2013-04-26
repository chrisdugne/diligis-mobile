-----------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------
--
--
function getUrlParams(url)

	local index = string.find(url,"?")
	local paramsString = url:sub(index+1, string.len(url) )

	local params = {}
	
	fillNextParam(params, paramsString);
	
	return params;

end

function fillNextParam(params, paramsString)

	local indexEqual = string.find(paramsString,"=")
	local indexAnd = string.find(paramsString,"&")
	
	local indexEndValue
	if(indexAnd == nil) then 
		indexEndValue = string.len(paramsString) 
	else 
		indexEndValue = indexAnd - 1 
	end
	 
	if ( indexEqual ~= nil ) then
		local varName = paramsString:sub(0, indexEqual-1)
		local value = paramsString:sub(indexEqual+1, indexEndValue)
		params[varName] = value

		if (indexAnd ~= nil) then
			paramsString = paramsString:sub(indexAnd+1, string.len(paramsString) )
			fillNextParam(params, paramsString)
		end

	end
	
end

-----------------------------------------------------------------------------------------

function emptyGroup( group )
	if(group ~= nil) then
		for i=group.numChildren,1,-1 do
        	local child = group[i]
		 	child:removeSelf()
			child = nil
		end
	end
end

-----------------------------------------------------------------------------------------

function string.startsWith(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function string.endsWith(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end

-----------------------------------------------------------------------------------------

function joinTables(t1, t2)
	if(t1 == nil) then t1 = {} end
	if(t2 == nil) then t2 = {} end
	for k,v in pairs(t2) do
		 table.insert(t1, v) 
	end 
	return t1
end

-----------------------------------------------------------------------------------------

function imageName( url )
	local index = string.find(url,"/")
	
	if(index == nil) then 
		if(not string.endsWith(url, ".png")) then
			url = url .. ".png"
		end
		return url;
	else
		local subURL = url:sub(index+1, string.len(url))
		return imageName(subURL)
	end
end

-----------------------------------------------------------------------------------------

--a tester  https://gist.github.com/874792

function tprint (tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      tprint(v, indent+1)
    else
      print(formatting .. v)
    end
  end
end

-----------------------------------------------------------------------------------------