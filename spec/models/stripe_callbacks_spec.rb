require 'spec_helper'

describe StripeCallbacks do

	describe "process_recurring_payment" do
		it "splits up the payment amongst endowments" do
			pending "payments not currently split, we use a separate stripe subscription per endowment"
			invoice = double(Stripe::Invoice)
			donor = create(:donor)
			pa = create(:payment_account, donor: donor)

			Share.create!(donation_price: 100, stripe_balance: 50, etrade_balance: 50)

			mock_unique_subscription_id = 'mock_stripe_sub_id'
			DonorSubscription.create!(unique_subscription_id: mock_unique_subscription_id,
				gross_amount: 5, donor_id: donor.id, endowment_id: create(:endowment).id, payment_account_id: pa.id)
			DonorSubscription.create!(unique_subscription_id: mock_unique_subscription_id,
				gross_amount: 10, donor_id: donor.id, endowment_id: create(:endowment).id, payment_account_id: pa.id)
			DonorSubscription.create!(unique_subscription_id: mock_unique_subscription_id,
				gross_amount: 15, donor_id: donor.id, endowment_id: create(:endowment).id, payment_account_id: pa.id)

			data_mock = double(Object)
			data_mock.should_receive(:amount).and_return 30
			data_mock.should_receive(:id).and_return mock_unique_subscription_id
			lines_mock = double(Object)
			lines_mock.should_receive(:data).and_return [data_mock]
			invoice.should_receive(:lines).and_return lines_mock

			subject.process_recurring_payment(invoice)
			Donation.count.should == 3
			Donation.sum(:gross_amount).should == 30
			Donation.sum(:net_amount).should == 30-(30*0.029 + 0.3)
		end
	end
end
