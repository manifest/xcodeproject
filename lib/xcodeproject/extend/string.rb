require 'json'

class String
	def to_plist (fmtr = nil)
		to_json
	end
end
