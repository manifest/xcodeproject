require 'xcodeproject/formatter'

class Array
	def to_plist (fmtr = XcodeProject::Formatter.new)
		items = map { |item| "#{item.to_plist(fmtr)}" }
		%{(#{fmtr.t2}#{items.join(",#{fmtr.t2}")}#{fmtr.t1})}
	end
end
