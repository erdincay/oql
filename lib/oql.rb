# encoding: UTF-8

# OpenProject Query Language (OQL) is intended to specify filter queries on OpenProject data.
# Copyright (C) 2014  OpenProject Foundation
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'oql/parser'
require 'oql/parsing_failed'
require 'oql/tree_transform'
require 'oql/version'

require 'parslet'

class OQL

  # Parses the given query string and returns a tree-ish representation of
  # the given query.
  #
  # @param query [String] The query string to be parsed
  # @return [Hash] A tree-ish representation of the parsed query
  # @raise [OQL::ParsingFailed] if the query provided was invalid
  def self.parse(query)
    begin
      parse_tree = Parser.new.parse(query)
    rescue Parslet::ParseFailed => e
      raise ParsingFailed, e.message
    end

    TreeTransform.new.apply(parse_tree)
  end
end
