class WebhookController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def receive
    # The only status we care about at this time is the failure.
    if params["type"] == "transfer.failed"
      transaction_id = params["data"]["object"]["id"]
      Showing.find_by_transfer_txn(transaction_id).update(payment_status: "paying_sellers_agent_failure")
    end
    render nothing: true
  end

end
