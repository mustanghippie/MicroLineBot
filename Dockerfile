FROM ruby:2.5.5
RUN apt-get update -qq && apt-get install -y \
    build-essential libpq-dev postgresql-client \
    nodejs \
 && rm -rf /var/lib/apt/lists/*

ENV APP_ROOT /app

RUN mkdir $APP_ROOT

WORKDIR $APP_ROOT

ADD Gemfile $APP_ROOT/Gemfile
ADD Gemfile.lock $APP_ROOT/Gemfile.lock
RUN \
bundle install
ADD . $APP_ROOT