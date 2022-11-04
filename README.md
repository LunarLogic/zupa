# README

### About

This is a a project for Zupa na Plantach organization.
You can find more info about ZnP here: [Zupa na Plantach](https://zupanaplantach.pl/)

### License

This project is licensed under the GNU Affero General Public License v3.0 (AGPL-3.0) - see the [LICENSE](LICENSE) file for details.

### Versions & dependencies

- ruby 3.1.2
- nodejs 18.20.8
- yarn 1.22.22
- rails 7.0.4
- postgres 13.8

**Version Management:** This project uses [asdf](https://asdf-vm.com/) for managing runtime versions. All required versions are specified in `.tool-versions`.

### System dependencies

- We're running latest and greatest rails 7 on ruby 3.1.2.
- For frontend js we're using React and Typescript.
- For testing we're using RSpec & FactoryBot.
- For unit testing in frontend we're using [Jest](https://jestjs.io/) and [RTL](https://testing-library.com/).
- For configuration we're using dotenv.
- We're using feature flipping with the flipper gem.

### Configuration

1. Clone the repo
2. Install runtime versions with asdf:
   - Install asdf plugins (if not already installed):
     ```bash
     asdf plugin add ruby
     asdf plugin add nodejs
     asdf plugin add yarn
     ```
   - Install all required versions: `asdf install`
3. `bundle install`
    - if you encounter an error while installing gen nio4r (on MacOS Sonoma or higher), run `bundle config build.nio4r --with-cflags="-Wno-incompatible-pointer-types"` and then retry
4. `cp .env.development.sample .env.development`
5. `cp .env.test.sample .env.test`
6. `bin/rails db:create`
7. `bin/rails db:migrate`
8. `bin/rails db:seed`
9. `yarn install` (or `yarn install --production=false` if you want dev dependecies installed too)
10. Run server: `bin/dev` || Alternative for Windows OS: run `foreman start -f Procfile-mingw.dev`
If you encounter problems with env vars try: `set -a && source .env.development && set +a && bin/dev`

🛖 Home: [http://localhost:4000](http://localhost:4000)

👩🏻‍💼 Admin: [http://localhost:4000/admin](http://localhost:4000/admin)

### Development

- System design according to the Atomic Design methodology [https://atomicdesign.bradfrost.com/chapter-2/](https://atomicdesign.bradfrost.com/chapter-2/)
- BEM methodology in class names [https://getbem.com/](https://getbem.com/)
- Prettier of JS code ([https://prettier.io/]())
- Standardrb for Ruby code ([https://github.com/testdouble/standard]())
- We are using React Google Maps library to display map snapshots. Documentation: [https://react-google-maps-api-docs.netlify.app/]()

#### Google Integrations

For Google Drive and Google Maps setup, see [docs/google-integration.md](docs/google-integration.md)

### How to run the test suite

- `bin/rspec` to run entire suite
- `yarn test` to run all unit frontend tests

**Note:** Make sure your `.env.test` includes the Google Drive dummy values from `.env.test.sample`. See [docs/google-integration.md](docs/google-integration.md) for details on generating test keys.

#### E2E tests - TO BE UPDATED

We have a basic setup for E2E tests, to run them - clone the [zupa tests repository](https://github.com/LunarLogic/zupa-tests) and follow the instructions in the readme.

### Frontend functional test requirements

Here you will find a list of functionalities that should be tested - [Functional requirements](https://docs.google.com/spreadsheets/d/16m1VCjcVug0GNjXV-dQM1ahSrdHaZ_Np4QA0EW9MQb4/edit#gid=0)

### Api documentation

- We're using Swagger and rswag gem to generate api docs
- Api documentation is available at: /api-docs/index.html on every server, including localhost.
- use `RAILS_ENV=test SWAGGER_DRY_RUN=0 rails rswag` to regenarate docs

### Feature Flipper

- Flipper config panel is available at /admin/flipper
- To set a flip in your conde use eg. `if Flipper.enabled?(:packages); YOUR CODE; end`
- Note: for flipping in Trestle Admin you mind need to restart the server after enabling/disabling a feature in UI.
- [Flipper docs](https://github.com/flippercloud/flipper)


---- IRRELEVANT ---- TO BE CLEANED UP

### Deployment instructions

To deploy a specific branch, run appropriate workflow from GitHub Actions: https://github.com/LunarLogic/zupa/actions/workflows/aws-staging.yml

#### Production

[zupa.lunarlogic.com](https://zupa.lunarlogic.com)

GitHub Actions deploy automatically from `production`.

Rebase (not merge) `main` to `production`:
```Shell
git checkout main
git pull
git checkout production
git rebase main
git push origin production
```

-------

### Links and Resources - TO BE UPDATED

[🗒 Project Board](https://trello.com/b/czRAmEef/zupa-na-plantach)

[💬 Slack - official](https://lunarlogic.slack.com/archives/C044D5JKFDJ)

[💬 Slack - internal](https://lunarlogic.slack.com/archives/C0474UB5SF8)

[🎨 Designs &amp; Wireframes](https://www.figma.com/file/HfvUpLdKSwQekI5LGcT8ka/Wireframes)

[⚙️ PRODUCTION](https://zupa.lunarlogic.io/)

[🔧STAGING](https://zupa.staging.lunarlogic.io/)

[🗂API DOCS](https://zupa.lunarlogic.io/api-docs)


#### Staging

[zupa.staging.lunarlogic.com](https://zupa.staging.lunarlogic.com)

GitHub Actions deploy automatically from `main`.

#### AWS
Infrastructure for the app is defined as code in https://github.com/LunarLogic/aws-infrastructure.

App's components are deployed to different AWS services:

- Docker image: ECR
- container and logs: ECS
- env vars and secrets: Secrets Manager
- database: RDS

You need an account on Lunar's AWS Console (web UI) to access them.

#### Servers and Databases

To access a server or database, you need to login to the AWS ECS container with `aws` command line client. Refer to the [instructions in aws-infastructure repository](https://github.com/LunarLogic/aws-infrastructure/blob/main/applications/README.md#access-and-debugging).

#### Secrets

Do not store any secret keys in the repository!

Secrets are stored in AWS Secrets Manager and task-definition files for each environment defines which one are available in the container.

See [docs/google-integration.md](docs/google-integration.md) for details on managing Google API secrets.
