TSC:= ./node_modules/.bin/tsc

# Clean compiled resources and dependencies
clean:
	rm -rf ./node_modules
	rm -f package-lock.json

# Clean GIT tags.
clean-tags:
	git tag | xargs git tag -d
	git fetch -t

# Compile and build resources
build:
	$(TSC)

# Run the app locally
run: build
	-cp -r ../core/settings*.json ./node_modules/strautomator-core/
	-cp -r ../core/settings.secret.json ./
	-cp -r ../core/lib/. ./node_modules/strautomator-core/lib/
	npm run start:dev

# Update dependencies and set new version
update:
	-rm -rf ./node_modules/strautomator-core
	-ncu -u -x axios,axios-debug-log,chalk,chart.js,floating-vue,nuxt,vue,vue-mention,vuetify-loader,webpack
	-ncu -u --target minor -x vue-mention
	npm version $(shell date '+%y.%-V%u.1%H%M') --force --allow-same-version --no-git-tag-version
	npm install
	-npm audit fix

# Deploy to Google Cloud Run
deploy:
	$(TSC)
	gcloud builds submit --region=europe-west1 --config cloudbuild.yaml .

# Deploy to GIT (by creating a new tag)
deploy-git:
	npm version $(shell date '+%y.%-V%u.1%H%M') --force --allow-same-version
	git push
	git push --tags
