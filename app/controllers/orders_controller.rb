require 'active_merchant'
include ActiveMerchant::Billing

class OrdersController < ApplicationController
  def create
    @order = Order.create!(order_params).tap do |order|
      order.line_items.create(order_line_items_params)
    end
    render json: order_json, status: :created
  end

  def checkout
    @order = Order.find(params[:id])
    result = purchase
    render json: { message: result }, status: :ok
  end

  private

  def purchase
    amount = 1000
    gateway = ActiveMerchant::Billing::TrustCommerceGateway.new(
      :login => 'TestMerchant',
      :password => 'password',
    )
    credit_card = ActiveMerchant::Billing::CreditCard.new(
      :first_name         => 'Bob',
      :last_name          => 'Bobsen',
      :number             => '4242424242424242',
      :month              => '8',
      :year               => Time.now.year + 1,
      :verification_value => '000',
    )
    if credit_card.validate.empty?
      response = gateway.purchase(@order.total, credit_card)
      if response.success?
        "Successfully charged $#{sprintf("%.2f", amount / 100)} to the credit card #{credit_card.display_number}"
      else
        raise StandardError, response.message
      end
    else
      raise StandardError, credit_card.validate
    end
  end

  def order_params
    params.require :customer_email
    params.permit :customer_email
  end

  def order_line_items_params
    params.require(:line_items).
      map { |line_item_params| line_item_params.permit(:quantity, :name, :unit_price) }
  end

  def order_json
    @order.to_json(:include => [:line_items])
  end
end
