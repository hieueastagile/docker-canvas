FROM ruby:2.4.1

USER root

ENV CANVAS_HOME /canvas
ENV BUNDLE_PATH /gems
ENV PATH /gems/bin:$PATH
ENV LC_ALL C.UTF-8

RUN apt-get update && \
    apt-get install -y apt-transport-https software-properties-common zlib1g-dev libxml2-dev \
                       libsqlite3-dev postgresql libpq-dev libxmlsec1-dev curl \
                       make g++ python python-pygments python-software-properties && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn=0.27.5-1 nodejs && \
    touch ~/.gemrc && \
    echo "gem: --no-ri --no-rdoc" >> ~/.gemrc && \
    gem install rubygems-update && \
    update_rubygems && \
    gem install bundler --version 1.13.6

RUN mkdir -p $BUNDLE_PATH $CANVAS_HOME
WORKDIR $CANVAS_HOME
COPY ./canvas-lms/Gemfile      ${CANVAS_HOME}
COPY ./canvas-lms/Gemfile.d    ${CANVAS_HOME}/Gemfile.d
COPY ./canvas-lms/config       ${CANVAS_HOME}/config
COPY ./canvas-lms/gems         ${CANVAS_HOME}/gems
COPY ./canvas-lms/script       ${CANVAS_HOME}/script
COPY ./canvas-lms/package.json ${CANVAS_HOME}
COPY ./canvas-lms/yarn.lock    ${CANVAS_HOME}
RUN bundle install && yarn install

COPY ./canvas-lms $CANVAS_HOME
RUN useradd -m canvas && chown -R canvas:canvas $CANVAS_HOME && chown -R canvas:canvas $BUNDLE_PATH
USER canvas

ENV RAILS_ENV 'production'
RUN mkdir -p log tmp/pids public/assets app/stylesheets/brandable_css_brands && \
    touch app/stylesheets/_brandable_variables_defaults_autogenerated.scss && \
    chown -R canvas config/environment.rb log tmp public/assets \
    app/stylesheets/_brandable_variables_defaults_autogenerated.scss \
    app/stylesheets/brandable_css_brands Gemfile.lock config.ru && \
    bundle exec rake canvas:compile_assets && \
    chown canvas config/*.yml && \
    chmod 400 config/*.yml