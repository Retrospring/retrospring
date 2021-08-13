# frozen_string_literal: true

FactoryBot.define do
  factory :theme do
    primary_color { 9_342_168 }
    primary_text { 16_777_215 }
    danger_color { 14_257_035 }
    danger_text { 16_777_215 }
    success_color { 12_573_067 }
    success_text { 16_777_215 }
    warning_color { 14_261_899 }
    warning_text { 16_777_215 }
    info_color { 9_165_273 }
    info_text { 16_777_215 }
    dark_color { 6_710_886 }
    dark_text { 15_658_734 }
    raised_background { 16_777_215 }
    background_color { 13_026_795 }
    body_text { 3_355_443 }
    muted_text { 3_355_443 }
    input_color { 15_789_556 }
    input_text { 6_710_886 }
    raised_accent { 16_250_871 }
    light_color { 16_316_922 }
    light_text { 0 }
  end
end
