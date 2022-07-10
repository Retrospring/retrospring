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

  after do
    filename = instance.instance_variable_get(:@export_dirname)
    FileUtils.rm_r(filename) if File.exist?(filename)
  end

  describe "#collect_user_info" do
    subject { instance.send(:collect_user_info) }

    context "exporting a user" do
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
                                                                            created_at:          q.created_at,
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

  describe "#collect_smiles" do
    let!(:smiles) { FactoryBot.create_list(:smile, 25, user: user) }

    subject { instance.send(:collect_smiles) }

    context "exporting a user" do
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
  end

  describe "#finalize" do
    let(:fake_rails_root) { Pathname(Dir.mktmpdir) }

    before do
      instance.instance_variable_set(:@obj, {
                                       some: {
                                         sample: {
                                           data: "Text"
                                         }
                                       }
                                     })
      allow(Rails).to receive(:root).and_return(fake_rails_root)
    end

    subject { instance.send(:finalize) }

    context "exporting a user" do
      let(:dir) { instance.instance_variable_get(:@export_dirname) }
      let(:name) { instance.instance_variable_get(:@export_filename) }

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
  end
end
