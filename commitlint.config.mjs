export default {
  extends: ["@commitlint/config-conventional"],
  parserPreset: {
    parserOpts: {
      headerPattern: /^(:\w+:|[\p{Emoji}])\s(\w+)/u,
      headerCorrespondence: ["type", "subject"],
    },
  },
  rules: {
    "subject-case": [2, "always", "sentence-case"],
    "type-enum": [
      2,
      "always",
      [
        ":adhesive_bandage:",
        ":age_facing_up:",
        ":alembic:",
        ":alien:",
        ":ambulance:",
        ":arrow_down:",
        ":arrow_up:",
        ":art:",
        ":bank:",
        ":bento:",
        ":bookmark:",
        ":books:",
        ":boom:",
        ":bug:",
        ":bulb:",
        ":busts_in_silhouette:",
        ":busts_in_silhouette:",
        ":camera-flash:",
        ":card_file_box:",
        ":chart_with_upwards_trend:",
        ":checkered_flag:",
        ":children_crossing:",
        ":clown_face:",
        ":construction:",
        ":construction_worker:",
        ":egg:",
        ":fast_forward:",
        ":fire:",
        ":gem:",
        ":globe_with_meridians:",
        ":green_ale:",
        ":green_heart:",
        ":hankey:",
        ":heavy_minus_sign:",
        ":heavy_plus_sign:",
        ":iphone:",
        ":label:",
        ":leaves:",
        ":lipstick:",
        ":lock:",
        ":loud-sound:",
        ":loud_sound:",
        ":mag:",
        ":memo:",
        ":microscope:",
        ":mute:",
        ":mute:",
        ":newspaper:",
        ":ok_hand:",
        ":package:",
        ":page_facing_up:",
        ":pencil2:",
        ":pencil:",
        ":penguin:",
        ":pushpin:",
        ":recycle:",
        ":rewind:",
        ":ribbon:",
        ":robot:",
        ":rocket:",
        ":rotating_light:",
        ":see_no_evil:",
        ":sparkles:",
        ":speech_balloon:",
        ":tada:",
        ":tractor:",
        ":triangular_flag_on_post:",
        ":truck:",
        ":twisted_rightwards_arrows:",
        ":whale:",
        ":wheel-of-dharma:",
        ":wheelchair:",
        ":white_check_mark:",
        ":wrench:",
        ":zap:",
      ],
    ],
    "header-max-length": [2, "always", 75],
  },
};
