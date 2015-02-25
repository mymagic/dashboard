module ControllerHelper
  # Setup Devise controller for testing Devise controllers.
  #
  #     before do
  #       setup_devise!
  #       sign_in member
  #     end
  #
  def setup_devise!
    request.env["devise.mapping"] = Devise.mappings[:member]
  end

  # Set params in controller to ActionController::Parameters object with
  # values of the provided parameters hash.
  #
  #     before do
  #       set_params!(:foo => {:bar => 1, :baz => 2})
  #     end
  #
  def set_params!(hsh)
    allow(controller).to receive(:params).and_return(ActionController::Parameters.new(hsh))
  end
end
