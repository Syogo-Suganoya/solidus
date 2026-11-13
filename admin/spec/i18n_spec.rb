# frozen_string_literal: true

require "i18n/tasks"

RSpec.describe I18n do
  # The configuration, and the paths it refers to, are relative to the root of
  # the gem.
  around { |example| Dir.chdir(File.expand_path("..", __dir__)) { example.run } }

  let(:i18n) { I18n::Tasks::BaseTask.new }
  let(:missing_keys) { i18n.missing_keys }
  let(:inconsistent_interpolations) { i18n.inconsistent_interpolations }

  it "does not have missing keys" do
    expect(missing_keys).to be_empty,
      "Missing #{missing_keys.leaves.count} i18n keys, run `i18n-tasks missing' from the admin directory to show them"
  end

  it "does not have inconsistent interpolations" do
    error_message = "#{inconsistent_interpolations.leaves.count} i18n keys have inconsistent interpolations.\n" \
                    "Run `i18n-tasks check-consistent-interpolations' from the admin directory to show them"
    expect(inconsistent_interpolations).to be_empty, error_message
  end
end
