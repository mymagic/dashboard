require 'rails_helper'

RSpec.describe 'community', type: :task do
  require 'rake'

  before do
    Rake.application.rake_require 'tasks/community'
    Rake::Task.define_task(:environment)
  end

  def run_task(name, slug, email)
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with("COMMUNITY_NAME").and_return(name)
    allow(ENV).to receive(:[]).with("COMMUNITY_SLUG").and_return(slug)
    allow(ENV).to receive(:[]).with("ADMIN_EMAIL").and_return(email)

    Rake::Task['community:create'].reenable
    capture_stderr { Rake.application.invoke_task 'community:create' }
  end

  it 'creates new community' do
    expect {
      run_task('Community Name', 'community-name', 'admin@magic.com')
    }.to change(Community, :count).from(0).to(1)
  end

  it 'auto generates community slug' do
    expect {
      run_task('Community Name', nil, 'admin@magic.com')
    }.to change(Community, :count).from(0).to(1)
    expect(Community.last.slug).to eq('community-name')
  end

  it 'abort generating community without community name' do
    expect { run_task(nil, nil, 'admin@magic.com') }
      .to raise_error(SystemExit, /Missing COMMUNITY_NAME/)
  end

  it 'abort generating community without admin email' do
    expect { run_task('Community Name', nil, nil) }
      .to raise_error(SystemExit, /Missing ADMIN_EMAIL/)
  end
end
