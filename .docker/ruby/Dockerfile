FROM ruby:2.7

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends build-essential \
    libpq-dev postgresql-client \ 
    libxml2-dev libxslt1-dev \
    libmagickwand-dev imagemagick \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /app
WORKDIR /app

ADD Gemfile* /app/
RUN bundle install
COPY . /app

COPY .docker/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]