class SamlController < ApplicationController
  skip_before_action :verify_authenticity_token

  def init
    request = OneLogin::RubySaml::Authrequest.new
    redirect_to(request.create(saml_settings))
  end

  def consume
    response          = OneLogin::RubySaml::Response.new(params[:SAMLResponse])
    response.settings = saml_settings

    # We validate the SAML Response and check if the user already exists in the system
    if response.is_valid?
      # authorize_success, log the user
      session[:userid] = response.name_id
      session[:attributes] = response.attributes
    else
      authorize_failure  # This method shows an error message
    end
  end

  private

  def saml_settings
    settings = OneLogin::RubySaml::Settings.new

    settings.assertion_consumer_service_url = "http://localhost:4000/saml/consume" # SP side
    settings.issuer                         = request.host
    settings.idp_sso_target_url             = "http://localhost:3000/saml/auth" # IdP side
    settings.idp_cert_fingerprint           = "9E:65:2E:03:06:8D:80:F2:86:C7:6C:77:A1:D9:14:97:0A:4D:F4:4D"
    settings.name_identifier_format         = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"

    # Optional for most SAML IdPs
    settings.authn_context = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"

    # Optional. Describe according to IdP specification (if supported) which attributes the SP desires to receive in SAMLResponse.
    # settings.attributes_index = 5
    # Optional. Describe an attribute consuming service for support of additional attributes.
    # settings.attribute_consuming_service.configure do
    #   service_name "Service"
    #   service_index 5
    #   add_attribute :name => "Name", :name_format => "Name Format", :friendly_name => "Friendly Name"
    # end

    settings
  end
end