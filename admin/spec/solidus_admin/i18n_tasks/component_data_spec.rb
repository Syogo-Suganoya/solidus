# frozen_string_literal: true

require "tmpdir"
require "fileutils"
require "solidus_admin/i18n_tasks/component_data"

RSpec.describe SolidusAdmin::I18nTasks::ComponentData do
  subject(:data) do
    described_class.new(
      base_locale: "en",
      locales: ["en"],
      read: [File.join(root, "config/locales/%{locale}.yml")],
      components_root: File.join(root, "app/components")
    )
  end

  let(:root) { Dir.mktmpdir }

  after { FileUtils.remove_entry(root) }

  def write(path, content)
    path = File.join(root, path)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end

  before do
    write "config/locales/en.yml", <<~YAML
      en:
        solidus_admin:
          title: "Admin"
    YAML

    write "app/components/solidus_admin/base/component.rb", <<~RUBY
      class SolidusAdmin::Base::Component < ViewComponent::Base
      end
    RUBY
    write "app/components/solidus_admin/base/component.yml", <<~YAML
      en:
        save: "Save"
        cancel: "Cancel"
    YAML

    write "app/components/solidus_admin/foo/index/component.rb", <<~RUBY
      class SolidusAdmin::Foo::Index::Component < SolidusAdmin::Base::Component
      end
    RUBY
    write "app/components/solidus_admin/foo/index/component.yml", <<~YAML
      en:
        save: "Save foo"
        nested:
          hint: "A hint"
    YAML

    write "app/components/solidus_admin/bar/component.rb", <<~RUBY
      class SolidusAdmin::Bar::Component < SolidusAdmin::Foo::Index::Component
      end
    RUBY
  end

  def translation(key)
    data["en"]["en.#{key}"]&.value
  end

  it "reads the regular locale files" do
    expect(translation("solidus_admin.title")).to eq("Admin")
  end

  it "nests the translations of a component under its scope" do
    expect(translation("solidus_admin.base.component.save")).to eq("Save")
    expect(translation("solidus_admin.foo.index.component.nested.hint")).to eq("A hint")
  end

  it "makes a component inherit the translations of its ancestors" do
    expect(translation("solidus_admin.foo.index.component.cancel")).to eq("Cancel")
  end

  it "lets a component override the translations it inherits" do
    expect(translation("solidus_admin.foo.index.component.save")).to eq("Save foo")
  end

  it "supports components without translations of their own" do
    expect(translation("solidus_admin.bar.component.save")).to eq("Save foo")
    expect(translation("solidus_admin.bar.component.cancel")).to eq("Cancel")
  end

  it "keeps track of the file each translation comes from" do
    leaf = data["en"]["en.solidus_admin.bar.component.cancel"]

    expect(leaf.data[:path]).to end_with("app/components/solidus_admin/base/component.yml")
  end
end
