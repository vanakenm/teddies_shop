class PaymentsController < ApplicationController
  before_action :set_order

  def new
  end

  def create
    @amount = @order.amount_cents

    customer = Stripe::Customer.create(
      source: params[:stripeToken],
      email: params[:stripeEmail]
    )
    # You should store this customer id and re-use it.

    charge = Stripe::Charge.create(
      customer: customer.id,
      amount:       @amount,  # in cents
      description:  "Payment for teddy #{@order.teddy_sku} for order #{@order.id}",
      currency:     'eur'
    )

    @order.update(payment: charge.to_json, state: 'paid')

    redirect_to order_path(@order)

    rescue Stripe::CardError => e
      flash[:error] = e.message
      redirect_to new_order_payment_path(@order)
  end

  private

  def set_order
      @order = Order.where(state: 'pending').find(params[:order_id])
  end
end
