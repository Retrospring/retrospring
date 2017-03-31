namespace :deploy do
  task :i18n_js do
    on roles(:all) do
      within release_path do
        with rails_env: fetch(:rails_env), rails_groups: fetch(:rails_assets_groups) do
          execute :rake, "i18n:js:export"
        end
      end
    end
  end
end
