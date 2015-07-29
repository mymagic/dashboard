module MagicConnect
  GET_USER_BY_EMAIL_URI = 'http://connect.mymagic.my/api/get-user-by-email/'
  SIGN_UP_USER_URI      = 'http://connect.mymagic.my/api/signup/'

  def self.user_exists?(email)
    response = MagicConnect.user_details(email)
    response.code.to_i == 200 && JSON.parse(response.body)["error"].blank?
  end

  def self.create_user!(first_name, last_name, email)
    response = MagicConnect.post_user_details(
      first_name: first_name, last_name: last_name, email: email
    )
    response.code == "200"
  end

  private

  def self.post(uri, data)
    req = Net::HTTP::Post.new(uri)
    req.set_form_data(data)
    req.basic_auth ENV['magic_api_username'], ENV['magic_api_password']
    Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
  end

  def self.get(uri)
    req = Net::HTTP::Get.new(uri)
    req.basic_auth ENV['magic_api_username'], ENV['magic_api_password']
    Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
  end

  def self.post_user_details(details)
    uri = URI(SIGN_UP_USER_URI)
    MagicConnect.post(uri, details)
  end

  def self.user_details(email)
    uri = URI(GET_USER_BY_EMAIL_URI)
    uri.query = { email: email }.to_query
    MagicConnect.get(uri).response
  end
end
