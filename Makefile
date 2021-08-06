.PHONY: deploy-heroku
deploy-heroku:
	git subtree push --prefix rails_app heroku master