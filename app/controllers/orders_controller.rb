class OrdersController < ApplicationController
  def create
    @order = Order.create!(order_params).tap do |order|
      order.line_items.create(order_line_items_params)
    end
    render json: order_json, status: :created
  end

  def checkout
    @order = PaymentService.purchase_order(
      Order.find(params[:id]),
      credit_card_params.to_h,
    )
    render json: order_json, status: :ok
  end

  private

  def order_params
    params.require :customer_email
    params.permit :customer_email
  end

  def order_line_items_params
    params.require(:line_items).
      map { |line_item_params| line_item_params.permit(:quantity, :name, :unit_price) }
  end

  def credit_card_params
    params.permit :first_name, :last_name, :number, :month, :year, :verification_value
  end

  def order_json
    @order.to_json(:include => [:line_items])
  end
end
