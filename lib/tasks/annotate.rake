namespace :annotate do
  desc 'Update the model schema annotations'
  task :models do
    sh 'bundle exec annotate --sort --position before --show-migration --ignore-model-subdirects'
  end
end

task('db:migrate').enhance do
  if Rails.env == 'development'
    task('annotate:models').invoke
  end
end