# frozen_string_literal: true

class ReadOnlyValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless Retrospring::Config.readonly?
    return if value == record.public_send(:"#{attribute}_was")

    record.errors.add(attribute, message: I18n.t("errors.read_only_mode"))
  end
end
