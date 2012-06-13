require 'xcodeproject/formatter'

class Hash
	def to_plist (fmtr = XCodeProject::Formatter.new)
		fmtr.inc
		items = map { |key, value| "#{key.to_plist(fmtr)} = #{value.to_plist(fmtr)};" }
		fmtr.dec

		%{{#{fmtr.t2}#{items.join("#{fmtr.t2}")}#{fmtr.t1}}}
	end
end
