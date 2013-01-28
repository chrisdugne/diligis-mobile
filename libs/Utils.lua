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