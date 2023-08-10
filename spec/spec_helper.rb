# frozen_string_literal: true

# Add lib/ to load path
$LOAD_PATH.prepend(File.dirname(__FILE__))
$LOAD_PATH.prepend(File.join(File.dirname(__FILE__), "..", "lib"))

require "rspec"

require "chingu"
require "chingu/require_all"

def media_path(file)
  File.join($window.root, "..", "..", "examples", "media", file)
end
