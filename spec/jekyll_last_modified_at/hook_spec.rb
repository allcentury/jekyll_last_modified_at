require "spec_helper"

RSpec.describe JekyllLastModifiedAt::Hook do
  it "registers the right hooks" do
    hooks = ::Jekyll::Hooks.instance_variable_get(:@registry)
    expect(hooks[:documents][:post_render]).not_to be_empty
    expect(hooks[:pages][:post_render]).not_to be_empty
    expect(hooks[:posts][:post_render]).not_to be_empty
  end
end
