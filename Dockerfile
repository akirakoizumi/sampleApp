# コピペでOK, app_nameもそのままでOK
# 19.01.20現在最新安定版のイメージを取得
FROM ruby:2.5.1

ENV ENTRYKIT_VERSION 0.4.0

# 作業ディレクトリの作成、設定
RUN mkdir /app_name 
##作業ディレクトリ名をAPP_ROOTに割り当てて、以下$APP_ROOTで参照
ENV APP_ROOT /app_name 
WORKDIR $APP_ROOT

# 必要なパッケージのインストール（基本的に必要になってくるものだと思うので削らないこと）
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



# ホスト側（ローカル）のGemfileを追加する（ローカルのGemfileは【３】で作成）
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

#"prehook", "bundle exec rspec -b spec", "--" \

#ENTRYPOINT [ \
  # "prehook", "bundle install -j3 --path vendor/bundle", "--", \
  # "prehook", "bundle exec rails init_db:setup", "--", \
  # "switch", "reset=bundle exec rails init_db:reset", "--", \
  # "prehook", "bundle exec rspec -b spec", "--", \
  # "prehook", "ruby -v", "--", \
  # "prehook", "node -v", "--" \
#]

#docker-compose run web rails db:create
#docker-compose run web rails db:migrate