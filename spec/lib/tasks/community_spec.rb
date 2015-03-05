require 'rails_helper'
require 'rake'

describe 'community' do
  before do
    Rake.application.rake_require 'tasks/community'
    Rake::Task.define_task(:environment)
  end

  def run_task(name, slug)
    allow(ENV).to receive(:[]).with("COMMUNITY_NAME").and_return(name)
    allow(ENV).to receive(:[]).with("COMMUNITY_SLUG").and_return(slug)

    Rake::Task['community:create'].reenable
    Rake.application.invoke_task 'community:create'
  end

  it 'creates new community' do
    expect { run_task('Community Name', 'community-name') }.to change { Community.count }.by(1)
  end

  it 'auto generates community slug' do
    expect { run_task('Community Name', nil) }.to change { Community.count }.by(1)
    expect(Community.last.slug).to eq('community-name')
  end

  it 'throws validation errors' do
    expect(Rails.logger)
      .to receive(:error)
      .with("Fail to create a community: Validation failed: Name can't be blank, Slug can't be blank")
    expect { run_task(nil, nil) }.to change { Community.count }.by(0)
  end
end
