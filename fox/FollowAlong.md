1) mix new cart --sup
2) go to fox/mix.exs and replace some of the contents
3) add 'config :fox, ecto_repos: [Fox.Repo]' to config/config.exs'
4) run mix deps.get and mix ecto.gen repo to generate the repo
5) repo config is added to config.exs. modify it to have the proper postgres username and password
6) add new repo to the supervision tree in lib/fox/application.ex by placing supervisor(Fox.Repo, []) in children = []
7) add 'config :fox, ecto_repos: [Fox.Repo]' to config.exs'
8) after finsishing up configuration for the database, run: mix ecto.create
9) run mix ecto.gen.migration create_actions
10) priv/repo/migrations will be the directory where the migration.exs is found
11) modify def change do function to create table to add whatever fields are needed
12) mix ecto.migrate to create the table with all the defined fields
13) create changeset for actions in lib/fox/action.ex
14) notes are commented in the action.ex file for changesets