FROM ruby:2.5.1

ENV ENTRYKIT_VERSION 0.4.0

# 作業ディレクトリの作成、設定
RUN mkdir /app_name 

ENV APP_ROOT /app_name 
WORKDIR $APP_ROOT

RUN apt-get update                                                                                                                      \
  && apt-get install                                                                                                                    \
    openssl                                                                                                                             \
  && wget https://github.com/progrium/entrykit/releases/download/v${ENTRYKIT_VERSION}/entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz     \
  && tar -xvzf entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz                                                                            \
  && rm entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz                                                                                   \
  && mv entrykit /bin/entrykit                                                                                                          \
  && chmod +x /bin/entrykit                                                                                                             \
  && entrykit --symlink \
  && apt-get update -qq  \
  && apt-get install -y build-essential \ 
                       libpq-dev \  
  && curl -sL https://deb.nodesource.com/setup_10.x | bash - \
  && apt-get install -y nodejs

ADD ./Gemfile $APP_ROOT/Gemfile
ADD ./Gemfile.lock $APP_ROOT/Gemfile.lock

# Gemfileのbundle install
RUN bundle install
ADD . $APP_ROOT

ENTRYPOINT [ \
  "prehook", "bundle install", "--", \  
  "prehook", "bin/rspec", "--", \
  "prehook", "ruby -v", "--" \
  ]