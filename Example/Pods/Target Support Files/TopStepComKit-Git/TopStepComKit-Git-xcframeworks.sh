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
  "TopStepComKit.xcframework/ios-arm64")
    echo ""
    ;;
  "TopStepComKit.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "ABParTool.xcframework/ios-arm64")
    echo ""
    ;;
  "ABParTool.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "maccatalyst"
    ;;
  "ABParTool.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "FitCloudDFUKit.xcframework/ios-arm64")
    echo ""
    ;;
  "FitCloudDFUKit.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "FitCloudKit.xcframework/ios-arm64")
    echo ""
    ;;
  "FitCloudKit.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "FitCloudNWFKit.xcframework/ios-arm64")
    echo ""
    ;;
  "FitCloudNWFKit.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "FitCloudWFKit.xcframework/ios-arm64")
    echo ""
    ;;
  "FitCloudWFKit.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "RTKLEFoundation.xcframework/ios-arm64")
    echo ""
    ;;
  "RTKLEFoundation.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "RTKLocalPlaybackSDK.xcframework/ios-arm64")
    echo ""
    ;;
  "RTKLocalPlaybackSDK.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "RTKOTASDK.xcframework/ios-arm64")
    echo ""
    ;;
  "RTKOTASDK.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "TopStepFitKit.xcframework/ios-arm64")
    echo ""
    ;;
  "TopStepFitKit.xcframework/ios-x86_64-simulator")
    echo "simulator"
    ;;
  "TopStepInterfaceKit.xcframework/ios-arm64")
    echo ""
    ;;
  "TopStepInterfaceKit.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "TopStepToolKit.xcframework/ios-arm64")
    echo ""
    ;;
  "TopStepToolKit.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "TopStepBleMetaKit.xcframework/ios-arm64")
    echo ""
    ;;
  "TopStepBleMetaKit.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "TopStepNewPlatformKit.xcframework/ios-arm64")
    echo ""
    ;;
  "TopStepNewPlatformKit.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  esac
}

archs_for_slice()
{
  case "$1" in
  "TopStepComKit.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "TopStepComKit.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "ABParTool.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "ABParTool.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "arm64 x86_64"
    ;;
  "ABParTool.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "FitCloudDFUKit.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "FitCloudDFUKit.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "FitCloudKit.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "FitCloudKit.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "FitCloudNWFKit.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "FitCloudNWFKit.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "FitCloudWFKit.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "FitCloudWFKit.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "RTKLEFoundation.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "RTKLEFoundation.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "RTKLocalPlaybackSDK.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "RTKLocalPlaybackSDK.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "RTKOTASDK.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "RTKOTASDK.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "TopStepFitKit.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "TopStepFitKit.xcframework/ios-x86_64-simulator")
    echo "x86_64"
    ;;
  "TopStepInterfaceKit.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "TopStepInterfaceKit.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "TopStepToolKit.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "TopStepToolKit.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "TopStepBleMetaKit.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "TopStepBleMetaKit.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "TopStepNewPlatformKit.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "TopStepNewPlatformKit.xcframework/ios-arm64_x86_64-simulator")
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

install_xcframework "${PODS_ROOT}/../../TopStepComKit-Git/Classes/ComKit/TopStepComKit.xcframework" "TopStepComKit-Git/ComKit" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/../../TopStepComKit-Git/Classes/FitCoreImp/ABParTool.xcframework" "TopStepComKit-Git/FitCoreImp" "framework" "ios-arm64" "ios-arm64_x86_64-maccatalyst" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/../../TopStepComKit-Git/Classes/FitCoreImp/FitCloudDFUKit.xcframework" "TopStepComKit-Git/FitCoreImp" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/../../TopStepComKit-Git/Classes/FitCoreImp/FitCloudKit.xcframework" "TopStepComKit-Git/FitCoreImp" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/../../TopStepComKit-Git/Classes/FitCoreImp/FitCloudNWFKit.xcframework" "TopStepComKit-Git/FitCoreImp" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/../../TopStepComKit-Git/Classes/FitCoreImp/FitCloudWFKit.xcframework" "TopStepComKit-Git/FitCoreImp" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/../../TopStepComKit-Git/Classes/FitCoreImp/RTKLEFoundation.xcframework" "TopStepComKit-Git/FitCoreImp" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/../../TopStepComKit-Git/Classes/FitCoreImp/RTKLocalPlaybackSDK.xcframework" "TopStepComKit-Git/FitCoreImp" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/../../TopStepComKit-Git/Classes/FitCoreImp/RTKOTASDK.xcframework" "TopStepComKit-Git/FitCoreImp" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/../../TopStepComKit-Git/Classes/FitCoreImp/TopStepFitKit.xcframework" "TopStepComKit-Git/FitCoreImp" "framework" "ios-arm64" "ios-x86_64-simulator"
install_xcframework "${PODS_ROOT}/../../TopStepComKit-Git/Classes/Foundation/TopStepInterfaceKit.xcframework" "TopStepComKit-Git/Foundation" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/../../TopStepComKit-Git/Classes/Foundation/TopStepToolKit.xcframework" "TopStepComKit-Git/Foundation" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/../../TopStepComKit-Git/Classes/NpkCoreImp/TopStepBleMetaKit.xcframework" "TopStepComKit-Git/NpkCoreImp" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/../../TopStepComKit-Git/Classes/NpkCoreImp/TopStepNewPlatformKit.xcframework" "TopStepComKit-Git/NpkCoreImp" "framework" "ios-arm64" "ios-arm64_x86_64-simulator"

