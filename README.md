# docker-canvas
Simple docker configuration for running Canvas-LMS

## Installation 
- Clone code to /canvas-lms
- Copy configuration file and fill with yours:
  - security.yml
  - database.yml
  - domain.yml
- Run the following commands:
  - docker-compose run -e RAILS_ENV=production web bundle exec rake db:initial_setup
  - docker-compose run -e RAILS_ENV=production web bundle exec rake brand_configs:generate_and_upload_all
  
## TODO
- [ ] Add nginx
- [ ] postgresql pg_collkey
- [ ] Add redis
- [ ] Container for background jobs
