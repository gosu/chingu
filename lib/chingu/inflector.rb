#--
#
# Chingu -- OpenGL accelerated 2D game framework for Ruby
# Copyright (C) 2009 ippa / ippa@rubylicio.us
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
#++

module Chingu
  module Inflector
		#
		# "automatic_assets" -> "AutomaticAssets"
		#
    def Inflector.camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
      if first_letter_in_uppercase
        lower_case_and_underscored_word.to_s
                                       .gsub(/\/(.?)/) { "::#{$1.upcase}" }
                                       .gsub(/(?:^|_)(.)/) { $1.upcase }
      else
        lower_case_and_underscored_word.first.downcase + camelize(
                                                           lower_case_and_underscored_word
                                                         )[1..-1]
      end
    end

    #
    # "Chingu::GameObject" -> "GameObject"
    #
    def Inflector.demodulize(class_name_in_module)
      class_name_in_module.to_s.gsub(/^.*::/, '')
    end

		#
		# "FireBall" -> "fire_ball"
		#
		def Inflector.underscore(camel_cased_word)
			camel_cased_word.to_s
                      .gsub(/::/, '/')
                      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
			                .gsub(/([a-z\d])([A-Z])/, '\1_\2')
			                .tr("-", "_")
			                .downcase
		end

  end
end
