# ローカルDBのリセット、シード
.PHONY: local-seed
local-seed:
	cd rails_app && rails db:migrate:reset
	cd rails_app && rails db:seed

# gitのherokuリモートへpush
# herokuの本番サーバーに自動デプロイされる
.PHONY: heroku-deploy
heroku-deploy:
	git subtree push --prefix rails_app heroku master

# herokuのmigrateコマンド
# デプロイ終わったあとでないといけないのでコマンド別
.PHONY: heroku-migrate
heroku-migrate:
	heroku run rails db:migrate