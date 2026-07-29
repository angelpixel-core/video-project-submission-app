namespace :db do
  namespace :data do
    desc "Run data bootstrap migrations from db/data"
    task migrate: :environment do
      Rake::Task["data:migrate"].invoke
    end
  end
end
