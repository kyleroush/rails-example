require 'rails_helper'
require 'active_merchant'

ActiveMerchant::Billing::Base.mode = :test

RSpec.describe 'Orders API', type: :request do
  describe 'POST /orders' do
    let(:valid_order_with_two_line_items) do
      {
        customer_email: 'customer@mail.com',
        line_items: [
          {
            name: 'T-shirt',
            unit_price: '10.0',
            quantity: 2,
          },
          {
            name: 'Shoes',
            unit_price: '60.0',
            quantity: 1,
          },
        ],
      }
    end

    context 'when the request is valid' do
      before { post '/orders', params: valid_order_with_two_line_items }

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end

      it 'returns order' do
        expect(json).to include_json(valid_order_with_two_line_items)
      end

      it 'creates order' do
        expect(Order.count).to eq(1)
      end

      it 'creates line items' do
        expect(LineItem.count).to eq(2)
      end
    end

    context 'when the request does not contain a customer e-mail' do
      before do
        post '/orders', params: valid_order_with_two_line_items.except(:customer_email)
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns error message' do
        expect(json).to include_json({
          errors: [
            {
              customer_email: 'param is missing or the value is empty: customer_email',
            },
          ],
        })
      end

      it 'does not create order' do
        expect(Order.count).to eq(0)
      end

      it 'does not create line items' do
        expect(LineItem.count).to eq(0)
      end
    end

    context 'when the request contains a invalid customer e-mail' do
      before do
        post '/orders', params: valid_order_with_two_line_items.merge(customer_email: 'bad_email')
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns error message' do
        expect(json).to include_json({
          errors: {
            customer_email: ['is invalid'],
          },
        })
      end

      it 'does not create order' do
        expect(Order.count).to eq(0)
      end

      it 'does not create line items' do
        expect(LineItem.count).to eq(0)
      end
    end
  end

  describe 'POST /order/:order_id/checkout' do
    purchase_response = nil

    let!(:orders) do
      create_list(:order, 3)
    end

    let(:order_id) { orders.first.id }

    let(:valid_payment_information) do
      {
        first_name: 'Bob',
        last_name: 'Bobsen',
        number: '4242424242424242',
        month: '8',
        year: Time.now.year + 1,
        verification_value: '000',
      }
    end

    before do
      purchase_response = instance_double('ActiveMerchant::Billing::Response')
      allow(purchase_response).to receive(:success?).and_return(true)

      allow_any_instance_of(ActiveMerchant::Billing::TrustCommerceGateway).
        to receive(:purchase).
        with(kind_of(Numeric), kind_of(ActiveMerchant::Billing::CreditCard)).
        and_return(purchase_response)

      post "/orders/#{order_id}/checkout", params: valid_payment_information
    end

    context 'when the request contains valid payment information' do
      context 'when purchase is successful' do
        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end

        it 'calls purchase and check if the response is success' do
          expect(purchase_response).to have_received(:success?)
        end
      end
    end
  end
end
