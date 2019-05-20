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
end
