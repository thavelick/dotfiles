# Attribution

## `pocock-*` skills

Every skill directory in here named `pocock-*` is a port of a skill by **Matt Pocock**.

Source: https://github.com/mattpocock/skills

The port is mechanical: each skill keeps its upstream content, with the skill `name`
in the frontmatter and every cross-skill `/reference` prefixed with `pocock-` so the
skills don't collide with the ones I wrote myself. Upstream `agents/openai.yaml`
files aren't carried over.

Upstream path for a given skill is `skills/<category>/<name>`, where `<name>` is the
local directory name minus the `pocock-` prefix — e.g. `pocock-tdd` comes from
`skills/engineering/tdd`. The one exception is `pocock-setup-skills`, which is
upstream's `skills/engineering/setup-matt-pocock-skills`.

Skills in this directory *without* the `pocock-` prefix are not Matt's.

## Local deviations

Two edits go beyond the mechanical rename, and a resync has to reapply them:

- `pocock-implement` drops upstream's `disable-model-invocation: true`, so an agent
  can reach for the skill on its own.
- `pocock-wizard/template.sh` carries a `shellcheck disable=SC2034` for its color
  palette, which exists for the stages an author writes below the marker.
