FROM ruby:3.2

USER root

ARG UID=1000
ARG GID=1000
ARG NODE_MAJOR=16

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update -qq \
    && apt-get install -y ca-certificates curl gnupg \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends build-essential \
    libpq-dev postgresql-client \
    libxml2-dev libxslt1-dev \
    libmagickwand-dev imagemagick \
    libidn11-dev \
    nodejs \
    yarn \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /app \
    && mkdir /cache
WORKDIR /app

RUN addgroup --gid ${GID} app \
	&& adduser --gecos "" --disabled-password --shell /bin/bash --uid ${UID} --gid ${GID} app \
	&& chown "${UID}:${GID}" -R /app/ \
    && chown "${UID}:${GID}" -R /cache/

COPY .docker/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

USER app:app

ADD Gemfile* /app/
RUN bundle install --jobs=$(nproc)
RUN gem install ruby-debug-ide

ADD package.json /app/
ADD yarn.lock /app/
RUN yarn install

COPY . /app

ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
