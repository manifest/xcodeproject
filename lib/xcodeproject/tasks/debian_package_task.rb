require 'rake'

module XcodeProject
	module Tasks
		module DebianPackageTask
			attr_accessor :deb_opts

			def define
				super

				bs = build_settings
				raise StandardError.new("You need to specify a `INFOPLIST_PATH' in order to be able to build debian package!") if bs['INFOPLIST_PATH'].nil?

				plist     = @project.read.target(bs['TARGET_NAME']).config(bs['CONFIGURATION']).plist
				app_name  = plist.read_property('CFBundleDisplayName', bs).downcase
				deb_name  = app_name.gsub('_', '-')
				build_dir = Pathname.new(bs['CONFIGURATION_BUILD_DIR'])
				app_path  = build_dir.join(bs['WRAPPER_NAME'])
				deb_path  = build_dir.join(deb_name + '.deb')
				
				package_dir        = build_dir.join(deb_name)
				package_apps_dir   = package_dir.join('Applications')
				package_debian_dir = package_dir.join('DEBIAN')

				namespace(@namespace) do
					directory(package_apps_dir.to_s)
					directory(package_debian_dir.to_s)

					file deb_path => [package_apps_dir.to_s, package_debian_dir.to_s] do
						# reading actual build settings
						bs        = build_settings
						raise StandardError.new("You need to specify a `INFOPLIST_PATH' in order to be able to build debian package!") if bs['INFOPLIST_PATH'].nil?

						plist     = @project.read.target(bs['TARGET_NAME']).config(bs['CONFIGURATION']).plist
						app_v     = plist.read_property('CFBundleShortVersionString', bs)
						app_id    = plist.read_property('CFBundleIdentifier', bs)
						
						@deb_opts ||= Hash.new
						@deb_opts.map {|setting, value| setting.capitalize }
						@deb_opts['Name']         ||= deb_name
						@deb_opts['Package']      ||= app_id
						@deb_opts['Version']      ||= app_v
						@deb_opts['Architecture'] ||= 'iphoneos-arm'

						# creating deb package source derictories
						`cp -fr "#{app_path}" "#{package_apps_dir}"`

						# creating control file
						package_debian_dir.join('control').open('w') do |f|
							@deb_opts.each {|key, value| f.puts("#{key}: #{value}") }
						end

						# this hack is needed
						dpkg_path = Gem.bin_path('xcodeproject', 'dpkg-deb-fat', VERSION)
						`#{dpkg_path} -b #{package_dir}`
					end

					desc "Builds the debian package."
					task :build_deb => [:build, deb_path]

					desc "Cleans the debian package build using the same build settings."
					task :clean_deb => [:clean] do
						clean = FileList.new
						clean.include(deb_path)
						clean.include(package_dir)
						clean.each {|fn| rm_r fn rescue nil }
					end

					desc "Builds the debian package from a clean state."
					task :cleanbuild_deb => [:clean_deb, :build_deb]
				end
			end
		end
	end
end
