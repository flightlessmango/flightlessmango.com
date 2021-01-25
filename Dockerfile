FROM ruby:2.6.4-stretch
# https://github.com/flightlessmango/flightlessmango.com

RUN apt update && apt install -y apt-transport-https

RUN curl -sL https://deb.nodesource.com/setup_lts.x | bash -
RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt update && apt-get install -y nodejs yarn

# COPY . /flightlessmango
RUN git clone https://github.com/flightlessmango/flightlessmango.com flightlessmango

WORKDIR /flightlessmango

RUN bundle
RUN yarn

RUN mkdir -p shared/log shared/pids shared/sockets

VOLUME /flightlessmango/storage

CMD ["rails", "s", "-b", "0.0.0.0", "--log-to-stdout"]
