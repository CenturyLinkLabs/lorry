FROM centurylink/ruby-base:2.1.2
MAINTAINER CenturyLink Labs

ADD . /temp
WORKDIR /temp
RUN bundle install --without development
EXPOSE 9292
CMD bundle exec rackup -o 0.0.0.0
