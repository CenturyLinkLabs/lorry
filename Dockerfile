FROM alpine:3.1
MAINTAINER CenturyLink Labs <ctl-labs-futuretech@centurylink.com>
EXPOSE 9292

RUN apk update && apk add ruby-dev=2.1.5-r1 ca-certificates
RUN echo 'install: --no-document' >> /root/.gemrc
RUN gem install bundler

ADD . /temp
WORKDIR /temp
RUN bundle install --without development test

CMD ["bundle","exec","rackup","-o","0.0.0.0"]
