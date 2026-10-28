# kilncms.dev's dependency plugins (kiln_cms#1967). The image workflow copies
# this file to config/project_deps.exs inside a kiln_cms checkout, where the
# core Dockerfile picks it up before `mix deps.get`.
#
# There is no project.lock here on purpose: the build seeds one from the
# checked-out core's mix.lock, so every core dependency stays at the version
# that kiln_cms commit was tested with, and only the plugin is resolved fresh.
# kiln_cloudinary is pinned by commit until it has a release tag.
[
  {:kiln_cloudinary,
   github: "The-Verscienta/kiln_cloudinary", ref: "0c5a5b24d25a0f4bea172457ddef1ddce2ea7308"}
]
