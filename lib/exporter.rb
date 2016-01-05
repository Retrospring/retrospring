require 'json'
require 'yaml'
require 'httparty'
require 'securerandom'

class Exporter
  def initialize(user)
    @user = user
    @obj = {}
    @export_dirname = "export_#{@user.screen_name}_#{Time.now.to_i}_#{SecureRandom.base64.gsub(/[+=\/]/, '')}"
    @export_filename = @user.screen_name
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
  rescue => _
    @user.export_processing = false
    @user.save validate: false
  end

  private

  def collect_user_info
    %i(admin answered_count asked_count ban_reason banned_until bio blogger comment_smiled_count commented_count
       confirmation_sent_at confirmed_at contributor created_at crop_h crop_h_h crop_h_w crop_h_x crop_h_y
       crop_w crop_x crop_y current_sign_in_at current_sign_in_ip display_name email follower_count friend_count
       id last_sign_in_at last_sign_in_ip locale location moderator motivation_header permanently_banned
       privacy_allow_anonymous_questions privacy_allow_public_timeline privacy_allow_stranger_answers
       privacy_show_in_search profile_header_content_type profile_header_file_name profile_header_file_size
       profile_header_updated_at profile_picture_content_type profile_picture_file_name profile_picture_file_size
       profile_picture_updated_at screen_name show_foreign_themes sign_in_count smiled_count supporter translator
       updated_at website).each do |f|
      @obj[f] = @user.send f
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
    `mkdir -p /tmp/rs_export/#{@export_dirname}/pictures`

    if @user.profile_picture_file_name
      %i(large medium small original).each do |s|
        url = @user.profile_picture.url(s)
        target_file = "/tmp/rs_export/#{@export_dirname}/pictures/picture_#{s}_#{@user.profile_picture_file_name}"
        File.open target_file, 'wb' do |f|
          f.binmode
          f.write HTTParty.get(url).parsed_response
        end
      end
    end

    if @user.profile_header_file_name
      %i(web mobile retina original).each do |s|
        url = @user.profile_header.url(s)
        target_file = "/tmp/rs_export/#{@export_dirname}/pictures/header_#{s}_#{@user.profile_header_file_name}"
        File.open target_file, 'wb' do |f|
          f.binmode
          f.write HTTParty.get(url).parsed_response
        end
      end
    end

    File.open "/tmp/rs_export/#{@export_dirname}/#{@export_filename}.json", 'w' do |f|
      f.puts @obj.to_json
    end

    File.open "/tmp/rs_export/#{@export_dirname}/#{@export_filename}.yml", 'w' do |f|
      f.puts @obj.to_yaml
    end

    File.open "/tmp/rs_export/#{@export_dirname}/#{@export_filename}.xml", 'w' do |f|
      f.puts @obj.to_xml
    end
  end

  def publish
    `tar czvf #{Rails.root.join "public", "export", "#{@export_dirname}.tar.gz"} -C /tmp/rs_export #{@export_dirname}`
    url = "https://retrospring.net/export/#{@export_dirname}.tar.gz"
    @user.export_processing = false
    @user.export_url = url
    @user.export_created_at = Time.now
    @user.save validate: false
    url
  end

  def process_question(question, options = {})
    opts = {
        include_user: true,
        include_answers: true
    }.merge(options)

    qobj = {}
    %i(answer_count author_is_anonymous content created_at id).each do |f|
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
    %i(comment_count content created_at id smile_count).each do |f|
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
    %i(content created_at id).each do |f|
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

    %i(id created_at).each do |f|
      sobj[f] = smile.send f
    end

    sobj[:answer] = process_answer(smile.answer, include_comments: false)

    sobj
  end

  def user_stub(user)
    uobj = {}
    %i(admin answered_count asked_count bio blogger comment_smiled_count commented_count contributor created_at
       display_name follower_count friend_count id location moderator motivation_header permanently_banned screen_name
       smiled_count supporter translator website).each do |f|
      uobj[f] = user.send f
    end
    uobj
  end
end
