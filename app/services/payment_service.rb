require 'active_merchant'

module PaymentService
  class << self
    def purchase_order(order, credit_card_params)
      gateway = ActiveMerchant::Billing::TrustCommerceGateway.new(
        :login => 'TestMerchant',
        :password => 'password',
      )
      credit_card = ActiveMerchant::Billing::CreditCard.new(credit_card_params)
      if credit_card.validate.empty?
        response = gateway.purchase(order.total_amount * 100, credit_card)
        if response.success?
          order.update(paid_at: Time.now)
        else
          raise Error::PaymentError, response.message
        end
      else
        raise Error::InvalidCreditCardError, credit_card.validate
      end
    end
  end
end
