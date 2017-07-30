namespace :db do
  desc 'Removes defunct records from the database'
  task cleanup: :environment do
    expired_users = User.where(validated: false,
                               created_at: (Time.at(0))..4.hours.ago)
    ActiveRecord::Base.transaction do
      expired_users.each(&:destroy)
    end
  end
end
