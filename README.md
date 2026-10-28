# kilncms.dev overlay

[kilncms.dev](https://kilncms.dev), Kiln's own site, is a stock
[kiln_cms](https://github.com/The-Verscienta/kiln_cms) with a small overlay.
This repo holds only that overlay, so core stays site-agnostic.

| File | What it does |
|---|---|
| `config/project_deps.exs` | Dependency plugins, appended to core's deps (kiln_cms#1967). Today that's [kiln_cloudinary](https://github.com/The-Verscienta/kiln_cloudinary), pinned by commit. |
| `config/project.exs` | Registers the plugins and selects the Cloudinary image backend. It's installed as core's `config/project.exs`. |
| `.github/workflows/image.yml` | Builds the image and pushes it to `ghcr.io/the-verscienta/kilncms-dev`. It can also trigger the Coolify redeploy. |

## How the image is built

The workflow checks out kiln_cms (`main` by default; `workflow_dispatch` takes
any ref), copies the overlay into it, and runs **kiln_cms's own Dockerfile**
with `--build-arg PROJECT=kilncms_dev`:

- `config/project_deps.exs` goes to the core's `config/`, where the
  Dockerfile's optional COPY picks it up before `mix deps.get`. No
  `project.lock` is committed: the build seeds it from the core's `mix.lock`,
  so core dependencies stay at the versions that commit was tested with.
- `config/project.exs` goes to `projects/kilncms_dev/project.exs`. The
  `PROJECT` build arg installs it as `config/project.exs` before `mix compile`.

There's no Dockerfile copy here, so nothing drifts from core. After the push,
the workflow checks that the release contains `kiln_cloudinary` and that
`KilnCloudinary.Plugin` is in its config.

It runs on every push to this repo's `main` and on demand. **A core change
reaches kilncms.dev only when this workflow runs**: dispatch it after merging
to kiln_cms `main` (Actions → Image → Run workflow).

## Settings

| Where | Name | |
|---|---|---|
| Repo variable | `KILN_ML` | `1` builds the ML stack in; empty (the default) is the lean build |
| Repo secret | `COOLIFY_WEBHOOK_URL`, `COOLIFY_TOKEN` | optional; without them, redeploy in Coolify by hand |
| Coolify env | `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, `CLOUDINARY_API_SECRET` | until all three are set, the backend reports itself unconfigured and Kiln stores images itself |

The other `CLOUDINARY_*` settings (signed URLs, upload size cap, AVIF) are in
the [plugin README](https://github.com/The-Verscienta/kiln_cloudinary#configure).
On the Free plan, also keep Kiln's pixel cap at 25 MP. If not, a larger image
fails to upload instead of staying local. That's a `config :kiln_cms, :media,
max_pixels: 25_000_000` line in `config/project.exs`.

## Checking it on the site

Signed in as a platform admin:

- **System → Plugins** lists `KilnCloudinary.Plugin`.
- **System → Image backend** shows Cloudinary. It reads "not configured" until
  the three variables are set, then shows the plan, usage and upload limits.
- Upload an image. Its variants are `res.cloudinary.com` URLs.

Only new uploads go to Cloudinary. Existing local media stays where it is.
