
namespace :app do

  # Checks and ensures task is not run in production.
  task :ensure_development_environment => :environment do
    if Rails.env.production?
      raise "\nI'm sorry, I can't do that.\n(You're asking me to drop your production database.)"
    end
  end

  # Populates development data
  desc "Populate the database with development data."
  task :populate => :environment do
  	puts "#{'*'*(`tput cols`.to_i)}\nChecking Environment... The database will be cleared of all content before populating.\n#{'*'*(`tput cols`.to_i)}"
    # Removes content before populating with data to avoid duplication
    Rake::Task['db:reset'].invoke

    # INSERT BELOW

  #  [
  #    {:first_name => "Darth",     :last_name => "Vader"},
  #    {:first_name => "Commander", :last_name => "Praji"},
  #    {:first_name => "Biggs",     :last_name => "Darklighter"},
  #    {:first_name => "Luke",      :last_name => "Skywalker"},
  #    {:first_name => "Han",       :last_name => "Solo"},
  #  ].each do |attributes|
  #    Person.find_or_create_by_first_name_and_last_name(attributes)
  #  end

    # INSERT ABOVE

    puts "#{'*'*(`tput cols`.to_i)}\nThe database has been populated!\n#{'*'*(`tput cols`.to_i)}"
  end

end
