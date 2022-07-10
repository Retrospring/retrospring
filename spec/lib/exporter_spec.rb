# frozen_string_literal: true

require "rails_helper"
require "exporter"

RSpec.describe Exporter do
  let(:user_params) do
    {
      answered_count:                    144,
      asked_count:                       72,
      comment_smiled_count:              15,
      commented_count:                   12,
      confirmation_sent_at:              2.weeks.ago.utc,
      confirmed_at:                      2.weeks.ago.utc + 1.hour,
      created_at:                        2.weeks.ago.utc,
      current_sign_in_at:                8.hours.ago.utc,
      current_sign_in_ip:                "198.51.100.220",
      last_sign_in_at:                   1.hour.ago,
      last_sign_in_ip:                   "192.0.2.14",
      locale:                            "en",
      privacy_allow_anonymous_questions: true,
      privacy_allow_public_timeline:     false,
      privacy_allow_stranger_answers:    false,
      privacy_show_in_search:            true,
      screen_name:                       "fizzyraccoon",
      show_foreign_themes:               true,
      sign_in_count:                     10,
      smiled_count:                      28,
      profile:                           {
        display_name:      "Fizzy Raccoon",
        description:       "A small raccoon",
        location:          "Binland",
        motivation_header: "",
        website:           "https://retrospring.net"
      }
    }
  end
  let(:user) { FactoryBot.create(:user, **user_params) }
  let(:instance) { described_class.new(user) }

  before do
    stub_const("APP_CONFIG", {
                 "hostname"       => "example.com",
                 "https"          => true,
                 "items_per_page" => 5,
                 "fog"            => {}
               })
  end

  after do
    filename = instance.instance_variable_get(:@export_dirname)
    FileUtils.rm_r(filename) if File.exist?(filename)
  end

  describe "#collect_user_info" do
    subject { instance.send(:collect_user_info) }

    it "collects user info" do
      subject
      expect(instance.instance_variable_get(:@obj)).to eq(user_params.merge({
                                                                              administrator:             false,
                                                                              moderator:                 false,
                                                                              id:                        user.id,
                                                                              updated_at:                user.updated_at,
                                                                              profile_header:            user.profile_header,
                                                                              profile_header_file_name:  nil,
                                                                              profile_header_h:          nil,
                                                                              profile_header_w:          nil,
                                                                              profile_header_x:          nil,
                                                                              profile_header_y:          nil,
                                                                              profile_picture_file_name: nil,
                                                                              profile_picture_h:         nil,
                                                                              profile_picture_w:         nil,
                                                                              profile_picture_x:         nil,
                                                                              profile_picture_y:         nil
                                                                            }))
    end
  end

  describe "#collect_questions" do
    subject { instance.send(:collect_questions) }

    context "exporting a user with several questions" do
      let!(:questions) { FactoryBot.create_list(:question, 25, user: user) }

      it "collects questions" do
        subject
        expect(instance.instance_variable_get(:@obj)[:questions]).to eq(questions.map do |q|
                                                                          {
                                                                            answer_count:        0,
                                                                            answers:             [],
                                                                            author_is_anonymous: q.author_is_anonymous,
                                                                            content:             q.content,
                                                                            created_at:          q.reload.created_at,
                                                                            id:                  q.id
                                                                          }
                                                                        end)
      end
    end

    context "exporting a user with a question which has been answered" do
      let!(:question) { FactoryBot.create(:question, user: user, author_is_anonymous: false) }
      let!(:answers) { FactoryBot.create_list(:answer, 5, question: question, user: FactoryBot.create(:user)) }

      it "collects questions and answers" do
        subject
        expect(instance.instance_variable_get(:@obj)[:questions]).to eq([
                                                                          {
                                                                            answer_count:        5,
                                                                            answers:             answers.map do |a|
                                                                              {
                                                                                comment_count: 0,
                                                                                comments:      [],
                                                                                content:       a.content,
                                                                                created_at:    a.reload.created_at,
                                                                                id:            a.id,
                                                                                smile_count:   a.smile_count,
                                                                                user:          instance.send(:user_stub, a.user)
                                                                              }
                                                                            end,
                                                                            author_is_anonymous: false,
                                                                            content:             question.content,
                                                                            created_at:          question.reload.created_at,
                                                                            id:                  question.id
                                                                          }
                                                                        ])
      end
    end
  end

  describe "#collect_answers" do
    let!(:answers) { FactoryBot.create_list(:answer, 25, user: user) }

    subject { instance.send(:collect_answers) }

    it "collects answers" do
      subject
      expect(instance.instance_variable_get(:@obj)[:answers]).to eq(answers.map do |a|
                                                                      {
                                                                        comment_count: 0,
                                                                        comments:      [],
                                                                        content:       a.content,
                                                                        created_at:    a.reload.created_at,
                                                                        id:            a.id,
                                                                        question:      instance.send(:process_question,
                                                                                                     a.question.reload,
                                                                                                     include_user:    true,
                                                                                                     include_answers: false),
                                                                        smile_count:   0
                                                                      }
                                                                    end)
    end
  end

  describe "#collect_comments" do
    let!(:comments) do
      FactoryBot.create_list(:comment,
                             25,
                             user:   user,
                             answer: FactoryBot.create(:answer, user: FactoryBot.create(:user)))
    end

    subject { instance.send(:collect_comments) }

    it "collects comments" do
      subject
      expect(instance.instance_variable_get(:@obj)[:comments]).to eq(comments.map do |c|
                                                                       {
                                                                         content:    c.content,
                                                                         created_at: c.reload.created_at,
                                                                         id:         c.id,
                                                                         answer:     instance.send(:process_answer,
                                                                                                   c.answer,
                                                                                                   include_comments: false)
                                                                       }
                                                                     end)
    end
  end

  describe "#collect_smiles" do
    let!(:smiles) { FactoryBot.create_list(:smile, 25, user: user) }

    subject { instance.send(:collect_smiles) }

    it "collects reactions" do
      subject
      expect(instance.instance_variable_get(:@obj)[:smiles]).to eq(smiles.map do |s|
                                                                     {
                                                                       id:         s.id,
                                                                       created_at: s.reload.created_at,
                                                                       answer:     {
                                                                         comment_count: s.parent.comment_count,
                                                                         content:       s.parent.content,
                                                                         created_at:    s.parent.reload.created_at,
                                                                         id:            s.parent.id,
                                                                         question:      {
                                                                           answer_count:        s.parent.question.answer_count,
                                                                           author_is_anonymous: s.parent.question.author_is_anonymous,
                                                                           content:             s.parent.question.content,
                                                                           created_at:          s.parent.question.reload.created_at,
                                                                           id:                  s.parent.question.id,
                                                                           user:                nil # we're not populating this in the factory
                                                                         },
                                                                         smile_count:   s.parent.smile_count
                                                                       }
                                                                     }
                                                                   end)
    end
  end

  describe "#finalize" do
    let(:fake_rails_root) { Pathname(Dir.mktmpdir) }
    let(:dir) { instance.instance_variable_get(:@export_dirname) }
    let(:name) { instance.instance_variable_get(:@export_filename) }

    before do
      instance.instance_variable_set(:@obj, {
                                       some: {
                                         sample: {
                                           data: "Text"
                                         }
                                       }
                                     })

      Dir.mkdir("#{fake_rails_root}/public")
      FileUtils.cp_r(Rails.root.join("public/images"), "#{fake_rails_root}/public/images")
      allow(Rails).to receive(:root).and_return(fake_rails_root)
    end

    after do
      FileUtils.rm_r(fake_rails_root)
    end

    subject { instance.send(:finalize) }

    context "exporting a user without a profile picture or header" do
      it "prepares files to be archived" do
        subject
        expect(File.directory?(fake_rails_root.join("public/export"))).to eq(true)
        expect(File.directory?("#{dir}/pictures")).to eq(true)
      end

      it "outputs JSON" do
        subject
        path = "#{dir}/#{name}.json"
        expect(File.exist?(path)).to eq(true)
        expect(JSON.load_file(path, symbolize_names: true)).to eq(instance.instance_variable_get(:@obj))
      end

      it "outputs YAML" do
        subject
        path = "#{dir}/#{name}.yml"
        expect(File.exist?(path)).to eq(true)
        expect(YAML.load_file(path)).to eq(instance.instance_variable_get(:@obj))
      end

      it "outputs XML" do
        subject
        path = "#{dir}/#{name}.xml"
        expect(File.exist?(path)).to eq(true)
      end
    end

    context "exporting a user with a profile header" do
      before do
        user.profile_header = Rack::Test::UploadedFile.new(File.open("#{file_fixture_path}/banana_racc.jpg"))
        user.save!
      end

      it "exports the header image" do
        subject
        dirname = instance.instance_variable_get(:@export_dirname)
        %i[web mobile retina original].each do |size|
          expect(File.exist?("#{dirname}/pictures/header_#{size}_banana_racc.jpg")).to eq(true)
        end
      end
    end

    context "exporting a user with a profile picture" do
      before do
        user.profile_picture = Rack::Test::UploadedFile.new(File.open("#{file_fixture_path}/banana_racc.jpg"))
        user.save!
      end

      it "exports the header image" do
        subject
        dirname = instance.instance_variable_get(:@export_dirname)
        %i[large medium small original].each do |size|
          expect(File.exist?("#{dirname}/pictures/picture_#{size}_banana_racc.jpg")).to eq(true)
        end
      end
    end
  end

  describe "#publish" do
    let(:fake_rails_root) { Pathname(Dir.mktmpdir) }
    let(:name) { instance.instance_variable_get(:@export_filename) }

    before do
      FileUtils.mkdir_p("#{fake_rails_root}/public/export")
      allow(Rails).to receive(:root).and_return(fake_rails_root)

      user.export_processing = true
      user.save!
    end

    after do
      FileUtils.rm_r(fake_rails_root)
    end

    subject { instance.send(:publish) }

    it "publishes an archive" do
      Timecop.freeze do
        expect { subject }.to change { user.export_processing }.from(true).to(false)
        expect(File.exist?("#{fake_rails_root}/public/export/#{name}.tar.gz")).to eq(true)
        expect(user.export_url).to eq("https://example.com/export/#{name}.tar.gz")
        expect(user.export_created_at).to eq(Time.now.utc)
        expect(user).to be_persisted
      end
    end
  end
end
