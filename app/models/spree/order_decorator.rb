Spree::Order.class_eval do

	def last_payment_method
		return nil if payments.blank?
		return nil if payments.last.blank?
		return nil if payments.last.payment_method.blank?
		return payments.last.payment_method
	end	

end

