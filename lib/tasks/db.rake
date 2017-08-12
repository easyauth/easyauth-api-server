namespace :db do
  desc 'Removes defunct records from the database'
  task cleanup: :environment do
    expired_users = User.where(validated: false,
                               created_at: (Time.at(0))..24.hours.ago)
    ActiveRecord::Base.transaction do
      expired_users.each(&:destroy)
    end
    expired_certificates = Certificate.where(active: true,
    										 valid_until: (Time.at(0)..1.seconds.ago))
    ActiveRecord::Base.transaction do
    	expired_certificates.each do |cert|
    		cert.active = false
    		cert.save
    	end
    end
  end
end
