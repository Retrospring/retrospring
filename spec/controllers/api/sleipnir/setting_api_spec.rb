RSpec.describe "API::Sleipnir::SettingAPI" do
  before :all do
    @me               = FactoryGirl.create :user
    @other            = FactoryGirl.create :user

    @me.admin = true
    @me.save!

    @app, @oa, @token = gen_oa_b @me
  end

  after :all do
    Warden.test_reset!
  end

  # can't test, unsure about this so it's blocked.
  # it "PATCH /api/sleipnir/setting/avatar should return less than 400" do
  #   upload = Faraday::UploadIO.new "#{File.expand_path(File.dirname(__FILE__))}/assets/avatar.png", "image/png"
  #
  #   res = oa_patch @token, "/api/sleipnir/setting/avatar.json", {crop_x: 0, crop_y: 0, crop_w: 280, crop_h: 280}, {avatar: upload}
  #
  #   expect(res.status).to be < 400
  # end
  #
  # it "PATCH /api/sleipnir/setting/header should return less than 400" do
  #   upload = Faraday::UploadIO.new "#{File.expand_path(File.dirname(__FILE__))}/assets/header.jpg", "image/jpeg"
  #
  #   res = oa_patch @token, "/api/sleipnir/setting/header.json", {crop_x: 0, crop_y: 0, crop_w: 1500, crop_h: 500}, {header: upload}
  #
  #   expect(res.status).to be < 400
  # end

  it "PATCH /api/sleipnir/setting/basic should return less than 400" do
    res = oa_patch @token, "/api/sleipnir/setting/basic.json", {display_name: "TEST", motivation_header: "TEST", website: "http://retrospring.test/", location: "Testartica", bio: "I AM A TEST LOL", screen_name: "NOPE"}

    expect(res.status).to be < 400

    expect(@me.screen_name).not_to eq "NOPE"
  end
end
