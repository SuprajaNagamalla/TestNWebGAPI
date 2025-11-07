#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./run_api_tests.sh [options]

Options:
  -g, --groups <groups>      TestNG groups to execute (default: regression)
  -s, --suite <path>         Path to the TestNG XML suite (default: src/test/resources/testSuites/csm.xml)
  -p, --publish <true|false> Whether to publish Teams notifications (default: false)
      --dry-run              Print the Maven command without executing it
  -h, --help                 Show this help message and exit

Environment variables API_GROUPS, API_SUITE and API_PUBLISH can also be used to
override the defaults.

Environment variable MASTER_KEY is required for encrypted configuration access.
USAGE
}

TEST_GROUPS=${API_GROUPS:-regression}
SUITE_FILE=${API_SUITE:-src/test/resources/testSuites/csm.xml}
PUBLISH_TEAMS=${API_PUBLISH:-true}
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -g|--groups)
      [[ $# -lt 2 ]] && { echo "Error: $1 requires an argument" >&2; usage; exit 1; }
      TEST_GROUPS=$2
      shift 2
      ;;
    --groups=*)
      TEST_GROUPS=${1#*=}
      shift
      ;;
    -s|--suite)
      [[ $# -lt 2 ]] && { echo "Error: $1 requires an argument" >&2; usage; exit 1; }
      SUITE_FILE=$2
      shift 2
      ;;
    --suite=*)
      SUITE_FILE=${1#*=}
      shift
      ;;
    -p|--publish)
      [[ $# -lt 2 ]] && { echo "Error: $1 requires an argument" >&2; usage; exit 1; }
      PUBLISH_TEAMS=$2
      shift 2
      ;;
    --publish=*)
      PUBLISH_TEAMS=${1#*=}
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

SUITE_POSIX=${SUITE_FILE//\\//}

# Check if MASTER_KEY is set (required for encrypted configuration)
if [[ -z "${MASTER_KEY:-}" ]]; then
  echo "Warning: MASTER_KEY environment variable is not set."
  echo "This may cause failures if encrypted configuration is required."
fi

MVN_ARGS=(
  -pl rac_pad_api
  -am
  "-Dgroups=${TEST_GROUPS}"
  "-DsuiteXmlFile=${SUITE_POSIX}"
  "-DtestngXml=${SUITE_POSIX}"
  "-DpublishTeamsNotification=${PUBLISH_TEAMS}"
)

printf 'Running Maven with:\n'
printf '  groups=%s\n' "$TEST_GROUPS"
printf '  suite=%s\n' "$SUITE_FILE"
printf '  publishTeamsNotification=%s\n\n' "$PUBLISH_TEAMS"

printf 'Full Maven Command:\n'
printf 'mvn'
for arg in "${MVN_ARGS[@]}"; do
  printf ' %q' "$arg"
done
printf ' clean install test\n\n'

if [[ "$DRY_RUN" == true ]]; then
  echo "Dry run requested, not executing Maven."
  exit 0
fi

mvn "${MVN_ARGS[@]}" clean install test

