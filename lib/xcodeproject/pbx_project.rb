#--
# The MIT License
#
# Copyright (c) 2012-2014 Andrei Nesterov <ae.nesterov@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
#++

require 'xcodeproject/node'

module XcodeProject
  class PBXProject < Node
    attr_reader :main_group
    attr_reader :product_ref_group
    attr_reader :project_dir_path
    attr_reader :compatibility_version
    attr_reader :development_region
    attr_reader :know_regions
    attr_reader :attributes

    def initialize(root, uuid, data)
      super(root, uuid, data)

      @main_group = root.object!(data['mainGroup'])
      @product_ref_group = root.object!(data['productRefGroup'])
      @project_dir_path = data['projectDirPath']
      @compatibility_version = data['compatibilityVersion']
      @development_region = data['developmentRegion']
      @know_regions = data['knownRegions']
      @attributes = data['attributes']
    end

    def targets
      data['targets'].map { |uuid| root.object!(uuid) }
    end

    def target(name)
      root.find_object('PBXNativeTarget', 'name' => name)
    end
  end
end
