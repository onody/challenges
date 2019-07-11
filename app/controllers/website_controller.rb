class WebsiteController < ApplicationController
  def index
    @token = nil
  end

  def donate
    unless params[:omise_token].present?
      create_response(nil, :failure, :index) && return
    end

    unless charity = Charity.find_by(id: params[:charity])
      create_response(retrieve_token(params[:omise_token]), :failure, :index) && return
    end

    if params[:amount].blank? || params[:amount].to_i <= 20
      create_response(retrieve_token(params[:omise_token]), :failure, :index) && return
    end

    charge = create_charge(charity, params[:amount], params[:omise_token])
    if charge.paid
      charity.credit_amount(charge.amount) 
      create_response(retrieve_token(params[:omise_token]), :success, :root)
    else
      create_response(nil, :failure, :index)
    end
  end

  private

  def retrieve_token(token)
    if Rails.env.test?
      OpenStruct.new({
        id: "tokn_X",
        card: OpenStruct.new({
          name: "J DOE",
          last_digits: "4242",
          expiration_month: 10,
          expiration_year: 2020,
          security_code_check: false,
        }),
      })
    else
      Omise::Token.retrieve(token)
    end
  end

  def create_response(token, status, redirect)
    @token = token 

    case status
    when :success then
      flash.notice = t(".success")
    when :failure then
      flash.now.alert = t(".failure")
    end

    case redirect
    when :index then
      render :index
    when :root then
      redirect_to root_path
    end
  end

  def create_charge(charity, amount, omise_token)
    if Rails.env.test?
      OpenStruct.new({
        amount: amount.to_i * 100,
        paid: (amount.to_i != 999),
      })
    else
      Omise::Charge.create({
        amount: amount.to_i * 100,
        currency: "JPY",
        card: omise_token,
        description: "Donation to #{charity.name} [#{charity.id}]",
      })
    end
  end
end
