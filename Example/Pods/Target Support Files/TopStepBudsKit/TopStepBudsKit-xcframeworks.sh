#!/bin/sh
set -e
set -u
set -o pipefail

function on_error {
  echo "$(realpath -mq "${0}"):$1: error: Unexpected failure"
}
trap 'on_error $LINENO' ERR


# This protects against multiple targets copying the same framework dependency at the same time. The solution
# was originally proposed here: https://lists.samba.org/archive/rsync/2008-February/020158.html
RSYNC_PROTECT_TMP_FILES=(--filter "P .*.??????")


variant_for_slice()
{
  case "$1" in
  "ABMate.xcframework/ios-arm64")
    echo ""
    ;;
  "ABMate.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "AIBudsAI.xcframework/ios-arm64")
    echo ""
    ;;
  "AIBudsAI.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "AIBudsAIFoundation.xcframework/ios-arm64")
    echo ""
    ;;
  "AIBudsAIFoundation.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "AIBudsMagicHelper.xcframework/ios-arm64")
    echo ""
    ;;
  "AIBudsMagicHelper.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "AIBudsStarBurst.xcframework/ios-arm64")
    echo ""
    ;;
  "AIBudsStarBurst.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "AIBudsAudio.xcframework/ios-arm64")
    echo ""
    ;;
  "AIBudsAudio.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "AIBuds.xcframework/ios-arm64")
    echo ""
    ;;
  "AIBuds.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "AIBudsFoundation.xcframework/ios-arm64")
    echo ""
    ;;
  "AIBudsFoundation.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "AIBudsLog.xcframework/ios-arm64")
    echo ""
    ;;
  "AIBudsLog.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "AIBudsXLFacility.xcframework/ios-arm64")
    echo ""
    ;;
  "AIBudsXLFacility.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "LAME.xcframework/ios-arm64")
    echo ""
    ;;
  "LAME.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "maccatalyst"
    ;;
  "LAME.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "MicrosoftCognitiveServicesSpeech.xcframework/ios-arm64")
    echo ""
    ;;
  "MicrosoftCognitiveServicesSpeech.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "MicrosoftCognitiveServicesSpeech.xcframework/macos-arm64_x86_64")
    echo ""
    ;;
  "AIBudsVoiceAssistant.xcframework/ios-arm64")
    echo ""
    ;;
  "AIBudsVoiceAssistant.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  esac
}

archs_for_slice()
{
  case "$1" in
  "ABMate.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "ABMate.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "AIBudsAI.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "AIBudsAI.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "AIBudsAIFoundation.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "AIBudsAIFoundation.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "AIBudsMagicHelper.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "AIBudsMagicHelper.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "AIBudsStarBurst.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "AIBudsStarBurst.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "AIBudsAudio.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "AIBudsAudio.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "AIBuds.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "AIBuds.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "AIBudsFoundation.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "AIBudsFoundation.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "AIBudsLog.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "AIBudsLog.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "AIBudsXLFacility.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "AIBudsXLFacility.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "LAME.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "LAME.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "arm64 x86_64"
    ;;
  "LAME.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "MicrosoftCognitiveServicesSpeech.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "MicrosoftCognitiveServicesSpeech.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "MicrosoftCognitiveServicesSpeech.xcframework/macos-arm64_x86_64")
    echo "arm64 x86_64"
    ;;
  "AIBudsVoiceAssistant.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "AIBudsVoiceAssistant.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  esac
}

