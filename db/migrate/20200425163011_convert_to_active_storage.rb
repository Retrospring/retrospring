class ConvertToActiveStorage < ActiveRecord::Migration[5.2]
  require 'open-uri'

  def up
    get_blob_id = 'LASTVAL()'

    ActiveRecord::Base.connection.raw_connection.prepare('active_storage_blob_statement', <<-SQL)
      INSERT INTO active_storage_blobs (
        key, filename, content_type, metadata, byte_size, checksum, created_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7)
    SQL

    ActiveRecord::Base.connection.raw_connection.prepare('active_storage_attachment_statement', <<-SQL)
      INSERT INTO active_storage_attachments (
        name, record_type, record_id, blob_id, created_at
      ) VALUES ($1, $2, $3, #{get_blob_id}, $4)
    SQL

    Rails.application.eager_load!
    models = ActiveRecord::Base.descendants.reject(&:abstract_class?)

    transaction do
      models.each do |model|
        attachments = model.column_names.map do |c|
          if c =~ /(.+)_file_name$/
            $1
          end
        end.compact

        if attachments.blank?
          next
        end

        model.find_each.each do |instance|
          attachments.each do |attachment|
            if instance.send(attachment).path.blank?
              next
            end

            ActiveRecord::Base.connection.raw_connection.exec_prepared(
              'active_storage_blob_statement', [
              key(instance, attachment),
              instance.send("#{attachment}_file_name"),
              instance.send("#{attachment}_content_type"),
              get_meta(instance, attachment),
              instance.send("#{attachment}_file_size"),
              checksum(instance.send(attachment)),
              instance.updated_at.iso8601
            ])

            ActiveRecord::Base.connection.raw_connection.exec_prepared(
              'active_storage_attachment_statement', [
              attachment,
              model.name,
              instance.id,
              instance.updated_at.iso8601,
            ])
          end
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def key(instance, attachment)
    SecureRandom.uuid
  end

  def checksum(attachment)
    if ENV.fetch('RAILS_ENV', 'development') == 'production'
      url = attachment.url
      Digest::MD5.base64digest(Net::HTTP.get(URI(url)))
    else
      url = attachment.path
      Digest::MD5.base64digest(File.read(Rails.public_path.join('system', url)))
    end
  end

  def get_meta(model, attachment)
    if attachment == 'profile_picture'
      return JSON.generate({
                      cropping: {
                        x: model.crop_x,
                        y: model.crop_y,
                        w: model.crop_w,
                        h: model.crop_h,
                      }
                    })
    elsif attachment == 'profile_header'
      return JSON.generate({
                      cropping: {
                        x: model.crop_h_x,
                        y: model.crop_h_y,
                        w: model.crop_h_w,
                        h: model.crop_h_h,
                      }
                    })
    end
    '{}'
  end
end