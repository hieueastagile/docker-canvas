FROM ruby:2.4.1

USER root

ENV CANVAS_HOME /canvas
ENV CANVAS_USER canvas
ENV CANVAS_SHARED /canvas/shared
ENV BUNDLE_PATH /gems
ENV GEM_HOME /gems
ENV PATH /gems/bin:$PATH
ENV LC_ALL C.UTF-8

RUN apt-get update && \
    apt-get install -y apt-transport-https software-properties-common zlib1g-dev libxml2-dev \
                       libsqlite3-dev postgresql libpq-dev libxmlsec1-dev curl \
                       make g++ python python-pygments python-software-properties nginx supervisor && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn=0.27.5-1 nodejs && \
    touch ~/.gemrc && \
    echo "gem: --no-ri --no-rdoc" >> ~/.gemrc && \
    gem install rubygems-update && \
    update_rubygems && \
    gem install bundler --version 1.13.6

COPY supervisord.conf /etc/supervisord.conf
COPY site.conf /etc/nginx/sites-available/default

RUN chown -R www-data:www-data /var/lib/nginx
RUN mkdir -p $BUNDLE_PATH $CANVAS_HOME $CANVAS_SHARED
RUN useradd -m $CANVAS_USER && usermod -aG $CANVAS_USER www-data && chown -R $CANVAS_USER:$CANVAS_USER $CANVAS_HOME && chown -R $CANVAS_USER:$CANVAS_USER $BUNDLE_PATH
USER $CANVAS_USER

WORKDIR $CANVAS_HOME

COPY --chown=canvas ./canvas-lms/Gemfile      ${CANVAS_HOME}
COPY --chown=canvas ./canvas-lms/Gemfile.d    ${CANVAS_HOME}/Gemfile.d
COPY --chown=canvas ./canvas-lms/config       ${CANVAS_HOME}/config
COPY --chown=canvas ./canvas-lms/gems         ${CANVAS_HOME}/gems
COPY --chown=canvas ./canvas-lms/script       ${CANVAS_HOME}/script
COPY --chown=canvas ./canvas-lms/package.json ${CANVAS_HOME}
COPY --chown=canvas ./canvas-lms/yarn.lock    ${CANVAS_HOME}
RUN bundle install && yarn install

COPY --chown=canvas ./canvas-lms $CANVAS_HOME

ENV RAILS_ENV 'production'
USER root