copy_dir()
{
  local source="$1"
  local destination="$2"

  # Use filter instead of exclude so missing patterns don't throw errors.
  echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --links --filter \"- CVS/\" --filter \"- .svn/\" --filter \"- .git/\" --filter \"- .hg/\" \"${source}*\" \"${destination}\""
  rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --links --filter "- CVS/" --filter "- .svn/" --filter "- .git/" --filter "- .hg/" "${source}"/* "${destination}"
}

SELECT_SLICE_RETVAL=""

select_slice() {
  local xcframework_name="$1"
  xcframework_name="${xcframework_name##*/}"
  local paths=("${@:2}")
  # Locate the correct slice of the .xcframework for the current architectures
  local target_path=""

  # Split archs on space so we can find a slice that has all the needed archs
  local target_archs=$(echo $ARCHS | tr " " "\n")

  local target_variant=""
  if [[ "$PLATFORM_NAME" == *"simulator" ]]; then
    target_variant="simulator"
  fi
  if [[ ! -z ${EFFECTIVE_PLATFORM_NAME+x} && "$EFFECTIVE_PLATFORM_NAME" == *"maccatalyst" ]]; then
    target_variant="maccatalyst"
  fi
  for i in ${!paths[@]}; do
    local matched_all_archs="1"
    local slice_archs="$(archs_for_slice "${xcframework_name}/${paths[$i]}")"
    local slice_variant="$(variant_for_slice "${xcframework_name}/${paths[$i]}")"
    for target_arch in $target_archs; do
      if ! [[ "${slice_variant}" == "$target_variant" ]]; then
        matched_all_archs="0"
        break
      fi

      if ! echo "${slice_archs}" | tr " " "\n" | grep -F -q -x "$target_arch"; then
        matched_all_archs="0"
        break
      fi
    done

    if [[ "$matched_all_archs" == "1" ]]; then
      # Found a matching slice
      echo "Selected xcframework slice ${paths[$i]}"
      SELECT_SLICE_RETVAL=${paths[$i]}
      break
    fi
  done
}

install_xcframework() {
  local basepath="$1"
  local name="$2"
  local package_type="$3"
  local paths=("${@:4}")

  # Locate the correct slice of the .xcframework for the current architectures
  select_slice "${basepath}" "${paths[@]}"
  local target_path="$SELECT_SLICE_RETVAL"
  if [[ -z "$target_path" ]]; then
    echo "warning: [CP] $(basename ${basepath}): Unable to find matching slice in '${paths[@]}' for the current build architectures ($ARCHS) and platform (${EFFECTIVE_PLATFORM_NAME-${PLATFORM_NAME}})."
    return
  fi
  local source="$basepath/$target_path"

  local destination="${PODS_XCFRAMEWORKS_BUILD_DIR}/${name}"

  if [ ! -d "$destination" ]; then
    mkdir -p "$destination"
  fi

  copy_dir "$source/" "$destination"
  echo "Copied $source to $destination"
}

install_xcframework "${PODS_ROOT}/../../../TopStepComKit/TopStepBudsKit/SDK/ABMate.xcframework" "TopStepBudsKit/ABMate" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/../../../TopStepComKit/TopStepBudsKit/SDK/AIBudsAI.xcframework" "TopStepBudsKit/AI/Core" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/../../../TopStepComKit/TopStepBudsKit/SDK/AIBudsAIFoundation.xcframework" "TopStepBudsKit/AI/Foundation" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/../../../TopStepComKit/TopStepBudsKit/SDK/AIBudsMagicHelper.xcframework" "TopStepBudsKit/AI/MltCloud" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/../../../TopStepComKit/TopStepBudsKit/SDK/AIBudsStarBurst.xcframework" "TopStepBudsKit/AI/StarBurst" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/../../../TopStepComKit/TopStepBudsKit/SDK/AIBudsAudio.xcframework" "TopStepBudsKit/Audio" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/../../../TopStepComKit/TopStepBudsKit/SDK/AIBuds.xcframework" "TopStepBudsKit/Core" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/../../../TopStepComKit/TopStepBudsKit/SDK/AIBudsFoundation.xcframework" "TopStepBudsKit/Foundation" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/../../../TopStepComKit/TopStepBudsKit/SDK/AIBudsLog.xcframework" "TopStepBudsKit/Log/Core" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/../../../TopStepComKit/TopStepBudsKit/SDK/AIBudsXLFacility.xcframework" "TopStepBudsKit/Log/XLFacility" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/../../../TopStepComKit/TopStepBudsKit/SDK/LAME.xcframework" "TopStepBudsKit/ThirdParty/Lame" "framework" "ios-arm64" "ios-arm64_x86_64-maccatalyst" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/../../../TopStepComKit/TopStepBudsKit/SDK/MicrosoftCognitiveServicesSpeech.xcframework" "TopStepBudsKit/ThirdParty/MagicHelper" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/../../../TopStepComKit/TopStepBudsKit/SDK/AIBudsVoiceAssistant.xcframework" "TopStepBudsKit/VoiceAssistant" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"

