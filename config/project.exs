import Config

# kilncms.dev's overlay config. The image workflow copies this file to
# projects/kilncms_dev/project.exs inside a kiln_cms checkout and builds with
# `--build-arg PROJECT=kilncms_dev`, so the core Dockerfile installs it as
# config/project.exs before `mix compile`. `config/config.exs` imports it last.

# Cloudinary image backend (The-Verscienta/kiln_cloudinary, kiln_cms#1959).
# Until CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY and CLOUDINARY_API_SECRET are
# set in the environment, the backend reports itself unconfigured and Kiln
# keeps storing images itself, so this is safe to deploy before the account
# exists.
config :kiln_cms, :plugins, [KilnCloudinary.Plugin]
config :kiln_cms, :image_backend, KilnCloudinary.Backend
