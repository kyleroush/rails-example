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
    gateway_mock, credit_card_mock, purchase_response_mock = nil

    let!(:orders) do
      create_list(:order, 3)
    end

    let(:order) { orders.first }

    let(:payment_information) do
      {
        first_name: 'Bob',
        last_name: 'Bobsen',
        number: '4242424242424242',
        month: '8',
        year: Time.now.year + 1,
        verification_value: '000',
      }
    end

    before do |example|
      allow(ActiveMerchant::Billing::CreditCard).
        to receive(:new) do |args|
          credit_card_mock = instance_double('ActiveMerchant::Billing::CreditCard', args)
          allow(credit_card_mock).to receive(:validate).and_return(
            case example.metadata[:payment_information]
            when :valid, nil then []
            when :invalid then ['illegal characters']
            end
          )
          credit_card_mock
        end

      allow(ActiveMerchant::Billing::TrustCommerceGateway).
        to receive(:new) do |args|
          gateway_mock = instance_double('ActiveMerchant::Billing::TrustCommerceGateway')
          purchase_response_mock = double('Gateway purchase response')
          allow(purchase_response_mock).to receive(:success?).and_return(
            case example.metadata[:purchase]
            when :success, nil then true
            when :fail then false
            end
          )
          allow(purchase_response_mock).to receive(:message).and_return('message')
          allow(gateway_mock).to receive(:purchase).and_return(purchase_response_mock)
          gateway_mock
        end

      order_id = case example.metadata[:requested_order]
                 when :not_paid, nil then order.id
                 when :unknown then 713705
                 end
      post "/orders/#{order_id}/checkout", params: payment_information
    end

    context 'when the requested order exist and has not been paid yet' do
      context 'when the request contains valid payment information' do
        it 'creates a CreditCard instance with the right information' do
          expect(ActiveMerchant::Billing::CreditCard).
            to have_received(:new).
            with(payment_information)
        end

        it 'creates a Gateway instance with login information' do
          # TODO
        end

        it 'calls purchase on Gateway' do
          expect(gateway_mock).
            to have_received(:purchase).
            with(order.total_amount * 100, credit_card_mock)
        end

        it 'checks if response is success' do
          expect(purchase_response_mock).to have_received(:success?)
        end

        context 'when purchase is successful', purchase: :success do
          before do
            allow(purchase_response_mock).to receive(:success?).and_return(true)
          end

          it 'updates order as paid' do
            expect(order.reload.paid_at).to be_within(1.second).of Time.now
          end

          it 'returns status code 200' do
            expect(response).to have_http_status(200)
          end
        end

        context 'when purchase fail', purchase: :fail do
          it 'do not update order as paid' do
            expect(order.reload.paid_at).to be_nil
          end

          it 'returns status code 500' do
            expect(response).to have_http_status(500)
          end
        end
      end

      context 'when the request does not contain valid payment information',
              payment_information: :invalid do
        it 'returns status 422' do
          expect(response).to have_http_status(422)
        end
      end
    end

    context 'when the requested order exist and has already been paid' do
      it 'returns status 409' do
        # TODO
        # expect(response).to have_http_status(409)
        # expect(response).to have_http_status(200)
      end

      # it 'do not process payment' do
      #   # TODO
      #   # expect(gateway_mock).to have_not_received(:purchase)
      # end
    end

    context 'when the requested order does not exist', requested_order: :unknown do
      it 'returns status 404' do
        expect(response).to have_http_status(404)
      end
    end
  end
end
