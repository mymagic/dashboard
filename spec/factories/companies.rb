FactoryGirl.define do
  factory :company do
    name 'ACME Corporation'
    logo do
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root, 'spec', 'support', 'companies', 'logos', 'acme_logo.jpg'
        )
      )
    end
  end
end
