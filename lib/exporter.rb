# frozen_string_literal: true

require "json"
require "yaml"
require "httparty"

class Exporter
  EXPORT_ROLES = %i[administrator moderator].freeze

  def initialize(user)
    @user = user
    @obj = {}
    @export_dirname = Dir.mktmpdir("rs-export-")
    @export_filename = File.basename(@export_dirname)
  end

  def export
    @user.export_processing = true
    @user.save validate: false
    collect_user_info
    collect_questions
    collect_answers
    collect_comments
    collect_smiles
    finalize
    publish
  rescue => e
    Sentry.capture_exception(e)
    @user.export_processing = false
    @user.save validate: false
  ensure
    FileUtils.remove_dir(@export_dirname)
  end

  private

  def collect_user_info
    %i[answered_count asked_count comment_smiled_count commented_count
       confirmation_sent_at confirmed_at created_at profile_header profile_header_h profile_header_w profile_header_x profile_header_y
       profile_picture_w profile_picture_h profile_picture_x profile_picture_y current_sign_in_at current_sign_in_ip
       id last_sign_in_at last_sign_in_ip locale
       privacy_allow_anonymous_questions privacy_allow_public_timeline privacy_allow_stranger_answers
       privacy_show_in_search profile_header_file_name profile_picture_file_name
       screen_name show_foreign_themes sign_in_count smiled_count updated_at].each do |f|
      @obj[f] = @user.send f
    end

    @obj[:profile] = {}
    %i[display_name motivation_header website location description].each do |f|
      @obj[:profile][f] = @user.profile.send f
    end

    EXPORT_ROLES.each do |role|
      @obj[role] = @user.has_role?(role)
    end
  end

  def collect_questions
    @obj[:questions] = []
    @user.questions.each do |q|
      @obj[:questions] << process_question(q, include_user: false)
    end
  end

  def collect_answers
    @obj[:answers] = []
    @user.answers.each do |a|
      @obj[:answers] << process_answer(a, include_user: false)
    end
  end

  def collect_comments
    @obj[:comments] = []
    @user.comments.each do |c|
      @obj[:comments] << process_comment(c, include_user: false, include_answer: true)
    end
  end

  def collect_smiles
    @obj[:smiles] = []
    @user.smiles.each do |s|
      @obj[:smiles] << process_smile(s)
    end
  end

  def finalize
    `mkdir -p "#{Rails.root.join "public", "export"}"`
    `mkdir -p #{@export_dirname}/pictures`

    if @user.profile_picture_file_name
      %i[large medium small original].each do |s|
        url = @user.profile_picture.url(s)
        target_file = "#{@export_dirname}/pictures/picture_#{s}_#{@user.profile_picture_file_name}"
        File.open target_file, "wb" do |f|
          f.binmode
          data = if url.start_with?("/")
                   File.read(Rails.root.join("public", url.sub(%r{\A/+}, "")))
                 else
                   HTTParty.get(url).parsed_response
                 end
          f.write data
        end
      end
    end

    if @user.profile_header_file_name
      %i[web mobile retina original].each do |s|
        url = @user.profile_header.url(s)
        target_file = "#{@export_dirname}/pictures/header_#{s}_#{@user.profile_header_file_name}"
        File.open target_file, "wb" do |f|
          f.binmode
          data = if url.start_with?("/")
                   File.read(Rails.root.join("public", url.sub(%r{\A/+}, "")))
                 else
                   HTTParty.get(url).parsed_response
                 end
          f.write data
        end
      end
    end

    File.open "#{@export_dirname}/#{@export_filename}.json", "w" do |f|
      f.puts @obj.to_json
    end

    File.open "#{@export_dirname}/#{@export_filename}.yml", "w" do |f|
      f.puts @obj.to_yaml
    end

    File.open "#{@export_dirname}/#{@export_filename}.xml", "w" do |f|
      f.puts @obj.to_xml
    end
  end

  def publish
    `tar czvf #{Rails.root.join "public", "export", "#{@export_filename}.tar.gz"} -C /tmp/rs_export #{@export_dirname}`
    url = "#{APP_CONFIG['https'] ? 'https' : 'http'}://#{APP_CONFIG['hostname']}/export/#{@export_filename}.tar.gz"
    @user.export_processing = false
    @user.export_url = url
    @user.export_created_at = Time.now.utc
    @user.save validate: false
    url
  end

  def process_question(question, options = {})
    opts = {
        include_user: true,
        include_answers: true
    }.merge(options)

    qobj = {}
    %i[answer_count author_is_anonymous content created_at id].each do |f|
      qobj[f] = question.send f
    end

    if opts[:include_answers]
      qobj[:answers] = []
      question.answers.each do |a|
        qobj[:answers] << process_answer(a, include_question: false)
      end
    end

    if opts[:include_user]
      qobj[:user] = question.author_is_anonymous ? nil : user_stub(question.user)
    end

    qobj
  end

  def process_answer(answer, options = {})
    opts = {
      include_question: true,
      include_user: true,
      include_comments: true
    }.merge(options)

    aobj = {}
    %i[comment_count content created_at id smile_count].each do |f|
      aobj[f] = answer.send f
    end

    if opts[:include_user]
      aobj[:user] = user_stub(answer.user)
    end

    if opts[:include_question]
      aobj[:question] = process_question(answer.question, include_user: true, include_answers: false)
    end

    if opts[:include_comments]
      aobj[:comments] = []
      answer.comments.each do |c|
        aobj[:comments] << process_comment(c, include_user: true, include_answer: false)
      end
    end

    aobj
  end

  def process_comment(comment, options = {})
    opts = {
        include_user: true,
        include_answer: false
    }.merge(options)

    cobj = {}
    %i[content created_at id].each do |f|
      cobj[f] = comment.send f
    end

    if opts[:include_user]
      cobj[:user] = user_stub(comment.user)
    end

    if opts[:include_answer]
      cobj[:answer] = process_answer(comment.answer, include_comments: false)
    end

    cobj
  end

  def process_smile(smile)
    sobj = {}

    %i[id created_at].each do |f|
      sobj[f] = smile.send f
    end

    type = smile.parent.class.name.downcase
    sobj[type.to_sym] = send(:"process_#{type}", smile.parent, include_comments: false, include_user: false)

    sobj
  end

  def user_stub(user)
    uobj = {}
    %i[answered_count asked_count comment_smiled_count commented_count created_at
       id permanently_banned? screen_name smiled_count].each do |f|
      uobj[f] = user.send f
    end

    uobj[:profile] = {}
    %i[display_name motivation_header website location description].each do |f|
      uobj[:profile][f] = user.profile.send f
    end

    EXPORT_ROLES.each do |role|
      uobj[role] = user.has_role?(role)
    end

    uobj
  end
end
