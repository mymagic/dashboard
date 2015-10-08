module ControllerHelper
  def setup_devise!
    request.env["devise.mapping"] = Devise.mappings[:member]
  end

  def set_params!(hsh)
    allow(controller).to receive(:params).and_return(ActionController::Parameters.new(hsh))
  end
end
