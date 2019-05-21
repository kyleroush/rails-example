class ApplicationController < ActionController::API
  rescue_from(ActionController::ParameterMissing) do |exception|
    error = {}
    error[exception.param] = exception.message
    response = { errors: [error] }
    render json: response, status: :unprocessable_entity
  end

  rescue_from(ActiveRecord::RecordInvalid) do |exception|
    response = { errors: exception.record.errors }
    render json: response, status: :unprocessable_entity
  end

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    response = { errors: exception.message }
    render json: response, status: :not_found
  end

  rescue_from(Error::InvalidCreditCardError) do |exception|
    response = { errors: exception.message }
    render json: response, status: :unprocessable_entity
  end

  rescue_from(Error::PaymentError) do |exception|
    response = { errors: exception.message }
    render json: response, status: :internal_server_error
  end
end
