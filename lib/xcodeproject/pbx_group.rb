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

require 'xcodeproject/pbx_file_reference'
require 'xcodeproject/exceptions'
require 'pathname'

module XcodeProject
  class PBXGroup < FileNode
    def initialize(root, uuid, data)
      super(root, uuid, data)
      @children = data['children']
    end

    def children
      @children.map { |uuid| root.object!(uuid) }
    end

    def groups
      children.select { |child| child.is_a?(PBXGroup) }
    end

    def files
      children.select { |child| child.is_a?(PBXFileReference) }
    end

    def child(gpath)
      gpath = Pathname.new(gpath).cleanpath

      if gpath == gpath.basename
        name = gpath.to_s
        case name
        when '.'
          self
        when '..'
          parent
        else
          chs = children.select { |obj| obj.name == name }
          raise GroupPathError, 'The group contains two children with the same name.' if chs.size > 1
          chs.first
        end
      else
        pn, name = gpath.split
        group = child(pn)
        group.child(name) if group.is_a?(PBXGroup)
      end
    end

    def file_ref(gpath)
      obj = child(gpath)
      obj.is_a?(PBXFileReference) ? obj : nil
    end

    def group?
      data['path'].nil?
    end

    def dir?
      !group?
    end

    def group(gpath)
      obj = child(gpath)
      obj.is_a?(PBXGroup) ? obj : nil
    end

    def add_group(gpath)
      create_group(gpath)
    end

    def add_dir(path, gpath = nil)
      path = absolute_path(path)
      raise FilePathError, "No such directory '#{path}'." unless path.exist?

      gpath ||= path.basename
      parent = create_group(gpath, path)

      chs = path.entries.select { |obj| obj.to_s.start_with?('.') ? false : true }
      chs.each do |pn|
        parent.absolute_path(pn).directory? ? parent.add_dir(pn) : parent.add_file(pn)
      end
      parent
    end

    def create_group(gpath, path = nil)
      gpath = Pathname.new(gpath).cleanpath

      if gpath == gpath.basename
        name = gpath.to_s
        case name
        when '.'
          self
        when '..'
          parent
        else
          obj = group(name)
          if obj.nil?
            path = relative_path(path) unless path.nil?
            obj = PBXGroup.add(root, name, path)
            add_child_uuid(obj.uuid)
          end
          obj
        end
      else
        pn, name = gpath.split
        create_group(pn).create_group(name)
      end
    end

    def add_child_uuid(uuid)
      @children << uuid
    end

    def remove_child_uuid(uuid)
      @children.delete(uuid)
    end

    def absolute_path(path)
      path = Pathname.new(path)
      path.absolute? ? path : root.absolute_path(total_path.join(path))
    end

    def relative_path(path)
      path = Pathname.new(path)
      path.relative? ? path : path.relative_path_from(total_path)
    end

    def remove_file_ref(gpath)
      obj = file(gpath)
      obj.remove! unless obj.nil?
    end

    def remove_group(gpath)
      obj = group(gpath)
      obj.remove! unless obj.nil?
    end

    def remove!
      return if parent.nil?

      children.each(&:remove!)

      parent.remove_child_uuid(uuid)
      root.remove_object(uuid)
    end

    def add_file_ref(path)
      raise FilePathError, "No such file '#{absolute_path(path)}'." unless absolute_path(path).exist?

      name = File.basename(path)
      obj = file_ref(name)
      if obj.nil?
        obj = PBXFileReference.add(root, relative_path(path))
        add_child_uuid(obj.uuid)
      end
      obj
    end

    def self.add(root, name, path = nil)
      uuid, data = root.add_object(create_object_hash(name, path))
      PBXGroup.new(root, uuid, data)
    end

    alias file        file_ref
    alias add_file    add_file_ref
    alias remove_file remove_file_ref

    private_class_method

    def self.create_object_hash(name, path = nil)
      path = path.to_s

      data = []
      data << %w[isa PBXGroup]
      data << ['children', []]
      data << ['name', name]
      data << ['path', path] unless path.empty?
      data << ['sourceTree', '<group>']

      Hash[data]
    end
  end
end
